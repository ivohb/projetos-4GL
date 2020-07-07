#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0525                                                 #
# MODULOS.: pol0525-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE DUNS                                        #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 26/12/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_retorno            SMALLINT,
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
          p_msg                CHAR(500)
          

   DEFINE p_duns_itaesbra   RECORD LIKE duns_itaesbra.*,
          p_duns_itaesbraa  RECORD LIKE duns_itaesbra.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0525-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0525.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0525_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0525_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0525") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0525 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0525_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0525_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0525_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0525_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0525_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0525_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0525","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0525_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0525.tmp'
                     START REPORT pol0525_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0525_relat TO p_nom_arquivo
               END IF
               CALL pol0525_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0525_relat   
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
         CALL pol0525_sobre()
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
   CLOSE WINDOW w_pol0525

END FUNCTION

#--------------------------#
 FUNCTION pol0525_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_duns_itaesbra.* TO NULL
   LET p_duns_itaesbra.cod_empresa = p_cod_empresa

   IF pol0525_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO duns_itaesbra VALUES (p_duns_itaesbra.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 CALL log003_err_sql("INCLUSAO","duns_itaesbra")       
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
 FUNCTION pol0525_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0525

   INPUT BY NAME p_duns_itaesbra.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_cliente
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD num_duns
      END IF 

      AFTER FIELD cod_cliente
      IF p_duns_itaesbra.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente   
      END IF
      
      CALL pol0525_le_cliente()
      
      IF p_nom_cliente IS NULL THEN
         ERROR 'Cliente não cadastrado !!!'
         NEXT FIELD cod_cliente   
      END IF
      
      DISPLAY p_nom_cliente TO nom_cliente
      
      SELECT cod_empresa
        FROM duns_itaesbra
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente = p_duns_itaesbra.cod_cliente
           
      IF STATUS = 0 THEN
         ERROR 'Empresa/Cliente já contém DUNS cadastrado !!!'
         NEXT FIELD cod_cliente
      END IF
      
      AFTER FIELD num_duns
      IF p_duns_itaesbra.num_duns IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_duns
      END IF

      ON KEY (control-z)
         CALL pol0525_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0525

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol0525_le_cliente()
#----------------------------#

   INITIALIZE p_nom_cliente TO NULL
   
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_duns_itaesbra.cod_cliente

END FUNCTION

#--------------------------#
 FUNCTION pol0525_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_duns_itaesbraa.* = p_duns_itaesbra.*

   CONSTRUCT BY NAME where_clause ON 
      duns_itaesbra.cod_cliente,
      duns_itaesbra.num_duns

   ON KEY (control-z)
      CALL pol0525_popup()

   END CONSTRUCT

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_duns_itaesbra.* = p_duns_itaesbraa.*
      CALL pol0525_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM duns_itaesbra ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_duns_itaesbra.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0525_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0525_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_duns_itaesbra.*
   DISPLAY p_cod_empresa TO cod_empresa
   CALL pol0525_le_cliente()
   DISPLAY p_nom_cliente TO nom_cliente
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0525_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * 
     INTO p_duns_itaesbra.*                                              
     FROM duns_itaesbra  
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = p_duns_itaesbra.cod_cliente
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","duns_itaesbra")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0525_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0525_cursor_for_update() THEN
      
      LET p_duns_itaesbraa.* = p_duns_itaesbra.*
      IF pol0525_entrada_dados("MODIFICACAO") THEN
         UPDATE duns_itaesbra 
            SET num_duns = p_duns_itaesbra.num_duns
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","duns_itaesbra")
         END IF
      ELSE
         LET p_duns_itaesbra.* = p_duns_itaesbraa.*
         CALL pol0525_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0525_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0525_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM duns_itaesbra
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_duns_itaesbra.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","duns_itaesbra")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0525_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_duns_itaesbraa.* = p_duns_itaesbra.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_duns_itaesbra.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_duns_itaesbra.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_duns_itaesbra.* = p_duns_itaesbraa.* 
            EXIT WHILE
         END IF

         SELECT * 
           INTO p_duns_itaesbra.* 
           FROM duns_itaesbra
          WHERE cod_empresa = p_cod_empresa
            AND cod_cliente = p_duns_itaesbra.cod_cliente
         
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0525_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0525_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0525
         IF p_codigo IS NOT NULL THEN
            LET p_duns_itaesbra.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0525_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_duns CURSOR FOR
    SELECT * 
      FROM duns_itaesbra
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_cliente
   
   FOREACH cq_duns INTO p_duns_itaesbra.*
   
      CALL pol0525_le_cliente()
      OUTPUT TO REPORT pol0525_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0525_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "LISTAGEM DE DUNS",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0525",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT
         PRINT COLUMN 005, "    CLIENTE                    DECRICAOO                    DUNS      "
         PRINT COLUMN 005, "---------------  ------------------------------------  ---------------"
      
      ON EVERY ROW

         PRINT COLUMN 005, p_duns_itaesbra.cod_cliente,
               COLUMN 022, p_nom_cliente,
               COLUMN 060, p_duns_itaesbra.num_duns
   
END REPORT

#-----------------------#
 FUNCTION pol0525_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

