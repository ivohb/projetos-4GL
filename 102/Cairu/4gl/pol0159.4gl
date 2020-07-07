#-------------------------------------------------------------------#
# SISTEMA.: CUSTOS                                                  #
# PROGRAMA: POL0159                                                 #
# MODULOS.: POL0159 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA SALDO_CAIRU                        #
# AUTOR...: CAIRU  - INTERNO                                        #
# DATA....: 31/07/2001                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         comando             CHAR(80),
      #  p_versao            CHAR(17),
         p_versao            CHAR(18),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_qtd_horas         LIKE consumo.qtd_horas,
         p_msg               CHAR(500)       


 DEFINE  p_last_row          SMALLINT,
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(01),
         p_nom_arquivo       CHAR(100),
         w_comando           CHAR(80),
         p_caminho           CHAR(080)

  DEFINE p_saldo_cairu         RECORD LIKE saldo_cairu.*,   
         p_saldo_cairur        RECORD LIKE saldo_cairu.*,    
         p_real              RECORD LIKE comp_custo_real.*,
         p_item              RECORD LIKE item.*,
         p_consumo           RECORD LIKE consumo.*           


END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
	LET p_versao = "pol0159-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0159.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

# CALL log001_acessa_usuario("SUPRIMEN")
   CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0159_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0159_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0159") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0159 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      CALL pol0159_inclusao() RETURNING p_status
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_saldo_cairu.cod_item    IS NOT NULL THEN
           CALL pol0159_modificacao()
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_saldo_cairu.cod_item IS NOT NULL THEN
           CALL pol0159_exclusao()
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela SALDO_CAIRU"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       CALL pol0159_consulta()
       IF p_ies_cons = TRUE THEN
          NEXT OPTION "Seguinte"
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0159_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0159_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0159_sobre()
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
  CLOSE WINDOW w_pol0159
END FUNCTION

#----------------------------#
 FUNCTION pol0159_inclusao()
#----------------------------#
  LET p_houve_erro = FALSE
#  CLEAR FORM
  IF  pol0159_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
  #   BEGIN WORK
      INSERT INTO saldo_cairu   VALUES (p_saldo_cairu.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","SALDO_CAIRU")       
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
 FUNCTION pol0159_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0159
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_saldo_cairu.* TO NULL
    DISPLAY p_cod_empresa TO cod_empresa
  END IF
  INPUT   BY NAME p_saldo_cairu.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_item    
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD qtd_saldo 
      END IF

    AFTER FIELD cod_item    
      IF p_saldo_cairu.cod_item  IS NOT NULL THEN
         IF pol0159_verifica_item() THEN
            ERROR "Item nao cadastrado" 
            NEXT FIELD cod_item  
         ELSE 
            DISPLAY BY NAME p_item.den_item
         END IF
      ELSE ERROR "O campo COD_ITEM nao pode ser nulo."
           NEXT FIELD cod_item  
      END IF

    AFTER FIELD dat_saldo
      IF p_saldo_cairu.dat_saldo    IS  NULL THEN
         ERROR "O campo DAT_SALDO nao pode ser nulo."
         NEXT FIELD dat_saldo    
      END IF 

    AFTER FIELD num_seq_operac 
      IF p_saldo_cairu.num_seq_operac    IS  NULL THEN
         ERROR "O campo NUM_SEQ_OPERAC nao pode ser nulo."
         NEXT FIELD num_seq_operac    
      END IF 

    AFTER FIELD cod_operac 
      IF p_saldo_cairu.cod_operac    IS  NULL THEN
         ERROR "O campo COD_OPERAC nao pode ser nulo."
         NEXT FIELD cod_operac    
      END IF 

    AFTER FIELD cod_cent_cust
      IF p_saldo_cairu.cod_cent_cust    IS  NULL THEN
         ERROR "O campo COD_CENT_CUST nao pode ser nulo."
         NEXT FIELD cod_cent_cust 
      ELSE
         IF pol0159_ver_cc()  THEN 
         ELSE
            ERROR "Centro nao cadastrado."
            NEXT FIELD cod_cent_cust 
         END IF 
      END IF 

    AFTER FIELD qtd_saldo
      IF p_saldo_cairu.qtd_saldo    IS  NULL THEN
         ERROR "O campo QTD_SALDO nao pode ser nulo."
         NEXT FIELD qtd_saldo 
      END IF 

    AFTER FIELD  ies_oper_final
     IF p_saldo_cairu.ies_oper_final MATCHES "[SsNn]"   THEN
     ELSE 
        ERROR "INFORMA S OU N"
        NEXT FIELD ies_oper_final
     END IF


 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0159
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0159_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(500)  
 CLEAR FORM

 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0159
 LET p_saldo_cairur.* = p_saldo_cairu.*
 INITIALIZE p_saldo_cairu.*   TO NULL 
 CLEAR FORM  
 CONSTRUCT BY NAME where_clause ON  cod_item,
                                    dat_saldo,
                                    cod_operac,
                                    num_seq_operac,
                                    cod_cent_cust
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0159
 IF int_flag THEN
   LET int_flag = 0 
   LET p_saldo_cairu.* = p_saldo_cairur.*
   CALL pol0159_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM saldo_cairu WHERE ", where_clause CLIPPED 

   LET sql_stmt = sql_stmt CLIPPED, 
         " ORDER BY cod_item, dat_saldo, num_seq_operac"  

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_saldo_cairu.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0159_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      IF pol0159_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0159_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0159_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_saldo_cairu.* 
  DISPLAY BY NAME p_item.den_item 
  DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#------------------------------------#
 FUNCTION pol0159_paginacao(p_funcao)   
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_saldo_cairur.* = p_saldo_cairu.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_saldo_cairu.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_saldo_cairu.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_saldo_cairu.* = p_saldo_cairur.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_saldo_cairu.* FROM saldo_cairu    
         WHERE     cod_item=p_saldo_cairu.cod_item 
           AND     dat_saldo=p_saldo_cairu.dat_saldo
           AND     cod_operac=p_saldo_cairu.cod_operac
           AND     num_seq_operac=p_saldo_cairu.num_seq_operac
           AND     cod_cent_cust=p_saldo_cairu.cod_cent_cust 
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0159_verifica_item() THEN
              LET p_item.den_item   =" NAO CADASTRADO" 
           END IF
           CALL pol0159_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
#------------------------------------#
 FUNCTION pol0159_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_saldo_cairu.*                                              
     FROM saldo_cairu        
     WHERE     cod_item=p_saldo_cairu.cod_item 
       AND     dat_saldo=p_saldo_cairu.dat_saldo
       AND     cod_operac=p_saldo_cairu.cod_operac
       AND     num_seq_operac=p_saldo_cairu.num_seq_operac
       AND     cod_cent_cust=p_saldo_cairu.cod_cent_cust 
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE sqlca.sqlcode
     
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","SALDO_CAIRU")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION
#----------------------------------#
 FUNCTION pol0159_modificacao()
#----------------------------------#
   IF pol0159_cursor_for_update() THEN
      LET p_saldo_cairur.* = p_saldo_cairu.*
      IF pol0159_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE saldo_cairu SET 
                    saldo_cairu.cod_item       = p_saldo_cairu.cod_item,
                    saldo_cairu.dat_saldo      = p_saldo_cairu.dat_saldo,
                    saldo_cairu.num_seq_operac = p_saldo_cairu.num_seq_operac,
                    saldo_cairu.cod_operac     = p_saldo_cairu.cod_operac,    
                    saldo_cairu.cod_cent_cust  = p_saldo_cairu.cod_cent_cust, 
                    saldo_cairu.qtd_saldo      = p_saldo_cairu.qtd_saldo,  
                    saldo_cairu.ies_oper_final = p_saldo_cairu.ies_oper_final  
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","T_SALDO_CAIRU")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","T_SALDO_CAIRU")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET p_saldo_cairu.* = p_saldo_cairur.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME p_saldo_cairu.cod_item         
         DISPLAY BY NAME p_saldo_cairu.dat_saldo         
         DISPLAY BY NAME p_saldo_cairu.num_seq_operac         
         DISPLAY BY NAME p_saldo_cairu.cod_operac         
         DISPLAY BY NAME p_saldo_cairu.cod_cent_cust      
         DISPLAY BY NAME p_saldo_cairu.qtd_saldo      
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0159_exclusao()
#----------------------------------------#
   IF pol0159_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM saldo_cairu      
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
          #  COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","SALDO_CAIRU")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_saldo_cairu.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","SALDO_CAIRU")
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
#-------------------------#
 FUNCTION pol0159_ver_cc()
#-------------------------#
  SELECT *        
   FROM cad_cc              
  WHERE cod_cent_cust  = p_saldo_cairu.cod_cent_cust
    AND cod_empresa    = p_cod_empresa 

  IF sqlca.sqlcode = 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0159_verifica_item()
#------------------------------------#
  SELECT den_item 
   INTO p_item.den_item  
   FROM item                
  WHERE cod_item  = p_saldo_cairu.cod_item
    AND cod_empresa    = p_cod_empresa 

  IF sqlca.sqlcode = 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0159_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
