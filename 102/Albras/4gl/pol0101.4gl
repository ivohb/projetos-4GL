#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: POL0101                                                 #
# MODULOS.: POL0101 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ITEM_CORRESP                       #
# AUTOR...: ALBRAS - INTERNO                                        #
# DATA....: 20/06/2000                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_user              LIKE usuario.nom_usuario,
         p_cod_item          LIKE item.cod_item,          
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
#        p_versao            CHAR(17),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tel           CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT
  DEFINE p_item_corresp      RECORD LIKE item_corresp.*,    
         p_item_correspr     RECORD LIKE item_corresp.*,    
         p_item              RECORD LIKE item.*             
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0101-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0101.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

# CALL log001_acessa_usuario("VDP")
  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0101_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0101_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tel TO NULL
  CALL log130_procura_caminho("POL0101") RETURNING p_nom_tel
  LET  p_nom_tel = p_nom_tel CLIPPED 
  OPEN WINDOW w_pol0101 AT 2,5 WITH FORM p_nom_tel 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0101","IN") THEN
        CALL pol0101_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_item_corresp.cod_item_ped IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0101","MO") THEN
               CALL pol0101_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_item_corresp.cod_item_ped IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0101","EX") THEN
               CALL pol0101_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE "" 
       DISPLAY "                           "  AT 7,36
       DISPLAY "                           "  AT 9,36
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0101","CO") THEN
           CALL pol0101_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0101_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0101_paginacao("ANTERIOR") 
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
  CLOSE WINDOW w_pol0101
END FUNCTION

#--------------------------------------#
 FUNCTION pol0101_inclusao()
#--------------------------------------#
   LET p_houve_erro = FALSE
#  CLEAR FORM
   IF pol0101_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO item_corresp VALUES (p_item_corresp.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","TABELA")       
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
 FUNCTION pol0101_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0101
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_item_corresp.* TO NULL
    DISPLAY BY NAME p_item_corresp.*
  END IF
  INPUT   BY NAME p_item_corresp.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_item_ped
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_item_nf 
      END IF

    AFTER FIELD cod_item_ped
      IF p_item_corresp.cod_item_ped IS NOT NULL THEN 
         LET p_cod_item = p_item_corresp.cod_item_ped
         IF pol0101_verifica_item() THEN
            ERROR "ITEM NAO CADASTRADO" 
            NEXT FIELD cod_item_ped 
         ELSE 
            DISPLAY p_item.den_item_reduz at 7,36
         END IF
         IF p_funcao <> "MODIFICACAO" THEN 
            IF pol0101_verifica_duplicidade() THEN
               ERROR "ITEM PEDIDO JA CADASTRADO" 
               NEXT FIELD cod_item_ped 
            END IF
         END IF
      ELSE ERROR "O campo COD.ITEM PEDIDO nao pode ser nulo."
           NEXT FIELD cod_item_ped 
      END IF

    AFTER FIELD cod_item_nf 
      IF p_item_corresp.cod_item_nf  IS NOT NULL THEN
         IF p_item_corresp.cod_item_nf = p_item_corresp.cod_item_ped THEN 
            ERROR " ITEM PEDIDO deve ser diferente de INTEM NOTA" 
            NEXT FIELD cod_item_nf  
         ELSE  
            LET p_cod_item = p_item_corresp.cod_item_nf 
            IF pol0101_verifica_item() THEN
               ERROR "ITEM NAO CADASTRADO" 
               NEXT FIELD cod_item_nf  
            ELSE 
               DISPLAY p_item.den_item_reduz at 9,36
            END IF 
         END IF
      ELSE ERROR "O campo COD. ITEM NOTA nao pode ser nulo."
           NEXT FIELD cod_item_nf     
      END IF 

    AFTER FIELD qtd_item_ped   
      IF p_item_corresp.qtd_item_ped IS  NULL OR    	
         p_item_corresp.qtd_item_ped = 0  THEN
           ERROR "O campo QTD.PEDIDO deve ser maior que 0." 
           NEXT FIELD qtd_item_ped    
      END IF

    AFTER FIELD qtd_item_nf    
      IF p_item_corresp.qtd_item_nf  IS  NULL OR    	
         p_item_corresp.qtd_item_nf  = 0  THEN
           ERROR "O campo QTD. NOTA  deve ser maior que 0." 
           NEXT FIELD qtd_item_ped    
      END IF

   ON KEY (control-z)
        CALL pol0101_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0101
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0101_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON item_corresp.cod_item_ped,
                                   item_corresp.cod_item_nf 
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0101
 IF int_flag THEN
   LET int_flag = 0 
   LET p_item_corresp.* = p_item_correspr.*
   CALL pol0101_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM item_corresp ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_item_nf "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_item_corresp.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_cod_item = p_item_corresp.cod_item_ped
      IF pol0101_verifica_item() THEN
         LET p_item.den_item_reduz=" NAO CADASTRADO" 
      END IF
      DISPLAY p_item.den_item_reduz at 7,36 

      LET p_cod_item = p_item_corresp.cod_item_nf 
      IF pol0101_verifica_item() THEN
         LET p_item.den_item_reduz=" NAO CADASTRADO" 
      END IF
      DISPLAY p_item.den_item_reduz at 9,36
 
      LET p_ies_cons = TRUE
   END IF
    CALL pol0101_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0101_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_item_corresp.* 

END FUNCTION

#------------------------------------#
 FUNCTION pol0101_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_item_correspr.* = p_item_corresp.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_item_corresp.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_item_corresp.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_item_corresp.* = p_item_correspr.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_item_corresp.* FROM item_corresp    
        WHERE cod_item_ped = p_item_corresp.cod_item_ped    
          AND cod_item_nf  = p_item_corresp.cod_item_nf      
  
        IF sqlca.sqlcode = 0 THEN 
           LET p_cod_item = p_item_corresp.cod_item_ped
           IF pol0101_verifica_item() THEN
              LET p_item.den_item_reduz=" NAO CADASTRADO" 
           END IF
           DISPLAY p_item.den_item_reduz at 7,36 

           LET p_cod_item = p_item_corresp.cod_item_nf 
           IF pol0101_verifica_item() THEN
               LET p_item.den_item_reduz=" NAO CADASTRADO" 
           END IF
           DISPLAY p_item.den_item_reduz at 9,36 

           CALL pol0101_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION pol0101_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_item_corresp.*                                              
     FROM item_corresp      
    WHERE cod_item_ped= p_item_corresp.cod_item_ped 
 FOR UPDATE 
   CALL log085_transacao("BEGIN")
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
 FUNCTION pol0101_modificacao()
#----------------------------------#
   IF pol0101_cursor_for_update() THEN
      LET p_item_correspr.* = p_item_corresp.*
      IF pol0101_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE item_corresp SET cod_item_nf  = p_item_corresp.cod_item_nf,  
                                 qtd_item_ped = p_item_corresp.qtd_item_ped,
                                 qtd_item_nf  = p_item_corresp.qtd_item_nf 
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
         LET p_item_corresp.* = p_item_correspr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_item_corresp.cod_item_ped
         DISPLAY BY NAME p_item_corresp.cod_item_nf 
         DISPLAY BY NAME p_item_corresp.qtd_item_ped  
         DISPLAY BY NAME p_item_corresp.qtd_item_nf  
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0101_exclusao()
#----------------------------------------#
   IF pol0101_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_corresp    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_item_corresp.* TO NULL
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

#------------------------------------#
 FUNCTION pol0101_verifica_item()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT den_item_reduz
  INTO p_item.den_item_reduz  
  FROM item                   
 WHERE cod_item  = p_cod_item                
   AND cod_empresa = p_cod_empresa           

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 


#------------------------------------#
 FUNCTION pol0101_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM item_corresp
 WHERE cod_item_ped = p_cod_item                    

IF p_cont > 0 THEN
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0101_popup()
#-----------------------#
  DEFINE p_cod_itemp          LIKE item.cod_item             
  
  CASE
  WHEN infield(cod_item_ped)
         LET p_cod_itemp = vdp373_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0101 
         IF   p_cod_itemp IS NOT NULL
         THEN LET p_item_corresp.cod_item_ped = p_cod_itemp
              DISPLAY BY NAME p_item_corresp.cod_item_ped
         END IF
  WHEN infield(cod_item_nf)
         LET p_cod_itemp = vdp373_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0101 
         IF   p_cod_itemp IS NOT NULL
         THEN LET p_item_corresp.cod_item_nf  = p_cod_itemp
              DISPLAY BY NAME p_item_corresp.cod_item_nf  
         END IF
  END CASE
END FUNCTION
