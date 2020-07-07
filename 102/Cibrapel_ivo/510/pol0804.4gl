#-----------------------------------------------------------------------#
# PROGRAMA: pol0804                                                     #
# OBJETIVO: RELATORIO DE ERROS                                          #
# AUTOR...: POLO INFORMATICA - BRUNO                                    #
# DATA....: 14/05/2008                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_lin_imp            SMALLINT,
          p_salto              SMALLINT,
          p_nom_usuario        CHAR(08),       
          p_ies_cons           SMALLINT,
          p_rowid              INTEGER,
          sql_stmt             CHAR(500),
          where_clause         CHAR(200),  
          p_count              INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_tela2          CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(100)


  DEFINE pr_item               ARRAY[5000] OF RECORD
         cod_empresa           LIKE reserva_erro_885.cod_empresa,
         num_reserva           LIKE reserva_erro_885.num_reserva,
         cod_item              LIKE reserva_erro_885.cod_item,
         des_erro              LIKE reserva_erro_885.des_erro
          
   END RECORD

   DEFINE p_reserva_erro_885  RECORD LIKE reserva_erro_885.*
   
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0804-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0804.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0804_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0804_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0804") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0804 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND 'Consultar' 'Consulta as auditorias gravadas'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0804_consultar()
      COMMAND 'Listar' 'Lista as informações da tela'
         HELP 001
         MESSAGE ''

		         IF log005_seguranca(p_user,"VDP","pol0804","MO") THEN
		            IF log028_saida_relat(18,35) IS NOT NULL THEN
		               MESSAGE " Processando a Extracao do Relatorio..." 
		                  ATTRIBUTE(REVERSE)
		               IF p_ies_impressao = "S" THEN
		                  IF g_ies_ambiente = "U" THEN
		                     START REPORT pol0804_relat TO PIPE p_nom_arquivo
		                  ELSE
		                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
		                     LET p_caminho = p_caminho CLIPPED, 'pol0804.tmp'
		                     START REPORT pol0804_relat  TO p_caminho
		                  END IF
		               ELSE
		                  START REPORT pol0804_relat TO p_nom_arquivo
		               END IF
		               CALL pol0804_listar()   
		               IF p_count = 0 THEN
		                  ERROR "Nao Existem Dados para serem Listados" 
		               ELSE
		                  ERROR "Relatorio Processado com Sucesso" 
		               END IF
		               FINISH REPORT pol0804_relat   
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
		         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0804_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 003
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0804

END FUNCTION

#----------------------------#
 FUNCTION pol0804_consultar()
#----------------------------#

          SELECT COUNT (*)
            INTO p_count      
            FROM reserva_erro_885
           
     IF p_count = 0 THEN 
        ERROR"NAO EXISTEM REGISTROS A SEREM LISTADOS"
         RETURN
     END IF    
           
   IF NOT pol0804_carrega_dados() THEN
    ERROR"NAO EXISTEM REGISTROS A SEREM LISTADOS"
      RETURN
   END IF
   
   IF p_count > 14 THEN
      DISPLAY ARRAY pr_item TO  sr_item.* 
   ELSE
      INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
      
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0804_carrega_dados()
#---------------------------------#

   DEFINE p_opcao CHAR(01)
   
   LET p_index = 1

      LET sql_stmt = 
          "SELECT cod_empresa,num_reserva,cod_item,des_erro",
          "  FROM reserva_erro_885",
          " ORDER BY num_reserva"
    
   IF STATUS <> 0 THEN
     ERROR"NAO EXISTEM REGISTROS A SEREM LISTADOS"   
      CALL log003_err_sql("LEITURA","reserva_erro_885")
      RETURN FALSE
    END IF

   PREPARE var_query FROM sql_stmt      
   DECLARE cq_op CURSOR FOR var_query
   FOREACH cq_op INTO pr_item[p_index].*
 
      LET p_index = p_index + 1
      
   END FOREACH
    
   CALL SET_COUNT(p_index - 1)

   RETURN TRUE
   
END FUNCTION

#-------------------------#
 FUNCTION pol0804_listar()
#-------------------------#

   IF NOT pol0804_carrega_dados() THEN
      RETURN
   END IF 
  
   FOR p_index = 1 TO p_count

      OUTPUT TO REPORT pol0804_relat() 

   END FOR

END FUNCTION

#----------------------#
 REPORT pol0804_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         LET p_lin_imp = 7
         
         PRINT COLUMN 015, "RELATORIO DE ERROS",
               COLUMN 040, "PAG:", PAGENO USING "#&"
               
         PRINT COLUMN 001, "pol0804",
               COLUMN 015, "ORDEM: ", p_user,
               COLUMN 040, TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' Empresa    Num.Reser.     Item                     Desc. Erro                           '   
         PRINT COLUMN 001, '----------  ---------- --------------- --------------------------------------------------'
         PRINT               
         
      ON EVERY ROW

         PRINT COLUMN 005, pr_item[p_index].cod_empresa, 
               COLUMN 012, pr_item[p_index].num_reserva, 
               COLUMN 024, pr_item[p_index].cod_item,
               COLUMN 040, pr_item[p_index].des_erro
               
               
               
         
         LET p_lin_imp = p_lin_imp + 1
         SKIP 001 LINES
         
      ON LAST ROW
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
         
                        
END REPORT

#-----------------------#
 FUNCTION pol0804_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
