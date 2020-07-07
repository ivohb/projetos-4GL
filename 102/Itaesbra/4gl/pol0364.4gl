#------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                  #
# PROGRAMA: POL0364                                                            #
# MODULOS.: POL0364 - LOG0010 - LOG0030 - LOG0040 - LOG0050                    #
#           LOG0060 - LOG1300 - LOG1400                                        #
# OBJETIVO: MANUTENCAO DA TABELA EMBAL_ITAESBRA                                #
# AUTOR...: POLO INFORMATICA                                                   #
# DATA....: 21/11/2005                                                         #
# ALTERADO: 24/09/2008 por Ana Paula - versao 07 - coloca zoom para tipo_venda #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_i                  SMALLINT,
          p_msg                CHAR(500)

   DEFINE p_embal_itaesbra     RECORD LIKE embal_itaesbra.*
   DEFINE p_embal_itaesbraa    RECORD LIKE embal_itaesbra.*

   DEFINE t_embal ARRAY[50] OF RECORD
      cod_embal                LIKE embal_itaesbra.cod_embal,
      den_embal                LIKE embalagem.den_embal,
      ies_tip_embal            LIKE embal_itaesbra.ies_tip_embal,
      qtd_padr_embal           LIKE embal_itaesbra.qtd_padr_embal,
      vol_padr_embal           LIKE embal_itaesbra.vol_padr_embal,
      contner                  LIKE embal_itaesbra.contner,
      dloc                     LIKE embal_itaesbra.dloc,
      doc                      LIKE embal_itaesbra.doc,
      stck                     LIKE embal_itaesbra.stck
   END RECORD 

   DEFINE p_tela RECORD
      nom_cliente              LIKE clientes.nom_cliente,
      den_item_reduz           LIKE item.den_item_reduz,
      den_tip_venda            LIKE tipo_venda.den_tip_venda
   END RECORD 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0364-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0364.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0364_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0364_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0364") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0364 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0364_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0364_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0364_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0364_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF 
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0364_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0364_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0364_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0364

END FUNCTION

#--------------------------#
 FUNCTION pol0364_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0364_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN") 
   #  BEGIN WORK
      FOR p_i = 1 TO 50
         IF p_embal_itaesbra.cod_cliente IS NOT NULL AND
            p_embal_itaesbra.cod_cliente <> " " AND
            p_embal_itaesbra.cod_item IS NOT NULL AND
            p_embal_itaesbra.cod_item <> " " AND
            p_embal_itaesbra.cod_tip_venda IS NOT NULL AND
            t_embal[p_i].cod_embal IS NOT NULL AND
            t_embal[p_i].cod_embal <> " " AND
            t_embal[p_i].ies_tip_embal IS NOT NULL AND
            t_embal[p_i].ies_tip_embal <> " " THEN
            LET p_embal_itaesbra.cod_empresa    = p_cod_empresa
            LET p_embal_itaesbra.cod_embal      = t_embal[p_i].cod_embal
            LET p_embal_itaesbra.ies_tip_embal  = t_embal[p_i].ies_tip_embal
            LET p_embal_itaesbra.qtd_padr_embal = t_embal[p_i].qtd_padr_embal
            LET p_embal_itaesbra.vol_padr_embal = t_embal[p_i].vol_padr_embal
            #--- alterado ana ---###
            LET p_embal_itaesbra.contner = t_embal[p_i].contner
            LET p_embal_itaesbra.dloc    = t_embal[p_i].dloc
            LET p_embal_itaesbra.doc     = t_embal[p_i].doc
            LET p_embal_itaesbra.stck    = t_embal[p_i].stck
            #--- fim --- 
            INSERT INTO embal_itaesbra VALUES (p_embal_itaesbra.*)
            IF SQLCA.SQLCODE <> 0 THEN 
	       LET p_houve_erro = TRUE
               EXIT FOR
            END IF	
         END IF	
      END FOR
      IF p_houve_erro = TRUE THEN
         CALL log085_transacao("ROLLBACK") 
      #  ROLLBACK WORK 
         CALL log003_err_sql("INCLUSAO","EMBAL_ITAESBRA")       
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT") 
      #  COMMIT WORK 
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
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
 FUNCTION pol0364_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0364
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_embal_itaesbra.*,
                 p_tela.*,
                 t_embal TO NULL
      DISPLAY BY NAME p_embal_itaesbra.cod_cliente,
                      p_embal_itaesbra.cod_item,
                      p_tela.*
      CLEAR FORM
   END IF
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE
   INPUT BY NAME p_embal_itaesbra.cod_cliente,
                 p_embal_itaesbra.cod_item,
                 p_embal_itaesbra.cod_tip_venda
      WITHOUT DEFAULTS

      BEFORE FIELD cod_cliente
      IF p_funcao = "MODIFICACAO" THEN
         EXIT INPUT
      END IF 

      AFTER FIELD cod_cliente   
      IF p_embal_itaesbra.cod_cliente IS NOT NULL THEN 
         SELECT nom_cliente
            INTO p_tela.nom_cliente
         FROM clientes
         WHERE cod_cliente = p_embal_itaesbra.cod_cliente
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"  
            NEXT FIELD cod_cliente
         END IF
         DISPLAY BY NAME p_tela.nom_cliente
      ELSE 
         ERROR "O Campo Cod Cliente nao pode ser Nulo"
         NEXT FIELD cod_cliente
      END IF

      AFTER FIELD cod_item       
      IF p_embal_itaesbra.cod_item IS NOT NULL THEN 
         SELECT den_item_reduz
            INTO p_tela.den_item_reduz
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_embal_itaesbra.cod_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Item nao Cadastrado"  
            NEXT FIELD cod_item
         END IF
         DISPLAY BY NAME p_tela.den_item_reduz
      ELSE 
         ERROR "O Campo Cod Item nao pode ser Nulo"
         NEXT FIELD cod_item
      END IF

      AFTER FIELD cod_tip_venda
      IF p_embal_itaesbra.cod_tip_venda IS NOT NULL THEN 
         SELECT den_tip_venda
            INTO p_tela.den_tip_venda
         FROM tipo_venda
         WHERE cod_tip_venda = p_embal_itaesbra.cod_tip_venda
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Tipo de Venda nao Cadastrado"
            NEXT FIELD cod_tip_venda
         END IF
         DISPLAY BY NAME p_tela.den_tip_venda
         IF p_funcao = "INCLUSAO" THEN
            SELECT UNIQUE cod_cliente,
                          cod_item,
                          cod_tip_venda
            FROM embal_itaesbra  
            WHERE cod_empresa = p_cod_empresa  
              AND cod_cliente = p_embal_itaesbra.cod_cliente
              AND cod_item = p_embal_itaesbra.cod_item
              AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda
            IF SQLCA.SQLCODE = 0 THEN 
               ERROR "Produto Já Cadastrado"
               NEXT FIELD cod_cliente
            END IF
         END IF
      ELSE 
         ERROR "O Campo Tipo de Venda pode ser Nulo"
         NEXT FIELD cod_tip_venda
      END IF

      ON KEY (control-z)
         CALL pol0364_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0364

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ies_cons = FALSE
      CLEAR FORM
      RETURN FALSE
   END IF

   LET INT_FLAG = FALSE
   INPUT ARRAY t_embal WITHOUT DEFAULTS FROM s_embal.*

      BEFORE FIELD cod_embal
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD cod_embal
      IF t_embal[pa_curr].cod_embal IS NOT NULL THEN
         SELECT den_embal
            INTO t_embal[pa_curr].den_embal
         FROM embalagem
         WHERE cod_embal = t_embal[pa_curr].cod_embal
         IF SQLCA.SQLCODE <> 0 THEN 
            ERROR "Embalagem nao Cadastrada"
            NEXT FIELD cod_embal
         ELSE
            DISPLAY t_embal[pa_curr].den_embal TO s_embal[sc_curr].den_embal
         END IF 
      END IF 

      AFTER FIELD ies_tip_embal
      IF t_embal[pa_curr].ies_tip_embal IS NOT NULL THEN 
         IF p_funcao = "INCLUSAO" OR p_funcao = "MODIFICACAO" THEN
            FOR p_i = 1 TO 50
               IF p_i = pa_curr OR
                  pa_curr = 1 THEN
                  CONTINUE FOR 
               ELSE
                  IF (t_embal[p_i].ies_tip_embal = t_embal[pa_curr].ies_tip_embal) THEN
                     ERROR "Tipo de Embalagem Já Informada"
                     NEXT FIELD ies_tip_embal
                  END IF
               END IF
            END FOR
         END IF
      END IF

      IF t_embal[pa_curr].cod_embal IS NULL AND  
         t_embal[pa_curr].ies_tip_embal IS NULL THEN 
         INITIALIZE t_embal[pa_curr].* TO NULL
         LET t_embal[pa_curr].ies_tip_embal = " "
         DISPLAY t_embal[pa_curr].* TO s_embal[sc_curr].*
         NEXT FIELD cod_embal
      ELSE
         IF t_embal[pa_curr].ies_tip_embal IS NULL THEN 
            LET t_embal[pa_curr].qtd_padr_embal = NULL
            LET t_embal[pa_curr].vol_padr_embal = NULL
            LET t_embal[pa_curr].ies_tip_embal = " "
            DISPLAY t_embal[pa_curr].* TO s_embal[sc_curr].*
            NEXT FIELD cod_embal
         END IF
      END IF

      AFTER FIELD qtd_padr_embal
      IF t_embal[pa_curr].qtd_padr_embal IS NULL OR   
         t_embal[pa_curr].qtd_padr_embal = 0 THEN 
         ERROR "O Campo Qtde Padrao Embalagem nao pode ser Zero/Nulo"
         NEXT FIELD qtd_padr_embal
      END IF

      AFTER FIELD vol_padr_embal
      IF t_embal[pa_curr].vol_padr_embal IS NULL OR   
         t_embal[pa_curr].vol_padr_embal = 0 THEN 
         ERROR "O Campo Volume Padrao Embalagem nao pode ser Zero/Nulo"
         NEXT FIELD vol_padr_embal
      END IF

{      AFTER FIELD contner
      IF t_embal[pa_curr].contner IS NULL OR   
         t_embal[pa_curr].contner = 0 THEN 
         ERROR "O Campo     nao pode ser Zero/Nulo"
         NEXT FIELD contner
      END IF

      AFTER FIELD dloc
      IF t_embal[pa_curr].dloc IS NULL OR   
         t_embal[pa_curr].dloc = 0 THEN 
         ERROR "O Campo    nao pode ser Zero/Nulo"
         NEXT FIELD dloc
      END IF

      AFTER FIELD doc
      IF t_embal[pa_curr].doc IS NULL OR   
         t_embal[pa_curr].doc = 0 THEN 
         ERROR "O Campo   nao pode ser Zero/Nulo"
         NEXT FIELD dloc
      END IF

      AFTER FIELD stck
      IF t_embal[pa_curr].stck IS NULL OR   
         t_embal[pa_curr].stck = 0 THEN 
         ERROR "O Campo   nao pode ser Zero/Nulo"
         NEXT FIELD stck
      END IF}

      AFTER INPUT
      IF INT_FLAG THEN 
         EXIT INPUT
      ELSE
         IF p_funcao = "INCLUSAO" OR p_funcao = "MODIFICACAO" THEN
            FOR p_i = 1 TO 50
               IF p_i = pa_curr THEN
                  CONTINUE FOR 
               ELSE
                  IF t_embal[p_i].ies_tip_embal = t_embal[pa_curr].ies_tip_embal THEN
                     ERROR "Tipo de Embalagem Já Informada"
                     NEXT FIELD ies_tip_embal
                  END IF
               END IF
            END FOR
         END IF
      END IF

      ON KEY (control-z)
         CALL pol0364_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0364

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      LET p_ies_cons = FALSE
      CLEAR FORM
      RETURN FALSE
   ELSE
   #  LET p_ies_cons = FALSE
      RETURN TRUE 
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0364_popup()
#-----------------------#

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_embal_itaesbra.cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0364 
         IF p_embal_itaesbra.cod_cliente IS NOT NULL THEN
            DISPLAY p_embal_itaesbra.cod_cliente TO cod_cliente
         END IF
      WHEN INFIELD(cod_item)
         LET p_embal_itaesbra.cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0364 
         IF p_embal_itaesbra.cod_item IS NOT NULL THEN
            DISPLAY p_embal_itaesbra.cod_item TO cod_item
         END IF
      WHEN INFIELD(cod_tip_venda)
         CALL log009_popup(6,25,"TIPO VENDA","tipo_venda",
                           "cod_tip_venda","den_tip_venda",
                           "","N","") 
            RETURNING p_embal_itaesbra.cod_tip_venda
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0364
         IF p_embal_itaesbra.cod_tip_venda IS NOT NULL THEN
            DISPLAY p_embal_itaesbra.cod_tip_venda TO cod_tip_venda
         END IF
      WHEN INFIELD(cod_embal)
         CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                           "cod_embal","den_embal",
                           "","N","") 
            RETURNING t_embal[pa_curr].cod_embal
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0364
         IF t_embal[pa_curr].cod_embal IS NOT NULL THEN
            DISPLAY t_embal[pa_curr].cod_embal TO s_embal[sc_curr].cod_embal
         END IF
   END CASE

END FUNCTION    

#--------------------------#
 FUNCTION pol0364_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON embal_itaesbra.cod_cliente,
                                     embal_itaesbra.cod_item,
                                     embal_itaesbra.cod_tip_venda

      ON KEY (control-z)
         CALL pol0364_popup()

   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0364

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_embal_itaesbra.* = p_embal_itaesbraa.*
      CALL pol0364_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT UNIQUE cod_empresa, ",
                  " cod_cliente,cod_item,cod_tip_venda ",
                  " FROM embal_itaesbra ",
                  " WHERE cod_empresa = ",p_cod_empresa,                 
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_embal_itaesbra.cod_empresa,
                        p_embal_itaesbra.cod_cliente,
                        p_embal_itaesbra.cod_item,
                        p_embal_itaesbra.cod_tip_venda
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0364_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0364_exibe_dados()
#-----------------------------#

   SELECT nom_cliente  
      INTO p_tela.nom_cliente
   FROM clientes
   WHERE cod_cliente = p_embal_itaesbra.cod_cliente

   SELECT den_item_reduz
      INTO p_tela.den_item_reduz
   FROM item
   WHERE cod_empresa = p_embal_itaesbra.cod_empresa
     AND cod_item = p_embal_itaesbra.cod_item

   SELECT den_tip_venda
      INTO p_tela.den_tip_venda
   FROM tipo_venda
   WHERE cod_tip_venda = p_embal_itaesbra.cod_tip_venda

   DISPLAY BY NAME p_embal_itaesbra.cod_cliente,
                   p_embal_itaesbra.cod_item,
                   p_embal_itaesbra.cod_tip_venda,
                   p_tela.*

   DECLARE cq_embal CURSOR WITH HOLD FOR
   SELECT cod_embal,
          ies_tip_embal,
          qtd_padr_embal,
          vol_padr_embal,
          contner,
          dloc,
          doc,
          stck
   FROM embal_itaesbra
   WHERE cod_empresa   = p_embal_itaesbra.cod_empresa
     AND cod_cliente   = p_embal_itaesbra.cod_cliente
     AND cod_item      = p_embal_itaesbra.cod_item
     AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda
   ORDER BY 2 DESC

   LET p_i = 1
   FOREACH cq_embal INTO t_embal[p_i].cod_embal,
                         t_embal[p_i].ies_tip_embal,
                         t_embal[p_i].qtd_padr_embal,
                         t_embal[p_i].vol_padr_embal,
                         t_embal[p_i].contner,
                         t_embal[p_i].dloc,
                         t_embal[p_i].doc,
                         t_embal[p_i].stck
      SELECT den_embal
         INTO t_embal[p_i].den_embal
      FROM embalagem
      WHERE cod_embal = t_embal[p_i].cod_embal

      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
  
   CALL SET_COUNT(p_i)

   INPUT ARRAY t_embal WITHOUT DEFAULTS FROM s_embal.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

#  DISPLAY ARRAY t_embal TO s_embal.*
#  END DISPLAY

END FUNCTION

#-----------------------------------#
 FUNCTION pol0364_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *
      INTO p_embal_itaesbra.*
   FROM embal_itaesbra  
   WHERE cod_empresa   = p_embal_itaesbra.cod_empresa
     AND cod_cliente   = p_embal_itaesbra.cod_cliente
     AND cod_item      = p_embal_itaesbra.cod_item
     AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda
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
      OTHERWISE CALL log003_err_sql("LEITURA","EMBAL_ITAESBRA")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0364_modificacao()
#-----------------------------#

   LET p_houve_erro = FALSE
#  IF pol0364_cursor_for_update() THEN
   CALL log085_transacao("BEGIN") 
#  BEGIN WORK
      LET p_embal_itaesbraa.* = p_embal_itaesbra.*
      IF pol0364_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM embal_itaesbra
      #  WHERE CURRENT OF cm_padrao
         WHERE cod_empresa   = p_embal_itaesbra.cod_empresa
           AND cod_cliente   = p_embal_itaesbra.cod_cliente
           AND cod_item      = p_embal_itaesbra.cod_item   
           AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda
         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("EXCLUSAO","EMBAL_ITAESBRA")
            CALL log085_transacao("ROLLBACK") 
         #  ROLLBACK WORK
         END IF
         FOR p_i = 1 TO 50
            IF p_embal_itaesbra.cod_empresa IS NOT NULL AND
               p_embal_itaesbra.cod_empresa <> " " AND
               p_embal_itaesbra.cod_cliente IS NOT NULL AND
               p_embal_itaesbra.cod_cliente <> " " AND
               p_embal_itaesbra.cod_item IS NOT NULL AND
               p_embal_itaesbra.cod_item <> " " AND
               p_embal_itaesbra.cod_tip_venda IS NOT NULL AND
               t_embal[p_i].cod_embal IS NOT NULL AND
               t_embal[p_i].cod_embal <> " " AND
               t_embal[p_i].ies_tip_embal IS NOT NULL AND
               t_embal[p_i].ies_tip_embal <> " " THEN
               LET p_embal_itaesbra.cod_embal      = t_embal[p_i].cod_embal
               LET p_embal_itaesbra.ies_tip_embal  = t_embal[p_i].ies_tip_embal
               LET p_embal_itaesbra.qtd_padr_embal = t_embal[p_i].qtd_padr_embal
               LET p_embal_itaesbra.vol_padr_embal = t_embal[p_i].vol_padr_embal
               LET p_embal_itaesbra.contner        = t_embal[p_i].contner
               LET p_embal_itaesbra.dloc           = t_embal[p_i].dloc
               LET p_embal_itaesbra.doc            = t_embal[p_i].doc
               LET p_embal_itaesbra.stck           = t_embal[p_i].stck

               INSERT INTO embal_itaesbra VALUES (p_embal_itaesbra.*)
               IF SQLCA.SQLCODE <> 0 THEN 
	          LET p_houve_erro = TRUE
                  EXIT FOR
               END IF	
            #  CURRENT OF cm_padrao
            END IF	
         END FOR
         IF p_houve_erro = TRUE THEN
            CALL log003_err_sql("MODIFICACAO","EMBAL_ITAESBRA")
            CALL log085_transacao("ROLLBACK") 
         #  ROLLBACK WORK
         ELSE
            CALL log085_transacao("COMMIT") 
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","EMBAL_ITAESBRA")
            ELSE
            #  LET p_ies_cons = FALSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         END IF
      ELSE
         LET p_ies_cons = FALSE
         LET p_embal_itaesbra.* = p_embal_itaesbraa.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK") 
      #  ROLLBACK WORK
         DISPLAY BY NAME p_embal_itaesbra.*,
                         p_tela.*
      END IF
   #  CLOSE cm_padrao
#  END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0364_exclusao()
#--------------------------#

#  IF pol0364_cursor_for_update() THEN
      IF log004_confirm(22,45) THEN
         CALL log085_transacao("BEGIN") 
      #  BEGIN WORK
         WHENEVER ERROR CONTINUE
         DELETE FROM embal_itaesbra
      #  WHERE CURRENT OF cm_padrao
         WHERE cod_empresa   = p_embal_itaesbra.cod_empresa
           AND cod_cliente   = p_embal_itaesbra.cod_cliente
           AND cod_item      = p_embal_itaesbra.cod_item   
           AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT") 
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","EMBAL_ITAESBRA")
            ELSE
            #  LET p_ies_cons = FALSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_embal_itaesbra.* TO NULL
               INITIALIZE p_tela.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","EMBAL_ITAESBRA")
            CALL log085_transacao("ROLLBACK") 
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
   #  ELSE
   #     ROLLBACK WORK
      END IF
   #  CLOSE cm_padrao
#  END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0364_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_embal_itaesbraa.* = p_embal_itaesbra.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_embal_itaesbra.cod_empresa,
                            p_embal_itaesbra.cod_cliente,
                            p_embal_itaesbra.cod_item,
                            p_embal_itaesbra.cod_tip_venda
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_embal_itaesbra.cod_empresa,
                            p_embal_itaesbra.cod_cliente,
                            p_embal_itaesbra.cod_item,
                            p_embal_itaesbra.cod_tip_venda
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_embal_itaesbra.* = p_embal_itaesbraa.* 
            EXIT WHILE
         END IF

         SELECT UNIQUE cod_empresa,
                       cod_cliente,
                       cod_item,
                       cod_tip_venda
            INTO p_embal_itaesbra.cod_empresa,
                 p_embal_itaesbra.cod_cliente,
                 p_embal_itaesbra.cod_item,
                 p_embal_itaesbra.cod_tip_venda
         FROM embal_itaesbra
         WHERE cod_empresa   = p_embal_itaesbra.cod_empresa
           AND cod_cliente   = p_embal_itaesbra.cod_cliente
           AND cod_item      = p_embal_itaesbra.cod_item   
           AND cod_tip_venda = p_embal_itaesbra.cod_tip_venda

         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0364_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0364_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

