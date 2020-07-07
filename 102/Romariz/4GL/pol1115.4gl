#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1115                                                 #
# OBJETIVO: Texto do Resultado                                      #
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
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(100),
          p_cod_cliente  LIKE clientes.cod_cliente,
          p_count        integer

END GLOBALS

 DEFINE mr_tipo_caract  RECORD
    cod_empresa      char(2),
    tip_analise      decimal(6,0),
    val_caracter     decimal(3,0),
    den_caracter     char(45),
    den_caracter_ing char(45),
    den_caracter_esp char(45),
    cod_cliente      CHAR(15)
    
 END RECORD   

 DEFINE mr_tipo_caractr  RECORD
    cod_empresa      char(2),
    tip_analise      decimal(6,0),
    val_caracter     decimal(3,0),
    den_caracter     char(45),
    den_caracter_ing char(45),
    den_caracter_esp char(45)
    
 END RECORD   

 DEFINE mr_caractr  RECORD
    cod_empresa      char(2),
    tip_analise      decimal(6,0),
    val_caracter     decimal(3,0),
    den_caracter     char(45),
    den_caracter_ing char(45),
    den_caracter_esp char(45)
    
 END RECORD   

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1115-10.02.04"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1115.iem") RETURNING p_nom_help
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
      CALL POL1115_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1115_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1115") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1115 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1115","IN") THEN
            CALL POL1115_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_tipo_caract.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1115","MO") THEN
               CALL POL1115_modificacao()
               LET p_ies_cons = TRUE
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_tipo_caract.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1115","EX") THEN
               CALL POL1115_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1115","CO") THEN
            CALL POL1115_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1115_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1115_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1115_sobre()
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
   CLOSE WINDOW w_POL1115

END FUNCTION

#--------------------------#
 FUNCTION POL1115_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF POL1115_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET mr_tipo_caract.cod_empresa = p_cod_empresa
      INSERT INTO tipo_caract_915 VALUES (mr_tipo_caract.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","tipo_caract_915")       
      ELSE
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK 
         MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
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
 FUNCTION POL1115_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30),
   				p_temPadrao SMALLINT
   
   LET p_temPadrao = 0
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1115
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_tipo_caract.* TO NULL
   END IF

   INPUT BY NAME mr_tipo_caract.tip_analise,
                 mr_tipo_caract.cod_cliente,
                 mr_tipo_caract.val_caracter,
                 mr_tipo_caract.den_caracter,
                 mr_tipo_caract.den_caracter_ing,
                 mr_tipo_caract.den_caracter_esp WITHOUT DEFAULTS  

      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_caracter
         END IF

      AFTER FIELD tip_analise  
         IF mr_tipo_caract.tip_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD tip_analise  
         ELSE
            IF POL1115_verifica_tip_analise() = FALSE THEN
               ERROR "Análise não cadastrada ou não marcada para imprimir o texto"
               NEXT FIELD tip_analise
            END IF
         END IF

      BEFORE FIELD cod_cliente
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_caracter
         END IF

      AFTER FIELD cod_cliente
         IF mr_tipo_caract.cod_cliente IS NOT NULL AND
            mr_tipo_caract.cod_cliente <> ' ' THEN
            IF POL1115_verifica_cliente() = FALSE THEN
               ERROR 'Cliente não cadastrado.'
               NEXT FIELD cod_cliente
            END IF 
         END IF  

      BEFORE FIELD val_caracter
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_caracter
         END IF

      AFTER FIELD val_caracter    
         IF mr_tipo_caract.val_caracter IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD val_caracter
         ELSE
            IF POL1115_verifica_val_caracter() THEN
               ERROR "Código já cadastrado."
               NEXT FIELD val_caracter 
            END IF
          SELECT COUNT(*)    
          INTO p_temPadrao                        
           FROM tipo_caract_915 
          WHERE cod_empresa  = p_cod_empresa
           AND tip_analise  = mr_tipo_caract.tip_analise
           AND val_caracter = mr_tipo_caract.val_caracter
           AND cod_cliente  IS NULL
           
           IF p_temPadrao = 0 AND mr_tipo_caract.cod_cliente <> ' ' THEN
           	ERROR "Pecisa ter um padrão cadastrado para este código"
           	NEXT FIELD val_caracter 
           END IF 
         END IF
      
      AFTER FIELD den_caracter    
         IF mr_tipo_caract.den_caracter IS NULL OR 
            mr_tipo_caract.den_caracter = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_caracter
         END IF

      AFTER FIELD den_caracter_ing    
         IF mr_tipo_caract.den_caracter_ing IS NULL OR 
            mr_tipo_caract.den_caracter_ing = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_caracter_ing
         END IF

      AFTER FIELD den_caracter_esp    
         IF mr_tipo_caract.den_caracter_esp IS NULL OR 
            mr_tipo_caract.den_caracter_esp = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_caracter_esp
         END IF

      ON KEY (control-z)
         CALL POL1115_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1115
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
 FUNCTION POL1115_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(tip_analise)
         CALL log009_popup(6,25,"TIPO DE ANALISES","it_analise_915","tip_analise",
                           "den_analise_port","","S"," ies_texto = 'S' ") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1115 
         IF p_codigo IS NOT NULL THEN 
            LET mr_tipo_caract.tip_analise = p_codigo
            DISPLAY p_codigo TO tip_analise
         END IF

         {LET p_codigo = pol1115_sel_analise()
         CURRENT WINDOW IS w_POL1115 

         IF p_codigo IS NOT NULL THEN 
            LET mr_tipo_caract.tip_analise = p_codigo
            DISPLAY p_codigo TO tip_analise
         END IF}
         
   END CASE

    IF infield(cod_cliente) THEN
    	CALL vdp372_popup_cliente() RETURNING mr_tipo_caract.cod_cliente
      CALL log006_exibe_teclas("01 02 03 07", p_versao)
      CURRENT WINDOW IS w_POL1115
      DISPLAY mr_tipo_caract.cod_cliente TO cod_cliente
      CALL POL1115_verifica_cliente() RETURNING p_status 
    END IF


END FUNCTION  

#------------------------------#
FUNCTION pol1115_sel_analise()
#------------------------------#

   DEFINE pr_item          ARRAY[500] OF RECORD
          codigo           char(15),
          descricao        char(50)
   END RECORD
   
   define p_ind            Integer,
          s_ind            Integer,
          p_query          char(500),
          p_where          char(500),
          p_tip_analese    Integer
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11151") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11151 AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
   
   LET p_query = 
      "SELECT tip_analise, den_analise_port",
      "  FROM it_analise_915 ",
      " ORDER BY den_analise_port"

   PREPARE sql_pop FROM p_query   
   DECLARE cq_pop  SCROLL CURSOR WITH HOLD FOR sql_pop

   FOREACH cq_pop INTO
      pr_item[p_ind].codigo,
      pr_item[p_ind].descricao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','it_analise_915:cq_pop')
         EXIT FOREACH
      END IF
      
      let p_tip_analese = pr_item[p_ind].codigo #converte para numérico
      
      select count(ies_texto)
        into p_count
        from especific_915
       where cod_empresa = p_cod_empresa
         and tip_analise = p_tip_analese
         and ies_texto   = 'S'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','especific_915:cq_pop')
         EXIT FOREACH
      END IF
      
      if p_count = 0 then
         CONTINUE FOREACH
      end if 
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Nenhum registro foi encontrado, para os parâmetros informados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_item TO sr_item.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11151
   
   IF NOT INT_FLAG THEN
      RETURN pr_item[p_ind].codigo
   ELSE
      RETURN ""
   END IF
   
END FUNCTION


#--------------------------------------#
 FUNCTION POL1115_verifica_tip_analise()
#--------------------------------------#
    DEFINE l_den_analise_port      LIKE it_analise_915.den_analise_port

    SELECT den_analise_port
      INTO l_den_analise_port
      FROM it_analise_915
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_tipo_caract.tip_analise
       AND ies_texto   = 'S'
    IF sqlca.sqlcode = 0 THEN
       DISPLAY l_den_analise_port TO den_analise_port
       RETURN TRUE
    ELSE
       DISPLAY l_den_analise_port TO den_analise_port
       RETURN FALSE
    END IF

END FUNCTION

#---------------------------------------#
 FUNCTION POL1115_verifica_val_caracter()
#---------------------------------------#
    
    IF mr_tipo_caract.cod_cliente <> '  ' THEN
    	SELECT *
      	FROM tipo_caract_915
    	WHERE cod_empresa  = p_cod_empresa  
       	AND tip_analise  = mr_tipo_caract.tip_analise
       	AND val_caracter = mr_tipo_caract.val_caracter 
       	AND cod_cliente  = mr_tipo_caract.cod_cliente
    ELSE
    	SELECT *
      	FROM tipo_caract_915
     	WHERE cod_empresa  = p_cod_empresa  
       	AND tip_analise  = mr_tipo_caract.tip_analise
       	AND val_caracter = mr_tipo_caract.val_caracter 
    END IF
        
    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1115_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON tipo_caract_915.tip_analise,
                                     tipo_caract_915.val_caracter, 
                                     tipo_caract_915.den_caracter,
                                     tipo_caract_915.den_caracter_ing,
                                     tipo_caract_915.den_caracter_esp,
                                     tipo_caract_915.cod_cliente
	ON KEY (control-z)
      CALL pol1115_popup()
	END CONSTRUCT
                                      

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1115

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_tipo_caract.* = mr_tipo_caractr.*
      CALL POL1115_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM tipo_caract_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY tip_analise, val_caracter "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_tipo_caract.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL POL1115_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION POL1115_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_tipo_caract.*
   
   CALL POL1115_verifica_tip_analise() RETURNING p_status
   CALL pol1115_busca_nom_cliente()
 
END FUNCTION

#-----------------------------------#
 FUNCTION POL1115_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_tipo_caractr.* = mr_tipo_caract.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_tipo_caract.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_tipo_caract.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção."
            LET mr_tipo_caract.* = mr_tipo_caractr.* 
            EXIT WHILE
         END IF
        
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1115_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1115_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
    IF mr_tipo_caract.cod_cliente <> '  ' THEN
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO mr_tipo_caract.*                                              
     FROM tipo_caract_915 
    WHERE cod_empresa  = mr_tipo_caract.cod_empresa
      AND tip_analise  = mr_tipo_caract.tip_analise
      AND val_caracter = mr_tipo_caract.val_caracter
      AND cod_cliente  = mr_tipo_caract.cod_cliente
   FOR UPDATE 
   ELSE
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO mr_tipo_caract.*                                              
     FROM tipo_caract_915 
    WHERE cod_empresa  = mr_tipo_caract.cod_empresa
      AND tip_analise  = mr_tipo_caract.tip_analise
      AND val_caracter = mr_tipo_caract.val_caracter
      AND cod_cliente  IS NULL
   FOR UPDATE 
   END IF    
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
      OTHERWISE CALL log003_err_sql("LEITURA","tipo_caract_915")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION POL1115_modificacao()
#-----------------------------#

   IF POL1115_cursor_for_update() THEN
      LET mr_tipo_caractr.* = mr_tipo_caract.*
      IF POL1115_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE tipo_caract_915
            SET den_caracter = mr_tipo_caract.den_caracter,
            den_caracter_ing = mr_tipo_caract.den_caracter_ing,
            den_caracter_esp = mr_tipo_caract.den_caracter_esp,
            cod_cliente      = mr_tipo_caract.cod_cliente  
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TIPO_CARACT_915")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TIPO_CARACT_915")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_tipo_caract.* = mr_tipo_caractr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         CALL POL1115_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1115_exclusao()
#--------------------------#

   IF POL1115_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM tipo_caract_915 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","TIPO_CARACT_915")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_tipo_caract.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","TIPO_CARACT_915")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#----------------------------------# 
 FUNCTION POL1115_verifica_cliente()
#----------------------------------# 
   DEFINE l_nom_cliente         LIKE clientes.nom_cliente

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_tipo_caract.cod_cliente

   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_nom_cliente TO nom_cliente
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF 

END FUNCTION

#-----------------------------------#
 FUNCTION pol1115_busca_nom_cliente()
#-----------------------------------#
   DEFINE l_nom_cliente  LIKE clientes.nom_cliente 

   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes 
    WHERE cod_cliente = mr_tipo_caract.cod_cliente

   DISPLAY l_nom_cliente TO nom_cliente

END FUNCTION      



#-----------------------#
 FUNCTION POL1115_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#