#-------------------------------------------------------------------#
# PROGRAMA: pol0770                                                 #
# MODULOS.: pol0770-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CLIENTES PARA BLOQUEIO DE ROMANEIO                      #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 03/07/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_cliente        LIKE par_cliente_159.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_msg                CHAR(300),
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
          sr_index             SMALLINT
          
   DEFINE p_par_cliente_159   RECORD LIKE par_cliente_159.*,
          p_par_cliente_159a  RECORD LIKE par_cliente_159.* 
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0770-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0770.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0770_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0770_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0770") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0770 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0770_inclusao() THEN
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
            IF pol0770_modificacao() THEN
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
            IF pol0770_exclusao() THEN
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
         CALL pol0770_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0770_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0770_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0770_sobre() 
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
   CLOSE WINDOW w_pol0770

END FUNCTION

#-----------------------#
FUNCTION pol0770_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0770_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_par_cliente_159.* TO NULL
   INITIALIZE p_nom_cliente TO NULL
   LET p_par_cliente_159.cod_empresa = p_cod_empresa

   IF pol0770_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO par_cliente_159 VALUES (p_par_cliente_159.*)
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
 FUNCTION pol0770_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0770

   INPUT BY NAME p_par_cliente_159.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_cliente
        IF p_funcao = "MODIFICACAO" THEN
           NEXT FIELD ies_verifica_etiq
        END IF 
      
       LET p_par_cliente_159.ies_verifica_etiq = 'N'

       AFTER FIELD cod_cliente
      IF p_par_cliente_159.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
         INTO p_nom_cliente
         FROM clientes
        WHERE cod_cliente = p_par_cliente_159.cod_cliente
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "clientes Inexistente !!!" 
            CLEAR FORM
            NEXT FIELD cod_cliente
         END IF
        
                            
           SELECT cod_cliente
           FROM par_cliente_159
          WHERE cod_empresa = p_cod_empresa
            AND cod_cliente = p_par_cliente_159.cod_cliente
            
          
         IF SQLCA.sqlcode = 0 THEN
            ERROR "Cliente Já Cadastrado !!!"
            CLEAR FORM 
            NEXT FIELD cod_cliente
         END IF 
          
         DISPLAY p_nom_cliente TO nom_cliente
         NEXT FIELD ies_verifica_etiq
      END IF
         
           AFTER FIELD ies_verifica_etiq
           
        IF p_par_cliente_159.ies_verifica_etiq IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD ies_verifica_etiq
        END IF  
        
        IF p_par_cliente_159.ies_verifica_item IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD ies_verifica_item
        END IF 

      ON KEY (control-z)
         CALL pol0770_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0770

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0770_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_cliente_159a.* = p_par_cliente_159.*

   CONSTRUCT BY NAME where_clause ON par_cliente_159.cod_cliente
  
        ON KEY (control-z)
         CALL pol0770_popup()
     
            {      LET p_cod_cliente = pol0770_carrega_clientes() 
               DISPLAY p_nom_cliente TO nom_cliente
            IF p_cod_cliente IS NOT NULL THEN
               LET p_par_cliente_159.cod_cliente = p_cod_cliente CLIPPED
               CURRENT WINDOW IS w_pol0770
               DISPLAY p_par_cliente_159.cod_cliente TO cod_cliente
               DISPLAY p_nom_cliente TO nom_cliente
            END IF}
     
  
  END CONSTRUCT  
  
   CALL log006_exibe_teclas("01",p_versao)

   CURRENT WINDOW IS w_pol0770

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_par_cliente_159.* = p_par_cliente_159a.*
      CALL pol0770_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM par_cliente_159 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_cliente_159.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0770_exibe_dados()
   END IF

END FUNCTION


#----------------------------------#   
 FUNCTION pol0770_carrega_clientes() 
#----------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_cliente        LIKE par_cliente_159.cod_cliente,
         nom_cliente        LIKE clientes.nom_cliente
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07701") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07701 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_cliente
        FROM par_cliente_159
        ORDER BY cod_cliente

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_cliente 
                         
        SELECT nom_cliente
        INTO pr_empresa[pr_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = pr_empresa[pr_index].cod_cliente

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
      
   CLOSE WINDOW w_pol0770
  
   RETURN pr_empresa[pr_index].cod_cliente
      
END FUNCTION 


#------------------------------#
 FUNCTION pol0770_exibe_dados()
#------------------------------#
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_par_cliente_159.cod_cliente

   DISPLAY BY NAME p_par_cliente_159.*
   DISPLAY p_nom_cliente TO nom_cliente
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0770_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE

   SELECT * 
     FROM par_cliente_159
     WHERE cod_empresa = p_cod_empresa 
       AND cod_cliente = p_par_cliente_159.cod_cliente
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_cliente_159")   
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------#
 FUNCTION pol0770_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0770_cursor_for_update() THEN
      LET p_par_cliente_159a.* = p_par_cliente_159.*
      IF pol0770_entrada_dados("MODIFICACAO") THEN
         UPDATE par_cliente_159
            SET ies_verifica_etiq = p_par_cliente_159.ies_verifica_etiq,
                ies_verifica_item = p_par_cliente_159.ies_verifica_item
              WHERE cod_empresa = p_cod_empresa
                AND cod_cliente = p_par_cliente_159.cod_cliente
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","par_cliente_159")
         END IF
      ELSE
         LET p_par_cliente_159.* = p_par_cliente_159a.*
         CALL pol0770_exibe_dados()
      END IF
    #  CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 


#--------------------------#
 FUNCTION pol0770_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0770_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM par_cliente_159
          WHERE cod_empresa = p_cod_empresa 
            AND cod_cliente = p_par_cliente_159.cod_cliente
         
         IF STATUS = 0 THEN
            INITIALIZE p_par_cliente_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_cliente_159")
         END IF
      END IF
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0770_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_par_cliente_159a.* = p_par_cliente_159.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_cliente_159.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_cliente_159.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_par_cliente_159.* = p_par_cliente_159a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_par_cliente_159.*
           FROM par_cliente_159
           WHERE cod_empresa    = p_cod_empresa 
             AND cod_cliente = p_par_cliente_159.cod_cliente
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0770_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0770_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao) 
             # RETURNING p_codigo
        
         CURRENT WINDOW IS w_pol0770
         IF p_codigo IS NOT NULL THEN
           LET p_par_cliente_159.cod_cliente = p_codigo
           DISPLAY p_par_cliente_159.cod_cliente TO cod_cliente
         END IF
END CASE
END FUNCTION 

#-------------------------------- FIM DE PROGRAMA -----------------------------#

