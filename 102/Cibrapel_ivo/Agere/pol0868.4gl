#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# CLIENTE.: TSUZUKI                                                 # 
# PROGRAMA: pol0868                                                 #
# OBJETIVO: CADASTRO DE LINHAS DE PRODUTO PARA ITENS LUVA           #
# AUTOR...: MARCELO ALVES CORREA                                    #
# DATA....: 03/11/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_erro_critico       SMALLINT,
          p_last_row           SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_msg                CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          
   DEFINE p_itens_luva_1049    RECORD LIKE itens_luva_1049.*  
   
   DEFINE p_den_estr_linprod   LIKE linha_prod.den_estr_linprod
   
   DEFINE p_cod_lin_proda      LIKE linha_prod.cod_lin_prod,
          p_cod_lin_receia     LIKE linha_prod.cod_lin_recei,
          p_cod_seg_merca      LIKE linha_prod.cod_seg_merc,
          p_cod_cla_usoa       LIKE linha_prod.cod_cla_uso                    
  
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP   
   DEFER INTERRUPT
   LET p_versao = "POL0868-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0868.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b
   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
      IF p_status = 0  THEN      
         CALL pol0868_controle()
      END IF      
END MAIN

#--------------------------#
 FUNCTION pol0868_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)      
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0868") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0868 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa   
   
   MENU "OPCAO"
   		COMMAND "Incluir" "Inclui Dados na Tabela"   
         HELP 001   		
         MESSAGE ""         
         CALL pol0868_inclusao() RETURNING p_status   		
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF           
      COMMAND "Excluir"  "Exclui Dados na Tabela"
        HELP 003
        MESSAGE ""
        IF p_ies_cons THEN
           CALL pol0868_exclusao() RETURNING p_status
           IF p_status THEN
              ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'              
           END IF
        ELSE
           ERROR "Consulte Previamente para fazer a Exclusao"
        END IF 
      COMMAND "Consultar Dados" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""      
         CALL pol0868_consulta()
         IF p_ies_cons THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         END IF         
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""            
         IF p_ies_cons THEN
            CALL pol0868_paginacao("S")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF                   		
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""            
         IF p_ies_cons THEN
            CALL pol0868_paginacao("A")
         ELSE
            ERROR "Nao Existe Nenhuma Consulta Ativa"
         END IF                
      COMMAND "Listar" "Listagem"
         HELP 007
         MESSAGE ""      
         CALL pol0868_listagem()       
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix        
         
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
            
   END MENU 
   CLOSE WINDOW w_pol0868
   
END FUNCTION

#--------------------------#
 FUNCTION pol0868_inclusao()
#--------------------------#

   INITIALIZE p_itens_luva_1049.* TO NULL

   IF pol0868_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO itens_luva_1049 VALUES (p_itens_luva_1049.*)
      IF SQLCA.SQLCODE <> 0 THEN 
      	 CALL log003_err_sql("INCLUSAO","p_itens_luva_1049")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa            
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0868_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   LET p_itens_luva_1049.cod_lin_prod = 0
   LET p_itens_luva_1049.cod_lin_recei = 0
   LET p_itens_luva_1049.cod_seg_merc = 0
   LET p_itens_luva_1049.cod_cla_uso = 0   
   INITIALIZE p_den_estr_linprod TO NULL     
   DISPLAY p_den_estr_linprod TO den_estr_linprod
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0868

   INPUT BY NAME p_itens_luva_1049.* WITHOUT DEFAULTS            
   
      ON KEY (control-z)
         CALL pol0868_popup()   
            
      AFTER INPUT

				 IF NOT INT_FLAG THEN
				 
 					 CALL pol0868_le_linha_produto() RETURNING p_msg
   
   				 IF p_msg IS NOT NULL THEN
              CALL log0030_mensagem(p_msg,'exclamation')   					
   					  INITIALIZE p_den_estr_linprod TO NULL
      				NEXT FIELD cod_lin_prod
   			 	 END IF
  				 DISPLAY p_den_estr_linprod TO den_estr_linprod			 
	         
           CALL pol0868_le_item_luva()

           IF STATUS <> 100 THEN
              IF STATUS = 0 THEN
                 DISPLAY BY NAME p_itens_luva_1049.*
                 LET p_msg = 'Linha de Produto para Item Luva já cadastrada'
              ELSE
                 LET p_msg = 'Erro (',STATUS,') Lendo tabela itens_luva_1049'
              END IF
              CALL log0030_mensagem(p_msg,'exclamation')
              LET p_den_estr_linprod = ''
              DISPLAY p_den_estr_linprod TO den_estr_linprod
              NEXT FIELD cod_lin_prod
           END IF			 
           
				 ELSE
  	       INITIALIZE p_itens_luva_1049 TO NULL	           				 				 
				 END IF		         				 			 				 
         
   END INPUT         

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0868

   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0868_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cq_prende CURSOR WITH HOLD FOR
   SELECT cod_lin_prod 
     FROM itens_luva_1049  
   WHERE cod_lin_prod = p_itens_luva_1049.cod_lin_prod
     AND cod_lin_recei = p_itens_luva_1049.cod_lin_recei
     AND cod_seg_merc = p_itens_luva_1049.cod_seg_merc
     AND cod_cla_uso = p_itens_luva_1049.cod_cla_uso      
   FOR UPDATE 
   
   OPEN cq_prende
   FETCH cq_prende
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
       CALL log003_err_sql("Lendo","itens_luva_1049")
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0868_exibe_dados()
#------------------------------#

   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0868_le_linha_produto() RETURNING p_msg
   IF p_msg IS NOT NULL THEN
      LET p_den_estr_linprod = p_msg
   END IF   
   
   DISPLAY BY NAME p_itens_luva_1049.*
   
   DISPLAY p_den_estr_linprod TO den_estr_linprod
     
END FUNCTION

#---------------------------------#
FUNCTION pol0868_le_linha_produto()
#---------------------------------#

   DEFINE p_erro CHAR(70)

   INITIALIZE p_den_estr_linprod, p_erro TO NULL

   SELECT den_estr_linprod          
     INTO p_den_estr_linprod          
     FROM linha_prod
    WHERE cod_lin_prod = p_itens_luva_1049.cod_lin_prod
      AND cod_lin_recei = p_itens_luva_1049.cod_lin_recei
      AND cod_seg_merc = p_itens_luva_1049.cod_seg_merc
      AND cod_cla_uso = p_itens_luva_1049.cod_cla_uso      
      
   IF STATUS = 100 THEN
      LET p_erro = 'Linha de Produto não cadastrada'
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = 'Erro (',STATUS,') Lendo tabela Linha Produto'
      END IF
   END IF

   RETURN(p_erro)      

END FUNCTION

#---------------------------------#
FUNCTION pol0868_le_item_luva()
#---------------------------------#

   SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso
     INTO p_itens_luva_1049.cod_lin_prod, p_itens_luva_1049.cod_lin_recei,
          p_itens_luva_1049.cod_seg_merc, p_itens_luva_1049.cod_cla_uso            
     FROM itens_luva_1049
    WHERE cod_lin_prod = p_itens_luva_1049.cod_lin_prod
      AND cod_lin_recei = p_itens_luva_1049.cod_lin_recei
      AND cod_seg_merc = p_itens_luva_1049.cod_seg_merc
      AND cod_cla_uso = p_itens_luva_1049.cod_cla_uso      

END FUNCTION

#---------------------------------#
FUNCTION pol0868_popup_linha_prod()
#---------------------------------#

   DEFINE pr_linha_prod    ARRAY[1000] OF RECORD
          cod_lin_prod     LIKE linha_prod.cod_lin_prod,
          cod_lin_recei    LIKE linha_prod.cod_lin_recei,
          cod_seg_merc     LIKE linha_prod.cod_seg_merc,
          cod_cla_uso      LIKE linha_prod.cod_cla_uso,
          den_estr_linprod LIKE linha_prod.den_estr_linprod                    
   END RECORD
   DEFINE  pr_index        SMALLINT
   
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08681") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08681 AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa   
   
   DECLARE cq_linha_prod CURSOR FOR 
    SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso, den_estr_linprod
      FROM linha_prod
      ORDER BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso

   LET pr_index = 1

   FOREACH cq_linha_prod INTO pr_linha_prod[pr_index].cod_lin_prod,
                              pr_linha_prod[pr_index].cod_lin_recei,
                              pr_linha_prod[pr_index].cod_seg_merc,
                              pr_linha_prod[pr_index].cod_cla_uso,                      
                              pr_linha_prod[pr_index].den_estr_linprod                      

      LET pr_index = pr_index + 1
      IF pr_index > 1000 THEN
         ERROR "Limite de Linhas da grade Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_linha_prod TO sr_linha_prod.*
   
   CLOSE WINDOW w_pol08681

   LET pr_index = ARR_CURR()
   
   LET p_itens_luva_1049.cod_lin_prod = pr_linha_prod[pr_index].cod_lin_prod
   LET p_itens_luva_1049.cod_lin_recei = pr_linha_prod[pr_index].cod_lin_recei
   LET p_itens_luva_1049.cod_seg_merc = pr_linha_prod[pr_index].cod_seg_merc
   LET p_itens_luva_1049.cod_cla_uso = pr_linha_prod[pr_index].cod_cla_uso
   LET p_den_estr_linprod = pr_linha_prod[pr_index].den_estr_linprod
   
   DISPLAY BY NAME p_itens_luva_1049.*
   
   DISPLAY p_den_estr_linprod TO den_estr_linprod           
   
   
END FUNCTION   

#-----------------------#
FUNCTION pol0868_popup()
#-----------------------#  

   CASE
      WHEN INFIELD(cod_lin_prod)
         CALL pol0868_popup_linha_prod()         
         CALL log006_exibe_teclas("01 02 03 07", p_versao)             
   END CASE

END FUNCTION 

#--------------------------#
 FUNCTION pol0868_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)              

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_lin_proda = p_itens_luva_1049.cod_lin_prod
   LET p_cod_lin_receia = p_itens_luva_1049.cod_lin_recei
   LET p_cod_seg_merca = p_itens_luva_1049.cod_seg_merc   
   LET p_cod_cla_usoa = p_itens_luva_1049.cod_cla_uso         
   
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      itens_luva_1049.cod_lin_prod,
      itens_luva_1049.cod_lin_recei,
      itens_luva_1049.cod_seg_merc,
      itens_luva_1049.cod_cla_uso            

   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_itens_luva_1049.cod_lin_prod = p_cod_lin_proda
         LET p_itens_luva_1049.cod_lin_recei = p_cod_lin_receia
         LET p_itens_luva_1049.cod_seg_merc = p_cod_seg_merca
         LET p_itens_luva_1049.cod_cla_uso = p_cod_cla_usoa      
         
         CALL pol0868_exibe_dados()
      END IF
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * ",
                  "  FROM itens_luva_1049 ",
                  " WHERE ", where_clause CLIPPED,                  
                  " ORDER BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_itens_luva_1049.*

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0868_exibe_dados()
   END IF
   
   RETURN

END FUNCTION

#-----------------------------------#
 FUNCTION pol0868_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_lin_proda = p_itens_luva_1049.cod_lin_prod
   LET p_cod_lin_receia = p_itens_luva_1049.cod_lin_recei
   LET p_cod_seg_merca = p_itens_luva_1049.cod_seg_merc   
   LET p_cod_cla_usoa = p_itens_luva_1049.cod_cla_uso         

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_itens_luva_1049.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_itens_luva_1049.*
         
      END CASE

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Nao Existem Mais Itens Nesta Direção"
         LET p_itens_luva_1049.cod_lin_prod = p_cod_lin_proda
         LET p_itens_luva_1049.cod_lin_recei = p_cod_lin_receia
         LET p_itens_luva_1049.cod_seg_merc = p_cod_seg_merca
         LET p_itens_luva_1049.cod_cla_uso = p_cod_cla_usoa                 
         EXIT WHILE
      END IF    
   
	    SELECT *
        INTO p_itens_luva_1049.cod_lin_prod,
             p_itens_luva_1049.cod_lin_recei,
             p_itens_luva_1049.cod_seg_merc,
             p_itens_luva_1049.cod_cla_uso
        FROM itens_luva_1049
       WHERE cod_lin_prod = p_itens_luva_1049.cod_lin_prod
         AND cod_lin_recei = p_itens_luva_1049.cod_lin_recei
         AND cod_seg_merc = p_itens_luva_1049.cod_seg_merc
         AND cod_cla_uso = p_itens_luva_1049.cod_cla_uso           
            
      IF STATUS = 0 THEN
         CALL pol0868_exibe_dados()
         EXIT WHILE
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql("Lendo","itens_luva_1049")       
            EXIT WHILE        
				 END IF                        
      END IF

   END WHILE

END FUNCTION

#--------------------------#
 FUNCTION pol0868_exclusao()
#--------------------------#

   LET p_retorno = FALSE   

   IF pol0868_prende_registro() THEN
      IF log004_confirm(18,35) THEN      
      
         DELETE FROM itens_luva_1049
				    		WHERE cod_lin_prod = p_itens_luva_1049.cod_lin_prod
    						AND cod_lin_recei = p_itens_luva_1049.cod_lin_recei
		      			AND cod_seg_merc = p_itens_luva_1049.cod_seg_merc
    		  			AND cod_cla_uso = p_itens_luva_1049.cod_cla_uso                       

         IF STATUS = 0 THEN               
            INITIALIZE p_itens_luva_1049 TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE                       
         ELSE
            CALL log003_err_sql("Excluindo","itens_luva_1049")
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
FUNCTION pol0868_listagem()
#--------------------------#     

   IF NOT pol0868_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0868_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imp CURSOR FOR
    SELECT cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso
      FROM itens_luva_1049
     ORDER BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso
   
   FOREACH cq_imp INTO 
           p_itens_luva_1049.cod_lin_prod,
           p_itens_luva_1049.cod_lin_recei,
           p_itens_luva_1049.cod_seg_merc,
           p_itens_luva_1049.cod_cla_uso

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','itens_luva_1049:cq_imp')
         EXIT FOREACH
      END IF
      
      CALL pol0868_le_linha_produto() RETURNING p_msg
      IF p_msg IS NOT NULL THEN
          LET p_den_estr_linprod = p_msg
      END IF      
      
      OUTPUT TO REPORT pol0868_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0868_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#-------------------------------#
FUNCTION pol0868_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0868.tmp"
         START REPORT pol0868_relat TO p_caminho
      ELSE
         START REPORT pol0868_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#----------------------------#
FUNCTION pol0868_le_empresa()
#----------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------#
 REPORT pol0868_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0868",
               COLUMN 017, "LINHAS DE PRODUTO PARA ITENS LUVA",
               COLUMN 052, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' LINHA PROD.   FAMILIA PROD.   SEG. MERCADO   CLASSE USO      DENOMINACAO      '
         PRINT COLUMN 001, '------------- --------------- -------------- ------------ -------------------- '

      ON EVERY ROW

         PRINT COLUMN 005, p_itens_luva_1049.cod_lin_prod USING '##&',
               COLUMN 020, p_itens_luva_1049.cod_lin_recei USING '##&', 
               COLUMN 036, p_itens_luva_1049.cod_seg_merc USING '##&',
               COLUMN 050, p_itens_luva_1049.cod_cla_uso USING '##&',                        
               COLUMN 059, p_den_estr_linprod[1,20]

      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#



 