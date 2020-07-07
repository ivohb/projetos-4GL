#-------------------------------------------------------------------#
# SISTEMA.: CUSTOS                                                  #
# PROGRAMA: POL0158                                                 #
# MODULOS.: POL0158 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA APO_CAIRU                          #
# AUTOR...: CAIRU  - INTERNO                                        #
# DATA....: 12/07/2001                                              #
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

  DEFINE p_apo_cairu         RECORD LIKE apo_cairu.*,   
         p_apo_cairur        RECORD LIKE apo_cairu.*,    
         p_real              RECORD LIKE comp_custo_real.*,
         p_item              RECORD LIKE item.*,
         p_consumo           RECORD LIKE consumo.*           


  DEFINE p_relat      RECORD 
                            cod_item       LIKE apo_cairu.cod_item,
                            dat_referencia LIKE apo_cairu.dat_referencia,
                            cod_operac     LIKE apo_cairu.cod_operac,
                            num_seq_operac LIKE apo_cairu.num_seq_operac,
                            cod_cent_cust  LIKE apo_cairu.cod_cent_cust,
                            qtd_diferenca  LIKE apo_cairu.qtd_diferenca,
                            val_custo      LIKE cent_cust_comp.val_custo,
                            val_total      DECIMAL(15,2),                  
                            qtd_horas      DECIMAL(11,7)                   
                         END RECORD
  
 DEFINE p_tela          RECORD
                         dat_referencia  LIKE apo_cairu.dat_referencia,
                         num_versao_cus  LIKE cent_cust_comp.num_versao_cus  
                       END RECORD

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
	LET p_versao = "pol0158-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0158.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
   CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0158_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0158_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("POL0158") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0158 AT 2,5 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      CALL pol0158_inclusao() RETURNING p_status
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_apo_cairu.cod_item    IS NOT NULL THEN
           CALL pol0158_modificacao()
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_apo_cairu.cod_item IS NOT NULL THEN
           CALL pol0158_exclusao()
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela APO_CAIRU"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       CALL pol0158_consulta()
       IF p_ies_cons = TRUE THEN
          NEXT OPTION "Seguinte"
       END IF
     COMMAND "Seguinte"   "Exibe o proximo item encontrado na consulta"
       HELP 005
       MESSAGE ""
       LET int_flag = 0
       CALL pol0158_paginacao("SEGUINTE")
     COMMAND "Anterior"   "Exibe o item anterior encontrado na consulta"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       CALL pol0158_paginacao("ANTERIOR") 
     COMMAND "Listar"   "Relacao de itens em apontamento"
       HELP 006
       MESSAGE ""
       LET int_flag = 0
       IF pol0158_relatorio()   THEN 
          ERROR " Relatorio emitido com sucesso. "
       END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0158_sobre()
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
  CLOSE WINDOW w_pol0158
END FUNCTION

#----------------------------#
 FUNCTION pol0158_inclusao()
#----------------------------#
  LET p_houve_erro = FALSE
#  CLEAR FORM
  IF  pol0158_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
  #   BEGIN WORK
      INSERT INTO apo_cairu   VALUES (p_apo_cairu.*)
      IF sqlca.sqlcode <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","APO_CAIRU")       
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
 FUNCTION pol0158_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0158
  IF p_funcao = "INCLUSAO" THEN
    INITIALIZE p_apo_cairu.* TO NULL
    DISPLAY p_cod_empresa TO cod_empresa
  END IF
  INPUT   BY NAME p_apo_cairu.* WITHOUT DEFAULTS  

    BEFORE FIELD cod_item    
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD qtd_diferenca 
      END IF

    AFTER FIELD cod_item    
      IF p_apo_cairu.cod_item  IS NOT NULL THEN
         IF pol0158_verifica_item() THEN
            ERROR "Item nao cadastrado" 
            NEXT FIELD cod_item  
         ELSE 
            DISPLAY BY NAME p_item.den_item
         END IF
      ELSE ERROR "O campo COD_ITEM nao pode ser nulo."
           NEXT FIELD cod_item  
      END IF

    AFTER FIELD dat_referencia
      IF p_apo_cairu.dat_referencia    IS  NULL THEN
         ERROR "O campo DAT_REFERENCIA nao pode ser nulo."
         NEXT FIELD dat_referencia    
      END IF 

    AFTER FIELD num_seq_operac 
      IF p_apo_cairu.num_seq_operac    IS  NULL THEN
         ERROR "O campo NUM_SEQ_OPERAC nao pode ser nulo."
         NEXT FIELD num_seq_operac    
      END IF 

    AFTER FIELD cod_operac 
      IF p_apo_cairu.cod_operac    IS  NULL THEN
         ERROR "O campo COD_OPERAC nao pode ser nulo."
         NEXT FIELD cod_operac    
      END IF 

    AFTER FIELD cod_cent_cust
      IF p_apo_cairu.cod_cent_cust    IS  NULL THEN
         ERROR "O campo COD_CENT_CUST nao pode ser nulo."
         NEXT FIELD cod_cent_cust 
      ELSE
         IF pol0158_ver_cc()  THEN 
         ELSE
            ERROR "Centro nao cadastrado."
            NEXT FIELD cod_cent_cust 
         END IF 
      END IF 

    AFTER FIELD qtd_diferenca
      IF p_apo_cairu.qtd_diferenca    IS  NULL THEN
         ERROR "O campo QTD_DIFERENCA nao pode ser nulo."
         NEXT FIELD qtd_diferenca 
      END IF 

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0158
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0158_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(500)  
 CLEAR FORM

 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0158
 LET p_apo_cairur.* = p_apo_cairu.*
 INITIALIZE p_apo_cairu.*   TO NULL 
 CLEAR FORM  
 CONSTRUCT BY NAME where_clause ON  cod_item,
                                    dat_referencia,
                                    cod_operac,
                                    num_seq_operac,
                                    cod_cent_cust
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0158
 IF int_flag THEN
   LET int_flag = 0 
   LET p_apo_cairu.* = p_apo_cairur.*
   CALL pol0158_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM apo_cairu WHERE ", where_clause CLIPPED 

   LET sql_stmt = sql_stmt CLIPPED, 
         " ORDER BY cod_item, dat_referencia, num_seq_operac"  

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_apo_cairu.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      IF pol0158_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      IF pol0158_verifica_item() THEN
         LET p_item.den_item=" NAO CADASTRADO" 
      END IF
      LET p_ies_cons = TRUE
   END IF
    CALL pol0158_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0158_exibe_dados()
#------------------------------#
  DISPLAY BY NAME p_apo_cairu.* 
  DISPLAY BY NAME p_item.den_item 
  DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#------------------------------------#
 FUNCTION pol0158_paginacao(p_funcao)   
#------------------------------------#
  DEFINE p_funcao      CHAR(20)

  IF p_ies_cons THEN
     LET p_apo_cairur.* = p_apo_cairu.*
     WHILE TRUE
        CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_apo_cairu.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_apo_cairu.*
        END CASE
     
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao Existem mais Itens nesta direcao"
           LET p_apo_cairu.* = p_apo_cairur.* 
           EXIT WHILE
        END IF
        
        SELECT * INTO p_apo_cairu.* FROM apo_cairu    
         WHERE     cod_item=p_apo_cairu.cod_item 
           AND     dat_referencia=p_apo_cairu.dat_referencia
           AND     cod_operac=p_apo_cairu.cod_operac
           AND     num_seq_operac=p_apo_cairu.num_seq_operac
           AND     cod_cent_cust=p_apo_cairu.cod_cent_cust 
  
        IF sqlca.sqlcode = 0 THEN 
           IF pol0158_verifica_item() THEN
              LET p_item.den_item   =" NAO CADASTRADO" 
           END IF
           CALL pol0158_exibe_dados()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa."
  END IF
END FUNCTION 
#---------------------------#
 FUNCTION pol0158_relatorio()
#---------------------------#
 CALL log130_procura_caminho("pol01581") RETURNING p_nom_tela
 OPEN WINDOW w_pol01581 AT 07,07 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)
 DISPLAY p_cod_empresa TO cod_empresa
 INPUT p_tela.dat_referencia,
       p_tela.num_versao_cus
  FROM dat_referencia,num_versao_cus 

 AFTER FIELD  dat_referencia 
     IF  p_tela.dat_referencia IS NULL THEN
         ERROR " Obrigatorio informar a data de referencia "
         NEXT FIELD dat_referencia
     ELSE
         SELECT dat_referencia
           FROM apo_cairu
          WHERE dat_referencia=p_tela.dat_referencia
          GROUP BY 1
         IF  sqlca.sqlcode  = NOTFOUND THEN
             ERROR " Nao existe movimento para a data de referencia " 
             NEXT FIELD dat_referencia
         ELSE
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("SELECT","APO_CAIRU 2")
             END IF
         END IF
     END IF


 AFTER FIELD  num_versao_cus 
     IF  p_tela.num_versao_cus IS NULL THEN
         ERROR " Obrigatorio informar a versao do custo "
         NEXT FIELD num_versao_cus
     ELSE
         SELECT num_versao_cus
           FROM cent_cust_comp
          WHERE  cod_empresa=p_cod_empresa 
            AND  num_versao_cus=p_tela.num_versao_cus
          GROUP BY 1
         IF  sqlca.sqlcode  = NOTFOUND THEN
             ERROR " A versao de custo informada nao existe " 
             NEXT FIELD num_versao_cus  
         ELSE
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("SELECT","CENT_CUST_COMP")
             END IF
         END IF
     END IF
 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol01581
  IF  int_flag = 0 THEN
      CALL pol0158_emite_relatorio()
      CLOSE WINDOW w_pol01581
      RETURN TRUE 
  ELSE
      LET int_flag = 0
      RETURN FALSE 
  END IF
END FUNCTION
#---------------------------------#
 FUNCTION pol0158_emite_relatorio()
#---------------------------------#

  IF log028_saida_relat(17,40) IS NOT NULL THEN
    IF p_ies_impressao = "S" THEN
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0158_relat TO PIPE p_nom_arquivo
       ELSE
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0158.tmp'
          START REPORT pol0158_relat TO p_caminho
       END IF
    ELSE
       START REPORT pol0158_relat TO p_nom_arquivo
    END IF
  END IF

 MESSAGE "Processando relatorio ..." ATTRIBUTE(REVERSE)


 DECLARE cq_apo CURSOR   FOR 
    SELECT * FROM apo_cairu
    WHERE dat_referencia=p_tela.dat_referencia
    ORDER BY cod_item, num_seq_operac

 FOREACH cq_apo  INTO p_apo_cairu.*

  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("FOREACH","APO_CAIRU")
     EXIT FOREACH
  END IF

     
  SELECT sum(a.val_custo)              
    INTO p_relat.val_custo
    FROM  cent_cust_comp a, comp_custo_real b
   WHERE  a.cod_empresa=p_cod_empresa 
     AND  a.cod_empresa=b.cod_empresa
     AND  a.num_versao_cus=b.num_versao_cus
     AND  a.cod_comp_custo=b.cod_comp_custo
     AND  a.cod_cent_cust=p_apo_cairu.cod_cent_cust
     AND  a.num_versao_cus=p_tela.num_versao_cus
     AND  b.ies_tipo_trat="T"                    

   IF sqlca.sqlcode = NOTFOUND   THEN 
      LET p_relat.val_custo = 0 
      CONTINUE FOREACH
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("SELECT","CENT_CUST_COMP/COMP_CUSTO_REAL")
      END IF
   END IF
   
   IF pol0158_ver_consumo()  THEN 
      LET p_relat.qtd_horas = p_qtd_horas
   ELSE
      LET  p_relat.qtd_horas = 0   
   END IF 

   LET     p_relat.cod_item          =  p_apo_cairu.cod_item 
   LET     p_relat.dat_referencia    =  p_apo_cairu.dat_referencia              
   LET     p_relat.cod_operac        =  p_apo_cairu.cod_operac
   LET     p_relat.num_seq_operac    =  p_apo_cairu.num_seq_operac              
   LET     p_relat.cod_cent_cust     =  p_apo_cairu.cod_cent_cust               
   LET     p_relat.qtd_diferenca     =  p_apo_cairu.qtd_diferenca               
   LET     p_relat.val_total         =  p_apo_cairu.qtd_diferenca  *
                                        p_relat.val_custo          *
                                        p_qtd_horas

   OUTPUT TO REPORT pol0158_relat(p_relat.*)

 END FOREACH

 FINISH REPORT pol0158_relat

END FUNCTION
#------------------------------#
 FUNCTION pol0158_ver_consumo()
#------------------------------#

 LET p_qtd_horas = 0  

 DECLARE cq_cons CURSOR   FOR 
    SELECT qtd_horas FROM consumo   
    WHERE cod_empresa=p_cod_empresa
      AND cod_item=p_apo_cairu.cod_item 
      AND cod_operac=p_apo_cairu.cod_operac
      AND cod_cent_cust=p_apo_cairu.cod_cent_cust 

 FOREACH cq_cons  INTO p_qtd_horas   

      IF sqlca.sqlcode = NOTFOUND   THEN 
         LET p_qtd_horas = 0 
         EXIT FOREACH 
      ELSE
         IF sqlca.sqlcode <>  0
            THEN
            CALL log003_err_sql("FOREACH","CONSUMO")
            EXIT FOREACH
         END IF
      END IF
  
      EXIT FOREACH 

  END FOREACH 
 
  IF p_qtd_horas = 0   THEN 
     RETURN FALSE
  ELSE
     RETURN TRUE 
  END IF 

 END FUNCTION
#------------------------------------#
 FUNCTION pol0158_cursor_for_update()
#------------------------------------#
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_apo_cairu.*                                              
     FROM apo_cairu        
     WHERE     cod_item=p_apo_cairu.cod_item 
       AND     dat_referencia=p_apo_cairu.dat_referencia
       AND     cod_operac=p_apo_cairu.cod_operac
       AND     num_seq_operac=p_apo_cairu.num_seq_operac
       AND     cod_cent_cust=p_apo_cairu.cod_cent_cust 
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
      OTHERWISE CALL log003_err_sql("LEITURA","APO_CAIRU")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION
#----------------------------------#
 FUNCTION pol0158_modificacao()
#----------------------------------#
   IF pol0158_cursor_for_update() THEN
      LET p_apo_cairur.* = p_apo_cairu.*
      IF pol0158_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE apo_cairu SET 
                    apo_cairu.cod_item       = p_apo_cairu.cod_item,
                    apo_cairu.dat_referencia = p_apo_cairu.dat_referencia,
                    apo_cairu.num_seq_operac = p_apo_cairu.num_seq_operac,
                    apo_cairu.cod_operac     = p_apo_cairu.cod_operac,    
                    apo_cairu.cod_cent_cust  = p_apo_cairu.cod_cent_cust, 
                    apo_cairu.qtd_diferenca  = p_apo_cairu.qtd_diferenca  
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","T_APO_CAIRU")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","T_APO_CAIRU")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET p_apo_cairu.* = p_apo_cairur.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME p_apo_cairu.cod_item         
         DISPLAY BY NAME p_apo_cairu.dat_referencia         
         DISPLAY BY NAME p_apo_cairu.num_seq_operac         
         DISPLAY BY NAME p_apo_cairu.cod_operac         
         DISPLAY BY NAME p_apo_cairu.cod_cent_cust      
         DISPLAY BY NAME p_apo_cairu.qtd_diferenca      
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0158_exclusao()
#----------------------------------------#
   IF pol0158_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM apo_cairu      
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
          #  COMMIT WORK
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","APO_CAIRU")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_apo_cairu.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","APO_CAIRU")
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
 FUNCTION pol0158_ver_cc()
#-------------------------#
  SELECT *        
   FROM cad_cc              
  WHERE cod_cent_cust  = p_apo_cairu.cod_cent_cust
    AND cod_empresa    = p_cod_empresa 

  IF sqlca.sqlcode = 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION 

#------------------------------------#
 FUNCTION pol0158_verifica_item()
#------------------------------------#
  SELECT den_item 
   INTO p_item.den_item  
   FROM item                
  WHERE cod_item  = p_apo_cairu.cod_item
    AND cod_empresa    = p_cod_empresa 

  IF sqlca.sqlcode = 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION 

#------------------------------#
 REPORT pol0158_relat(p_relat)
#------------------------------#

  DEFINE p_relat      RECORD 
                            cod_item       LIKE apo_cairu.cod_item,
                            dat_referencia LIKE apo_cairu.dat_referencia,
                            cod_operac     LIKE apo_cairu.cod_operac,
                            num_seq_operac LIKE apo_cairu.num_seq_operac,
                            cod_cent_cust  LIKE apo_cairu.cod_cent_cust,
                            qtd_diferenca  LIKE apo_cairu.qtd_diferenca,
                            val_custo      LIKE cent_cust_comp.val_custo,
                            val_total      DECIMAL(15,2),                  
                            qtd_horas      DECIMAL(11,7)                   
                         END RECORD

 DEFINE p_total_empresa    DECIMAL (15,2) 

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
  FORMAT
    PAGE HEADER
      IF  PAGENO = 1 THEN
          LET p_total_empresa = 0                    
      END IF

      PRINT COLUMN 001, "POL0158",
            COLUMN 043, "INVENTARIO EM PROCESSO REF= ",
            COLUMN 073, MONTH(p_tela.dat_referencia),                
            COLUMN 075, "/",                                      
            COLUMN 076, YEAR(p_tela.dat_referencia),                
            COLUMN 094, "VERSAO CUSTO= ",                        
            COLUMN 110, p_tela.num_versao_cus  USING "####" ,       
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN 096, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN 001, "     ITEM          OPERAC.   SEQ.   CENTRO DE CUSTO     QUANTIDADE              VALOR DO CUSTO       QTD. HORAS        CUSTO TOTAL "     

      PRINT COLUMN 001, "---------------   --------  ------  -----------------   --------------------  ------------------   ----------------  -----------------"                                         

    ON EVERY ROW
      PRINT COLUMN 001, p_relat.cod_item,
            COLUMN 020, p_relat.cod_operac, 
            COLUMN 028, p_relat.num_seq_operac, 
            COLUMN 040, p_relat.cod_cent_cust, 
            COLUMN 057, p_relat.qtd_diferenca USING "-,---,---,--&.&&&", 
            COLUMN 076, p_relat.val_custo USING "----,---,--&.&&&&&&&",     
            COLUMN 095, p_relat.qtd_horas USING "-----,---,--&.&&&&&&&",     
            COLUMN 113, p_relat.val_total USING "---,---,---,--&.&&"     
   
    LET p_total_empresa = p_total_empresa + p_relat.val_total 

    ON LAST ROW
      LET p_last_row = true
      SKIP 1 LINE 
      PRINT COLUMN 090, "TOTAL DA EMPRESA ------: ",                       
            COLUMN 113, p_total_empresa   USING "---,---,---,--&.&&"     
      LET p_last_row = true

    PAGE TRAILER
      IF p_last_row = true THEN
         PRINT "* * * ULTIMA FOLHA * * *"
         LET p_last_row = true
      ELSE
         PRINT " "
      END IF
END REPORT

#-----------------------#
 FUNCTION pol0158_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
