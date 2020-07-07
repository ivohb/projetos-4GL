#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0593                                                 #
# MODULOS.: pol0593-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE PARAMETROS PARA REVISAO GRAUNA              #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 14/05/2007                                              #
# ALTERADO: 07/06/2007 por Ana Paula - versao 01                    #
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
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_den_dados          LIKE par_revisao_1040.den_dados

   DEFINE p_par_revisao_1040   RECORD LIKE par_revisao_1040.*,
          p_par_revisao_1040a  RECORD LIKE par_revisao_1040.* 

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
   LET p_versao = "pol0593-05.10.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0593.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0593_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0593_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0593") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0593 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na divisao"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0593_inclusao() THEN
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
            IF pol0593_modificacao() THEN
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
            IF pol0593_exclusao() THEN
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
         CALL pol0593_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0593_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0593_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0593","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0593_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0593.tmp'
                     START REPORT pol0593_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0593_relat TO p_nom_arquivo
               END IF
               CALL pol0593_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0593_relat   
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
   CLOSE WINDOW w_pol0593

END FUNCTION

#--------------------------#
 FUNCTION pol0593_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_par_revisao_1040.* TO NULL
   LET p_par_revisao_1040.cod_empresa = p_cod_empresa

   IF pol0593_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO par_revisao_1040 VALUES (p_par_revisao_1040.*)
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
 FUNCTION pol0593_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0593

   INPUT BY NAME p_par_revisao_1040.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD tipo_dados
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD den_dados
      END IF 

      AFTER FIELD tipo_dados
      IF p_par_revisao_1040.tipo_dados IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD tipo_dados
      END IF

      AFTER FIELD den_dados
      IF p_par_revisao_1040.den_dados IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_dados
      END IF
       
      AFTER FIELD revisao
   #  LET  p_par_revisao_1040.revisao = 'N'
      IF p_par_revisao_1040.revisao IS NULL OR      
         p_par_revisao_1040.revisao = ' ' THEN
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD revisao
         END IF
      ELSE
         IF p_par_revisao_1040.revisao <> 'S' AND 
            p_par_revisao_1040.revisao <> 'N' THEN
            ERROR 'Valor inválido. Informe (S)-Sim ou (N)-Não'
            NEXT FIELD revisao
         END IF
      END IF
      IF p_par_revisao_1040.revisao = 'S' THEN
         LET p_par_revisao_1040.situacao = 'N'
      ELSE 
         IF p_par_revisao_1040.revisao = 'N' THEN
            LET p_par_revisao_1040.situacao = 'S'
         END IF      
      END  IF

      AFTER FIELD data_revisao
     # LET  p_par_revisao_1040.data_revisao = 'N'
      IF p_par_revisao_1040.data_revisao IS NULL OR      
         p_par_revisao_1040.data_revisao = ' ' THEN
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD data_revisao
         END IF
      ELSE
         IF p_par_revisao_1040.data_revisao <> 'S' AND 
            p_par_revisao_1040.data_revisao <> 'N' THEN
            ERROR 'Valor inválido. Informe (S)-Sim ou (N)-Não'
            NEXT FIELD data_revisao
         END IF
      END IF

      AFTER FIELD hora_revisao
     # LET  p_par_revisao_1040.hora_revisao = 'N'
      IF p_par_revisao_1040.hora_revisao IS NULL OR      
         p_par_revisao_1040.hora_revisao = ' ' THEN
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD hora_revisao
         END IF
      ELSE
         IF p_par_revisao_1040.hora_revisao <> 'S' AND 
            p_par_revisao_1040.hora_revisao <> 'N' THEN
            ERROR 'Valor inválido. Informe (S)-Sim ou (N)-Não'
            NEXT FIELD hora_revisao
         END IF
      END IF

      AFTER FIELD situacao
      #LET  p_par_revisao_1040.situacao = 'N'
      IF p_par_revisao_1040.situacao IS NULL OR      
         p_par_revisao_1040.situacao = ' ' THEN
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD situacao
         END IF
      ELSE
         IF p_par_revisao_1040.situacao <> 'S' AND 
            p_par_revisao_1040.situacao <> 'N' THEN
            ERROR 'Valor inválido. Informe (S)-Sim ou (N)-Não'
            NEXT FIELD situacao
         END IF
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0593

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0593_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_revisao_1040a.* = p_par_revisao_1040.*

   CONSTRUCT BY NAME where_clause ON
       par_revisao_1040.tipo_dados
         
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0593

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_par_revisao_1040.* = p_par_revisao_1040a.*
      CALL pol0593_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM par_revisao_1040 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY tipo_dados "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_par_revisao_1040.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0593_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0593_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_par_revisao_1040.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_dados TO NULL
   SELECT den_dados
     INTO p_den_dados
     FROM par_revisao_1040
    WHERE cod_empresa = p_cod_empresa
      AND tipo_dados  = p_par_revisao_1040.tipo_dados
      
   DISPLAY p_den_dados TO den_dados
   
END FUNCTION
 
#-----------------------------------#
 FUNCTION pol0593_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   
   SELECT * 
     INTO p_par_revisao_1040.*                                              
     FROM par_revisao_1040
    WHERE cod_empresa = p_cod_empresa
      AND tipo_dados = p_par_revisao_1040.tipo_dados
   FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_revisao_1040")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0593_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0593_cursor_for_update() THEN
      LET p_par_revisao_1040a.* = p_par_revisao_1040.*
      IF pol0593_entrada_dados("MODIFICACAO") THEN
         UPDATE par_revisao_1040
            SET den_dados    = p_par_revisao_1040.den_dados,
                revisao      = p_par_revisao_1040.revisao,
                data_revisao = p_par_revisao_1040.data_revisao,
                hora_revisao = p_par_revisao_1040.hora_revisao,
                situacao     = p_par_revisao_1040.situacao
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","par_revisao_1040")
         END IF
      ELSE
         LET p_par_revisao_1040.* = p_par_revisao_1040a.*
         CALL pol0593_exibe_dados()
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
 FUNCTION pol0593_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0593_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM par_revisao_1040
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_par_revisao_1040.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_revisao_1040")
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
 FUNCTION pol0593_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(30)

   IF p_ies_cons THEN
      LET p_par_revisao_1040a.* = p_par_revisao_1040.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_par_revisao_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_par_revisao_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_par_revisao_1040.* = p_par_revisao_1040a.* 
            EXIT WHILE
         END IF

         SELECT * 
           INTO p_par_revisao_1040.* 
           FROM par_revisao_1040
          WHERE cod_empresa = p_cod_empresa
            AND tipo_dados  = p_par_revisao_1040.tipo_dados
            
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0593_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0593_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_analise CURSOR FOR
    SELECT * 
      FROM par_revisao_1040
     WHERE cod_empresa = p_cod_empresa
     ORDER BY tipo_dados
   
   FOREACH cq_analise INTO p_par_revisao_1040.*

      OUTPUT TO REPORT pol0593_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0593_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "LISTAGEM DE PARAMETROS PARA REVISAO",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0593",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT COLUMN 000, p_comprime
         PRINT COLUMN 002, " TIPO   "
         PRINT COLUMN 002, "DADOS  DESCRICAO                                    REVISAO  DATA REV  HORA REV  SITUACAO"
         PRINT COLUMN 002, "-----  -------------------------------------------  -------  --------  --------  --------"
      
      ON EVERY ROW

         PRINT COLUMN 003, p_par_revisao_1040.tipo_dados,
               COLUMN 008, p_par_revisao_1040.den_dados,
               COLUMN 056, p_par_revisao_1040.revisao,
               COLUMN 065, p_par_revisao_1040.data_revisao,
               COLUMN 075, p_par_revisao_1040.hora_revisao,
               COLUMN 085, p_par_revisao_1040.situacao
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#
