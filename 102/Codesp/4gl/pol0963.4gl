#-------------------------------------------------------------------#
# SISTEMA.: TESTE                          												  #
# PROGRAMA: pol0963    																							#
# EMPRESA.:	CODESP		                                              #
# OBJETIVO: Cadastrar tabela retenção 912											      #
# AUTOR...: POLO INFORMATICA - THIAGO                               #
# DATA....: 16/03/2009                                              #
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
          

   DEFINE p_retencao  	RECORD 	LIKE 	retencao_912.*
   				
   DEFINE p_retencao01  RECORD 	LIKE 	retencao_912.*
   					

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0963-10.02.01"
   INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0963.iem") RETURNING p_nom_help
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
      CALL pol0963_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0963_controle()
#--------------------------#

  
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0963") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0963 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0963_inclusao() RETURNING p_status
      COMMAND "Modificar" "Inclui Dados das Cotas"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0963_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados das Cotas"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0963_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados das Cotas"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0963_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0963_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0963_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0963","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0963_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0963.tmp'
                     START REPORT pol0963_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0963_relat TO p_nom_arquivo
               END IF
               CALL pol0963_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0963_relat   
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
   CLOSE WINDOW w_pol0963
   
END FUNCTION

#--------------------------#
 FUNCTION pol0963_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0963_entrada_dados("INCLUSAO") THEN
      		LET p_retencao.cod_empresa = p_cod_empresa
      
      WHENEVER ERROR CONTINUE
      
      CALL log085_transacao("BEGIN")
      INSERT INTO retencao_912 VALUES (p_retencao.*)
      IF SQLCA.SQLCODE <> 0 THEN 
				 LET p_houve_erro = TRUE
				 CALL log003_err_sql("INCLUSAO","retencao_912")       
			ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_retencao.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0963_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0963
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_retencao.* TO NULL
      CALL pol0963_exibe_dados()
     LET p_retencao.cod_empresa = p_cod_empresa
   END IF

    INPUT BY NAME p_retencao.* WITHOUT DEFAULTS 
    		
        BEFORE FIELD	cod_retencao 
        	IF p_funcao  <> "INCLUSAO" THEN
        		NEXT FIELD pct_iss
        	END IF
				AFTER FIELD	cod_retencao 
					IF p_retencao.cod_retencao  IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD cod_retencao
					ELSE
						IF pol0963_verifica_duplicidade() THEN 
							ERROR"CODIGO JA CADASTRADO!!!"
							NEXT FIELD cod_retencao
						ELSE
							NEXT FIELD pct_iss
						END IF 
					END IF 
			
				AFTER FIELD	pct_iss 
					IF p_retencao.pct_iss  IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD pct_iss
					ELSE
						NEXT FIELD pct_irpj
					END IF 
					
				AFTER FIELD	pct_irpj
					IF p_retencao.pct_irpj  IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD pct_irpj
					ELSE
						NEXT FIELD pct_csll
					END IF 
					
				AFTER FIELD	pct_csll 
					IF p_retencao.pct_csll  IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD pct_csll
					ELSE
						NEXT FIELD pct_cofins
					END IF
					
				AFTER FIELD	pct_cofins
					IF p_retencao.pct_cofins IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD pct_cofins
					ELSE
						NEXT FIELD pct_pis
					END IF 
					
				AFTER FIELD	pct_pis
					IF p_retencao.pct_pis  IS NULL THEN
						ERROR"CAMPO DE PREENCHIMENTO OBRIGATORIO!!!"
						NEXT FIELD pct_pis
					END IF   
                            
     END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0963

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------------------#
 FUNCTION pol0963_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE cod_retencao
     FROM retencao_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_retencao = p_retencao.cod_retencao
   
   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 

#--------------------------#
 FUNCTION pol0963_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_retencao01.* = p_retencao.*

	CONSTRUCT BY NAME where_clause ON cod_retencao ,
																    pct_iss ,
																    pct_irpj ,
																    pct_csll ,
																    pct_cofins,
																    pct_pis
	



   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0963

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
    	LET p_retencao.* = p_retencao01.*
      CALL pol0963_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM retencao_912 ",
                  " WHERE ",where_clause CLIPPED,             
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_retencao "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_retencao.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0963_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0963_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_retencao.*
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION
   
   
#-----------------------------------#
 FUNCTION pol0963_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_retencao.*                                              
      FROM retencao_912
         WHERE cod_empresa    = p_retencao.cod_empresa
           AND cod_retencao      = p_retencao.cod_retencao
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
      OTHERWISE CALL log003_err_sql("LEITURA","retencao_912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0963_modificacao()
#-----------------------------#

   IF pol0963_cursor_for_update() THEN
      LET p_retencao01.* = p_retencao.*
      IF pol0963_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         
         			UPDATE retencao_912
            		SET pct_iss    = p_retencao.pct_iss,
								    pct_irpj   = p_retencao.pct_irpj,
								    pct_csll   = p_retencao.pct_csll,
								    pct_cofins = p_retencao.pct_cofins,
								    pct_pis    = p_retencao.pct_pis
                
                WHERE CURRENT OF cm_padrao
          	
          
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","retencao_912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_retencao.* = p_retencao01.*
         ERROR "Modificacao Cancelada"
         CALL pol0963_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0963_exclusao()
#--------------------------#

   IF pol0963_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM retencao_912
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_retencao.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
          
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","retencao_912")
            
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
         
      END IF
      CLOSE cm_padrao
   END IF
 
END FUNCTION  


#-----------------------------------#
 FUNCTION pol0963_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_retencao01.* = p_retencao.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_retencao.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_retencao.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_retencao.* = p_retencao01.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_retencao.* 
         FROM retencao_912
            WHERE cod_empresa    = p_retencao.cod_empresa
              AND cod_retencao = p_retencao.cod_retencao
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0963_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION




#-----------------------------------#
 FUNCTION pol0963_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM retencao_912
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_retencao
   
   FOREACH cq_oper INTO p_retencao.*
      
       OUTPUT TO REPORT pol0963_relat(p_retencao.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0963_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD   LIKE retencao_912.*
     

  
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0963",
               COLUMN 030, "CADASTRO DE RETENÇÃO DE IMPOSTO",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 001, "  CODIGO      ISS%      IRPJ%     CSLL%    COFINS%    PIS%  "                      
         PRINT COLUMN 001, "----------- --------- --------- --------- --------- -------- "
      

      ON EVERY ROW
         PRINT COLUMN 002, p_relat.cod_retencao,
         			 COLUMN 0013,p_relat.pct_iss ,
         			 COLUMN 0023,p_relat.pct_irpj ,
         			 COLUMN 0033,p_relat.pct_csll ,
         			 COLUMN 0043,p_relat.pct_cofins ,
         			 COLUMN 0053,p_relat.pct_pis 
        
   
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#