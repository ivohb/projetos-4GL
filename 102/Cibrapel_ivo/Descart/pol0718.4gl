#---------------------------------------------------------------------#
# PROGRAMA: pol0718                                                   #
# OBJETIVO: COPIA DE TABELA DE ESTOQUE                                #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_registro      INTEGER,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_dat_ini           CHAR(10),
         p_mes_ini           CHAR(02),
         p_ano_ini           CHAR(04), 
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(18),
         p_ies_gr            CHAR(1),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_last_row          SMALLINT,
         p_ies_cons          SMALLINT,
         p_houve_erro        SMALLINT


  DEFINE p_estoque_trans     RECORD LIKE estoque_trans.*        

   

  DEFINE p_tela  RECORD
                   cod_empresa    LIKE empresa.cod_empresa,
                   mes_ref        CHAR(2), 
                   ano_ref        CHAR(4)
                 END RECORD

 END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 60
  DEFER INTERRUPT
  LET p_versao = "POL0718-05.10.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0718.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("RHUMANOS","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0 THEN
      INITIALIZE p_tela.* TO NULL
      CALL pol0718_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0718_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0718") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0718 AT 5,11 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa data parametros para processamento."           
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"","pol0718","CO") THEN
        IF pol0718_informa_dados() THEN
             NEXT OPTION "Processar"
        ELSE
           ERROR "Funcao Cancelada"
        END IF
      END IF
    COMMAND "Processar" "Processa copia "         
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"","pol0718","CO") THEN
        IF p_tela.mes_ref IS NOT NULL THEN
           CALL pol0718_processa()
        ELSE
           ERROR "Informe dados para processamento"
           NEXT OPTION "Informar"
        END IF
      END IF
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
  CLOSE WINDOW w_pol0718
END FUNCTION

#----------------------------------------#
 FUNCTION pol0718_informa_dados()
#----------------------------------------#
  CLEAR FORM
  INITIALIZE p_tela.* TO NULL
  
  CALL log006_exibe_teclas("01 02",p_versao)
  CURRENT WINDOW IS w_pol0718
  LET p_tela.cod_empresa = p_cod_empresa
  DISPLAY BY NAME p_tela.cod_empresa

  INPUT BY NAME p_tela.* WITHOUT DEFAULTS

     AFTER FIELD mes_ref     
        IF p_tela.mes_ref      IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD mes_ref  
        ELSE
           IF p_tela.mes_ref < '01' OR 
              p_tela.mes_ref > '12' THEN
              ERROR "Mes invalido" 
              NEXT FIELD mes_ref  
           ELSE      
              IF pol0718_checa_par() THEN
                 ERROR "Estoque para copia sem paramentros cadastrados" 
                 NEXT FIELD mes_ref  
              END IF
           END IF
        END IF

     AFTER FIELD ano_ref    
        IF p_tela.ano_ref     IS NULL THEN
           ERROR "Campo de Preenchimento Obrigatorio"
           NEXT FIELD ano_ref 
        END IF 

   END INPUT

  IF int_flag <> 0 THEN
     RETURN FALSE 
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0718_checa_par()
#----------------------------------------# 

 SELECT * 
   INTO p_estoque_trans.*		
   FROM estoque_trans 
  WHERE cod_empresa = p_cod_empresa

 IF sqlca.sqlcode <> 0 THEN 
    RETURN TRUE 
 ELSE 
    RETURN FALSE 
 END IF
    
END FUNCTION 

#----------------------------#
 FUNCTION pol0718_processa()
#----------------------------#
  DEFINE p_cont   SMALLINT,
         l_count  SMALLINT
     

   CALL log085_transacao("BEGIN") 
   
   DECLARE cq_estoque_trans CURSOR FOR
        SELECT *
          FROM estoque_trans                    
         WHERE cod_empresa = p_cod_empresa
           AND YEAR(dat_ini_desc)  = p_tela.ano_ref  
           AND MONTH(dat_ini_desc) = p_tela.mes_ref 
           
     
      FOREACH cq_estoque_trans INTO p_estoque_trans.*              
     
        DISPLAY "Fun:..."  at 8,15
              
        INSERT INTO estoque_trans_end VALUES (p_estoque_trans.*)

        IF SQLCA.SQLCODE <> 0  THEN 
      	   LET p_houve_erro = TRUE
      	   MESSAGE p_num_registro
	         CALL log003_err_sql("INCLUSAO","")
	         EXIT FOREACH        
        END IF                                    
     
      END FOREACH

      IF  p_houve_erro THEN
         # EXIT FOREACH 
      END IF   
END FUNCTION 