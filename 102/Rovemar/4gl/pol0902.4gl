#-------------------------------------------------------------------#
# SISTEMA.: TESTE                          												  #
# PROGRAMA: pol0902                                                 #
# OBJETIVO: TESTE DE DESENVOLVIMENTO													      #
# AUTOR...: POLO INFORMATICA - THIAGO                               #
# DATA....: 16/03/2009                                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
#          p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          

   DEFINE p_cota  	RECORD 	LIKE 	cotas_1120.*
   				
   DEFINE p_cota01  RECORD 	LIKE 	cotas_1120.*
   					

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0902-10.02.02"
   INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0902.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0902_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0902_controle()
#--------------------------#

  
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0902") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0902 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0902_inclusao() RETURNING p_status
      COMMAND "Modificar" "Inclui Dados das Cotas"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0902_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados das Cotas"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0902_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados das Cotas"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0902_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0902_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0902_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0902","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0902_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0902.tmp'
                     START REPORT pol0902_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0902_relat TO p_nom_arquivo
               END IF
               CALL pol0902_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0902_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0902
   
END FUNCTION

#--------------------------#
 FUNCTION pol0902_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0902_entrada_dados("INCLUSAO") THEN
      		LET p_cota.cod_empresa = p_cod_empresa
      
      WHENEVER ERROR CONTINUE
      
      CALL log085_transacao("BEGIN")
      INSERT INTO cotas_1120 VALUES (p_cota.*)
      IF SQLCA.SQLCODE <> 0 THEN 
				 LET p_houve_erro = TRUE
				 CALL log003_err_sql("INCLUSAO","cotas_1120")       
			ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_cota.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0902_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0902
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_cota.* TO NULL
      CALL pol0902_exibe_dados()
      LET p_cota.cod_empresa = p_cod_empresa
   END IF

    INPUT BY NAME p_cota.* WITHOUT DEFAULTS 
       
        	
              
      { AFTER FIELD num_cota
          IF p_cota.num_cota IS NULL OR 
             p_cota.num_cota = " " THEN 
             ERROR 'Informe um codigo...'
             NEXT FIELD num_cota
             
          ELSE
             IF pol0902_verifica_duplicidade() THEN
                ERROR 'Codigo ja cadastrado Cadastrada.'
              	NEXT FIELD num_cota
             ELSE
             	NEXT FIELD den_cota
             END IF 
          END IF }
          BEFORE FIELD den_cota
			       IF p_funcao = "INCLUSAO" THEN
			       		SELECT MAX(num_cota )
			       		INTO p_cota.num_cota 
			       		FROM cotas_1120
			       		
			       		IF p_cota.num_cota IS NULL THEN
			       			LET p_cota.num_cota = 0
			       		END IF 
			       		
			       		 LET p_cota.num_cota =p_cota.num_cota +1
			       		 DISPLAY p_cota.num_cota TO num_cota
			       END IF
          
          
          AFTER FIELD den_cota
          	IF p_cota.den_cota IS NULL OR p_cota.num_cota = "" THEN 
             ERROR 'CAMPO DESCRIÇÃO NULO, POR FAVOR INFORMAR DESCRIÇÃO...'
             NEXT FIELD den_cota
           END IF
            
       BEFORE FIELD observacao
       			IF p_cota.den_cota IS NULL THEN 
             ERROR 'CAMPO DESCRIÇÃO NULO, POR FAVOR INFORMAR DESCRIÇÃO...'
             NEXT FIELD den_cota
           END IF

                            
     END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0902

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------------------#
 FUNCTION pol0902_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE num_cota
     FROM cotas_1120
    WHERE cod_empresa = p_cod_empresa
      AND num_cota = p_cota.num_cota
   
   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 

#--------------------------#
 FUNCTION pol0902_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cota01.* = p_cota.*

	CONSTRUCT BY NAME where_clause ON num_cota,
																		den_cota,
																		observacao
	



   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0902

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
    	LET p_cota.* = p_cota01.*
      CALL pol0902_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM cotas_1120 ",
                  " WHERE ",where_clause CLIPPED,             
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY num_cota "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_cota.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0902_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0902_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_cota.*
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION
   
   
#-----------------------------------#
 FUNCTION pol0902_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_cota.*                                              
      FROM cotas_1120
         WHERE cod_empresa    = p_cota.cod_empresa
           AND num_cota      = p_cota.num_cota
             FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","cotas_1120")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0902_modificacao()
#-----------------------------#

   IF pol0902_cursor_for_update() THEN
      LET p_cota01.* = p_cota.*
      IF pol0902_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         
         			UPDATE cotas_1120
            		SET den_cota     = p_cota.den_cota,
            				observacao = p_cota.observacao
                
                WHERE CURRENT OF cm_padrao
          	
          
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","cotas_1120")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_cota.* = p_cota01.*
         ERROR "Modificacao Cancelada"
         CALL pol0902_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0902_exclusao()
#--------------------------#

   IF pol0902_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM cotas_1120
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_cota.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
          
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","cotas_1120")
            
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
         
      END IF
      CLOSE cm_padrao
   END IF
 
END FUNCTION  


#-----------------------------------#
 FUNCTION pol0902_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cota01.* = p_cota.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cota.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cota.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_cota.* = p_cota01.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_cota.* 
         FROM cotas_1120
            WHERE cod_empresa    = p_cota.cod_empresa
              AND num_cota = p_cota.num_cota
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0902_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION




#-----------------------------------#
 FUNCTION pol0902_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM cotas_1120
       WHERE cod_empresa = p_cod_empresa
       ORDER BY num_cota
   
   FOREACH cq_oper INTO p_cota.*
      
       OUTPUT TO REPORT pol0902_relat(p_cota.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0902_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD   LIKE cotas_1120.*
     

  
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0902",
               COLUMN 030, "COTAS CADASTRADAS",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 001, "  Codigo        Descriçao"                      
         PRINT COLUMN 001, "-----------     ------------------------- "
      

      ON EVERY ROW
					
					IF p_relat.observacao IS NULL THEN
						LET p_relat.observacao = "*********************************"
				END IF
					
         PRINT COLUMN 002, p_relat.num_cota,
         			 COLUMN 0019,p_relat.den_cota
        
         			 
        PRINT  COLUMN 002, "Observação: ", p_relat.observacao
             
               
   
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#