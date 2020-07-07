#-------------------------------------------------------------------#
# SISTEMA.: ASSISTÊNCIA TÉCNICA                                     #
# PROGRAMA: pol0557                                                 #
# MODULOS.: pol0557-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO PARAMETROS PARA ROMANEIO - ITAESBRA            #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 08/03/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_msg                CHAR(500)          
         
   DEFINE p_cod_cliente        LIKE clientes.cod_cliente,  
          p_nom_cliente        LIKE clientes.nom_cliente,  
          p_qtd_linhas_nf      LIKE par_romaneio_970.qtd_linhas_nf
                             
   DEFINE p_par_romaneio_970   RECORD LIKE par_romaneio_970.*,
          p_par_romaneio_970a  RECORD LIKE par_romaneio_970.*
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0557-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0557.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  #CALL log001_acessa_usuario("VDP")
  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0557_controle()
   END IF
END MAIN
  
#--------------------------#
 FUNCTION pol0557_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0557") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0557 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0557_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0557_modificacao()
          ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0557_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0557_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0557_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0557_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0557","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0557_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0557.tmp'
                     START REPORT pol0557_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0557_relat TO p_nom_arquivo
               END IF
               CALL pol0557_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0557_relat   
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
         CALL pol0557_sobre()
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
   CLOSE WINDOW w_pol0557

END FUNCTION

#--------------------------#
 FUNCTION pol0557_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0557_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_romaneio_970 VALUES(p_par_romaneio_970.*)
      IF SQLCA.SQLCODE <> 0 THEN 
   	     LET p_houve_erro = TRUE
         CALL log085_transacao("ROLLBACK")   	     
   	     CALL log003_err_sql("INCLUSAO","par_romaneio_970")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_par_romaneio_970 TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
 
#---------------------------------------#
 FUNCTION pol0557_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0557
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_par_romaneio_970.* TO NULL
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   INPUT BY NAME p_par_romaneio_970.* 
      WITHOUT DEFAULTS  
 
      BEFORE FIELD cod_cliente
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD qtd_linhas_nf
      END IF 

      AFTER FIELD cod_cliente 
      IF p_par_romaneio_970.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente
      END IF
      
      SELECT cod_cliente
        FROM par_romaneio_970
       WHERE cod_cliente = p_par_romaneio_970.cod_cliente

      IF SQLCA.sqlcode = 0 THEN 
         ERROR "Cliente ja cadastrado na Tabela PAR_ROMANEIO_970!!!"
         NEXT FIELD cod_cliente
      END IF

      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_par_romaneio_970.cod_cliente

      IF SQLCA.sqlcode = NOTFOUND THEN 
         ERROR "Cliente não Cadastrado !!!"
         NEXT FIELD cod_cliente
      ELSE
         DISPLAY p_nom_cliente TO nom_cliente
      END IF

      AFTER FIELD qtd_linhas_nf
      IF p_par_romaneio_970.qtd_linhas_nf IS NULL THEN 
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD qtd_linhas_nf
      ELSE
         IF p_par_romaneio_970.qtd_linhas_nf = 0 THEN
            ERROR "Qtde de linhas da NF deve ser > 0 !!!"
            NEXT FIELD qtd_linhas_nf
         END IF                 
      END IF
   
      ON KEY (control-z)
         CALL pol0557_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0557

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0557_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_romaneio_970a.* = p_par_romaneio_970.*
   
   CONSTRUCT BY NAME where_clause ON 
      par_romaneio_970.cod_cliente
      
      ON KEY (control-z)
      CALL pol0557_popup()
   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0557

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_par_romaneio_970.* = p_par_romaneio_970a.*
      CALL pol0557_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM par_romaneio_970 ",
                  " WHERE ", where_clause CLIPPED,                 
                  "ORDER BY cod_cliente"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_romaneio_970.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0557_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0557_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_par_romaneio_970.*
   DISPLAY p_cod_empresa TO cod_empresa   

   INITIALIZE p_qtd_linhas_nf TO NULL
   INITIALIZE p_nom_cliente   TO NULL
    
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_par_romaneio_970.cod_cliente
   DISPLAY p_nom_cliente TO nom_cliente
   
   SELECT qtd_linhas_nf
     INTO p_qtd_linhas_nf
     FROM par_romaneio_970
    WHERE cod_cliente = p_par_romaneio_970.cod_cliente
   DISPLAY p_qtd_linhas_nf TO qtd_linhas_nf

END FUNCTION

#------------------------------------#
 FUNCTION pol0557_cursor_for_update()
#------------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *
     INTO p_par_romaneio_970.*                                              
     FROM par_romaneio_970
    WHERE cod_cliente = p_par_romaneio_970.cod_cliente
    
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
      OTHERWISE CALL log003_err_sql("LEITURA","par_romaneio_970")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE
END FUNCTION

#------------------------------#
 FUNCTION pol0557_modificacao()
#------------------------------#

   IF pol0557_cursor_for_update() THEN
      LET p_par_romaneio_970a.* = p_par_romaneio_970.*
      IF pol0557_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE par_romaneio_970
            SET par_romaneio_970.* = p_par_romaneio_970.*
          WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","par_romaneio_970")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_par_romaneio_970.* = p_par_romaneio_970a.*
         ERROR "Modificacao Cancelada"
         CALL pol0557_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF
END FUNCTION

#--------------------------#
 FUNCTION pol0557_exclusao()
#--------------------------#

   IF pol0557_cursor_for_update() THEN
      IF log004_confirm(20,40) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM par_romaneio_970
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_par_romaneio_970.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            DISPLAY p_user TO cod_usuario
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","par_romaneio_970")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0557_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_par_romaneio_970a.* = p_par_romaneio_970.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_romaneio_970.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_romaneio_970.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_par_romaneio_970.* = p_par_romaneio_970a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_par_romaneio_970.* 
           FROM par_romaneio_970
          WHERE cod_cliente = p_par_romaneio_970.cod_cliente

         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0557_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0557_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0557
         IF p_codigo IS NOT NULL THEN
            LET p_par_romaneio_970.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

   END CASE

END FUNCTION

#-----------------------------------#
 FUNCTION pol0557_emite_relatorio()
#-----------------------------------#

   DEFINE P_tamanho, p_espaco, p_ind SMALLINT

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   INITIALIZE p_par_romaneio_970.* TO NULL
  
   DECLARE cq_romaneio CURSOR FOR 
    SELECT *
      FROM par_romaneio_970
     ORDER BY cod_cliente
  
   FOREACH cq_romaneio INTO p_par_romaneio_970.*  

      OUTPUT TO REPORT pol0557_relat() 
      LET p_count = p_count + 1

   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0557_relat()
#----------------------#

   OUTPUT LEFT    MARGIN 0
           TOP    MARGIN 0
           BOTTOM MARGIN 3
   
   FORMAT

      PAGE HEADER
      
         PRINT COLUMN 001, p_descomprime, p_den_empresa,
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0557",
               COLUMN 025, "RELATORIO DOS PARAMETROS DO ROMANEIO",
               COLUMN 065, "DATA: ", TODAY USING "DD/MM/YYYY"
         
         PRINT COLUMN 001, "*----------------------------------------------------------------",
                           "----------------------------------------------------------------*"
         PRINT
         PRINT COLUMN 002, "CLIENTE           QTDE LINHAS NF"
         PRINT COLUMN 002, "---------------   --------------"
     
      ON EVERY ROW

         PRINT COLUMN 002, p_par_romaneio_970.cod_cliente,
               COLUMN 020, p_par_romaneio_970.qtd_linhas_nf
         
END REPORT

#-----------------------#
 FUNCTION pol0557_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
