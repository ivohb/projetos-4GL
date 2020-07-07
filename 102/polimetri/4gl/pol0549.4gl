#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0549                                                 #
# MODULOS.: pol0549-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DO DESCONTO PADRÃO - KANAFLEX                  #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 19/02/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_recur          LIKE recurso.cod_recur,
          p_tem_recurso        SMALLINT,
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
          p_caminho            CHAR(80),
          p_den_arranjo        CHAR(30),
          p_den_cent_trab      CHAR(30),
          p_nom_cent_cust      CHAR(50),
          p_cod_arranjo        LIKE arranjo_drummer.cod_arranjo,
          p_msg                CHAR(500)

          
   DEFINE p_arranjo_drummer  RECORD LIKE arranjo_drummer.*,
          p_arranjo_drummera RECORD LIKE arranjo_drummer.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0549-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0549.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0549_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0549_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0549") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0549 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0549_inclusao() THEN
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
            IF pol0549_modificacao() THEN
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
            IF pol0549_exclusao() THEN
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
         CALL pol0549_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0549_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0549_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0549","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0549_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0549.tmp'
                     START REPORT pol0549_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0549_relat TO p_nom_arquivo
               END IF
               CALL pol0549_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0549_relat   
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
         CALL pol0549_sobre()
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
   CLOSE WINDOW w_pol0549

END FUNCTION

#--------------------------#
 FUNCTION pol0549_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_arranjo_drummer.* TO NULL
   LET p_arranjo_drummer.cod_empresa = p_cod_empresa

   IF pol0549_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO arranjo_drummer VALUES (p_arranjo_drummer.*)
      IF SQLCA.SQLCODE <> 0 THEN 
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
 FUNCTION pol0549_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0549

   INPUT BY NAME p_arranjo_drummer.*
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_arranjo
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_cent_trab
      END IF 

      #--- arranjo ---#
      AFTER FIELD cod_arranjo
      IF p_arranjo_drummer.cod_arranjo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_arranjo
      END IF
      SELECT den_arranjo
        INTO p_den_arranjo
        FROM arranjo
       WHERE cod_empresa = p_cod_empresa 
         AND cod_arranjo = p_arranjo_drummer.cod_arranjo
        
      IF SQLCA.sqlcode <> 0 THEN
         ERROR "Arranjo inexistente !!!"
         NEXT FIELD cod_arranjo
      END IF 
      DISPLAY p_den_arranjo TO den_arranjo
     
      SELECT * 
        FROM arranjo_drummer
       WHERE cod_empresa = p_cod_empresa
         AND cod_arranjo = p_arranjo_drummer.cod_arranjo
         
      IF STATUS = 0 THEN  
         ERROR 'Código já Cadastrado !!!'
         NEXT FIELD cod_arranjo
      END IF
      
      INITIALIZE p_cod_recur TO NULL

      LET p_tem_recurso = FALSE
      
      DECLARE cq_rec_ar CURSOR FOR
       SELECT cod_recur
         FROM rec_arranjo
        WHERE cod_empresa = p_cod_empresa
          AND cod_arranjo = p_arranjo_drummer.cod_arranjo
         
      FOREACH cq_rec_ar INTO p_cod_recur
         SELECT cod_recur
           FROM recurso
          WHERE cod_empresa   = p_cod_empresa
            AND cod_recur     = p_cod_recur
            AND ies_tip_recur = '2'
         
         IF SQLCA.sqlcode = 0 THEN 
            LET p_tem_recurso = TRUE
            EXIT FOREACH
         END IF      
         
      END FOREACH
   
      IF NOT p_tem_recurso THEN
         ERROR 'Arranjo sem recurso !!!'
         NEXT FIELD cod_arranjo
      END IF
      
      #--- cent_trabalho ---#
      AFTER FIELD cod_cent_trab
      IF p_arranjo_drummer.cod_cent_trab IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cent_trab
      END IF
      
      SELECT den_cent_trab
        INTO p_den_cent_trab
        FROM cent_trabalho
       WHERE cod_empresa   = p_cod_empresa
         AND cod_cent_trab = p_arranjo_drummer.cod_cent_trab
    
      IF SQLCA.sqlcode <> 0 THEN
         ERROR "Codigo do Centro de Trabalho não Cadastrado na Tabela CENT_TRABALHO !!!"
         NEXT FIELD cod_cent_trab
      END IF 
      DISPLAY p_den_cent_trab TO den_cent_trab

      #--- cad_cc ---#
      AFTER FIELD cod_cent_cust
      IF p_arranjo_drummer.cod_cent_cust IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cent_cust
      END IF
      SELECT nom_cent_cust
        INTO p_nom_cent_cust
        FROM cad_cc
       WHERE cod_empresa   = p_cod_empresa
         AND cod_cent_cust = p_arranjo_drummer.cod_cent_cust
     
      IF SQLCA.sqlcode <> 0 THEN
         ERROR "Codigo do Centro de Custo não Cadastrado na Tabela CAD_CC !!!"
         NEXT FIELD cod_cent_cust
      END IF 
      DISPLAY p_nom_cent_cust TO nom_cent_cust
    
      ON KEY (control-z)
      CALL pol0549_popup()
      
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0549

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0549_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_arranjo_drummera.* = p_arranjo_drummer.*

   CONSTRUCT BY NAME where_clause ON
       arranjo_drummer.cod_arranjo
         
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0549

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_arranjo_drummer.* = p_arranjo_drummera.*
      CALL pol0549_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM arranjo_drummer ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_arranjo "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_arranjo_drummer.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0549_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0549_exibe_dados()
#------------------------------#

  INITIALIZE p_den_arranjo,
             p_den_cent_trab,
             p_nom_cent_cust TO NULL
             
   SELECT den_arranjo
     INTO p_den_arranjo
     FROM arranjo
    WHERE cod_empresa = p_cod_empresa 
      AND cod_arranjo = p_arranjo_drummer.cod_arranjo

   SELECT den_cent_trab
     INTO p_den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa     = p_cod_empresa
      AND cod_cent_trab   = p_arranjo_drummer.cod_cent_trab

  DECLARE cq_custo CURSOR FOR
   SELECT nom_cent_cust
     FROM cad_cc
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_cust = p_arranjo_drummer.cod_cent_cust
  
  FOREACH cq_custo INTO p_nom_cent_cust
     EXIT FOREACH
  END FOREACH
  
  DISPLAY BY NAME p_arranjo_drummer.*
  DISPLAY p_den_arranjo   TO den_arranjo
  DISPLAY p_den_cent_trab TO den_cent_trab
  DISPLAY p_nom_cent_cust TO nom_cent_cust
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0549_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_arranjo_drummer.*                                              
     FROM arranjo_drummer
    WHERE cod_empresa = p_cod_empresa
      AND cod_arranjo = p_arranjo_drummer.cod_arranjo
   FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","arranjo_drummer")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0549_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0549_cursor_for_update() THEN
      LET p_arranjo_drummera.* = p_arranjo_drummer.*
      IF pol0549_entrada_dados("MODIFICACAO") THEN
         UPDATE arranjo_drummer
            SET cod_cent_trab = p_arranjo_drummer.cod_cent_trab,
                cod_cent_cust = p_arranjo_drummer.cod_cent_cust
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","ARRANJO_DRUMMER")
         END IF
      ELSE
         LET p_arranjo_drummer.* = p_arranjo_drummera.*
         CALL pol0549_exibe_dados()
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
 FUNCTION pol0549_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0549_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM arranjo_drummer
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_arranjo_drummer.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","ARRANJO_DRUMMER")
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
 FUNCTION pol0549_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_arranjo_drummera.* =  p_arranjo_drummer.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_arranjo_drummer.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_arranjo_drummer.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_arranjo_drummer.* = p_arranjo_drummera.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_arranjo_drummer.*
           FROM arranjo_drummer
          WHERE cod_empresa = p_cod_empresa
            AND cod_arranjo = p_arranjo_drummer.cod_arranjo

         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0549_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0549_popup()
#-----------------------#

   CASE
      WHEN INFIELD(cod_arranjo)
         CALL log009_popup(6,25,"ARRANJO","arranjo",
                            "cod_arranjo","den_arranjo","","N","") 
         RETURNING p_arranjo_drummer.cod_arranjo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0549
         IF p_arranjo_drummer.cod_arranjo IS NOT NULL THEN
            DISPLAY BY NAME p_arranjo_drummer.cod_arranjo
         END IF

      WHEN INFIELD (cod_cent_trab)
         CALL log009_popup(6,25,"CENTRO TRABALHO","cent_trabalho",
                            "cod_cent_trab","den_cent_trab","","N","") 
         RETURNING p_arranjo_drummer.cod_cent_trab
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0549
         IF p_arranjo_drummer.cod_cent_trab IS NOT NULL THEN
            DISPLAY BY NAME p_arranjo_drummer.cod_cent_trab
         END IF

      WHEN INFIELD(cod_cent_cust)
         CALL log009_popup(6,25,"CENTRO DE CUSTO","cad_cc",
                            "cod_cent_cust","nom_cent_cust","","N","") 
         RETURNING p_arranjo_drummer.cod_cent_cust
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0549
         IF p_arranjo_drummer.cod_cent_cust IS NOT NULL THEN
            DISPLAY BY NAME p_arranjo_drummer.cod_cent_cust
         END IF

   END CASE
END FUNCTION

#-----------------------------------#
 FUNCTION pol0549_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_arranjo_drummer CURSOR FOR
    SELECT * 
      FROM arranjo_drummer
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_arranjo
     
     FOREACH cq_arranjo_drummer INTO p_arranjo_drummer.*
   
      OUTPUT TO REPORT pol0549_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0549_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "TABELA DE ARRANJO DRUMMER",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0549",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT                  
         PRINT COLUMN 005, "           CENTRO     CENTRO"
         PRINT COLUMN 005, "ARRANJO    TRABALHO   CUSTO"
         PRINT COLUMN 005, "-------    --------   ------"
      
      ON EVERY ROW

         PRINT COLUMN 006, p_arranjo_drummer.cod_arranjo,
               COLUMN 018, p_arranjo_drummer.cod_cent_trab, 
               COLUMN 026, p_arranjo_drummer.cod_cent_cust
   
END REPORT

#-----------------------#
 FUNCTION pol0549_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#


