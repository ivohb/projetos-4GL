#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0318                                                 #
# MODULOS.: POL0318 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA GM_POLIMETRI                       #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 11/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa LIKE empresa.cod_empresa,
          p_den_empresa LIKE empresa.den_empresa,  
          p_user        LIKE usuario.nom_usuario,
          p_nom_cliente LIKE clientes.nom_cliente,
          p_status      SMALLINT,
          p_houve_erro  SMALLINT,
          comando       CHAR(80),
          p_versao      CHAR(17),
      #   p_versao      CHAR(18),
          p_nom_tela    CHAR(080),
          p_nom_help    CHAR(200),
          p_ies_cons    SMALLINT,
          p_last_row    SMALLINT,
          p_msg         CHAR(500)

   DEFINE p_gm_polimetri  RECORD LIKE gm_polimetri.*,
          p_gm_polimetrii RECORD LIKE gm_polimetri.*
END GLOBALS

MAIN
# CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0318-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0318.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
 CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0318_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0318_controle()
#--------------------------#

  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0318") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0318 AT 2,2 WITH FORM p_nom_tela 
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0318","IN") THEN
        CALL pol0318_inclusao() RETURNING p_status
      END IF
    COMMAND "Excluir" "Exclui dados da tabela"
      HELP 003
      MESSAGE ""
      LET int_flag = 0
      IF  p_gm_polimetri.cod_empresa IS NOT NULL THEN
          IF  log005_seguranca(p_user,"VDP","pol0318","EX") THEN
              CALL pol0318_exclusao()
          END IF
      ELSE
          ERROR " Consulte Previamente para fazer a Exclusao"
      END IF 
    COMMAND "Consultar" "Consulta dados da tabela"
      HELP 004
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0318","CO") THEN
          CALL pol0318_consulta()
          IF p_ies_cons = TRUE THEN
             NEXT OPTION "Seguinte"
          END IF
      END IF
    COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
      HELP 005
      MESSAGE ""
      LET int_flag = 0
      CALL pol0318_paginacao("SEGUINTE")
    COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
      HELP 006
      MESSAGE ""
      LET int_flag = 0
      CALL pol0318_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0318_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0318

END FUNCTION

#--------------------------------------#
 FUNCTION pol0318_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  CLEAR FORM
  IF pol0318_entrada_dados() THEN
  #  CALL log085_transacao("BEGIN")
     BEGIN WORK
     LET p_gm_polimetri.cod_empresa = p_cod_empresa
     INSERT INTO gm_polimetri VALUES (p_gm_polimetri.*)
     IF sqlca.sqlcode <> 0 THEN 
     #  CALL log085_transacao("ROLLBACK")
        ROLLBACK WORK 
	LET p_houve_erro = TRUE
	CALL log003_err_sql("INCLUSAO","GM_POLIMETRI")
     ELSE
     #  CALL log085_transacao("COMMIT")
        COMMIT WORK 
        MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
        LET p_ies_cons = FALSE
     END IF
  ELSE
     CLEAR FORM
     ERROR " Inclusao Cancelada"
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0318_entrada_dados()
#-------------------------------#

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0318
  INITIALIZE p_gm_polimetri.*, p_nom_cliente TO NULL
  DISPLAY BY NAME p_gm_polimetri.*
  DISPLAY p_nom_cliente TO nom_cliente 
  DISPLAY p_cod_empresa TO cod_empresa 

  INPUT BY NAME p_gm_polimetri.cod_cliente 
    WITHOUT DEFAULTS  

    AFTER FIELD cod_cliente
      IF p_gm_polimetri.cod_cliente IS NULL THEN
         ERROR "O Campo Cod Cliente nao pode ser Nulo"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
            INTO p_nom_cliente
         FROM clientes
         WHERE cod_cliente = p_gm_polimetri.cod_cliente 
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente
         END IF
         IF pol0318_verifica_dupl() THEN
            ERROR "Cliente Já Cadastrado"
            NEXT FIELD cod_cliente
         END IF
         DISPLAY p_nom_cliente TO nom_cliente
      END IF

      ON KEY (control-z)
         IF INFIELD(cod_cliente) THEN
            LET p_gm_polimetri.cod_cliente = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0318 
            IF p_gm_polimetri.cod_cliente IS NOT NULL THEN 
               DISPLAY BY NAME p_gm_polimetri.cod_cliente 
            END IF
         END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0318
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0318_consulta()
#--------------------------#

 DEFINE sql_stmt, 
        where_clause  CHAR(300)  
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa 

 CONSTRUCT BY NAME where_clause ON gm_polimetri.cod_cliente  

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0318
 IF INT_FLAG THEN
   LET INT_FLAG = 0 
   LET p_gm_polimetri.* = p_gm_polimetrii.*
   CALL pol0318_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM gm_polimetri ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_cliente "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_gm_polimetri.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0318_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0318_exibe_dados()
#-----------------------------#

   SELECT nom_cliente
      INTO p_nom_cliente
   FROM clientes
   WHERE cod_cliente = p_gm_polimetri.cod_cliente 

   DISPLAY BY NAME p_gm_polimetri.cod_cliente
   DISPLAY p_nom_cliente TO nom_cliente

END FUNCTION

#-----------------------------------#
 FUNCTION pol0318_paginacao(p_funcao)
#-----------------------------------#

  DEFINE p_funcao CHAR(20)

  IF p_ies_cons THEN
     LET p_gm_polimetrii.* = p_gm_polimetri.*
     WHILE TRUE
        CASE
           WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_gm_polimetri.*
           WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_gm_polimetri.*
        END CASE
     
        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR "Nao Existem mais Registros nesta Direcao"
           LET p_gm_polimetri.* = p_gm_polimetrii.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_gm_polimetri.* FROM gm_polimetri    
        WHERE cod_empresa = p_gm_polimetri.cod_empresa 
          AND cod_cliente = p_gm_polimetri.cod_cliente 
  
        IF SQLCA.SQLCODE = 0 THEN 
           CALL pol0318_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao Existe Nenhuma Consulta Ativa"
  END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0318_cursor_for_update()
#-----------------------------------#

  WHENEVER ERROR CONTINUE
  DECLARE cm_padrao CURSOR WITH HOLD FOR
  SELECT *                            
    INTO p_gm_polimetri.*                                              
  FROM gm_polimetri      
  WHERE cod_empresa = p_gm_polimetri.cod_empresa 
    AND cod_cliente = p_gm_polimetri.cod_cliente 
  FOR UPDATE 
# CALL log085_transacao("BEGIN")
  BEGIN WORK
  OPEN cm_padrao
  FETCH cm_padrao
  CASE SQLCA.SQLCODE
     WHEN    0 RETURN TRUE 
     WHEN -250 ERROR " Registro sendo Atualizado por outro Usua",
                     "rio. Aguarde e tente Novamente"
     WHEN  100 ERROR " Registro nao mais Existe na Tabela. Exec",
                      "ute a Consulta Novamente"
     OTHERWISE CALL log003_err_sql("LEITURA","GM_POLIMETRI")
  END CASE
  WHENEVER ERROR STOP

  RETURN FALSE

END FUNCTION

#--------------------------#
 FUNCTION pol0318_exclusao()
#--------------------------#

   IF pol0318_cursor_for_update() THEN
      IF log004_confirm(11,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM gm_polimetri    
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
         #  CALL log085_transacao("COMMIT")
            COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","GM_POLIMETRI")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_gm_polimetri.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","GM_POLIMETRI")
         #  CALL log085_transacao("ROLLBACK")
            ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-------------------------------#
 FUNCTION pol0318_verifica_dupl()
#-------------------------------#

   SELECT *
   FROM gm_polimetri
   WHERE cod_empresa = p_cod_empresa
     AND cod_cliente = p_gm_polimetri.cod_cliente
   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0318_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
