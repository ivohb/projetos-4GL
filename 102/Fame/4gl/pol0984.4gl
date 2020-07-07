#-------------------------------------------------------------------#
# SISTEMA.: PRAMETROS FAME                 												  #
# PROGRAMA: pol0984                                                 #
# OBJETIVO: CADASTRO DE PARAMETROS DE NOTA FISCAIS A SEREM AGRUPADAS#
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
          p_msg                CHAR(100),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),  
          g_ies_ambiente       CHAR(01),
#          p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
     			p_cod_excecao				 CHAR(05),
     			p_cod_excecao01			 CHAR(05)

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0984-10.02.00"
   INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0984.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0984_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0984_controle()
#--------------------------#

  
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0984") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0984 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0984_inclusao() RETURNING p_status
      COMMAND "Modificar" "Inclui Dados das Cotas"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0984_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados das Cotas"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0984_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados das Cotas"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0984_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0984_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0984_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0984","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0984_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0984.tmp'
                     START REPORT pol0984_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0984_relat TO p_nom_arquivo
               END IF
               CALL pol0984_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0984_relat   
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
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0984_sobre() 
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
   CLOSE WINDOW w_pol0984
   
END FUNCTION

#-----------------------#
FUNCTION pol0984_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION



#--------------------------#
 FUNCTION pol0984_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0984_entrada_dados("INCLUSAO") THEN
      
      WHENEVER ERROR CONTINUE
      
      CALL log085_transacao("BEGIN")
      INSERT INTO par_excecoes VALUES (p_cod_empresa,p_cod_excecao)
      IF SQLCA.SQLCODE <> 0 THEN 
				 LET p_houve_erro = TRUE
				 CALL log003_err_sql("INCLUSAO","par_excecoes")       
			ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_cod_excecao TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0984_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0984
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_cod_excecao TO NULL
      CALL pol0984_exibe_dados()
   END IF

    INPUT  p_cod_excecao WITHOUT DEFAULTS  FROM cod_excecao
          
          AFTER FIELD cod_excecao    

          	IF p_cod_excecao IS NULL OR p_cod_excecao = "" THEN 
             ERROR "Erro campo de preenchimento obrigatorio!!!"
             NEXT FIELD cod_excecao
           ELSE
           	IF pol0984_verifica_duplicidade() THEN
           		 ERROR "Registro duplicado!!"
           		 NEXT FIELD cod_excecao
           	END IF 
           END IF
                            
     END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0984

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------------------#
 FUNCTION pol0984_verifica_duplicidade()
#--------------------------------------#
   
   SELECT cod_excecao
     FROM par_excecoes
    WHERE cod_empresa = p_cod_empresa
      AND cod_excecao = p_cod_excecao
   
   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 

#--------------------------#
 FUNCTION pol0984_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_excecao01= p_cod_excecao

	CONSTRUCT BY NAME where_clause ON cod_excecao

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0984

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
    	LET p_cod_excecao= p_cod_excecao01
      CALL pol0984_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_excecao FROM par_excecoes ",
                  " WHERE ",where_clause CLIPPED,             
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_excecao "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_cod_excecao
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0984_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0984_exibe_dados()
#------------------------------#

   DISPLAY p_cod_excecao TO cod_excecao
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION
   
   
#-----------------------------------#
 FUNCTION pol0984_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_cod_excecao                                              
      FROM par_excecoes
         WHERE cod_empresa    = p_cod_empresa
           AND p_cod_excecao      = p_cod_excecao
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
      OTHERWISE CALL log003_err_sql("LEITURA","par_excecoes")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0984_modificacao()
#-----------------------------#

   IF pol0984_cursor_for_update() THEN
      LET p_cod_excecao01 = p_cod_excecao
      IF pol0984_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         
         			UPDATE par_excecoes
            		SET cod_excecao     = p_cod_excecao
                WHERE CURRENT OF cm_padrao
          	
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","par_excecoes")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_cod_excecao = p_cod_excecao01
         ERROR "Modificacao Cancelada"
         CALL pol0984_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0984_exclusao()
#--------------------------#

   IF pol0984_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM par_excecoes
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_cod_excecao TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
          
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","par_excecoes")
            
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
         
      END IF
      CLOSE cm_padrao
   END IF
 
END FUNCTION  


#-----------------------------------#
 FUNCTION pol0984_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_excecao01 = p_cod_excecao
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cod_excecao
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cod_excecao
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_cod_excecao = p_cod_excecao01 
            EXIT WHILE
         END IF

         SELECT cod_excecao INTO p_cod_excecao
         FROM par_excecoes
            WHERE cod_empresa    = p_cod_empresa
              AND cod_excecao =p_cod_excecao
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0984_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0984_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT cod_excecao FROM par_excecoes
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_excecao
   
   FOREACH cq_oper INTO p_cod_excecao
      
       OUTPUT TO REPORT pol0984_relat(p_cod_excecao) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0984_relat(p_relat)
#------------------------------#

   DEFINE p_relat    LIKE par_excecoes.cod_excecao
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0984",
               COLUMN 030, "EXCEÇÕES CADASTRADAS",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 001, "  Codigo      "                     
         PRINT COLUMN 001, "-----------     "
      
      ON EVERY ROW
					
         PRINT COLUMN 002, p_relat	
   
END REPORT

