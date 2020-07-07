#-------------------------------------------------------------------#
# PROGRAMA: POL0756                                                 #
# OBJETIVO: MANUTENCAO DA TABELA lanc_acerto_com_885                #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_nom_repres           LIKE representante.nom_repres,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         p_mes_cor              CHAR(2),
         p_ano_cor              CHAR(4), 
         p_houve_erro           SMALLINT,
         pa_curr                SMALLINT,
         sc_curr                SMALLINT,
         comando                CHAR(80),
         p_versao               CHAR(18),
         p_nom_arquivo          CHAR(100),
         p_nom_tela             CHAR(200),
         p_nom_help             CHAR(200),
         p_ies_cons             SMALLINT,
         p_last_row             SMALLINT 
  DEFINE p_lanc_acerto_com_885  RECORD LIKE lanc_acerto_com_885.*,    
         p_lanc_acerto_com_885r RECORD LIKE lanc_acerto_com_885.*,    
         p_representante        RECORD LIKE representante.*      
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0756-05.10.02"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0756.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0756_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0756_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0756") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0756 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0756","IN") THEN
        CALL pol0756_inclusao() RETURNING p_status
      END IF
    COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_lanc_acerto_com_885.cod_repres IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0756","MO") THEN
               CALL pol0756_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
    COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_lanc_acerto_com_885.cod_repres IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0756","EX") THEN
               CALL pol0756_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
    COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0756","CO") THEN
           CALL pol0756_consulta()
           IF p_ies_cons = TRUE THEN
              NEXT OPTION "Seguinte"
           END IF
       END IF
    COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0756_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0756_paginacao("ANTERIOR") 
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
  CLOSE WINDOW w_pol0756
END FUNCTION

#--------------------------------------#
 FUNCTION pol0756_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
   CLEAR FORM
  IF  pol0756_entrada_dados("INCLUSAO") THEN
      LET  p_lanc_acerto_com_885.cod_empresa = p_cod_empresa 
      LET  p_lanc_acerto_com_885.nom_usuario = p_user
      LET  p_lanc_acerto_com_885.dat_lanc    = TODAY
      #BEGIN WORK
      CALL log085_transacao("BEGIN")
      INSERT INTO lanc_acerto_com_885 VALUES (p_lanc_acerto_com_885.*)
      IF sqlca.sqlcode <> 0 THEN 
	       LET p_houve_erro = TRUE
	       CALL log003_err_sql("INCLUSAO","TABELA")       
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
 FUNCTION pol0756_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0756
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_lanc_acerto_com_885.* TO NULL
    LET p_lanc_acerto_com_885.cod_empresa = p_cod_empresa 
    DISPLAY BY NAME p_lanc_acerto_com_885.*
  END IF
  INPUT BY NAME p_lanc_acerto_com_885.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_empresa
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD ies_tip_lanc 
      END IF

    AFTER FIELD cod_empresa
      IF p_lanc_acerto_com_885.cod_empresa IS NULL THEN
         ERROR 'Campo empresa de prenchimento obrigatorio '
         NEXT FIELD cod_empresa
      END IF

    AFTER FIELD cod_repres 
      IF p_lanc_acerto_com_885.cod_repres  IS NOT NULL THEN
         IF pol0756_verifica_repres() THEN
            ERROR "Representante nao cadastrado" 
            NEXT FIELD cod_repres  
         ELSE 
            DISPLAY BY NAME p_representante.nom_repres  
         END IF
      ELSE ERROR "O campo COD_REPRESENTANTE nao pode ser nulo."
           NEXT FIELD cod_repres  
      END IF

    AFTER FIELD num_docum  
      IF p_lanc_acerto_com_885.num_docum IS NULL THEN
         ERROR 'Numero de Documento Invalido'
         NEXT FIELD num_docum  
      END IF

    AFTER FIELD ies_tip_lanc       
      IF p_lanc_acerto_com_885.ies_tip_lanc IS NULL  THEN
           ERROR "O campo tipo de lancamento nao pode se nulo"
           NEXT FIELD ies_tip_lanc    
      END IF 

    AFTER FIELD val_lanc    
      IF p_lanc_acerto_com_885.val_lanc IS NULL OR 
         p_lanc_acerto_com_885.val_lanc = 0 THEN 
           ERROR "O campo Valor lanc deve ser maior 0."
           NEXT FIELD val_lanc    
      END IF 

    AFTER FIELD mes_cred       
      IF p_lanc_acerto_com_885.mes_cred IS NULL THEN  
           ERROR "O campo mes de credito nao pode ser nulo"
           NEXT FIELD mes_cred    
      END IF 

    AFTER FIELD ano_cred       
      IF p_lanc_acerto_com_885.ano_cred IS NULL THEN
           ERROR "O campo ano de credito nao pode ser nulo"
           NEXT FIELD ano_cred 
      ELSE 
         LET p_ano_cor = year(today)
         LET p_mes_cor = month(today) USING '&&'
         IF p_lanc_acerto_com_885.ano_cred < p_ano_cor THEN 
            ERROR "Ano de credito nao pode ser inferior a corrente."
            NEXT FIELD ano_cred 
         ELSE 
            IF p_lanc_acerto_com_885.ano_cred = p_ano_cor AND    
               p_lanc_acerto_com_885.mes_cred < p_mes_cor THEN
               ERROR "Data de credito nao pode ser inferior a corrente."
               NEXT FIELD mes_cred 
            END IF
         END IF
      END IF 

    AFTER FIELD ies_base_ir    
      IF p_lanc_acerto_com_885.ies_base_ir IS NULL THEN 
           ERROR "Indicador de base de ir invalido"
           NEXT FIELD ies_base_ir 
      END IF 

    AFTER FIELD des_lanc       
      IF p_lanc_acerto_com_885.des_lanc IS NULL THEN  
           ERROR "Descricao nao pode ser nula"
           NEXT FIELD des_lanc    
      END IF 

   ON KEY (control-z)
        CALL pol0756_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0756
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#--------------------------#
 FUNCTION pol0756_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 LET p_lanc_acerto_com_885.cod_empresa = p_cod_empresa

 CONSTRUCT BY NAME where_clause ON lanc_acerto_com_885.cod_empresa,
                                   lanc_acerto_com_885.cod_repres,       
                                   lanc_acerto_com_885.num_docum,        
                                   lanc_acerto_com_885.mes_cred,   
                                   lanc_acerto_com_885.ano_cred    
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0756
 IF int_flag THEN
   LET int_flag = 0 
   LET p_lanc_acerto_com_885.* = p_lanc_acerto_com_885r.*
   CALL pol0756_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM lanc_acerto_com_885 ",
                " WHERE ", where_clause CLIPPED,
                " ORDER BY cod_repres,ano_cred,mes_cred "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_lanc_acerto_com_885.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0756_verifica_repres() THEN
         LET p_representante.nom_repres=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0756_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0756_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_lanc_acerto_com_885.* 
  DISPLAY BY NAME p_representante.nom_repres

END FUNCTION

#------------------------------------#
 FUNCTION pol0756_paginacao(p_funcao)
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_lanc_acerto_com_885r.* = p_lanc_acerto_com_885.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_lanc_acerto_com_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_lanc_acerto_com_885.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_lanc_acerto_com_885.* = p_lanc_acerto_com_885r.* 
           EXIT WHILE
        END IF
        
        IF pol0756_verifica_repres() THEN
           LET p_representante.nom_repres=" NAO CADASTRADO" 
        END IF
        CALL pol0756_exibe_dados()
        EXIT WHILE
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 

 
#------------------------------------#
 FUNCTION pol0756_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO p_lanc_acerto_com_885.*                                              
     FROM lanc_acerto_com_885      
    WHERE cod_empresa    = p_cod_empresa                     
      AND cod_repres     = p_lanc_acerto_com_885.cod_repres
      AND num_docum      = p_lanc_acerto_com_885.num_docum   
      AND mes_cred       = p_lanc_acerto_com_885.mes_cred
      AND ano_cred       = p_lanc_acerto_com_885.ano_cred      
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
 FUNCTION pol0756_modificacao()
#----------------------------------#
   IF pol0756_cursor_for_update() THEN
      LET p_lanc_acerto_com_885r.* = p_lanc_acerto_com_885.*
      IF pol0756_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE lanc_acerto_com_885 SET val_lanc     = p_lanc_acerto_com_885.val_lanc,
                                        ies_tip_lanc = p_lanc_acerto_com_885.ies_tip_lanc,
                                        ies_base_ir  = p_lanc_acerto_com_885.ies_base_ir, 
                                        des_lanc     = p_lanc_acerto_com_885.des_lanc,
                                        mes_cred     = p_lanc_acerto_com_885.mes_cred,
                                        ano_cred     = p_lanc_acerto_com_885.ano_cred
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
         LET p_lanc_acerto_com_885.* = p_lanc_acerto_com_885r.*
         ERROR "Modificacao Cancelada"
         #ROLLBACK WORK
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_lanc_acerto_com_885.cod_repres 
         DISPLAY BY NAME p_nom_repres                 
         DISPLAY BY NAME p_lanc_acerto_com_885.val_lanc  
         DISPLAY BY NAME p_lanc_acerto_com_885.mes_cred        
         DISPLAY BY NAME p_lanc_acerto_com_885.ano_cred        
         DISPLAY BY NAME p_lanc_acerto_com_885.ies_tip_lanc    
         DISPLAY BY NAME p_lanc_acerto_com_885.ies_base_ir     
         DISPLAY BY NAME p_lanc_acerto_com_885.dat_lanc        
         DISPLAY BY NAME p_lanc_acerto_com_885.des_lanc        
         DISPLAY BY NAME p_lanc_acerto_com_885.nom_usuario     
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0756_exclusao()
#----------------------------------------#
   IF pol0756_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM lanc_acerto_com_885    
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             #COMMIT WORK
             CALL log085_transacao("COMMIT")
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_lanc_acerto_com_885.* TO NULL
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

#------------------------------------#
 FUNCTION pol0756_verifica_repres()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT nom_repres 
  INTO p_representante.nom_repres
  FROM representante          
 WHERE cod_repres  = p_lanc_acerto_com_885.cod_repres

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 

#-----------------------#
 FUNCTION pol0756_popup()
#-----------------------#
  DEFINE p_cod_repres         LIKE representante.cod_repres   

  CASE

    WHEN infield(cod_repres)
         CALL log009_popup(6,25,"REPRESENTANTES","representante",
                          "cod_repres","nom_repres",
                          "","N","") RETURNING p_lanc_acerto_com_885.cod_repres
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0756
              DISPLAY BY NAME p_lanc_acerto_com_885.cod_repres

  END CASE
END FUNCTION
