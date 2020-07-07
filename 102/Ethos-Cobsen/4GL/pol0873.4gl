#BI

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_msg               CHAR(500)
         
  DEFINE p_item_kanban_547   RECORD LIKE item_kanban_547.*,    
         p_item_kanban_547r  RECORD LIKE item_kanban_547.*,     
         p_item              RECORD LIKE item.*      
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0873-10.02.03"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0873.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0873_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0873_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0873") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0873 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0873","IN") THEN
        CALL pol0873_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_item_kanban_547.cod_item_cliente IS NOT NULL THEN
           CALL pol0873_modificacao()
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_item_kanban_547.cod_item_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0873","EX") THEN
               CALL pol0873_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       CALL pol0873_consulta()
       IF p_ies_cons = TRUE THEN
          NEXT OPTION "Seguinte"
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0873_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0873_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0873_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0873
END FUNCTION

#--------------------------------------#
 FUNCTION pol0873_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0873_entrada_dados("INCLUSAO") THEN
      LET p_item_kanban_547.cod_empresa = p_cod_empresa
      CALL log085_transacao("BEGIN")
      INSERT INTO item_kanban_547 VALUES (p_item_kanban_547.*)
      IF sqlca.sqlcode <> 0 THEN 
	       LET p_houve_erro = TRUE
	       CALL log085_transacao("ROLLBACK")
	       CALL log003_err_sql("INCLUSAO","item_kanban_547")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol0873_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_item_kanban_547.* TO NULL
    DISPLAY BY NAME p_item_kanban_547.*
  END IF

  INPUT   BY NAME p_item_kanban_547.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_item 
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD dat_inicio
      ELSE
         LET p_item_kanban_547.cod_empresa = p_cod_empresa
         LET p_item_kanban_547.dat_inicio = TODAY 
         LET p_item_kanban_547.dat_termino = '31/12/2999'	
         DISPLAY BY NAME p_item_kanban_547.dat_inicio
         DISPLAY BY NAME p_item_kanban_547.dat_termino
      END IF

    AFTER FIELD cod_item 
      IF p_item_kanban_547.cod_item  IS NOT NULL THEN
         IF pol0873_verifica_item() THEN
            ERROR "Item nao cadastrado" 
            NEXT FIELD cod_item 
         ELSE 
            DISPLAY BY NAME p_item.den_item
         END IF
      ELSE ERROR "O campo cod_item  nao pode ser nulo."
           NEXT FIELD cod_item  
      END IF

    BEFORE FIELD cod_item_cliente 
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD dat_inicio
      END IF

    AFTER FIELD cod_item_cliente
         IF not pol0873_verifica_item_cli() THEN
            ERROR "Item nao cadastrado para Cliente" 
            NEXT FIELD cod_item_cliente
         END IF

      IF pol0873_verifica_duplicidade(1) THEN
      ELSE
         ERROR "Item ja cadastrado para o periodo informado" 
         NEXT FIELD cod_item_cliente  
      END IF  
         
    AFTER FIELD dat_inicio
      IF p_item_kanban_547.dat_inicio IS NOT NULL THEN
      ELSE
         LET p_item_kanban_547.dat_inicio = TODAY   
      END IF 

    AFTER FIELD dat_termino
      IF p_item_kanban_547.dat_termino IS NOT NULL THEN
      ELSE
         LET p_item_kanban_547.dat_termino = '31/12/2999'               
      END IF

      IF p_item_kanban_547.dat_termino < p_item_kanban_547.dat_inicio THEN
         ERROR "Data deve ser maior ou igual a data inicio" 
         NEXT FIELD dat_inicio  
      END IF
  
    AFTER FIELD tipo_item
       IF p_item_kanban_547.tipo_item IS NULL THEN
          ERROR 'Campo com preenchimento obrigatório!'
          NEXT FIELD tipo_item
       END IF

    AFTER FIELD qtd_dias
       IF p_item_kanban_547.qtd_dias IS NULL THEN
          ERROR 'Campo com preenchimento obrigatório!'
          NEXT FIELD qtd_dias
       END IF
          
  
   ON KEY (control-z)
        CALL pol0873_popup()

 END INPUT 

  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0873_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 let INT_FLAG = false

 CONSTRUCT BY NAME where_clause ON item_kanban_547.cod_item,
                                   item_kanban_547.cod_item_cliente                                  
 
 IF int_flag THEN
   LET int_flag = 0 
   LET p_item_kanban_547.* = p_item_kanban_547r.*
   CALL pol0873_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM item_kanban_547 ",
                " WHERE ", where_clause CLIPPED,  
                "   AND cod_empresa = '",p_cod_empresa,"' ",               
                " ORDER BY cod_item "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao_1 SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao_1
 FETCH cq_padrao_1 INTO p_item_kanban_547.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0873_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
   
    CALL pol0873_exibe_dados()
    
END FUNCTION

#------------------------------#
 FUNCTION pol0873_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_item_kanban_547.* 
  DISPLAY BY NAME p_item.den_item

END FUNCTION

#------------------------------------#
 FUNCTION pol0873_paginacao(p_funcao)
#------------------------------------#
 
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_item_kanban_547r.* = p_item_kanban_547.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao_1 INTO p_item_kanban_547.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao_1 INTO p_item_kanban_547.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_item_kanban_547.* = p_item_kanban_547r.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_item_kanban_547.* FROM item_kanban_547    
        WHERE cod_item_cliente = p_item_kanban_547.cod_item_cliente
          AND cod_empresa = p_cod_empresa
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0873_verifica_item() THEN
              LET p_item.den_item=" NAO CADASTRADO" 
           END IF
           CALL pol0873_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0873_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE

 CALL log085_transacao("BEGIN")

 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_item_kanban_547.*                                              
     FROM item_kanban_547      
    WHERE cod_item_cliente = p_item_kanban_547.cod_item_cliente
      AND cod_empresa = p_cod_empresa
 FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   CASE sqlca.sqlcode
     
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","TABELA")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION

#----------------------------------#
 FUNCTION pol0873_modificacao()
#----------------------------------#

   IF pol0873_cursor_for_update() THEN
      LET p_item_kanban_547r.* = p_item_kanban_547.*
      IF pol0873_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE item_kanban_547 
            SET dat_inicio  = p_item_kanban_547.dat_inicio,
                dat_termino = p_item_kanban_547.dat_termino,
                tipo_item   = p_item_kanban_547.tipo_item,
                qtd_dias    = p_item_kanban_547.qtd_dias
          WHERE CURRENT OF cm_padrao
          
         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET p_item_kanban_547.* = p_item_kanban_547r.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_item_kanban_547.cod_item_cliente 
         IF pol0873_verifica_item() THEN 
            LET p_item.den_item=" NAO CADASTRADO" 
         END IF
         DISPLAY BY NAME p_item.den_item              
         DISPLAY BY NAME p_item_kanban_547.dat_inicio
         DISPLAY BY NAME p_item_kanban_547.dat_termino
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0873_exclusao()
#----------------------------------------#
   IF pol0873_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_kanban_547    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_item_kanban_547.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             CALL log085_transacao("ROLLBACK")
          END IF
          WHENEVER ERROR STOP
       ELSE
          CALL log085_transacao("ROLLBACK")
       END IF
       CLOSE cm_padrao
   END IF
 END FUNCTION  

#---------------------------------------#
 FUNCTION pol0873_verifica_item()
#---------------------------------------#
DEFINE p_cont      SMALLINT

SELECT den_item
  INTO p_item.den_item
  FROM item               
 WHERE cod_item    = p_item_kanban_547.cod_item
   AND cod_empresa = p_cod_empresa

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#---------------------------------------#
 FUNCTION pol0873_verifica_item_cli()
#---------------------------------------#
DEFINE l_count    INTEGER

SELECT count(*)  
  INTO l_count
  FROM cliente_item
 WHERE cod_empresa = p_cod_empresa 
   AND cod_item_cliente =  p_item_kanban_547.cod_item_cliente
   AND cod_item = p_item_kanban_547.cod_item

IF sqlca.sqlcode > 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#-------------------------------------------#
 FUNCTION pol0873_verifica_duplicidade(l_ind)
#-------------------------------------------#
DEFINE p_cont      SMALLINT,
       l_ind       SMALLINT

IF l_ind = 1 THEN 
   SELECT COUNT(*) 
     INTO p_cont
     FROM item_kanban_547
    WHERE cod_item_cliente  = p_item_kanban_547.cod_item_cliente
      AND dat_termino       >= p_item_kanban_547.dat_inicio
      AND cod_empresa = p_cod_empresa
   
   IF p_cont > 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
ELSE
   SELECT COUNT(*) 
     INTO p_cont
     FROM item_kanban_547
    WHERE cod_item_cliente = p_item_kanban_547.cod_item_cliente
      AND dat_inicio       >= p_item_kanban_547.dat_inicio
      AND dat_inicio       <= p_item_kanban_547.dat_termino
      AND cod_empresa = p_cod_empresa
   
   IF p_cont > 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF

END IF 
END FUNCTION   

#-----------------------#
 FUNCTION pol0873_popup()
#-----------------------#
  DEFINE p_cod_item_cliente   LIKE item_kanban_547.cod_item_cliente,
         p_cod_item           LIKE item_kanban_547.cod_item
  
  CASE
    WHEN infield(cod_item_cliente)
         CALL log009_popup(6,25,"PRODUTO","cliente_item",
                          "cod_item_cliente","cod_item",
                          "vdp0050","N","") RETURNING p_cod_item_cliente 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0873 
         IF   p_cod_item_cliente IS NOT NULL OR
              p_cod_item_cliente <> " " 
         THEN
              LET p_item_kanban_547.cod_item_cliente  = p_cod_item_cliente
              DISPLAY BY NAME p_item_kanban_547.cod_item_cliente
         END IF

    WHEN infield(cod_item)
         LET p_cod_item   = vdp373_popup_item(p_cod_empresa) 
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_cod_item IS NOT NULL THEN
              LET p_item_kanban_547.cod_item  = p_cod_item
              DISPLAY BY NAME p_item_kanban_547.cod_item
         END IF 
  END CASE
END FUNCTION

#-----------------------#
 FUNCTION pol0873_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION