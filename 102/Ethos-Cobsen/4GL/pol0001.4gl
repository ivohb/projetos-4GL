#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: POL0001                                                 #
# MODULOS.: POL0001 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# DATA....: 20/06/2000                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_msg               CHAR(500)

  DEFINE p_cli_hayward      RECORD LIKE cli_hayward.*,    
         p_cli_haywardr     RECORD LIKE cli_hayward.*,     
         p_clientes          RECORD LIKE clientes.*          
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0001-10.01.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0001.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol001_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol001_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0001") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0001 AT 2,2 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  DISPLAY p_cod_empresa TO cod_empresa
  
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0001","IN") THEN
        CALL pol001_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_cli_hayward.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0001","MO") THEN
               CALL pol001_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_cli_hayward.cod_cliente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0001","EX") THEN
               CALL pol001_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0001","CO") THEN
           CALL pol001_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol001_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol001_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0001_sobre() 
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
  CLOSE WINDOW w_pol0001
END FUNCTION

#-----------------------#
 FUNCTION pol0001_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION     

#--------------------------------------#
 FUNCTION pol001_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
#  CLEAR FORM 
  IF  pol001_entrada_dados("INCLUSAO") THEN
      BEGIN WORK  
      IF p_cli_hayward.set_contato  is  NULL THEN
         LET p_cli_hayward.set_contato = "  " 
      END IF
      IF p_cli_hayward.tel_contato is NULL THEN
         LET p_cli_hayward.tel_contato = "  " 
      END IF
      IF p_cli_hayward.fax_contato is NULL THEN
         LET p_cli_hayward.fax_contato = "  " 
      END IF
      IF p_cli_hayward.email_contato is NULL THEN
         LET p_cli_hayward.email_contato = "  " 
      END IF
      IF p_cli_hayward.obs_contato is NULL THEN
         LET p_cli_hayward.obs_contato = "  " 
      END IF
      LET p_cli_hayward.dat_alter = TODAY      
      LET p_cli_hayward.nom_usuario = p_user           
      INSERT INTO cli_hayward VALUES (p_cli_hayward.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","CLI_HAYWARD")       
      ELSE
          COMMIT WORK 
          MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol001_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0001
  IF p_funcao <> "MODIFICACAO" THEN
    INITIALIZE p_cli_hayward.* TO NULL
    DISPLAY BY NAME p_cli_hayward.*
  END IF
  INPUT   BY NAME p_cli_hayward.* WITHOUT DEFAULTS  


    BEFORE FIELD cod_cliente 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD nom_contato 
      ELSE    
        IF p_funcao = "CONSULTA" THEN
           EXIT INPUT
         END IF
      END IF

    AFTER FIELD cod_cliente 
      IF p_cli_hayward.cod_cliente  IS NOT NULL THEN
         IF pol001_verifica_cliente() THEN
            ERROR "Cliente nao cadastrado" 
            NEXT FIELD cod_cliente  
         ELSE 
            DISPLAY BY NAME p_clientes.nom_cliente 
         END IF
      ELSE ERROR "O campo COD_CLIENTE nao pode ser nulo."
           NEXT FIELD cod_cliente  
      END IF

    AFTER FIELD nom_contato 
      IF p_cli_hayward.nom_contato IS NULL THEN
         ERROR "O campo NOME nao pode ser nulo."
         NEXT FIELD nom_contato     
      END IF 

   ON KEY (control-z)
        CALL pol0001_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0001
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol001_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa

 IF  pol001_entrada_dados("CONSULTA") THEN
 CONSTRUCT BY NAME where_clause ON cli_hayward.cod_cliente
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0001
 IF int_flag THEN
   LET int_flag = 0 
   LET p_cli_hayward.* = p_cli_haywardr.*
   CALL pol001_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM cli_hayward ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_cliente, nom_contato "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_cli_hayward.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol001_verifica_cliente() THEN
         LET p_clientes.nom_cliente=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol001_exibe_dados()
  END IF 
END FUNCTION

#------------------------------#
 FUNCTION pol001_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_cli_hayward.* 
  DISPLAY BY NAME p_clientes.nom_cliente 

END FUNCTION

#------------------------------------#
 FUNCTION pol001_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_cli_haywardr.* = p_cli_hayward.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_cli_hayward.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_cli_hayward.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_cli_hayward.* = p_cli_haywardr.* 
           EXIT WHILE
        END IF
        
        SELECT unique cod_cliente  INTO p_cli_hayward.cod_cliente  
          FROM cli_hayward    
        WHERE cod_cliente = p_cli_hayward.cod_cliente 
          AND nom_contato = p_cli_hayward.nom_contato 
          AND set_contato = p_cli_hayward.set_contato
          AND tel_contato = p_cli_hayward.tel_contato
          AND email_contato = p_cli_hayward.email_contato
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol001_verifica_cliente() THEN
              LET p_clientes.nom_cliente=" NAO CADASTRADO" 
           END IF
           CALL pol001_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION pol001_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_cli_hayward.*                                              
     FROM cli_hayward      
    WHERE cod_cliente = p_cli_hayward.cod_cliente 
      AND nom_contato = p_cli_hayward.nom_contato 
      AND set_contato = p_cli_hayward.set_contato
      AND tel_contato = p_cli_hayward.tel_contato
      AND email_contato = p_cli_hayward.email_contato
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
 FUNCTION pol001_modificacao()
#----------------------------------#
   IF pol001_cursor_for_update() THEN
      LET p_cli_haywardr.* = p_cli_hayward.*
      IF pol001_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE cli_hayward SET nom_contato = p_cli_hayward.nom_contato, 
                                 set_contato = p_cli_hayward.set_contato,   
                                 tel_contato = p_cli_hayward.tel_contato,   
                                 fax_contato = p_cli_hayward.fax_contato,   
                                 email_contato = p_cli_hayward.email_contato, 
                                 obs_contato = p_cli_hayward.obs_contato,   
                                 dat_alter   = TODAY,                      
                                 nom_usuario = p_user                        
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","CLI_HAYWARD")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_cli_hayward.* = p_cli_haywardr.*
         ERROR "Modificacao Cancelada"
         ROLLBACK WORK
         DISPLAY BY NAME p_cli_hayward.cod_cliente 
         DISPLAY BY NAME p_nom_cliente                
         DISPLAY BY NAME p_cli_hayward.set_contato 
         DISPLAY BY NAME p_cli_hayward.tel_contato 
         DISPLAY BY NAME p_cli_hayward.fax_contato 
         DISPLAY BY NAME p_cli_hayward.email_contato 
         DISPLAY BY NAME p_cli_hayward.obs_contato 
         DISPLAY BY NAME p_cli_hayward.dat_alter   
         DISPLAY BY NAME p_cli_hayward.nom_usuario 
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol001_exclusao()
#----------------------------------------#
   IF pol001_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM cli_hayward    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","CLI_HAYWARD")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_cli_hayward.* TO NULL
                CLEAR FORM
                DISPLAY p_cod_empresa TO cod_empresa
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

#------------------------------------#
 FUNCTION pol001_verifica_cliente()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT nom_cliente
  INTO p_clientes.nom_cliente
  FROM clientes               
 WHERE cod_cliente  = p_cli_hayward.cod_cliente

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 


#-----------------------#
 FUNCTION pol0001_popup()
#-----------------------#
  
  DEFINE p_cod_cliente        LIKE clientes.cod_cliente
  
  CASE
    WHEN infield(cod_cliente)
         LET  p_cod_cliente = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0001   
         IF   p_cod_cliente IS NOT NULL THEN 
              LET  p_cli_hayward.cod_cliente = p_cod_cliente
              DISPLAY p_cli_hayward.cod_cliente TO cod_cliente
         END IF
  END CASE
  
END FUNCTION
