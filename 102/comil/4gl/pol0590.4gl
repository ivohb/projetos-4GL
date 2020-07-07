#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0590                                                 #
# MODULOS.: pol0590-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE RESULTADOS POR TIPO DE ANALISE - COMIL      #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 14/05/2007                                              #
# ALTERADO: 14/05/2007 por Ana Paula - versao 01                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,          
          p_tip_analise        LIKE it_analise_comil.tip_analise,
          p_den_analise        LIKE it_analise_comil.den_analise         

   DEFINE p_result_analise741   RECORD LIKE result_analise741.*,
          p_result_analise741a  RECORD LIKE result_analise741.* 

   DEFINE p_it_analise_comil    RECORD LIKE it_analise_comil.*,
          p_it_analise_comila   RECORD LIKE it_analise_comil.*

   DEFINE pr_analise  ARRAY[300] OF RECORD
          tip_analise LIKE it_analise_comil.tip_analise,
          den_analise LIKE it_analise_comil.den_analise
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0590-05.10.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0590.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0590_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0590_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0590") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0590 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na divisao"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0590_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da divisao"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0590_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da divisao"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0590_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da divisao"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0590_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0590_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0590_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0590","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0590_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0590.tmp'
                     START REPORT pol0590_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0590_relat TO p_nom_arquivo
               END IF
               CALL pol0590_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0590_relat   
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
   CLOSE WINDOW w_pol0590

END FUNCTION

#--------------------------#
 FUNCTION pol0590_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_result_analise741.* TO NULL
   LET p_result_analise741.cod_empresa = p_cod_empresa

   IF pol0590_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO result_analise741 VALUES (p_result_analise741.*)
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
 FUNCTION pol0590_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0590

   INPUT BY NAME p_result_analise741.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD tip_analise
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_result
      END IF 

      AFTER FIELD tip_analise
      IF p_result_analise741.tip_analise IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD tip_analise
      END IF
      
      SELECT den_analise
        INTO p_den_analise
        FROM it_analise_comil
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = p_result_analise741.tip_analise
         AND ies_tip_texto = "S"

      IF STATUS <> 0 THEN  
         ERROR 'Analise nao cadastrada ou inválida !!!'
         NEXT FIELD tip_analise
      END IF
       
      DISPLAY p_den_analise TO den_analise
       
      AFTER FIELD cod_result
      IF p_result_analise741.cod_result IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_result
      END IF
      
      SELECT cod_result
        FROM result_analise741
       WHERE cod_empresa = p_cod_empresa
         AND tip_analise = p_result_analise741.tip_analise
         AND cod_result  = p_result_analise741.cod_result

      IF STATUS = 0 THEN  
         ERROR 'Codigo ja cadastrado na Tabela RESULT_ANALISE741 !!!'
         NEXT FIELD cod_result
      END IF
            
      AFTER FIELD den_result
      IF p_result_analise741.den_result IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_result
      END IF

      ON KEY (control-z)
         CALL pol0590_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0590

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0590_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_result_analise741a.* = p_result_analise741.*

   CONSTRUCT BY NAME where_clause ON
       result_analise741.tip_analise,
       result_analise741.cod_result
         
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0590

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_result_analise741.* = p_result_analise741a.*
      CALL pol0590_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM result_analise741 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY tip_analise,cod_result "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_result_analise741.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0590_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0590_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_result_analise741.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_analise TO NULL
   SELECT den_analise
     INTO p_den_analise
     FROM it_analise_comil
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = p_result_analise741.tip_analise
      
   DISPLAY p_den_analise TO den_analise
   
END FUNCTION
 
#-----------------------------------#
 FUNCTION pol0590_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   
   SELECT * 
     INTO p_result_analise741.*                                              
     FROM result_analise741
    WHERE cod_empresa = p_cod_empresa
      AND tip_analise = p_result_analise741.tip_analise
      AND cod_result  = p_result_analise741.cod_result
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","result_analise741")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0590_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0590_cursor_for_update() THEN
      LET p_result_analise741a.* = p_result_analise741.*
      IF pol0590_entrada_dados("MODIFICACAO") THEN
         UPDATE result_analise741
            SET cod_result = p_result_analise741.cod_result,
                den_result = p_result_analise741.den_result
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","result_analise741")
         END IF
      ELSE
         LET p_result_analise741.* = p_result_analise741a.*
         CALL pol0590_exibe_dados()
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
 FUNCTION pol0590_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0590_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM result_analise741
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_result_analise741.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","result_analise741")
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
 FUNCTION pol0590_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(30)

   IF p_ies_cons THEN
      LET p_result_analise741a.* = p_result_analise741.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_result_analise741.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_result_analise741.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_result_analise741.* = p_result_analise741a.* 
            EXIT WHILE
         END IF

         SELECT * 
           INTO p_result_analise741.* 
           FROM result_analise741
          WHERE cod_empresa = p_cod_empresa
            AND tip_analise = p_result_analise741.tip_analise
            AND cod_result  = p_result_analise741.cod_result
            
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0590_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-------------------------#
 FUNCTION pol0590_popup()
#-------------------------#

   DEFINE p_codigo CHAR(03)

   CASE
      WHEN INFIELD(tip_analise)
         INITIALIZE p_nom_tela TO NULL
         CALL log130_procura_caminho("pol05901") RETURNING p_nom_tela
         LET p_nom_tela = p_nom_tela CLIPPED
         OPEN WINDOW w_pol05901 AT 8,27 WITH FORM p_nom_tela
              ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

         DECLARE cq_analise2 CURSOR FOR
          SELECT tip_analise,
                 den_analise
            FROM it_analise_comil
           WHERE cod_empresa   = cod_empresa
             AND ies_tip_texto = 'S'

         LET p_index = 1
         FOREACH cq_analise2 INTO pr_analise[p_index].tip_analise,
                                  pr_analise[p_index].den_analise            
                      
            LET p_index = p_index + 1
            IF p_index >300 THEN
               ERROR "Limite de Linhas Ultrapassado !!!"
               EXIT FOREACH
            END IF
            
         END FOREACH
         
         CALL SET_COUNT(p_index - 1)

         DISPLAY ARRAY pr_analise TO sr_analise.*

         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

         CLOSE WINDOW w_pol05901

         #RETURN pr_analise[p_index].tip_analise
 
         #CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0590
         
         IF INT_FLAG = 0 THEN
            LET p_result_analise741.tip_analise = pr_analise[p_index].tip_analise
            DISPLAY p_result_analise741.tip_analise TO tip_analise
         ELSE
            LET INT_FLAG = 0
         END IF
         {LET p_codigo = pr_analise[p_index].tip_analise
         IF p_codigo IS NOT NULL THEN
            LET p_tip_analise = p_codigo CLIPPED
            DISPLAY p_tip_analise TO tip_analise
         END IF}
        
      END CASE
END FUNCTION

#-----------------------------------#
 FUNCTION pol0590_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_analise CURSOR FOR
    SELECT * 
      FROM result_analise741
     WHERE cod_empresa = p_cod_empresa
     ORDER BY tip_analise
   
   FOREACH cq_analise INTO p_result_analise741.*

      OUTPUT TO REPORT pol0590_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0590_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "LISTAGEM DE RESULTADO POR ANALISE",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0590",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT
         PRINT COLUMN 005, " TIPO   "
         PRINT COLUMN 005, "ANALISE  COD.RESULTADO  DESCRICAO RESULTADO           "
         PRINT COLUMN 005, "-------  -------------  ------------------------------"
      
      ON EVERY ROW

         PRINT COLUMN 006, p_result_analise741.tip_analise,
               COLUMN 019, p_result_analise741.cod_result,
               COLUMN 029, p_result_analise741.den_result
   
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
