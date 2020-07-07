#-------------------------------------------------------------------#
# SISTEMA.: EMBALAGEM                                               #
# PROGRAMA: POL0411                                                 #
# MODULOS.: POL0411 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA DE_PARA_EMBAL  (ITAESBRA)          #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 26/12/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa LIKE empresa.cod_empresa,
          p_den_empresa LIKE empresa.den_empresa,  
          p_user        LIKE usuario.nom_usuario,
          p_status      SMALLINT,
          p_houve_erro  SMALLINT,
          comando       CHAR(80),
          p_versao      CHAR(18),
          p_nom_tela    CHAR(080),
          p_nom_help    CHAR(200),
          p_ies_cons    SMALLINT,
          p_last_row    SMALLINT,
          p_msg         CHAR(500)

   DEFINE p_de_para_embal  RECORD LIKE de_para_embal.*,
          p_de_para_emball RECORD LIKE de_para_embal.*

   DEFINE p_tela RECORD
      den_embal      LIKE embalagem.den_embal,
      den_item_reduz LIKE item.den_item_reduz
   END RECORD
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0411-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0411.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0411_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0411_controle()
#--------------------------#

  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0411") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0411 AT 2,2 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Dados na Tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
        CALL pol0411_inclusao() RETURNING p_status
     COMMAND "Modificar" "Modifica Dados da Tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_de_para_embal.cod_empresa IS NOT NULL THEN
               CALL pol0411_modificacao()
       ELSE
           ERROR " Consulte Previamente para fazer a Modificacao"
       END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_de_para_embal.cod_empresa IS NOT NULL THEN
               CALL pol0411_exclusao()
       ELSE
           ERROR " Consulte Previamente para fazer a Exclusao"
       END IF 
     COMMAND "Consultar" "Consulta Dados da Tabela"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
           CALL pol0411_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
     COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0411_paginacao("SEGUINTE")
     COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0411_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0411_sobre()
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
  CLOSE WINDOW w_pol0411

END FUNCTION

#--------------------------------------#
 FUNCTION pol0411_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  CLEAR FORM
  IF  pol0411_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
  #   BEGIN WORK
      LET p_de_para_embal.cod_empresa = p_cod_empresa
      INSERT INTO de_para_embal VALUES (p_de_para_embal.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","DE_PARA_EMBAL")       
      ELSE
          CALL log085_transacao("COMMIT")
      #   COMMIT WORK 
          MESSAGE " Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada "
      RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0411_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0411
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_de_para_embal.*, p_tela.* TO NULL
      DISPLAY BY NAME p_de_para_embal.cod_embal_vdp,
                      p_de_para_embal.cod_embal_item,
                      p_tela.*
   END IF
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_de_para_embal.cod_embal_vdp,
                 p_de_para_embal.cod_embal_item 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_embal_vdp
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_embal_item 
      END IF

      AFTER FIELD cod_embal_vdp
      IF p_de_para_embal.cod_embal_vdp IS NOT NULL THEN
         IF pol0411_verifica_embal() THEN
            ERROR "Embalagem Já Cadastrada" 
            NEXT FIELD cod_embal_vdp 
         END IF
         SELECT den_embal
            INTO p_tela.den_embal
         FROM embalagem
         WHERE cod_embal = p_de_para_embal.cod_embal_vdp
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Codigo Embalagem nao Cadastrado"
            NEXT FIELD cod_embal_vdp 
         END IF
         DISPLAY BY NAME p_tela.den_embal
      ELSE 
         ERROR "O Campo Codigo da Embalagem - VDP nao pode ser Nulo"
         NEXT FIELD cod_embal_vdp 
      END IF

      AFTER FIELD cod_embal_item
      IF p_de_para_embal.cod_embal_item IS NULL THEN
         ERROR "O Campo Codigo do Item nao pode ser Nulo"
         NEXT FIELD cod_embal_item
      ELSE   
         SELECT den_item_reduz
            INTO p_tela.den_item_reduz
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_de_para_embal.cod_embal_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Codigo do Item nao Cadastrado"
            NEXT FIELD cod_embal_item
         END IF
      END IF

      ON KEY (control-z)
         IF INFIELD(cod_embal_vdp) THEN
            CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                           "cod_embal","den_embal",
                           "","N","") 
               RETURNING p_de_para_embal.cod_embal_vdp
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0411
            IF p_de_para_embal.cod_embal_vdp IS NOT NULL THEN
               DISPLAY BY NAME p_de_para_embal.cod_embal_vdp
            END IF 
         END IF                                                                
         IF INFIELD(cod_embal_item) THEN
         #  LET p_de_para_embal.cod_embal_item=min071_popup_item(p_cod_empresa)
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0411
            IF p_de_para_embal.cod_embal_item IS NOT NULL THEN
               DISPLAY BY NAME p_de_para_embal.cod_embal_item
            END IF
         END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0411

   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0411_consulta()
#--------------------------#

 DEFINE sql_stmt, 
        where_clause  CHAR(300)  

 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa

 CONSTRUCT BY NAME where_clause ON de_para_embal.cod_embal_vdp,
                                   de_para_embal.cod_embal_item

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0411
 IF INT_FLAG THEN
   LET INT_FLAG = 0 
   LET p_de_para_embal.* = p_de_para_emball.*
   CALL pol0411_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF

 LET sql_stmt = "SELECT * FROM de_para_embal ",
                "WHERE cod_empresa = ",p_cod_empresa,                 
                " AND ", where_clause CLIPPED,                 
                " ORDER BY cod_embal_vdp "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_de_para_embal.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0411_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0411_exibe_dados()
#-----------------------------#

   SELECT den_embal
      INTO p_tela.den_embal
   FROM embalagem
   WHERE cod_embal = p_de_para_embal.cod_embal_vdp

   SELECT den_item_reduz
      INTO p_tela.den_item_reduz
   FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item = p_de_para_embal.cod_embal_item

   DISPLAY BY NAME p_de_para_embal.cod_embal_vdp,
                   p_de_para_embal.cod_embal_item,
                   p_tela.*

END FUNCTION

#-----------------------------------#
 FUNCTION pol0411_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_de_para_emball.* = p_de_para_embal.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_de_para_embal.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_de_para_embal.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Itens nesta Direcao"
            LET p_de_para_embal.* = p_de_para_emball.* 
            EXIT WHILE
         END IF
        
         SELECT * INTO p_de_para_embal.* FROM de_para_embal    
         WHERE cod_empresa = p_de_para_embal.cod_empresa 
           AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp 
  
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0411_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0411_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
      INTO p_de_para_embal.*                                              
   FROM de_para_embal      
   WHERE cod_empresa = p_de_para_embal.cod_empresa 
     AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp 
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
      OTHERWISE CALL log003_err_sql("LEITURA","DE_PARA_EMBAL")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0411_modificacao()
#-----------------------------#

   IF pol0411_cursor_for_update() THEN
      LET p_de_para_emball.* = p_de_para_embal.*
      IF pol0411_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE de_para_embal 
            SET cod_embal_item = p_de_para_embal.cod_embal_item
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","DE_PARA_EMBAL")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","DE_PARA_EMBAL")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET p_de_para_embal.* = p_de_para_emball.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME p_de_para_embal.cod_embal_vdp
         DISPLAY BY NAME p_de_para_embal.cod_embal_item
         DISPLAY BY NAME p_tela.*
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0411_exclusao()
#--------------------------#

   IF pol0411_cursor_for_update() THEN
      IF log004_confirm(14,41) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM de_para_embal    
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","DE_PARA_EMBAL")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_de_para_embal.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","DE_PARA_EMBAL")
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

#--------------------------------#
 FUNCTION pol0411_verifica_embal()
#--------------------------------#
 
   DEFINE p_cont SMALLINT

   SELECT *
   FROM de_para_embal
   WHERE cod_empresa = p_cod_empresa 
     AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp

   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0411_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
