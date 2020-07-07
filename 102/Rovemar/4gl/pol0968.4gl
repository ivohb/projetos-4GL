#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO DO LOGIX x EGA - MAN912                      #
# PROGRAMA: pol0968                                                 #
# MODULOS.: pol0968-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: DE-PARA CÓDIGOS DE MOVIMENTO EGA x LIGIX                #
# AUTOR...: POLO INFORMATICA 				                                #
# DATA....: 18/09/2009                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_des_parada         LIKE cfp_para.des_parada,
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
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          

   DEFINE p_rovmov_ega_man912   RECORD LIKE rovmov_ega_man912.*,
          p_rovmov_ega_man912a  RECORD LIKE rovmov_ega_man912.* 

   DEFINE pr_parada ARRAY[3000] OF RECORD
          cod_parada  LIKE cfp_para.cod_parada,
          des_parada  LIKE cfp_para.des_parada
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0968-12.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0968.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0968_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0968_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0968") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0968 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0968_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0968_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0968_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0968_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0968_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0968_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0968","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0968_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0968.tmp'
                     START REPORT pol0968_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0968_relat TO p_nom_arquivo
               END IF
               CALL pol0968_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0968_relat   
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
   CLOSE WINDOW w_pol0968

END FUNCTION

#--------------------------#
 FUNCTION pol0968_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0968_entrada_dados("INCLUSAO") THEN
      LET p_rovmov_ega_man912.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO rovmov_ega_man912 VALUES (p_rovmov_ega_man912.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","rovmov_ega_man912")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_rovmov_ega_man912.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0968_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0968
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_rovmov_ega_man912.* TO NULL
      CALL pol0968_exibe_dados()
      LET p_rovmov_ega_man912.cod_empresa = p_cod_empresa
   END IF

   INPUT BY NAME p_rovmov_ega_man912.* 
      WITHOUT DEFAULTS  

       BEFORE FIELD cod_mov_ega
          IF p_funcao = 'MODIFICACAO' THEN
             NEXT FIELD cod_mov_logix
          END IF
          
       AFTER FIELD cod_mov_ega
          IF p_rovmov_ega_man912.cod_mov_ega IS NULL OR 
             p_rovmov_ega_man912.cod_mov_ega = " " THEN 
             ERROR 'Campo c/ Preenchimento Obrigatório !!!'
             NEXT FIELD cod_mov_ega
          END IF
          IF pol0968_verifica_duplicidade() THEN
             ERROR 'Movimento já Cadastrado !!!'
             NEXT FIELD cod_mov_ega
          END IF 
       
       AFTER FIELD cod_mov_logix
          IF p_rovmov_ega_man912.cod_mov_logix IS NULL OR 
             p_rovmov_ega_man912.cod_mov_logix = " " THEN 
             ERROR 'Campo c/ Preenchimento Obrigatório !!!'
             NEXT FIELD cod_mov_logix
          END IF
          
          IF pol0968_verifica_existencia() = FALSE THEN
             ERROR 'Movimento não cadastrado !!!'
             NEXT FIELD cod_mov_logix
          ELSE
             IF pol0968_verifica_duplic_mov_logix(p_funcao) THEN
                ERROR 'Movimento LOGIX já Cadastrado !!!'
                NEXT FIELD cod_mov_logix
             END IF    
          END IF 

       AFTER FIELD ies_liberar
          IF p_rovmov_ega_man912.ies_liberar IS NOT NULL THEN
             IF p_rovmov_ega_man912.ies_liberar <> 'S' AND
                p_rovmov_ega_man912.ies_liberar <> 'N' THEN
                   ERROR 'Valor Ilegal !!!'
                   NEXT FIELD ies_liberar
             END IF    
          ELSE
             ERROR 'Campo com preenchimento obrigatório !!!'
             NEXT FIELD ies_liberar
          END IF

       AFTER FIELD aponta_como_boa
          IF p_rovmov_ega_man912.aponta_como_boa IS NOT NULL THEN
             IF p_rovmov_ega_man912.aponta_como_boa <> 'S' AND
                p_rovmov_ega_man912.aponta_como_boa <> 'N' THEN
                   ERROR 'Valor Ilegal !!!'
                   NEXT FIELD aponta_como_boa
             END IF    
          ELSE
             ERROR 'Campo com preenchimento obrigatório !!!'
             NEXT FIELD aponta_como_boa
          END IF
  
       ON KEY (f4,control-z)
          CALL pol0968_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0968

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol0968_verifica_existencia()
#-------------------------------------#

   SELECT des_parada
     INTO p_des_parada
     FROM cfp_para
    WHERE cod_empresa = p_cod_empresa
      AND cod_parada  = p_rovmov_ega_man912.cod_mov_logix
   IF SQLCA.sqlcode = NOTFOUND THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
      
END FUNCTION 
 
#--------------------------------------#
 FUNCTION pol0968_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE cod_mov_ega
     FROM rovmov_ega_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_mov_ega = p_rovmov_ega_man912.cod_mov_ega
   
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 
 
#----------------------------------------------------#
 FUNCTION pol0968_verifica_duplic_mov_logix(p_funcao)
#----------------------------------------------------#

   DEFINE p_funcao      CHAR(30)
   DEFINE p_cod_mov_ega LIKE rovmov_ega_man912.cod_mov_ega
   
   SELECT UNIQUE cod_mov_ega
     INTO p_cod_mov_ega
     FROM rovmov_ega_man912
    WHERE cod_empresa     = p_cod_empresa
      AND cod_mov_logix = p_rovmov_ega_man912.cod_mov_logix
   
   IF SQLCA.sqlcode = 0 THEN
      IF p_funcao = 'INCLUSAO' THEN
         RETURN TRUE
      ELSE
         IF p_cod_mov_ega <> p_rovmov_ega_man912.cod_mov_ega THEN
            RETURN TRUE
         ELSE
            RETURN FALSE
         END IF
      END IF
   ELSE 
      RETURN FALSE
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0968_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rovmov_ega_man912a.* = p_rovmov_ega_man912.*

 CONSTRUCT BY NAME where_clause ON rovmov_ega_man912.cod_mov_ega,
                                   rovmov_ega_man912.cod_mov_logix,
                                   rovmov_ega_man912.ies_liberar,
                                   rovmov_ega_man912.aponta_como_boa
                                   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0968
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_rovmov_ega_man912.* = p_rovmov_ega_man912a.*
      CALL pol0968_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF
   LET sql_stmt = "SELECT * FROM rovmov_ega_man912 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_mov_ega "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_rovmov_ega_man912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0968_exibe_dados()
   END IF
END FUNCTION

{
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rovmov_ega_man912a.* = p_rovmov_ega_man912.*

 CONSTRUCT BY NAME where_clause ON rovmov_ega_man912.cod_mov_ega,
                                   rovmov_ega_man912.cod_mov_logix
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0968
   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_rovmov_ega_man912.* = p_rovmov_ega_man912a.*
      CALL pol0968_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF
   LET sql_stmt = "SELECT * FROM rovmov_ega_man912 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_mov_ega "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_rovmov_ega_man912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0968_exibe_dados()
   END IF
END FUNCTION
}

#------------------------------#
 FUNCTION pol0968_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_rovmov_ega_man912.*
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0968_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_rovmov_ega_man912.*                                              
     FROM rovmov_ega_man912  
    WHERE cod_empresa = p_rovmov_ega_man912.cod_empresa
      AND cod_mov_ega = p_rovmov_ega_man912.cod_mov_ega
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
      OTHERWISE CALL log003_err_sql("LEITURA","rovmov_ega_man912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0968_modificacao()
#-----------------------------#

   IF pol0968_cursor_for_update() THEN
      LET p_rovmov_ega_man912a.* = p_rovmov_ega_man912.*
      IF pol0968_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE rovmov_ega_man912 
            SET cod_mov_logix   = p_rovmov_ega_man912.cod_mov_logix,
                ies_liberar     = p_rovmov_ega_man912.ies_liberar,
                aponta_como_boa = p_rovmov_ega_man912.aponta_como_boa
                WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","rovmov_ega_man912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_rovmov_ega_man912.* = p_rovmov_ega_man912a.*
         ERROR "Modificacao Cancelada"
         CALL pol0968_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0968_exclusao()
#--------------------------#

   IF pol0968_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM rovmov_ega_man912
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_rovmov_ega_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","rovmov_ega_man912")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0968_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rovmov_ega_man912a.* = p_rovmov_ega_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_rovmov_ega_man912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_rovmov_ega_man912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_rovmov_ega_man912.* = p_rovmov_ega_man912a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_rovmov_ega_man912.* 
         FROM rovmov_ega_man912
            WHERE cod_empresa = p_rovmov_ega_man912.cod_empresa
              AND cod_mov_ega = p_rovmov_ega_man912.cod_mov_ega
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0968_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0968_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_mov CURSOR FOR
      SELECT * FROM rovmov_ega_man912
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_mov_ega
   
   FOREACH cq_mov INTO p_rovmov_ega_man912.*
 
      OUTPUT TO REPORT pol0968_relat(p_rovmov_ega_man912.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0968_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD 
      cod_empresa     LIKE rovmov_ega_man912.cod_empresa,
      cod_mov_ega     LIKE rovmov_ega_man912.cod_mov_ega,          
      cod_mov_logix   LIKE rovmov_ega_man912.cod_mov_logix,
      ies_liberar     LIKE rovmov_ega_man912.ies_liberar,
      aponta_como_boa LIKE rovmov_ega_man912.aponta_como_boa
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0968",
               COLUMN 021, "MOVIMENTOS EGA - man912",
               COLUMN 054, "DATA: ", DATE USING "dd/mm/yyyy", " - ", TIME
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 015, "COD MOV EGA   COD MOV LOGIX   LIBERAR AP.C/BOA"
         PRINT COLUMN 015, "-----------   -------------   ------- --------"
      

      ON EVERY ROW

         PRINT COLUMN 015, p_relat.cod_mov_ega,
               COLUMN 029, p_relat.cod_mov_logix,
               COLUMN 048, p_relat.ies_liberar,
               COLUMN 057, p_relat.aponta_como_boa
   
END REPORT

#-----------------------#
 FUNCTION pol0968_popup()
#-----------------------#
   
   DEFINE p_codigo CHAR(05)
   CASE
      WHEN INFIELD(cod_mov_logix)
         CALL pol0968_popup_parada() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0968
         IF p_codigo IS NOT NULL THEN
            LET p_rovmov_ega_man912.cod_mov_logix = p_codigo
            DISPLAY BY NAME p_rovmov_ega_man912.cod_mov_logix
         END IF

   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol0968_popup_parada()
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09681") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09681 AT 7,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1

   DECLARE cq_parada CURSOR FOR
    SELECT cod_parada,
           des_parada
      FROM cfp_para
    WHERE cod_empresa = p_cod_empresa
    ORDER BY 2   

   FOREACH cq_parada INTO pr_parada[p_index].*
   
      LET p_index = p_index + 1
      
   END FOREACH

   CALL SET_COUNT(p_index - 1)
   

   DISPLAY ARRAY pr_parada TO  sr_parada.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
   
  RETURN pr_parada[p_index].cod_parada

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

