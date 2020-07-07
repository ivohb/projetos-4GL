##----------------------------------------------------------##
##  pol0790 - CADASTRO MATERIAS DE ACABAMENTO - EDI         ##
##----------------------------------------------------------##
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_msg               CHAR(500), 
         p_last_row          SMALLINT,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_cod_cliente       LIKE clientes.cod_cliente
  DEFINE p_acab_cli_ethos    RECORD LIKE acab_cli_ethos.*,
         p_acab_cli_ethosr   RECORD LIKE acab_cli_ethos.*
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0790-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0790.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0790_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0790_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0790") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0790 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela acab_cli_ethos"
      HELP 001 
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0790","IN") THEN
        CALL pol0790_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela acab_cli_ethos"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_acab_cli_ethos.cod_acabamento IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0790","MO") THEN
               CALL pol0790_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela acab_cli_ethos"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_acab_cli_ethos.cod_acabamento IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0790","EX") THEN
               CALL pol0790_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA acab_cli_ethos"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0790","CO") THEN
           CALL pol0790_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0790_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0790_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0790_sobre()
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
  CLOSE WINDOW w_pol0790
END FUNCTION

#-----------------------#
 FUNCTION pol0790_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------------#
 FUNCTION pol0790_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0790_entrada_dados("INCLUSAO") THEN
      BEGIN WORK
      INSERT INTO acab_cli_ethos VALUES (p_acab_cli_ethos.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","acab_cli_ethos")       
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
 FUNCTION pol0790_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0790
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_acab_cli_ethos.*,
               p_nom_cliente  TO NULL
    LET p_acab_cli_ethos.cod_empresa = p_cod_empresa           
    DISPLAY BY NAME p_acab_cli_ethos.*
    DISPLAY BY NAME p_nom_cliente
  END IF
  
  INPUT   BY NAME p_acab_cli_ethos.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_cliente 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD den_acabamento
      END IF

    AFTER FIELD cod_cliente 
      IF p_acab_cli_ethos.cod_cliente  IS NOT NULL THEN
         LET p_cod_cliente =  p_acab_cli_ethos.cod_cliente
         IF pol0790_verifica_cliente() THEN
            ERROR "Cliente nao cadastrado " 
            NEXT FIELD cod_cliente
         ELSE 
            DISPLAY BY NAME p_nom_cliente
         END IF
      ELSE ERROR "O campo cod_cliente nao pode ser nulo."
           NEXT FIELD cod_cliente
      END IF

    AFTER FIELD cod_acabamento 
      IF p_acab_cli_ethos.cod_acabamento  IS NOT NULL THEN
         IF pol0790_verifica_duplicidade() THEN
         ELSE
            ERROR "Acabamento ja cadastrado para o Cliente" 
            NEXT FIELD cod_cliente 
         END IF  
      ELSE
         ERROR "O campo Acabamento nao pode ser nulo."
         NEXT FIELD cod_acabamento
      END IF

    AFTER FIELD den_acabamento
      IF p_acab_cli_ethos.den_acabamento IS NOT NULL THEN
      ELSE
         ERROR "O campo nao pode ser nulo."
         NEXT FIELD den_acabamento
      END IF

    AFTER FIELD val_acabamento
      IF p_acab_cli_ethos.val_acabamento IS NOT NULL THEN
      ELSE
         LET p_acab_cli_ethos.val_acabamento = 0   
      END IF 

   ON KEY (control-z)
        CALL pol0790_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0790
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0790_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON cod_cliente,
                                   cod_acabamento
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0790
 IF int_flag THEN
   LET int_flag = 0 
   LET p_acab_cli_ethos.* = p_acab_cli_ethosr.*
   CALL pol0790_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM acab_cli_ethos ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_cliente,cod_acabamento "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_acab_cli_ethos.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_cod_cliente = p_acab_cli_ethos.cod_cliente
      IF pol0790_verifica_cliente() THEN
         LET p_nom_cliente = " NAO CADASTRADO"
      END IF

      LET p_ies_cons = TRUE
   END IF
    CALL pol0790_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0790_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_acab_cli_ethos.* 
  DISPLAY BY NAME p_nom_cliente
END FUNCTION

#------------------------------------#
 FUNCTION pol0790_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_acab_cli_ethosr.* = p_acab_cli_ethos.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_acab_cli_ethos.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_acab_cli_ethos.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_acab_cli_ethos.* = p_acab_cli_ethosr.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_acab_cli_ethos.* FROM acab_cli_ethos    
        WHERE cod_empresa    = p_acab_cli_ethos.cod_empresa
          AND cod_cliente    = p_acab_cli_ethos.cod_cliente
          AND cod_acabamento = p_acab_cli_ethos.cod_acabamento
  
        IF sqlca.sqlcode = 0 THEN 
           LET p_cod_cliente = p_acab_cli_ethos.cod_cliente
           IF pol0790_verifica_cliente() THEN
              LET p_nom_cliente = " NAO CADASTRADO"
           END IF
           
           CALL pol0790_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0790_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_acab_cli_ethos.*                                              
     FROM acab_cli_ethos      
    WHERE cod_empresa    = p_acab_cli_ethos.cod_empresa
      AND cod_cliente    = p_acab_cli_ethos.cod_cliente
      AND cod_acabamento = p_acab_cli_ethos.cod_acabamento
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
 FUNCTION pol0790_modificacao()
#----------------------------------#
   IF pol0790_cursor_for_update() THEN
      LET p_acab_cli_ethosr.* = p_acab_cli_ethos.*
      IF pol0790_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE acab_cli_ethos SET  den_acabamento  = p_acab_cli_ethos.den_acabamento,
                                val_acabamento = p_acab_cli_ethos.val_acabamento,
                                den_historico1 = p_acab_cli_ethos.den_historico1,
                                den_historico2 = p_acab_cli_ethos.den_historico2,
                                den_historico3 = p_acab_cli_ethos.den_historico3,
                                den_historico4 = p_acab_cli_ethos.den_historico4,
                                den_historico5 = p_acab_cli_ethos.den_historico5
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
         LET p_acab_cli_ethos.* = p_acab_cli_ethosr.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_acab_cli_ethos.cod_cliente
         LET p_cod_cliente = p_acab_cli_ethos.cod_cliente
         IF pol0790_verifica_cliente() THEN
            LET p_nom_cliente = " NAO CADASTRADO"
         END IF
         CALL pol0790_exibe_dados()            
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0790_exclusao()
#----------------------------------------#
   IF pol0790_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM acab_cli_ethos    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_acab_cli_ethos.* TO NULL
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
 FUNCTION pol0790_verifica_cliente()
#---------------------------------------#
DEFINE p_cont      SMALLINT

SELECT nom_cliente
  INTO p_nom_cliente
  FROM clientes
 WHERE cod_cliente  = p_cod_cliente

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0790_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM acab_cli_ethos
 WHERE cod_cliente    = p_acab_cli_ethos.cod_cliente
   AND cod_empresa    = p_acab_cli_ethos.cod_empresa
   AND cod_acabamento = p_acab_cli_ethos.cod_acabamento 

IF p_cont > 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0790_popup()
#-----------------------#
  DEFINE l_cod_cliente         LIKE clientes.cod_cliente
  CASE
    WHEN infield(cod_cliente)
         CALL log009_popup(6,20,"CLIENTE","clientes",
                          "cod_cliente","nom_cliente",
                          "vdp0050","N","") RETURNING l_cod_cliente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0790 
         IF   l_cod_cliente IS NOT NULL OR
              l_cod_cliente <> " " 
         THEN
              LET p_acab_cli_ethos.cod_cliente  = l_cod_cliente
              DISPLAY BY NAME p_acab_cli_ethos.cod_cliente
         END IF
                 
  END CASE
END FUNCTION
