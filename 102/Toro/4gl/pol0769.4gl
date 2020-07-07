#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0769                                                 #
# MODULOS.: pol0769-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CODIGO LOCAL DE ESTOQUE - TORO                          #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 03/03/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_local          LIKE par_ppte_159.cod_local,
          p_den_cliente        LIKE local.den_local,
          p_user               LIKE usuario.nom_usuario,
          p_msg                CHAR(300),
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
          p_den_local        LIKE local.den_local
          
   DEFINE p_par_ppte_159   RECORD LIKE par_ppte_159.*,
          p_par_ppte_159a  RECORD LIKE par_ppte_159.* 
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0769-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0769.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0769_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0769_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0769") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0769 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0769_inclusao() THEN
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
            IF pol0769_exclusao() THEN
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
         CALL pol0769_consulta()
         IF p_ies_cons THEN
            
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0769_sobre() 

      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0769

END FUNCTION

#-----------------------#
FUNCTION pol0769_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0769_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_par_ppte_159.* TO NULL
   LET p_par_ppte_159.cod_empresa = p_cod_empresa

   IF pol0769_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO par_ppte_159 VALUES (p_par_ppte_159.*)
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
 FUNCTION pol0769_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0769

   INPUT BY NAME p_par_ppte_159.* 
      WITHOUT DEFAULTS  

     { BEFORE FIELD cod_local
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_local
      END IF }
      
      AFTER FIELD cod_local
      IF p_par_ppte_159.cod_local IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_local
      ELSE
         SELECT den_local
         INTO p_den_local
         FROM local
         WHERE cod_local = p_par_ppte_159.cod_local
         AND cod_empresa = p_cod_empresa
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Local nao Cadastrado na Tabela LOCAL !!!" 
            NEXT FIELD cod_local
         END IF
                  
           SELECT cod_empresa
           
           FROM par_ppte_159
           WHERE cod_empresa = p_cod_empresa
            
          IF STATUS = 0 THEN  
           ERROR "Empresa Ja Contem Um Cadastro!!!"
            NEXT FIELD cod_local 
          END IF 
          
    
         DISPLAY p_den_local TO den_local 
         # NEXT FIELD qtd_exp
      END IF
       
       
           { AFTER FIELD qtd_exp
      IF p_par_ppte_159.qtd_exp IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_exp
      END IF          }
      
         ON KEY (control-z)
           CALL pol0769_popup()
           
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0769

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0769_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_ppte_159a.* = p_par_ppte_159.*

   CONSTRUCT BY NAME where_clause ON par_ppte_159.cod_local
  
      ON KEY (control-z)
              LET p_cod_local = pol0769_carrega_cliente()
         IF p_cod_local IS NOT NULL THEN
            LET p_par_ppte_159.cod_local = p_cod_local  CLIPPED
            CURRENT WINDOW IS w_pol0769
            DISPLAY p_par_ppte_159.cod_local TO cod_local
         END IF

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0769

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_par_ppte_159.* = p_par_ppte_159a.*
      CALL pol0769_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM par_ppte_159 ",
                 " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_local "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_ppte_159.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0769_exibe_dados()
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0769_carrega_cliente() 
#-------------------------------#
 
  DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_local    LIKE par_ppte_159.cod_local,
         den_local    LIKE local.den_local
     END RECORD

    INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07691") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07691 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item1 CURSOR FOR 
    SELECT cod_local 
      FROM par_ppte_159
     ORDER BY cod_local

   LET pr_index = 1

   FOREACH cq_item1 INTO pr_item[pr_index].cod_local
   
      SELECT den_local
        INTO pr_item[pr_index].den_local
        FROM local
       WHERE cod_local = pr_item[pr_index].cod_local
         

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

      LET pr_index = ARR_CURR()
      LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0769
   
   RETURN pr_item[pr_index].cod_local
      
END FUNCTION 




#------------------------------#
 FUNCTION pol0769_exibe_dados()
#------------------------------#
   SELECT den_local
     INTO p_den_local
     FROM local
    WHERE cod_local = p_par_ppte_159.cod_local
    AND cod_empresa = p_cod_empresa

   DISPLAY BY NAME p_par_ppte_159.*
   DISPLAY p_den_local TO den_local
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0769_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_par_ppte_159.*                                              
     FROM par_ppte_159
    WHERE cod_local = p_par_ppte_159.cod_local
    AND cod_empresa = p_cod_empresa
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_ppte_159")   
      RETURN FALSE
   END IF

END FUNCTION



#--------------------------#
 FUNCTION pol0769_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0769_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM par_ppte_159
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_par_ppte_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_ppte_159")
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
 FUNCTION pol0769_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_par_ppte_159a.* = p_par_ppte_159.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_ppte_159.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_ppte_159.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_par_ppte_159.* = p_par_ppte_159a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_par_ppte_159.*
           FROM par_ppte_159
          WHERE cod_local = p_par_ppte_159.cod_local 
          AND cod_empresa = p_cod_empresa
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0769_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0769_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_local)
         CALL log009_popup(5,12,"LOCAL","local",
              "cod_local","den_local","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0769
         IF p_codigo IS NOT NULL THEN
           LET p_par_ppte_159.cod_local = p_codigo
           SELECT den_local
              INTO p_den_local
              FROM local
             WHERE cod_local = p_par_ppte_159.cod_local
            
           DISPLAY p_par_ppte_159.cod_local TO cod_local
           DISPLAY p_den_local TO den_local
           
         END IF
       END CASE
     END FUNCTION    
#-------------------------------- FIM DE PROGRAMA -----------------------------#

