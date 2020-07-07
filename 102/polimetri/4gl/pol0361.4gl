#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0361                                                 #
# MODULOS.: POL0361 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA PORT_DES_POLIMETRI                 #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 30/08/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
      #   p_versao       CHAR(17),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(500)

   DEFINE p_tela RECORD 
      nom_portador    LIKE portador.nom_portador
   END RECORD 

   DEFINE p_port_des_polimetri  RECORD LIKE port_des_polimetri.*,
          p_port_des_polimetrii RECORD LIKE port_des_polimetri.*
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0361-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0361.iem") RETURNING p_nom_help
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
      CALL pol0361_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0361_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0361") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0361 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0361","IN") THEN
            CALL pol0361_inclusao() RETURNING p_status
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_port_des_polimetri.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0361","EX") THEN
               CALL pol0361_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0361","CO") THEN
            CALL pol0361_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0361_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0361_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0361_sobre()
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
   CLOSE WINDOW w_pol0361

END FUNCTION

#--------------------------#
 FUNCTION pol0361_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0361_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET p_port_des_polimetri.cod_empresa = p_cod_empresa
      INSERT INTO port_des_polimetri VALUES (p_port_des_polimetri.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","PORT_DES_POLIMETRI")       
      ELSE
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK 
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
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
 FUNCTION pol0361_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0361
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_port_des_polimetri.*, 
                 p_tela.* TO NULL
   END IF

   INPUT BY NAME p_port_des_polimetri.cod_portador,   
                 p_port_des_polimetri.ies_tip_portador
      WITHOUT DEFAULTS  

      AFTER FIELD cod_portador
      IF p_port_des_polimetri.cod_portador IS NULL THEN
         ERROR "O Campo Cod Portador nao pode ser Nulo"
         NEXT FIELD cod_portador
      ELSE
         SELECT nom_portador
            INTO p_tela.nom_portador
         FROM portador
         WHERE cod_portador = p_port_des_polimetri.cod_portador
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Portador nao Cadastrado"
            NEXT FIELD cod_portador 
         END IF
         DISPLAY BY NAME p_tela.nom_portador 
      END IF

      AFTER FIELD ies_tip_portador
      IF p_port_des_polimetri.ies_tip_portador IS NULL THEN
         ERROR "O Campo Tipo do Portador nao pode ser Nulo"
         NEXT FIELD ies_tip_portador
      ELSE
         SELECT *
         FROM port_des_polimetri
         WHERE cod_empresa = p_cod_empresa
           AND cod_portador = p_port_des_polimetri.cod_portador
           AND ies_tip_portador = p_port_des_polimetri.ies_tip_portador
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Portador Já Cadastrado"
            NEXT FIELD cod_portador 
         END IF
      END IF

      ON KEY (control-z)
         IF INFIELD(cod_portador) THEN
            CALL log009_popup(6,25,"PORTADOR","portador","cod_portador",
                             "nom_portador","","N","") 
               RETURNING p_port_des_polimetri.cod_portador     
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0361
            IF p_port_des_polimetri.cod_portador IS NOT NULL THEN
               DISPLAY BY NAME p_port_des_polimetri.cod_portador
            END IF
         END IF   

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0361
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0361_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON port_des_polimetri.cod_portador,
                                     port_des_polimetri.ies_tip_portador

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0361

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_port_des_polimetri.* = p_port_des_polimetrii.*
      CALL pol0361_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM port_des_polimetri ",
                  " WHERE ", where_clause CLIPPED,                 
                  " ORDER BY cod_portador "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_port_des_polimetri.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0361_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0361_exibe_dados()
#-----------------------------#

   SELECT nom_portador
      INTO p_tela.nom_portador
   FROM portador
   WHERE cod_portador = p_port_des_polimetri.cod_portador

   DISPLAY BY NAME p_port_des_polimetri.cod_portador,
                   p_port_des_polimetri.ies_tip_portador,
                   p_tela.*

END FUNCTION

#-----------------------------------#
 FUNCTION pol0361_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_port_des_polimetrii.* = p_port_des_polimetri.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_port_des_polimetri.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_port_des_polimetri.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Registros nesta Direcao"
            LET p_port_des_polimetri.* = p_port_des_polimetrii.* 
            EXIT WHILE
         END IF
        
         SELECT * 
            INTO p_port_des_polimetri.* 
         FROM port_des_polimetri    
         WHERE cod_empresa = p_port_des_polimetri.cod_empresa
           AND cod_portador = p_port_des_polimetri.cod_portador
           AND ies_tip_portador = p_port_des_polimetri.ies_tip_portador
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0361_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0361_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
      INTO p_port_des_polimetri.*                                              
   FROM port_des_polimetri      
   WHERE cod_empresa = p_port_des_polimetri.cod_empresa
     AND cod_portador = p_port_des_polimetri.cod_portador
     AND ies_tip_portador = p_port_des_polimetri.ies_tip_portador
   FOR UPDATE 
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
      OTHERWISE CALL log003_err_sql("LEITURA","PORT_DES_POLIMETRI")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#--------------------------#
 FUNCTION pol0361_exclusao()
#--------------------------#

   IF pol0361_cursor_for_update() THEN
      IF log004_confirm(13,40) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM port_des_polimetri    
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","PORT_DES_POLIMETRI")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_port_des_polimetri.*, 
                          p_tela.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","PORT_DES_POLIMETRI")
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

#-----------------------#
 FUNCTION pol0361_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
