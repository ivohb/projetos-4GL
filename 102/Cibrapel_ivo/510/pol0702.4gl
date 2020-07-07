#-------------------------------------------------------------------#
# PROGRAMA: pol0702                                                 #
# MODULOS.: pol0702-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE ARRANJO - CIBRAPEL                          #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 20/12/2007                                              #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE 
          p_den_arranjo        LIKE arranjo.den_arranjo,
          p_user               LIKE usuario.nom_usuario,
          p_data_disp          LIKE disp_arranjo_885.data_disp,
          p_cod_arranjo        LIKE disp_arranjo_885.cod_arranjo,
          p_retorno            SMALLINT,
          p_cod_empresa        LIKE empresa.cod_empresa,
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
          p_cod_formulario     CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_msg                CHAR(100),
          p_dat_disp           DATE
          
   DEFINE p_disp_arranjo_885   RECORD LIKE disp_arranjo_885.*,
          p_disp_arranjo_885a  RECORD LIKE disp_arranjo_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0702-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0702.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0702_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0702_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0702") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0702 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0702_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0702_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0702_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0702_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0702_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0702_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0702

END FUNCTION

#--------------------------#
 FUNCTION pol0702_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_disp_arranjo_885.* TO NULL
   LET p_disp_arranjo_885.cod_empresa = p_cod_empresa

   IF pol0702_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO disp_arranjo_885 VALUES (p_disp_arranjo_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0702_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0702

   INPUT BY NAME p_disp_arranjo_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_arranjo
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD data_disp
      END IF   
      
      AFTER FIELD cod_arranjo
      IF p_disp_arranjo_885.cod_arranjo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_arranjo
      ELSE
          SELECT den_arranjo
          INTO p_den_arranjo
          FROM arranjo
          WHERE cod_empresa = p_cod_empresa 
          AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
   
                            
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela arranjo !!!" 
            NEXT FIELD cod_arranjo  
        END IF  
           
         
           
         SELECT cod_arranjo
           FROM disp_arranjo_885
          WHERE cod_empresa = p_cod_empresa 
            AND cod_arranjo = p_disp_arranjo_885.cod_arranjo   
        
         IF STATUS = 0 THEN
            ERROR "Código do Arranjo já Cadastrado na Tabela disp_arranjo_885 !!!"
            NEXT FIELD cod_arranjo
         END IF

      IF STATUS <> 0 THEN
                               
         DISPLAY p_disp_arranjo_885.cod_arranjo TO cod_arranjo
         DISPLAY p_den_arranjo TO den_arranjo 
         
      NEXT FIELD data_disp
        END IF

          
      END IF
      
      AFTER FIELD data_disp
      IF p_disp_arranjo_885.data_disp IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD data_disp
      END IF 
               
    ON KEY (control-z)
      CALL pol0702_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0702

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------#
 FUNCTION pol0702_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_disp_arranjo_885a.* = p_disp_arranjo_885.*

   CONSTRUCT BY NAME where_clause ON  
      disp_arranjo_885.cod_arranjo,
      disp_arranjo_885.data_disp
  
      ON KEY (control-z)
       # CALL pol0702_popup()
        
           LET p_cod_arranjo = pol0702_carrega_empresa() 
               DISPLAY p_den_arranjo TO den_arranjo 
            IF p_cod_arranjo IS NOT NULL THEN
               LET p_disp_arranjo_885.cod_arranjo = p_cod_arranjo CLIPPED
               CURRENT WINDOW IS w_pol0702
         DISPLAY p_disp_arranjo_885.cod_arranjo TO cod_arranjo         
         DISPLAY p_den_arranjo TO den_arranjo 
            END IF   
        
   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0702

         IF SQLCA.sqlcode <> 0 THEN
            CLEAR FORM
         END IF

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_disp_arranjo_885.* = p_disp_arranjo_885a.*
      CALL pol0702_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM disp_arranjo_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_arranjo"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_disp_arranjo_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0702_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0702_exibe_dados()
#------------------------------#
 
   SELECT den_arranjo
     INTO p_den_arranjo
     FROM arranjo
    WHERE cod_empresa = p_cod_empresa
      AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
   
   LET p_dat_disp = p_disp_arranjo_885.data_disp
   
   DISPLAY BY NAME p_disp_arranjo_885.*
   DISPLAY p_den_arranjo TO den_arranjo
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0702_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_disp_arranjo_885.*                                              
     FROM disp_arranjo_885
     WHERE cod_empresa = p_cod_empresa 
       AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","disp_arranjo_885")   
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------#
 FUNCTION pol0702_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0702_cursor_for_update() THEN
      LET p_disp_arranjo_885a.* = p_disp_arranjo_885.*
      IF pol0702_entrada_dados("MODIFICACAO") THEN
         UPDATE disp_arranjo_885
            SET data_disp = p_disp_arranjo_885.data_disp
              WHERE cod_empresa = p_cod_empresa
                AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","disp_arranjo_885")
         END IF
      ELSE
         LET p_disp_arranjo_885.* = p_disp_arranjo_885a.*
         CALL pol0702_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 


#--------------------------#
 FUNCTION pol0702_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0702_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM disp_arranjo_885
         #WHERE CURRENT OF cm_padrao
         WHERE cod_empresa = p_cod_empresa
         AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
         
         
         
         IF STATUS = 0 THEN
            INITIALIZE p_disp_arranjo_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","disp_arranjo_885")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0702_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_disp_arranjo_885a.* = p_disp_arranjo_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_disp_arranjo_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_disp_arranjo_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_disp_arranjo_885.* = p_disp_arranjo_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_disp_arranjo_885.*
           FROM disp_arranjo_885
           WHERE cod_empresa = p_cod_empresa 
             AND cod_arranjo = p_disp_arranjo_885.cod_arranjo
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0702_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0702_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_arranjo          LIKE disp_arranjo_885.cod_arranjo,
         den_arranjo          LIKE arranjo.den_arranjo
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07021") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07021 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_arranjo
        FROM disp_arranjo_885
        ORDER BY cod_arranjo

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_arranjo 
                         
        SELECT den_arranjo
        INTO pr_empresa[pr_index].den_arranjo
        FROM arranjo
       WHERE cod_arranjo = pr_empresa[pr_index].cod_arranjo                                

      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_empresa TO sr_empresa.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0702
  
  
   RETURN pr_empresa[pr_index].cod_arranjo
      
END FUNCTION 


#-----------------------#
FUNCTION pol0702_popup()
#-----------------------#
   DEFINE p_codigo CHAR(05)

   CASE
      WHEN INFIELD(cod_arranjo)
         CALL log009_popup(8,10,"ARRANJO","arranjo",
              "cod_arranjo","den_arranjo","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0702
          
         IF p_codigo IS NOT NULL THEN
           LET p_disp_arranjo_885.cod_arranjo = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_arranjo
         END IF 
      
         
   END CASE
END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#

