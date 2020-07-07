##----------------------------------------------------------##
##  POL0752 - CADASTRO DE GERENTES DE VENDAS - COMISSAO     ##
##----------------------------------------------------------##
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
         p_last_row          SMALLINT
  DEFINE p_ger_com_885       RECORD LIKE ger_com_885.*,    
         p_ger_com_885r      RECORD LIKE ger_com_885.*,     
         p_representante     RECORD LIKE representante.*      
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0752-05.10.02"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0752.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0752_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0752_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0752") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0752 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0752","IN") THEN
        CALL pol0752_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_ger_com_885.cod_gerente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0752","MO") THEN
               CALL pol0752_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_ger_com_885.cod_gerente IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0752","EX") THEN
               CALL pol0752_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0752","CO") THEN
           CALL pol0752_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0752_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0752_paginacao("ANTERIOR") 
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
  CLOSE WINDOW w_pol0752
END FUNCTION

#--------------------------------------#
 FUNCTION pol0752_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0752_entrada_dados("INCLUSAO") THEN
      #BEGIN WORK
      CALL log085_transacao("BEGIN")       
      INSERT INTO ger_com_885 VALUES (p_ger_com_885.*)
      IF sqlca.sqlcode <> 0 THEN 
	       LET p_houve_erro = TRUE
	       #ROLLBACK WORK 
	       CALL log085_transacao("ROLLBACK")       
	       CALL log003_err_sql("INCLUSAO","GER_COM_885")       
      ELSE
         #COMMIT WORK 
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
 FUNCTION pol0752_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0752
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_ger_com_885.* TO NULL
    DISPLAY BY NAME p_ger_com_885.*
  END IF
  INPUT   BY NAME p_ger_com_885.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_gerente 
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD pct_com_ofi
      END IF

    AFTER FIELD cod_gerente 
      IF p_ger_com_885.cod_gerente  IS NOT NULL THEN
         IF pol0752_verifica_representante() THEN
            ERROR "Gerente nao cadastrado como representante" 
            NEXT FIELD cod_gerente  
         ELSE 
            DISPLAY BY NAME p_representante.raz_social 
         END IF
         IF pol0752_verifica_duplicidade() THEN
         ELSE
            ERROR "Gerente ja cadastrado" 
            NEXT FIELD cod_gerente  
         END IF  
      ELSE ERROR "O campo cod_gerente nao pode ser nulo."
           NEXT FIELD cod_gerente  
      END IF

    AFTER FIELD pct_com_ofi
      IF p_ger_com_885.pct_com_ofi IS NOT NULL THEN
      ELSE
         LET p_ger_com_885.pct_com_ofi = 0   
      END IF 

    AFTER FIELD pct_com_ger
      IF p_ger_com_885.pct_com_ger IS NOT NULL THEN
      ELSE
         LET p_ger_com_885.pct_com_ger = 0               
      END IF

    AFTER FIELD val_gar_ofi   
      IF p_ger_com_885.val_gar_ofi   IS NOT NULL THEN
      ELSE 
         LET p_ger_com_885.val_gar_ofi = 0
      END IF 

    AFTER FIELD val_gar_ger   
      IF p_ger_com_885.val_gar_ger   IS NOT NULL THEN
      ELSE 
         LET p_ger_com_885.val_gar_ger = 0
      END IF 

    BEFORE FIELD dat_exp_gar
      IF p_funcao = "INCLUSAO" THEN
         LET p_ger_com_885.dat_exp_gar = '31/12/2999'
      END IF    
    
    AFTER FIELD dat_exp_gar 
      IF p_ger_com_885.dat_exp_gar IS NULL THEN
         ERROR "Data nao pode ser nula" 
         NEXT FIELD dat_exp_gar   
      END IF 

    AFTER FIELD ies_exp
      IF p_ger_com_885.ies_exp  IS NULL THEN
         ERROR "Campo deve ser S ou N" 
         NEXT FIELD ies_exp
      ELSE
         IF p_ger_com_885.ies_exp  <> 'S' AND 
            p_ger_com_885.ies_exp  <> 'N' THEN
            ERROR "Campo deve ser S ou N" 
            NEXT FIELD ies_exp
         END IF 
      END IF 


   ON KEY (control-z)
        CALL pol0752_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0752
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0752_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON ger_com_885.cod_gerente
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0752
 IF int_flag THEN
   LET int_flag = 0 
   LET p_ger_com_885.* = p_ger_com_885r.*
   CALL pol0752_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM ger_com_885 ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_gerente "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_ger_com_885.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0752_verifica_representante() THEN
         LET p_representante.raz_social=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0752_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0752_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_ger_com_885.* 
  DISPLAY BY NAME p_representante.raz_social 

END FUNCTION

#------------------------------------#
 FUNCTION pol0752_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_ger_com_885r.* = p_ger_com_885.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_ger_com_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_ger_com_885.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_ger_com_885.* = p_ger_com_885r.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_ger_com_885.* FROM ger_com_885    
        WHERE cod_gerente = p_ger_com_885.cod_gerente
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0752_verifica_representante() THEN
              LET p_representante.raz_social=" NAO CADASTRADO" 
           END IF
           CALL pol0752_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
 
#------------------------------------#
 FUNCTION pol0752_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_ger_com_885.*                                              
     FROM ger_com_885      
    WHERE cod_gerente = p_ger_com_885.cod_gerente
 FOR UPDATE 
   #BEGIN WORK
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
 FUNCTION pol0752_modificacao()
#----------------------------------#
   IF pol0752_cursor_for_update() THEN
      LET p_ger_com_885r.* = p_ger_com_885.*
      IF pol0752_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE ger_com_885 SET pct_com_ofi = p_ger_com_885.pct_com_ofi,
                                pct_com_ger= p_ger_com_885.pct_com_ger,
                                val_gar_ofi  = p_ger_com_885.val_gar_ofi,
                                val_gar_ger  = p_ger_com_885.val_gar_ger,
                                dat_exp_gar  = p_ger_com_885.dat_exp_gar,
                                ies_exp      = p_ger_com_885.ies_exp
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            #COMMIT WORK
            CALL log085_transacao("COMMIT")       
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            #ROLLBACK WORK
            CALL log085_transacao("ROLLBACK")       
         END IF
      ELSE
         LET p_ger_com_885.* = p_ger_com_885r.*
         ERROR "Modificacao Cancelada"
         #ROLLBACK WORK
         CALL log085_transacao("ROLLBACK")       
         DISPLAY BY NAME p_ger_com_885.cod_gerente 
         IF pol0752_verifica_representante() THEN 
            LET p_representante.raz_social=" NAO CADASTRADO" 
         END IF
         DISPLAY BY NAME p_representante.raz_social               
         DISPLAY BY NAME p_ger_com_885.pct_com_ofi
         DISPLAY BY NAME p_ger_com_885.pct_com_ger
         DISPLAY BY NAME p_ger_com_885.val_gar_ofi 
         DISPLAY BY NAME p_ger_com_885.ies_exp 
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0752_exclusao()
#----------------------------------------#
   IF pol0752_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM ger_com_885    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             #COMMIT WORK
             CALL log085_transacao("COMMIT")       
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_ger_com_885.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             #ROLLBACK WORK
             CALL log085_transacao("ROLLBACK")       
          END IF
          WHENEVER ERROR STOP
       ELSE
          #ROLLBACK WORK
          CALL log085_transacao("ROLLBACK")       
       END IF
       CLOSE cm_padrao
   END IF
 END FUNCTION  

#---------------------------------------#
 FUNCTION pol0752_verifica_representante()
#---------------------------------------#
DEFINE p_cont      SMALLINT

SELECT raz_social
  INTO p_representante.raz_social
  FROM representante               
 WHERE cod_repres  = p_ger_com_885.cod_gerente

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0752_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM ger_com_885
 WHERE cod_gerente  = p_ger_com_885.cod_gerente

IF p_cont > 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE 
END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol0752_popup()
#-----------------------#
  DEFINE p_cod_gerente   LIKE ger_com_885.cod_gerente
  
  CASE
    WHEN infield(cod_gerente)
         CALL log009_popup(6,25,"GERENTE","representante",
                          "cod_repres","raz_social",
                          "vdp0050","N","") RETURNING p_cod_gerente
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0752 
         IF   p_cod_gerente IS NOT NULL OR
              p_cod_gerente <> " " 
         THEN
              LET p_ger_com_885.cod_gerente  = p_cod_gerente
              DISPLAY BY NAME p_ger_com_885.cod_gerente
         END IF
  END CASE
END FUNCTION
