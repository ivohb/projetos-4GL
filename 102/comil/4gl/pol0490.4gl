#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE ANALISES                                    #
# PROGRAMA: pol0490                                                 #
# MODULOS.: pol0490 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: PRODUTOS PARA ANÁLISES                                  #
# AUTOR...: LOGOCENTER ABC - IVO                                    #
# DATA....: 30/10/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_cod_item           LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          pa_curr              SMALLINT,
          sr_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
          p_msg                CHAR(500)


   DEFINE mr_item_comil   RECORD LIKE item_comil.*,
          mr_item_comilm  RECORD LIKE item_comil.*
         
   DEFINE m_ies_cons      SMALLINT,
          m_item          LIKE item_comil.cod_item_comil

   DEFINE ma_tela ARRAY[50] OF RECORD
      cod_item            LIKE item.cod_item,
      den_item            LIKE item.den_item
   END RECORD

END GLOBALS

   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	 LET p_versao = "pol0490-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0490.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
#   CALL log001_acessa_usuario("VDP","LIC_LIB")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0490_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0490_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0490") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0490 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0490","IN") THEN
            CALL pol0490_inclusao() RETURNING p_status
         END IF
         LET p_ies_cons = FALSE
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0490","MO") THEN
               CALL pol0490_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0490","EX") THEN
               CALL pol0490_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0490","CO") THEN
            CALL pol0490_consulta()
            IF m_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0490_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0490_paginacao("ANTERIOR") 
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 007
         MESSAGE ""
         IF NOT pol0490_informar() THEN 
            ERROR "Operação Cancelada !!!"
            CONTINUE MENU
         END IF
         IF log005_seguranca(p_user,"VDP","pol0490","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0490_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0490.tmp'
                     START REPORT pol0490_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0490_relat TO p_nom_arquivo
               END IF
               CALL pol0490_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0490_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0490_sobre()
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
   CLOSE WINDOW w_pol0490

END FUNCTION

#--------------------------#
 FUNCTION pol0490_inclusao()
#--------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE
   CLEAR FORM
   
   IF pol0490_entrada_dados("INCLUSAO") THEN
      IF pol0490_entrada_item("INCLUSAO") THEN 
         CALL log085_transacao("BEGIN")
         LET mr_item_comil.cod_empresa = p_cod_empresa
         WHENEVER ERROR CONTINUE
         INSERT INTO item_comil VALUES (mr_item_comil.cod_empresa,
                                         mr_item_comil.cod_item_comil,
                                         mr_item_comil.den_item_comil, 
                                         mr_item_comil.den_ingles_comil)
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
	    LET p_houve_erro = TRUE
	    CALL log003_err_sql("INCLUSAO","item_comil")       
         END IF

         IF NOT p_houve_erro THEN           
            FOR l_ind = 1 TO 50
               IF ma_tela[l_ind].cod_item IS NOT NULL AND
                  ma_tela[l_ind].cod_item <> ' ' THEN
                  WHENEVER ERROR CONTINUE
                    INSERT INTO item_refer_comil 
                    VALUES (p_cod_empresa,
                            mr_item_comil.cod_item_comil,
                            ma_tela[l_ind].cod_item)
                  WHENEVER ERROR STOP 
                  IF SQLCA.SQLCODE <> 0 THEN 
	             LET p_houve_erro = TRUE
	             CALL log003_err_sql("INCLUSAO","ITEM_REFER_comil")       
                     EXIT FOR
                  END IF
               END IF
            END FOR
         END IF

         IF p_houve_erro THEN 
            CALL log085_transacao("ROLLBACK")
            MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
            MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            RETURN TRUE 
         END IF
      ELSE
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0490_entrada_dados(l_funcao)
#---------------------------------------#

   DEFINE l_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0490
   DISPLAY p_cod_empresa TO cod_empresa
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_item_comil.* TO NULL
   END IF

   INPUT BY NAME mr_item_comil.cod_item_comil,
                 mr_item_comil.den_item_comil, 
                 mr_item_comil.den_ingles_comil
                 WITHOUT DEFAULTS  

      BEFORE FIELD cod_item_comil 
         IF l_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_item_comil
         END IF

      AFTER FIELD cod_item_comil  
         IF mr_item_comil.cod_item_comil IS NOT NULL AND 
            mr_item_comil.cod_item_comil <> ' ' THEN
            IF pol0490_verifica_duplicidade() THEN
               ERROR "Item já Cadastrado."
               NEXT FIELD cod_item_comil 
            END IF
         ELSE
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD cod_item_comil  
            END IF
         END IF

      AFTER FIELD den_item_comil    
         IF mr_item_comil.den_item_comil IS NULL OR 
            mr_item_comil.den_item_comil = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD den_item_comil
            END IF
         END IF

      AFTER FIELD den_ingles_comil    
         IF mr_item_comil.den_ingles_comil IS NULL OR 
            mr_item_comil.den_ingles_comil = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD den_ingles_comil
            END IF
         END IF

      ON KEY (Control-z)
         CALL pol0490_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0490
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol0490_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = pa_curr THEN
          CONTINUE FOR
       END IF
       IF ma_tela[p_ind].cod_item = ma_tela[pa_curr].cod_item THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION


#--------------------------------------#
 FUNCTION pol0490_entrada_item(p_funcao)
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0490

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
            IF pol0490_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item 
            ELSE
               IF pol0490_verifica_duplic_refer() THEN
                  ERROR 'Item já cadastrado para o Item comil ',m_item 
                  NEXT FIELD cod_item 
               END IF                            
            END IF                            
            IF pol0490_repetiu_cod() THEN
               ERROR 'Item já associado !!!'
               NEXT FIELD cod_item 
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0490_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0490

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
 FUNCTION pol0490_verifica_item()
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
 FUNCTION pol0490_verifica_duplic_refer()
#---------------------------------------#
   DEFINE l_item_existe         SMALLINT

   LET l_item_existe = FALSE

   DECLARE cq_refer CURSOR FOR
    SELECT cod_item_comil
      FROM item_refer_comil
     WHERE cod_empresa = p_cod_empresa 
       AND cod_item    = ma_tela[pa_curr].cod_item

   FOREACH cq_refer INTO m_item
      IF m_item <> mr_item_comil.cod_item_comil THEN
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
 FUNCTION pol0490_verifica_duplicidade()
#--------------------------------------#
   DEFINE l_den_item_comil         LIKE item_comil.den_item_comil

   SELECT den_item_comil
     INTO l_den_item_comil
     FROM item_comil
    WHERE cod_empresa     = p_cod_empresa  
      AND cod_item_comil = mr_item_comil.cod_item_comil
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item_comil TO den_item_comil
      RETURN TRUE
   ELSE
      DISPLAY l_den_item_comil TO den_item_comil
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0490_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET mr_item_comilm.* = mr_item_comil.*
   
   CONSTRUCT BY NAME where_clause ON item_comil.cod_item_comil,
                                     item_comil.den_item_comil

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0490

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_item_comil.* = mr_item_comilm.*
      CALL pol0490_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_comil ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item_comil "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_item_comil.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET m_ies_cons = FALSE
   ELSE 
      LET m_ies_cons = TRUE
      CALL pol0490_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0490_carrega_array()
#-------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0490
   INITIALIZE ma_tela TO NULL
   CLEAR FORM

   LET l_ind = 1
   
   DECLARE c_item CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM item_refer_comil
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item_comil = mr_item_comil.cod_item_comil
     ORDER BY cod_item 

   FOREACH c_item INTO ma_tela[l_ind].cod_item           

      SELECT den_item
        INTO ma_tela[l_ind].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela[l_ind].cod_item

      LET l_ind = l_ind + 1

   END FOREACH 

   DISPLAY BY NAME mr_item_comil.*
   CALL pol0490_verifica_duplicidade() RETURNING p_status

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
 FUNCTION pol0490_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_item_comil.*
   CALL pol0490_carrega_array()

END FUNCTION

#-----------------------------------#
 FUNCTION pol0490_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao             CHAR(20)

   IF m_ies_cons THEN
      LET mr_item_comilm.* = mr_item_comil.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_item_comil.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_item_comil.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_item_comil.* = mr_item_comilm.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_item_comil.* 
           FROM item_comil   
          WHERE cod_empresa     = mr_item_comil.cod_empresa
            AND cod_item_comil = mr_item_comil.cod_item_comil
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0490_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0490_cursor_for_update()
#-----------------------------------#
   WHENEVER ERROR CONTINUE
    DECLARE cm_padrao CURSOR FOR
     SELECT *                            
       INTO mr_item_comil.*                                              
       FROM item_comil 
      WHERE cod_empresa     = mr_item_comil.cod_empresa
        AND cod_item_comil = mr_item_comil.cod_item_comil
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
      OTHERWISE CALL log003_err_sql("LEITURA","ITEM_comil")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0490_modificacao()
#-----------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE

   IF pol0490_cursor_for_update() THEN
      LET mr_item_comilm.* = mr_item_comil.*
      IF pol0490_entrada_dados("MODIFICACAO") THEN
         IF pol0490_entrada_item("MODIFICACAO") THEN 
            WHENEVER ERROR CONTINUE
            UPDATE item_comil
               SET den_item_comil   = mr_item_comil.den_item_comil,
                   den_ingles_comil = mr_item_comil.den_ingles_comil
            WHERE CURRENT OF cm_padrao
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","ITEM_comil")
               LET p_houve_erro = TRUE
               CALL log085_transacao("ROLLBACK")
               RETURN
            END IF

            WHENEVER ERROR CONTINUE
            DELETE FROM item_refer_comil
             WHERE cod_empresa     = p_cod_empresa
               AND cod_item_comil = mr_item_comil.cod_item_comil
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EXCLUSAO","ITEM_REFER_comil")
               LET p_houve_erro = TRUE
               CALL log085_transacao("ROLLBACK")
               RETURN
            END IF

            FOR l_ind = 1 TO 50
               IF ma_tela[l_ind].cod_item IS NOT NULL AND
                  ma_tela[l_ind].cod_item <> ' ' THEN
                  WHENEVER ERROR CONTINUE
                    INSERT INTO item_refer_comil 
                    VALUES (p_cod_empresa,
                            mr_item_comil.cod_item_comil,
                            ma_tela[l_ind].cod_item)
                  WHENEVER ERROR STOP
                  IF SQLCA.SQLCODE <> 0 THEN
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("INCLUSAO","ITEM_REFER_comil")
                     EXIT FOR
                  END IF
               END IF
            END FOR
 
            IF p_houve_erro = FALSE THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Houve problemas na Modificação." ATTRIBUTE(REVERSE)
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            LET mr_item_comil.* = mr_item_comilm.*
            ERROR "Modificação Cancelada."
            CALL log085_transacao("ROLLBACK")
            CALL pol0490_exibe_dados()
         END IF
      ELSE
         LET mr_item_comil.* = mr_item_comilm.*
         ERROR "Modificação Cancelada."
         CALL log085_transacao("ROLLBACK")
         CALL pol0490_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0490_exclusao()
#--------------------------#
   IF pol0490_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_comil 
         WHERE CURRENT OF cm_padrao
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE = 0 THEN
            DELETE FROM item_refer_comil 
            WHERE cod_empresa = p_cod_empresa
              AND cod_item_comil = mr_item_comil.cod_item_comil
            IF SQLCA.SQLCODE = 0 THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_item_comil.* TO NULL
               CLEAR FORM
            ELSE
               CALL log003_err_sql("EXCLUSAO","ITEM_REFER_comil")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ITEM_comil")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION pol0490_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_item)
         LET ma_tela[pa_curr].cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0490
         IF ma_tela[pa_curr].cod_item IS NOT NULL THEN
            DISPLAY ma_tela[pa_curr].cod_item TO s_itens[sc_curr].cod_item
         END IF
   END CASE

END FUNCTION

#-------------------------#
FUNCTION pol0490_informar() 
#-------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CONSTRUCT BY NAME where_clause ON 
      item_comil.cod_item_comil

      ON KEY (control-z)
         CALL pol0490_popup()

   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0490

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0490_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   LET sql_stmt = "SELECT * FROM item_comil ",
                  " WHERE ", where_clause CLIPPED, 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",                
                  "ORDER BY cod_item_comil"

   PREPARE var_listar FROM sql_stmt   
   DECLARE cq_listar CURSOR FOR var_listar

   FOREACH cq_listar INTO mr_item_comil.*
   

      OUTPUT TO REPORT pol0490_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#---------------------#
 REPORT pol0490_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "POL0490              PRODUTOS PARA ANALISES",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT
         PRINT COLUMN 001, "     ITEM             DESCRICAO PORTUGUES             DESCRICAO INGLES"
         PRINT COLUMN 001, "--------------- ------------------------------- -------------------------------"
                           
      ON EVERY ROW

         PRINT         
         PRINT COLUMN 001, mr_item_comil.cod_item_comil,
               COLUMN 017, mr_item_comil.den_item_comil[1,31],
               COLUMN 049, mr_item_comil.den_ingles_comil[1,31]
         PRINT
                         
         DECLARE cq_itens CURSOR FOR
          SELECT a.cod_item,
                 b.den_item
            FROM item_refer_comil a,
                 item b
           WHERE a.cod_empresa    = p_cod_empresa
             AND a.cod_item_comil = mr_item_comil.cod_item_comil
             AND b.cod_empresa    = a.cod_empresa
             AND b.cod_item       = a.cod_item
         
         FOREACH cq_itens INTO 
                 p_cod_item,
                 p_den_item
            
            PRINT COLUMN 001, p_cod_item,
                  COLUMN 017, p_den_item
        
        END FOREACH
        
END REPORT

#-----------------------#
 FUNCTION pol0490_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION       
#----------------------------- FIM DE PROGRAMA --------------------------------#
