DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_msg               char(300),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT
  DEFINE p_qtd_padrao_546    RECORD LIKE qtd_padrao_546.*,    
         p_qtd_padrao_546r   RECORD LIKE qtd_padrao_546.*,     
         p_item              RECORD LIKE item.*      
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0866-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0866.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0866_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0866_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0866") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0866 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui qtdes padroes"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0866","IN") THEN
        CALL pol0866_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica qtdes padroes"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_qtd_padrao_546.cod_item_barra_dig IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0866","MO") THEN
               CALL pol0866_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui qtdes padroes"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_qtd_padrao_546.cod_item_barra_dig IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0866","EX") THEN
               CALL pol0866_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da qtdes padroes"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0866","CO") THEN
           CALL pol0866_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0866_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0866_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0866_sobre() 
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
  CLOSE WINDOW w_pol0866
END FUNCTION

#-----------------------#
FUNCTION pol0866_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------------#
 FUNCTION pol0866_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0866_entrada_dados("INCLUSAO") THEN
      BEGIN WORK
      INSERT INTO qtd_padrao_546 VALUES (p_qtd_padrao_546.*)
      IF sqlca.sqlcode <> 0 THEN 
	       LET p_houve_erro = TRUE
	       ROLLBACK WORK 
	       CALL log003_err_sql("INCLUSAO","qtd_padrao_546")       
      ELSE
         COMMIT WORK 
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
 FUNCTION pol0866_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0866
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_qtd_padrao_546.* TO NULL
    INITIALIZE p_item.* TO NULL
    LET p_qtd_padrao_546.cod_empresa = p_cod_empresa
    DISPLAY p_item.cod_item TO cod_item
    DISPLAY p_item.den_item TO den_item
    DISPLAY BY NAME p_qtd_padrao_546.*
  END IF
  
   INPUT p_item.cod_item,
         p_qtd_padrao_546.cod_dap,
         p_qtd_padrao_546.qtd_embal
   WITHOUT DEFAULTS  
    FROM cod_item,
         cod_dap,
         qtd_embal  

    BEFORE FIELD cod_item  
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD qtd_embal	
      END IF

    AFTER FIELD cod_item  
      IF p_item.cod_item  IS NOT NULL THEN
         IF pol0866_verifica_item() THEN
            ERROR "Item nao cadastrado" 
            NEXT FIELD cod_item  
         ELSE 
            DISPLAY p_item.den_item TO den_item
            DISPLAY BY NAME p_qtd_padrao_546.cod_item_barra_dig
         END IF
         IF pol0866_verifica_duplicidade() THEN
         ELSE
            ERROR "Item ja cadastrado" 
            NEXT FIELD cod_item  
         END IF  
      ELSE ERROR "O campo cod_item nao pode ser nulo."
           NEXT FIELD cod_item  
      END IF

    AFTER FIELD qtd_embal
      IF p_qtd_padrao_546.qtd_embal IS NULL OR  
         p_qtd_padrao_546.qtd_embal = 0   THEN 
            ERROR "Quantidade invalida" 
            NEXT FIELD qtd_embal
      END IF 

   ON KEY (control-z)
        CALL pol0866_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0866
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0866_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON b.cod_item, a.cod_item_barra_dig, a.qtd_embal
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0866
 IF int_flag THEN
   LET int_flag = 0 
   LET p_qtd_padrao_546.* = p_qtd_padrao_546r.*
   CALL pol0866_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT a.*,b.cod_item FROM qtd_padrao_546 a, ",
                 "item b, item_barra c ",
                " WHERE b.cod_empresa = c.cod_empresa ",
                "AND b.cod_item = c.cod_item ",
                "AND a.cod_empresa = c.cod_empresa ",
                "AND a.cod_item_barra_dig = c.cod_item_barra_dig and ", where_clause CLIPPED,                 
                " ORDER BY a.cod_item_barra_dig "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_qtd_padrao_546.*,p_item.cod_item 
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0866_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0866_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0866_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_qtd_padrao_546.cod_item_barra_dig
  DISPLAY BY NAME p_qtd_padrao_546.cod_dap
  DISPLAY BY NAME p_qtd_padrao_546.qtd_embal
  DISPLAY p_item.cod_item TO cod_item
  DISPLAY p_item.den_item TO den_item

END FUNCTION

#------------------------------------#
 FUNCTION pol0866_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_qtd_padrao_546r.* = p_qtd_padrao_546.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_qtd_padrao_546.*,p_item.cod_item 
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_qtd_padrao_546.*,p_item.cod_item 
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_qtd_padrao_546.* = p_qtd_padrao_546r.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_qtd_padrao_546.* FROM qtd_padrao_546    
        WHERE cod_item_barra_dig = p_qtd_padrao_546.cod_item_barra_dig
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0866_verifica_item() THEN
              LET p_item.den_item=" NAO CADASTRADO" 
           END IF
           CALL pol0866_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0866_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_qtd_padrao_546.*                                              
     FROM qtd_padrao_546      
    WHERE cod_item_barra_dig = p_qtd_padrao_546.cod_item_barra_dig
 FOR UPDATE 
   BEGIN WORK
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
 FUNCTION pol0866_modificacao()
#----------------------------------#
   IF pol0866_cursor_for_update() THEN
      LET p_qtd_padrao_546r.* = p_qtd_padrao_546.*
      IF pol0866_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE qtd_padrao_546 SET qtd_embal = p_qtd_padrao_546.qtd_embal,
                                   cod_dap   = p_qtd_padrao_546.cod_dap
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_qtd_padrao_546.* = p_qtd_padrao_546r.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_qtd_padrao_546.cod_item_barra_dig 
         IF pol0866_verifica_item() THEN 
            LET p_item.den_item=" NAO CADASTRADO" 
         END IF
         DISPLAY BY NAME p_item.den_item               
         DISPLAY BY NAME p_item.cod_item               
         DISPLAY BY NAME p_qtd_padrao_546.cod_item_barra_dig
         DISPLAY BY NAME p_qtd_padrao_546.cod_dap
         DISPLAY BY NAME p_qtd_padrao_546.qtd_embal
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0866_exclusao()
#----------------------------------------#
   IF pol0866_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM qtd_padrao_546    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_qtd_padrao_546.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             ROLLBACK WORK
          END IF
          WHENEVER ERROR STOP
       ELSE
          ROLLBACK WORK
       END IF
       CLOSE cm_padrao
   END IF
 END FUNCTION  

#---------------------------------------#
 FUNCTION pol0866_verifica_item()
#---------------------------------------#
DEFINE p_cont      SMALLINT

SELECT den_item, 
       cod_item_barra_dig 
  INTO p_item.den_item, 
       p_qtd_padrao_546.cod_item_barra_dig 
  FROM item a, item_barra b          
 WHERE a.cod_item    = p_item.cod_item 
   AND a.cod_empresa = p_cod_empresa  
   AND a.cod_empresa = b.cod_empresa 
   AND a.cod_item    = b.cod_item 

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0866_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM qtd_padrao_546
 WHERE cod_item_barra_dig  = p_qtd_padrao_546.cod_item_barra_dig

IF p_cont > 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE 
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0866_popup()
#-----------------------#
  DEFINE p_cod_item   LIKE item.cod_item
  
   CASE
      WHEN INFIELD(cod_item)
         LET p_cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0866
         IF p_cod_item IS NOT NULL THEN
           LET p_item.cod_item = p_cod_item
           DISPLAY p_item.cod_item TO cod_item
         END IF
   END CASE
END FUNCTION
