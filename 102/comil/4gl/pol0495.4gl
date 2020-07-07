#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE ANÁLISES                                    #
# PROGRAMA: pol0495                                                 #
# OBJETIVO: CADASTRO DE MALHAS                                      #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 30/10/2006                                              #
# ALTERADO: 13/08/2007 por Ana Paula - versao 04                    #
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
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_retorno            SMALLINT,
          p_msg                CHAR(500)


   DEFINE p_malhas_comil   RECORD LIKE malhas_comil.*,
          p_malhas_comila  RECORD LIKE malhas_comil.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	LET p_versao = "pol0495-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0495.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0495_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0495_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0495") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0495 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         LET p_ies_cons = FALSE
         CALL pol0495_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0495_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF

{         IF p_ies_cons THEN
            IF pol0495_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF}
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0495_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0495_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0495_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0495_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0495","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0495_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0495.tmp'
                     START REPORT pol0495_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0495_relat TO p_nom_arquivo
               END IF
               CALL pol0495_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0495_relat   
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
	 			CALL pol0495_sobre()
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
   CLOSE WINDOW w_pol0495

END FUNCTION

#--------------------------#
 FUNCTION pol0495_inclusao()
#--------------------------#

   IF pol0495_entrada_dados("INCLUSAO") THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO malhas_comil VALUES (p_malhas_comil.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 CALL log003_err_sql("INCLUSAO","malhas_comil")       
         MESSAGE "Erro na gravação dos dados !!!" ATTRIBUTE(REVERSE)
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_malhas_comil.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0495_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(11)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0495
   
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_malhas_comil.* TO NULL
      CALL pol0495_exibe_dados()
      LET p_malhas_comil.cod_empresa = p_cod_empresa
   END IF

   INPUT BY NAME p_malhas_comil.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD tipo_granulo
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD val_malha
         END IF 

      AFTER FIELD tipo_granulo
         IF p_malhas_comil.tipo_granulo IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD tipo_granulo   
         END IF

      AFTER FIELD cod_malha  
         IF p_malhas_comil.cod_malha IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_malha   
         END IF

         SELECT *
           FROM malhas_comil
          WHERE cod_empresa  = p_malhas_comil.cod_empresa
            AND tipo_granulo = p_malhas_comil.tipo_granulo
            AND cod_malha    = p_malhas_comil.cod_malha

         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Tipo Granulometria/Malha já Cadastrada"  
            NEXT FIELD cod_malha
         END IF
           
      BEFORE FIELD val_malha
         IF p_malhas_comil.val_malha IS NULL THEN 
            LET p_malhas_comil.val_malha = 0
         END IF
      
      AFTER FIELD val_malha
         IF p_malhas_comil.val_malha IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD val_malha
         END IF

      AFTER FIELD min_malha
         IF p_malhas_comil.min_malha IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD min_malha
         END IF

      AFTER FIELD max_malha
         IF p_malhas_comil.max_malha IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD max_malha
         ELSE
            IF p_malhas_comil.max_malha <= p_malhas_comil.min_malha THEN
               ERROR "Malha Maxima nao poder menor que Malha Minima"
               NEXT FIELD max_malha
            END IF 
         END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0495

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0495_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_malhas_comil.*
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION

#--------------------------#
 FUNCTION pol0495_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_malhas_comila.* = p_malhas_comil.*

   CONSTRUCT BY NAME where_clause ON
      malhas_comil.tipo_granulo, 
      malhas_comil.cod_malha

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0495

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_malhas_comil.* = p_malhas_comila.*
      CALL pol0495_exibe_dados()
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM malhas_comil ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY tipo_granulo,cod_malha "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_malhas_comil.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0495_exibe_dados()
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0495_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(11)

   IF p_ies_cons THEN
      LET p_malhas_comila.* = p_malhas_comil.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_malhas_comil.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_malhas_comil.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_malhas_comil.* = p_malhas_comila.* 
            EXIT WHILE
         END IF

         SELECT *
          INTO p_malhas_comil.* 
           FROM malhas_comil
           WHERE cod_empresa  = p_malhas_comil.cod_empresa
             AND tipo_granulo = p_malhas_comil.tipo_granulo
             AND cod_malha    = p_malhas_comil.cod_malha
      
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0495_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0495_cursor_for_update()
#-----------------------------------#

{   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   
   SELECT * 
     INTO p_malhas_comil.*                                              
     FROM malhas_comil
    WHERE cod_empresa = p_cod_empresa
      AND cod_malha   = p_malhas_comil.cod_malha
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","malhas_comil")
      RETURN FALSE
   END IF}
   
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_malhas_comil.*                                              
     FROM malhas_comil  
    WHERE cod_empresa  = p_malhas_comil.cod_empresa
      AND tipo_granulo = p_malhas_comil.tipo_granulo
      AND cod_malha    = p_malhas_comil.cod_malha
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
      OTHERWISE CALL log003_err_sql("LEITURA","malhas_comil")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION


#-----------------------------#
 FUNCTION pol0495_modificacao()
#-----------------------------#

{   LET p_retorno = FALSE

   IF pol0495_cursor_for_update() THEN
      LET p_malhas_comila.* = p_malhas_comil.*
      IF pol0495_entrada_dados("MODIFICACAO") THEN
         UPDATE malhas_comil
            SET val_malha = p_malhas_comil.val_malha,
                min_malha = p_malhas_comil.min_malha,
                max_malha = p_malhas_comil.max_malha
         WHERE CURRENT OF cm_padrao       
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","malhas_comil,")
         END IF
      ELSE
         LET p_malhas_comil.* = p_malhas_comila.*
         CALL pol0495_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   RETURN p_retorno}

   IF pol0495_cursor_for_update() THEN
      LET p_malhas_comila.* = p_malhas_comil.*
      IF pol0495_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE malhas_comil 
            SET val_malha = p_malhas_comil.val_malha,
                min_malha = p_malhas_comil.min_malha,
                max_malha = p_malhas_comil.max_malha
            WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","malhas_comil")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_malhas_comil.* = p_malhas_comila.*
         ERROR "Modificacao Cancelada"
         CALL pol0495_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0495_exclusao()
#--------------------------#
   
   IF pol0495_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM malhas_comil
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_malhas_comil.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","malhas_comil")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0495_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_malha CURSOR FOR
    SELECT *
      FROM malhas_comil
     WHERE cod_empresa = p_cod_empresa
     ORDER BY tipo_granulo,cod_malha
     
   FOREACH cq_malha INTO p_malhas_comil.*
   
      OUTPUT TO REPORT pol0495_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#-----------------------#
 REPORT pol0495_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "POL0495                  MALHAS PARA GRANULAÇÃO",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"

         PRINT
         PRINT COLUMN 020, "    TIPO"
         PRINT COLUMN 018, "GRANULOMETRIA  MALHA    VALOR   MINIMO   MAXIMO"
         PRINT COLUMN 018, "-------------  -----   ------  -------  -------"
         PRINT
                           
      ON EVERY ROW
         PRINT COLUMN 018, p_malhas_comil.tipo_granulo USING "###############",
               COLUMN 033, p_malhas_comil.cod_malha    USING "#####",
               COLUMN 041, p_malhas_comil.val_malha    USING '##&.&&',
               COLUMN 049, p_malhas_comil.min_malha    USING '###&.&&&',
               COLUMN 058, p_malhas_comil.max_malha    USING '###&.&&&'
   
END REPORT


#-----------------------#
 FUNCTION pol0495_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#

