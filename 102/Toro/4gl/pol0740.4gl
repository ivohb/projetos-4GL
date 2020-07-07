#-----------------------------------------------------------------------#
# PROGRAMA: pol0740                                                     #
# OBJETIVO: RELATORIO DE AUDITORIA TORO                                 #
# AUTOR...: POLO INFORMATICA - BRUNO                                    #
# DATA....: 18/02/2008                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item2          LIKE audit_toro.cod_item,
          p_lin_imp            SMALLINT,
          p_msg                CHAR(300),
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
          p_caminho            CHAR(080)
      

  # END RECORD

   DEFINE p_audit_toro  RECORD LIKE audit_toro.*,
          p_audit_toroa RECORD LIKE audit_toro.*
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0740-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0740.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0740_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0740_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0740") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0740 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   MENU "OPCAO"
      COMMAND 'Consultar' 'Consulta as auditorias gravadas'
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
            CALL pol0740_consultar()
         COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0740_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0740_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0 
      COMMAND 'Listar' 'Lista as informações da tela'
         HELP 001
         MESSAGE ''
         IF p_ies_cons THEN
		         IF log005_seguranca(p_user,"VDP","pol0740","MO") THEN
		            IF log028_saida_relat(18,35) IS NOT NULL THEN
		               MESSAGE " Processando a Extracao do Relatorio..." 
		                  ATTRIBUTE(REVERSE)
		               IF p_ies_impressao = "S" THEN
		                  IF g_ies_ambiente = "U" THEN
		                     START REPORT pol0740_relat TO PIPE p_nom_arquivo
		                  ELSE
		                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
		                     LET p_caminho = p_caminho CLIPPED, 'pol0740.tmp'
		                     START REPORT pol0740_relat  TO p_caminho
		                  END IF
		               ELSE
		                  START REPORT pol0740_relat TO p_nom_arquivo
		               END IF
		               CALL pol0740_listar()   
		               IF p_count = 0 THEN
		                  ERROR "Nao Existem Dados para serem Listados" 
		               ELSE
		                  ERROR "Relatorio Processado com Sucesso" 
		               END IF
		               FINISH REPORT pol0740_relat   
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
         ELSE
            ERROR 'Ifrome previamente os parâmetros'
            NEXT OPTION 'Informar'
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0740_sobre() 
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

   CLOSE WINDOW w_pol0740

END FUNCTION

#-----------------------#
FUNCTION pol0740_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol0740_consultar()
#----------------------------#
 
  DEFINE sql_stmt, 
         where_clause CHAR(300)  
  
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  LET p_audit_toroa.* = p_audit_toro.*

   CONSTRUCT BY NAME where_clause ON audit_toro.cod_item, 
                                     audit_toro.num_programa,
                                     audit_toro.data,
                                     audit_toro.hora,
                                     audit_toro.usuario
   
         ON KEY (control-z)
         CALL pol0740_popup()
         
     END CONSTRUCT    

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0740

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_audit_toro.* = p_audit_toroa.*
      CALL pol0740_exibe_item()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM audit_toro ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,        
                  "ORDER BY cod_empresa "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_audit_toro.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0740_exibe_item()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0740_exibe_item()
#------------------------------#

 DISPLAY p_audit_toro.cod_empresa   TO cod_empresa
 DISPLAY p_audit_toro.cod_item      TO cod_item
 DISPLAY p_audit_toro.num_programa  TO num_programa
 DISPLAY p_audit_toro.data          TO data
 DISPLAY p_audit_toro.hora          TO hora
 DISPLAY p_audit_toro.usuario       TO usuario
 

 
 DISPLAY p_audit_toro.texto[1,71] TO texto
 DISPLAY p_audit_toro.texto[72,152] TO texto2

    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0740_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_audit_toroa.* = p_audit_toro.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_audit_toro.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_audit_toro.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_audit_toro.* = p_audit_toroa.* 
            EXIT WHILE
        END IF
         
         SELECT UNIQUE *
           INTO p_audit_toro.*
           FROM audit_toro
          WHERE cod_empresa = p_cod_empresa
          AND texto = p_audit_toro.texto
          AND hora = p_audit_toro.hora
          AND cod_item = p_audit_toro.cod_item
          AND data = p_audit_toro.data
          AND usuario = p_audit_toro.usuario
          AND num_programa = p_audit_toro.num_programa
          
                          
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0740_exibe_item()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-------------------------#
 FUNCTION pol0740_listar()
#-------------------------#


   DECLARE cq_toro CURSOR FOR
    SELECT * 
      FROM audit_toro
     ORDER BY cod_item
     
     FOREACH cq_toro INTO p_audit_toro.*

      OUTPUT TO REPORT pol0740_relat() 

  
    END FOREACH 

END FUNCTION

#----------------------#
 REPORT pol0740_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         LET p_lin_imp = 7
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 040, "AUDITORIA TABELA audit_toro",
               COLUMN 075, "PAG:", PAGENO USING "#&"
               
         PRINT COLUMN 001, "pol0740",
               COLUMN 040, "ORDEM: ", p_user,
               COLUMN 060, TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '     ITEM        PROGRAMA    DATA      HORA    USUARIO                        TEXTO                                       '
         PRINT COLUMN 001, '--------------- ---------- ---------- -------- -------- ------------------------------------------------------------------'
         PRINT
         
      ON EVERY ROW

         PRINT COLUMN 001, p_audit_toro.cod_item CLIPPED,
               COLUMN 017, p_audit_toro.num_programa CLIPPED,
               COLUMN 028, p_audit_toro.data CLIPPED,
               COLUMN 039, p_audit_toro.hora CLIPPED,
               COLUMN 048, p_audit_toro.usuario CLIPPED, 
               COLUMN 057, p_audit_toro.texto WORDWRAP RIGHT MARGIN 120
               
               
         
         LET p_lin_imp = p_lin_imp + 1
         
      ON LAST ROW
  
END REPORT
#-----------------------#
FUNCTION pol0740_popup()
#-----------------------#
   DEFINE p_codigo  CHAR(15)
          
     
   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0740
         IF p_codigo IS NOT NULL THEN
           LET p_audit_toro.cod_item = p_codigo
           DISPLAY p_audit_toro.cod_item TO cod_item
         END IF
   END CASE 
   
 END FUNCTION  
#-------------------------------- FIM DE PROGRAMA -----------------------------#
