#-------------------------------------------------------------------#
# SISTEMA.: EMBALAGEM                                               #
# PROGRAMA: POL0213                                                 #
# MODULOS.: POL0213 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA DE_PARA_EMBAL                      #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 06/12/2002                                              #
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
          p_msg         CHAR(100)

   DEFINE p_de_para_embal  RECORD LIKE de_para_embal.*,
          p_de_para_emball RECORD LIKE de_para_embal.*
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "pol0215-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0213.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0213_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0213_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0213") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0213 AT 2,2 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0213","IN") THEN
        CALL pol0213_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_de_para_embal.cod_empresa IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0213","MO") THEN
               CALL pol0213_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_de_para_embal.cod_empresa IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0213","EX") THEN
               CALL pol0213_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0213","CO") THEN
           CALL pol0213_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0213_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0213_paginacao("ANTERIOR") 
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0213_sobre() 
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
  CLOSE WINDOW w_pol0213
END FUNCTION

#-----------------------#
FUNCTION esp0213_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------------#
 FUNCTION pol0213_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  CLEAR FORM
  IF  pol0213_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
  #   BEGIN WORK
      INSERT INTO de_para_embal VALUES (p_de_para_embal.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","TABELA")       
      ELSE
          CALL log085_transacao("COMMIT")
      #   COMMIT WORK 
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
 FUNCTION pol0213_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0213
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_de_para_embal.* TO NULL
    DISPLAY BY NAME p_de_para_embal.*
  END IF
  INPUT BY NAME p_de_para_embal.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_empresa 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_embal_item 
      END IF

    AFTER FIELD cod_empresa  
      IF p_de_para_embal.cod_empresa IS NULL THEN
         ERROR "O campo COD EMPRESA nao pode ser nulo."
         NEXT FIELD cod_empresa  
      ELSE
         SELECT den_empresa
            INTO p_den_empresa 
         FROM empresa
         WHERE cod_empresa = p_de_para_embal.cod_empresa
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Empresa Nao Cadastrada"
            NEXT FIELD cod_empresa  
         END IF
         DISPLAY BY NAME p_den_empresa
      END IF

    AFTER FIELD cod_embal_vdp
      IF p_de_para_embal.cod_embal_vdp IS NOT NULL THEN
         SELECT cod_embal
         FROM embalagem
         WHERE cod_embal = p_de_para_embal.cod_embal_vdp
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Codigo Embalagem nao Cadastrado"
            NEXT FIELD cod_embal_vdp
         END IF
         IF p_funcao <> "INCLUSAO" THEN
            IF NOT pol0213_verifica_embal() THEN
               ERROR "Embalagem nao Cadastrada" 
               NEXT FIELD cod_empresa   
            END IF
         ELSE
            IF pol0213_verifica_embal() THEN
               ERROR "Embalagem ja' Cadastrada" 
               NEXT FIELD cod_empresa   
            END IF
         END IF
      ELSE ERROR "O Campo Cod Vdp nao pode ser Nulo"
           NEXT FIELD cod_embal_vdp 
      END IF

    AFTER FIELD cod_embal_item
      IF p_de_para_embal.cod_embal_item IS NULL THEN
         ERROR "O Campo Cod Item nao pode ser Nulo"
         NEXT FIELD cod_embal_item
      ELSE   
         SELECT cod_item
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_de_para_embal.cod_embal_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cod Item nao Cadastrado"
            NEXT FIELD cod_embal_item
         END IF
      END IF

   ON KEY (control-z)
      IF infield(cod_embal_item) THEN
         LET p_de_para_embal.cod_embal_item = vdp373_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0213 
         IF p_de_para_embal.cod_embal_item IS NOT NULL THEN
            DISPLAY BY NAME p_de_para_embal.cod_embal_item
         END IF                                                                
      END IF                                                                

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0213
   IF int_flag = 0 THEN
      RETURN TRUE 
   ELSE
      LET int_flag = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0213_consulta()
#--------------------------#
 DEFINE sql_stmt, 
        where_clause  CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON de_para_embal.cod_empresa,
                                   de_para_embal.cod_embal_vdp
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0213
 IF int_flag THEN
   LET int_flag = 0 
   LET p_de_para_embal.* = p_de_para_emball.*
   CALL pol0213_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM de_para_embal ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_empresa, cod_embal_vdp "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_de_para_embal.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0213_verifica_embal() THEN
#        LET p_den_empresa = " NAO CADASTRADA" 
#     END IF
#     IF pol0213_verifica_nat_oper() THEN
#        LET p_clientes.nom_cliente=" NAO CADASTRADO" 
#     END IF
         LET p_ies_cons = TRUE
         CALL pol0213_exibe_dados()
      END IF
   END IF
#  CALL pol0213_exibe_dados()

END FUNCTION

#------------------------------#
 FUNCTION pol0213_exibe_dados()
#------------------------------#

  DISPLAY BY NAME p_de_para_embal.*, 
                  p_den_empresa            

END FUNCTION

#-----------------------------------#
 FUNCTION pol0213_paginacao(p_funcao)
#-----------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_de_para_emball.* = p_de_para_embal.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_de_para_embal.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_de_para_embal.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_de_para_embal.* = p_de_para_emball.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_de_para_embal.* FROM de_para_embal    
        WHERE cod_empresa   = p_de_para_embal.cod_empresa 
          AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp 
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0213_verifica_embal() THEN
              CALL pol0213_exibe_dados()
#             LET p_den_empresa = " EMPRESA NAO CADASTRADA" 
           END IF
#          IF pol0213_verifica_nat_oper() THEN
#             LET p_clientes.nom_cliente=" NAO CADASTRADO" 
#          END IF
#          CALL pol0213_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF

END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0213_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_de_para_embal.*                                              
     FROM de_para_embal      
    WHERE cod_empresa   = p_de_para_embal.cod_empresa 
      AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp 
 FOR UPDATE 
   CALL log085_transacao("BEGIN")
 # BEGIN WORK
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
 FUNCTION pol0213_modificacao()
#----------------------------------#
   IF pol0213_cursor_for_update() THEN
      LET p_de_para_emball.* = p_de_para_embal.*
      IF pol0213_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE de_para_embal 
            SET cod_embal_item = p_de_para_embal.cod_embal_item
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET p_de_para_embal.* = p_de_para_emball.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME p_de_para_embal.cod_empresa
         DISPLAY BY NAME p_den_empresa
         DISPLAY BY NAME p_de_para_embal.cod_embal_vdp
         DISPLAY BY NAME p_de_para_embal.cod_embal_item
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0213_exclusao()
#----------------------------------------#

   IF pol0213_cursor_for_update() THEN
      IF log004_confirm(16,44) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM de_para_embal    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
          #  COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_de_para_embal.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
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

#------------------------------------#
 FUNCTION pol0213_verifica_embal()
#------------------------------------#
DEFINE p_cont SMALLINT

  SELECT cod_empresa,
         cod_embal_vdp 
# INTO p_de_para_embal.cod_empresa,
#      p_de_para_embal.cod_embal_vdp 
  FROM de_para_embal
  WHERE cod_empresa   = p_de_para_embal.cod_empresa 
    AND cod_embal_vdp = p_de_para_embal.cod_embal_vdp

IF sqlca.sqlcode = 0 THEN
   SELECT den_empresa
      INTO p_den_empresa 
   FROM empresa
   WHERE cod_empresa = p_de_para_embal.cod_empresa
   IF SQLCA.SQLCODE <> 0 THEN
      LET p_den_empresa = "Nao Cadastrada"
   END IF
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION 

#------------------------------------#
#FUNCTION pol0213_verifica_nat_oper()
#------------------------------------#
{DEFINE p_cont      SMALLINT

SELECT den_nat_oper
  INTO p_nat_operacao.den_nat_oper
  FROM nat_operacao           
 WHERE cod_nat_oper = p_de_para_embal.cod_nat_oper

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION   }


#--------------------------------------#
#FUNCTION pol0213_verifica_duplicidade()
#--------------------------------------#
{DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM de_para_embal
 WHERE cod_cliente  = p_de_para_embal.cod_cliente
   AND cod_nat_oper = p_de_para_embal.cod_nat_oper 

IF p_cont > 0 THEN
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION   }
#----------------------------- FIM DE PROGRAMA --------------------------------#
