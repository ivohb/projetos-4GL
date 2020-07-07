#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0810                                                 #
# MODULOS.: pol0810-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: BLOQUEIA ROMANEIOS GM - TORO                            #
# AUTOR...: Logocente GSP - Bruno                               #
# DATA....: 03/06/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_familia        LIKE dias_expirac_159.cod_familia,
          p_den_familia        LIKE familia.den_familia,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_msg                CHAR(300),
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
          sr_index             SMALLINT
          
          
   DEFINE p_dias_expirac_159   RECORD LIKE dias_expirac_159.*,
          p_dias_expirac_159a  RECORD LIKE dias_expirac_159.* 
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0810-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0810.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0810_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0810_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0810") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0810 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0810_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0810_exclusao() THEN
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
         CALL pol0810_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
            COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0810_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0810_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0810_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0810_sobre() 
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
   CLOSE WINDOW w_pol0810

END FUNCTION

#-----------------------#
FUNCTION pol0810_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0810_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_dias_expirac_159.* TO NULL
   LET p_dias_expirac_159.cod_empresa = p_cod_empresa

   IF pol0810_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO dias_expirac_159 VALUES (p_dias_expirac_159.*)
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
 FUNCTION pol0810_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0810

   INPUT BY NAME p_dias_expirac_159.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_familia
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD num_dias
      END IF 
      
      AFTER FIELD cod_familia
      IF p_dias_expirac_159.cod_familia IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_familia
      ELSE
         SELECT den_familia
         INTO p_den_familia
         FROM familia
         WHERE cod_familia = p_dias_expirac_159.cod_familia
         AND cod_empresa = p_cod_empresa
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo da Familia nao Cadastrado na Tabela Familia !!!" 
            NEXT FIELD cod_familia
         END IF
                  
           SELECT cod_familia
           INTO p_cod_familia
           FROM dias_expirac_159
          WHERE cod_familia = p_dias_expirac_159.cod_familia
            
          
         IF STATUS = 0 THEN
            ERROR "Código da Familia já Cadastrado na Tabela dias_expirac_159 !!!"
            NEXT FIELD cod_familia
         END IF
         DISPLAY p_den_familia TO den_familia 
      END IF
         
       AFTER FIELD num_dias
      IF p_dias_expirac_159.num_dias IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_dias
      END IF
         
         ON KEY (control-z)
            CALL pol0810_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0810

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0810_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_dias_expirac_159a.* = p_dias_expirac_159.*

   CONSTRUCT BY NAME where_clause ON dias_expirac_159.cod_familia
  
      ON KEY (control-z)
         # CALL pol0810_popup()
          LET p_cod_familia = pol0810_carrega_familia() 
               DISPLAY p_den_familia TO den_familia
            IF p_cod_familia IS NOT NULL THEN
               LET p_dias_expirac_159.cod_familia = p_cod_familia CLIPPED
               CURRENT WINDOW IS w_pol0810
               DISPLAY p_dias_expirac_159.cod_familia TO cod_familia
               DISPLAY p_den_familia TO den_familia
            END IF
     

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0810

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_dias_expirac_159.* = p_dias_expirac_159a.*
      CALL pol0810_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM dias_expirac_159 ",
                 " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_familia "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_dias_expirac_159.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0810_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#   
 FUNCTION pol0810_carrega_familia() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_familia        LIKE dias_expirac_159.cod_familia,
         den_familia        LIKE familia.den_familia
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08101") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08101 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_familia
        FROM dias_expirac_159
        ORDER BY cod_familia

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_familia 
                         
        SELECT den_familia
        INTO pr_empresa[pr_index].den_familia
        FROM familia
       WHERE cod_familia = pr_empresa[pr_index].cod_familia

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
      
   CLOSE WINDOW w_pol0810
  
   RETURN pr_empresa[pr_index].cod_familia
      
END FUNCTION 
#------------------------------#
 FUNCTION pol0810_exibe_dados()
#------------------------------#
   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_familia = p_dias_expirac_159.cod_familia
    AND cod_empresa = p_cod_empresa

   DISPLAY BY NAME p_dias_expirac_159.*
   DISPLAY p_den_familia TO den_familia
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0810_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_dias_expirac_159.*                                              
     FROM dias_expirac_159
    WHERE cod_familia = p_dias_expirac_159.cod_familia
    AND cod_empresa = p_cod_empresa
    
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","dias_expirac_159")   
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0810_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0810_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM dias_expirac_159
         #WHERE CURRENT OF cm_padrao
         WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_dias_expirac_159.cod_familia
         IF STATUS = 0 THEN
            INITIALIZE p_dias_expirac_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","dias_expirac_159")
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
#-----------------------------#
 FUNCTION pol0810_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0810_cursor_for_update() THEN
      LET p_dias_expirac_159a.* = p_dias_expirac_159.*
      IF pol0810_entrada_dados("MODIFICACAO") THEN
         UPDATE dias_expirac_159
            SET num_dias = p_dias_expirac_159.num_dias
            #   WHERE CURRENT OF cm_padrao
               WHERE cod_empresa = p_cod_empresa
               AND cod_familia = p_dias_expirac_159.cod_familia
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","dias_expirac_159")
         END IF
      ELSE
         LET p_dias_expirac_159.* = p_dias_expirac_159a.*
         CALL pol0810_exibe_dados()
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
 FUNCTION pol0810_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_dias_expirac_159a.* = p_dias_expirac_159.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_dias_expirac_159.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_dias_expirac_159.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_dias_expirac_159.* = p_dias_expirac_159a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_dias_expirac_159.*
           FROM dias_expirac_159
          WHERE cod_familia = p_dias_expirac_159.cod_familia 
          AND cod_empresa = p_cod_empresa
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0810_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0810_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_familia)
         CALL log009_popup(5,12,"FAMILIAS","familia",
              "cod_familia","den_familia","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0810
         IF p_codigo IS NOT NULL THEN
           LET p_dias_expirac_159.cod_familia = p_codigo
           DISPLAY p_dias_expirac_159.cod_familia TO cod_familia
         END IF
END CASE
END FUNCTION      
#-------------------------------- FIM DE PROGRAMA -----------------------------#

