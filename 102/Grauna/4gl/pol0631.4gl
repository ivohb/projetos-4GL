#-------------------------------------------------------------------#
# PROGRAMA: pol0631                                                 #
# MODULOS.: pol0631-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE CERTIFICADO DAS OPERACOES - GRAUNA          #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 10/09/2007                                              #
# ALTERADO: 10/09/2007 por Ana Paula - versao 02                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_retorno            SMALLINT,          
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_houve_erro         SMALLINT


   DEFINE p_cod_item           LIKE item.cod_item,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_operacoes          CHAR(50),
          p_ies_operacao       CHAR(01)
          
   DEFINE pr_certif            ARRAY[200] OF RECORD
          cod_fornecedor       LIKE certif_oper_1040.cod_fornecedor,
          sequencia            LIKE certif_oper_1040.sequencia,
          operacoes            LIKE certif_oper_1040.operacoes, 
          ies_operacao         LIKE certif_oper_1040.ies_operacao
      END RECORD

   DEFINE p_certif_oper_1040   RECORD LIKE certif_oper_1040.*,
          p_certif_oper_1040a  RECORD LIKE certif_oper_1040.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0631-05.10.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0631.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0631_controle()
   END IF
END MAIN
  
#--------------------------#
 FUNCTION pol0631_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0631") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0631 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0631_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
       
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0631_modificar() RETURNING p_status
            IF p_status THEN
               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
                  ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Operação Cancelada !!!"
                  ATTRIBUTE (REVERSE)
            END IF
          ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF p_certif_oper_1040.cod_item IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
                CALL pol0631_excluir() RETURNING p_status
               IF p_status THEN
                  MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
                     ATTRIBUTE(REVERSE)
               ELSE
                  MESSAGE "Operação Cancelada !!!"
                     ATTRIBUTE(REVERSE)
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0631_consultar()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0631_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0631_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 007
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0631

END FUNCTION

#--------------------------#
 FUNCTION pol0631_incluir()
#--------------------------#

   IF pol0631_aceita_chave() THEN
      IF pol0631_aceita_itens() THEN
         CALL pol0631_grava_itens()
      END IF
   END IF
   RETURN(p_retorno)
   
   END FUNCTION

#--------------------------#
FUNCTION pol0631_modificar()
#--------------------------#

   IF pol0631_aceita_itens() THEN
      CALL pol0631_grava_itens()
   ELSE
      CALL pol0631_exibe_fornec()
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#------------------------------#
FUNCTION pol0631_aceita_chave()
#------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0631
   CLEAR FORM
   
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_certif_oper_1040 TO NULL
  
   LET p_certif_oper_1040.cod_empresa = p_cod_empresa
 
   INPUT BY NAME p_certif_oper_1040.cod_item WITHOUT DEFAULTS  

      AFTER FIELD cod_item
      IF p_certif_oper_1040.cod_item IS NULL THEN
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD cod_item
      END IF
     
      SELECT COUNT(cod_item)
        INTO p_count
        FROM certif_oper_1040
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_certif_oper_1040.cod_item
          
      IF p_count > 0 THEN 
         ERROR "Código já Cadastrado na Tabela CERTIF_OPER_1040 !!!"
         NEXT FIELD cod_item
      END IF
      
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_certif_oper_1040.cod_item
 
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Item nao cadastrado na Tabela ITEM !!!"  
            NEXT FIELD cod_item
         ELSE
            DISPLAY p_den_item_reduz TO den_item_reduz
         END IF

      ON KEY (control-z)
         CALL pol0631_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

#-----------------------------#
FUNCTION pol0631_aceita_itens()
#-----------------------------#

   INITIALIZE pr_certif TO NULL
         
   WHENEVER ERROR CONTINUE
         
   LET p_index = 1
   
   DECLARE cq_certif CURSOR FOR 
    SELECT cod_fornecedor,
           sequencia,
           operacoes,
           ies_operacao
      FROM certif_oper_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_certif_oper_1040.cod_item
     ORDER BY cod_fornecedor,sequencia
      
    FOREACH cq_certif INTO pr_certif[p_index].cod_fornecedor,
                           pr_certif[p_index].sequencia,
                           pr_certif[p_index].operacoes,
                           pr_certif[p_index].ies_operacao
                             
      LET p_index = p_index + 1

      IF p_index > 200 THEN
         ERROR 'Limite de itens ultrapassado !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_certif
      WITHOUT DEFAULTS FROM sr_certif.*

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      #BEFORE FIELD cod_fornecedor
      #   LET p_cod_fornecedor = pr_certif[p_index].cod_fornecedor
         
      AFTER FIELD cod_fornecedor
         IF pr_certif[p_index].cod_fornecedor IS NOT NULL THEN
            SELECT raz_social_reduz
              FROM fornecedor
             WHERE cod_fornecedor = pr_certif[p_index].cod_fornecedor
             
            IF SQLCA.sqlcode = NOTFOUND THEN
               ERROR "Item nao cadastrado na Tabela Fornecedor!!!"
               NEXT FIELD cod_fornecedor
            END IF
         LET pr_certif[p_index].sequencia = p_index          
         DISPLAY pr_certif[p_index].sequencia TO sr_certif[s_index].sequencia
            NEXT FIELD operacoes
         END IF

        # LET pr_certif[p_index].sequencia = p_index          
        # DISPLAY pr_certif[p_index].sequencia TO sr_certif[s_index].sequencia

      AFTER FIELD operacoes
         IF pr_certif[p_index].operacoes IS NULL THEN
            ERROR "Campo c/ Prenchimento Obrigatório !!!"
            LET pr_certif[p_index].operacoes = p_operacoes
            NEXT FIELD operacoes
         END IF
        
      AFTER FIELD ies_operacao
         IF pr_certif[p_index].ies_operacao IS NULL OR      
            pr_certif[p_index].ies_operacao = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_operacao
            END IF
         ELSE
            IF pr_certif[p_index].ies_operacao <> 'I' AND 
               pr_certif[p_index].ies_operacao <> 'E' THEN
               ERROR 'Valor inválido. Informe (I)-Interno ou (E)-Externo'
               NEXT FIELD ies_operacao
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0631_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   
   RETURN(p_retorno)
   
END FUNCTION

#-------------------------------#
FUNCTION pol0631_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_certif[p_ind].cod_fornecedor = pr_certif[p_index].cod_fornecedor THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0631_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM certif_oper_1040
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = p_certif_oper_1040.cod_item

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF pr_certif[p_ind].cod_fornecedor IS NULL THEN
             CONTINUE FOR
          END IF

          INSERT INTO certif_oper_1040
             VALUES(p_cod_empresa,
                    p_certif_oper_1040.cod_item,
                    pr_certif[p_ind].cod_fornecedor,
                    p_ind,
                    pr_certif[p_ind].operacoes,
                    pr_certif[p_ind].ies_operacao)
          
          IF sqlca.sqlcode <> 0 THEN 
             LET p_houve_erro = TRUE
             MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
             EXIT FOR
          END IF
      END FOR
   END IF
   
   IF NOT p_houve_erro THEN
      CALL log085_transacao("COMMIT")	      
      LET p_retorno = TRUE
   ELSE
      CALL log003_err_sql("GRAVAÇÃO","CERTIF_OPER_1040")
      CALL log085_transacao("ROLLBACK")
      LET p_retorno = FALSE
   END IF      
   WHENEVER ERROR STOP
   
END FUNCTION

#------------------------#
FUNCTION pol0631_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      DELETE FROM certif_oper_1040
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_certif_oper_1040.cod_item
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_certif_oper_1040.* TO NULL
      ELSE
         CALL log003_err_sql("DELEÇÃO","certif_oper_1040")
      END IF
   END IF
   WHENEVER ERROR STOP
   RETURN(p_retorno)
   
END FUNCTION


#----------------------------#
 FUNCTION pol0631_consultar()
#----------------------------#

  DEFINE sql_stmt, 
         where_clause CHAR(300)  
  
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  LET p_certif_oper_1040a.* = p_certif_oper_1040.*

   CONSTRUCT BY NAME where_clause ON certif_oper_1040.cod_item
   
         ON KEY (control-z)
         CALL pol0631_popup()
         
     END CONSTRUCT    

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0631

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_certif_oper_1040.* = p_certif_oper_1040a.*
      CALL pol0631_exibe_item()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM certif_oper_1040 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_empresa,cod_item,sequencia "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_certif_oper_1040.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0631_exibe_item()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0631_exibe_item()
#------------------------------#

   DISPLAY BY NAME p_certif_oper_1040.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_item_reduz TO NULL
   
   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_certif_oper_1040.cod_item
   
   DISPLAY p_den_item_reduz TO den_item_reduz

   DECLARE cq_dados CURSOR FOR
   SELECT *
     FROM certif_oper_1040
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_certif_oper_1040.cod_item
      
   FOREACH cq_dados INTO p_certif_oper_1040.*

      CALL pol0631_exibe_fornec()
      
   END FOREACH
      
   END FUNCTION
  
  #---------------------------------#
    FUNCTION pol0631_exibe_fornec()
  #---------------------------------#

    LET p_index = 1
   
    DECLARE cq_certif1 CURSOR FOR 
    SELECT cod_fornecedor,
           sequencia,
           operacoes,
           ies_operacao
      FROM certif_oper_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_certif_oper_1040.cod_item
     
   FOREACH cq_certif1 INTO pr_certif[p_index].cod_fornecedor,
                           pr_certif[p_index].sequencia,
                           pr_certif[p_index].operacoes,
                           pr_certif[p_index].ies_operacao
                            
      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_certif WITHOUT DEFAULTS FROM sr_certif.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0631_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_item = p_certif_oper_1040.cod_item
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_certif_oper_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_certif_oper_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_certif_oper_1040.cod_item = p_cod_item
            EXIT WHILE
         END IF

         IF p_certif_oper_1040.cod_item = p_cod_item THEN
            CONTINUE WHILE
         END IF

         SELECT COUNT(cod_item) INTO p_count
           FROM certif_oper_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_certif_oper_1040.cod_item
            
         IF p_count > 0 THEN
            CALL pol0631_exibe_item()
            EXIT WHILE 
         END IF

      END WHILE
                  
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0631_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0631
         IF p_codigo IS NOT NULL THEN
           LET p_certif_oper_1040.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

       WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0631
         IF p_codigo IS NOT NULL THEN
            LET pr_certif[p_index].cod_fornecedor = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_certif[s_index].cod_fornecedor
         END IF
      
   END CASE

END FUNCTION

#-------------------------------#
FUNCTION pol0631_repetiu_seq()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_certif[p_ind].cod_fornecedor = pr_certif[p_index].cod_fornecedor THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
