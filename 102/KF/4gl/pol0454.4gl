#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX - EGA                                  #
# PROGRAMA: pol0454                                                 #
# MODULOS.: pol0454-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
#           MIN0710                                                 #
# OBJETIVO: CADASTRO PEÇAS SIMETRICA                                #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 02/05/2006                                              #
# ALTERADO: 12/12/2006 por ANA PAULA                                #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_peca_princ     LIKE item.cod_item,
          m_cod_peca_princ     LIKE item.cod_item,
          p_den_peca_princ     LIKE item.den_item,
          p_den_peca_gemea     LIKE item.den_item,
          p_cod_peca_gemea     LIKE item.cod_item,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
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
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
          p_msg                CHAR(500)  
          

   DEFINE p_peca_geme_man912 RECORD LIKE peca_geme_man912.*

   DEFINE p_tela          RECORD
          cod_peca_princ  LIKE peca_geme_man912.cod_peca_princ
   END RECORD
    
   DEFINE pr_gemea        ARRAY[200] OF RECORD
          cod_peca_gemea  LIKE peca_geme_man912.cod_peca_gemea,
          qtd_peca_gemea  LIKE peca_geme_man912.qtd_peca_gemea,
          den_peca_gemea  LIKE item.den_item
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0454-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0454.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0454_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0454_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0454") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0454 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0454_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND "Modificar" "Modifica/Inclui dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0454_modificar() RETURNING p_status
            IF p_status THEN
               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
                  ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Operação Cancelada !!!"
                  ATTRIBUTE(REVERSE)
            END IF      
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Todos os dados da Tela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF p_tela.cod_peca_princ IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
               CALL pol0454_excluir() RETURNING p_status
               IF p_status THEN
                  MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
                     ATTRIBUTE(REVERSE)
               ELSE
                  MESSAGE "Operação Cancelada !!!"
                     ATTRIBUTE(REVERSE)
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0454_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0454_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0454_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF NOT pol0454_informar() THEN 
            ERROR "Operação Cancelada !!!"
            CONTINUE MENU
         END IF
         IF log005_seguranca(p_user,"VDP","pol0454","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0454_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0454.tmp'
                     START REPORT pol0454_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0454_relat TO p_nom_arquivo
               END IF
               CALL pol0454_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0454_relat   
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
      COMMAND KEY ("S") "Sobre" "Exibe a versão do programa"
         CALL pol0454_sobre()
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
   CLOSE WINDOW w_pol0454

END FUNCTION

#-----------------------#
FUNCTION pol0454_incluir()
#-----------------------#


   IF pol0454_aceita_chave() THEN 
      IF pol0454_aceita_itens() THEN
         CALL pol0454_grava_itens()
      END IF
   END IF
   RETURN(p_retorno)
   
END FUNCTION

#--------------------------#
FUNCTION pol0454_modificar()
#--------------------------#

   IF pol0454_aceita_itens() THEN
      CALL pol0454_grava_itens()
   ELSE
      CALL pol0454_exibe_gemeas()
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#-----------------------------#
FUNCTION pol0454_aceita_chave()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0454
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_den_peca_princ,
              p_tela.cod_peca_princ TO NULL

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

      AFTER FIELD cod_peca_princ

         IF p_tela.cod_peca_princ IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD cod_peca_princ
         END IF

         SELECT den_item
           INTO p_den_peca_princ
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_tela.cod_peca_princ

          IF STATUS <> 0 THEN 
             ERROR "Peça Não Cadastrada na Tabela ITEM !!!"
             NEXT FIELD cod_peca_princ
          END IF

         SELECT COUNT(cod_peca_princ)
           INTO p_count
           FROM peca_geme_man912
          WHERE cod_empresa = p_cod_empresa
            AND cod_peca_princ = p_tela.cod_peca_princ

          IF p_count > 0 THEN 
             ERROR "Peça já Cadastrado Como Principal !!!"
             NEXT FIELD cod_peca_princ
          END IF

         SELECT cod_peca_princ
           INTO m_cod_peca_princ
           FROM peca_geme_man912
          WHERE cod_empresa    = p_cod_empresa
            AND cod_peca_gemea = p_tela.cod_peca_princ

          IF STATUS = 0 THEN 
             ERROR "Peça já Cadastrado Como Simétrica p/ a Principal ", m_cod_peca_princ
             NEXT FIELD cod_peca_princ
          END IF

          DISPLAY p_den_peca_princ TO den_peca_princ

      ON KEY (control-z)
         CALL pol0454_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

#-----------------------------#
FUNCTION pol0454_aceita_itens()
#-----------------------------#

   INITIALIZE pr_gemea TO NULL
   
   DECLARE cq_gemea CURSOR FOR 
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM peca_geme_man912
     WHERE cod_empresa = p_cod_empresa
       AND cod_peca_princ  = p_tela.cod_peca_princ
   
   LET p_index = 1
   
   FOREACH cq_gemea INTO 
           pr_gemea[p_index].cod_peca_gemea,
           pr_gemea[p_index].qtd_peca_gemea
      
      SELECT den_item
        INTO pr_gemea[p_index].den_peca_gemea
       FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = pr_gemea[p_index].cod_peca_gemea
        
      LET p_index = p_index + 1

      IF p_index > 200 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_gemea
      WITHOUT DEFAULTS FROM sr_gemea.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      BEFORE FIELD cod_peca_gemea
         LET p_cod_peca_gemea = pr_gemea[p_index].cod_peca_gemea
         
      AFTER FIELD cod_peca_gemea
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_gemea[p_index].cod_peca_gemea IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_gemea[p_index].cod_peca_gemea = p_cod_peca_gemea
               NEXT FIELD cod_peca_gemea
            END IF
         END IF
         IF pr_gemea[p_index].cod_peca_gemea IS NOT NULL THEN
            IF pol0454_repetiu_cod() THEN
               ERROR "Peça ",pr_gemea[p_index].cod_peca_gemea," já informada !!!"
               LET pr_gemea[p_index].cod_peca_gemea = p_cod_peca_gemea
               NEXT FIELD cod_peca_gemea
            ELSE
              SELECT den_item
                INTO pr_gemea[p_index].den_peca_gemea
                FROM item
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item    = pr_gemea[p_index].cod_peca_gemea
              IF STATUS = 0 THEN 
              ELSE
                 ERROR "Peça ",pr_gemea[p_index].cod_peca_gemea,
                       " Não Cadastrada no Logix!!!"
                 LET pr_gemea[p_index].cod_peca_gemea = p_cod_peca_gemea
                 NEXT FIELD cod_peca_gemea
              END IF

              SELECT UNIQUE cod_peca_princ
                FROM peca_geme_man912
               WHERE cod_empresa    = p_cod_empresa
                 AND cod_peca_princ = pr_gemea[p_index].cod_peca_gemea
              IF STATUS = 0 THEN
                 ERROR "Peça ",pr_gemea[p_index].cod_peca_gemea,
                       " já foi Cadastrada Como Principal !!!"
                 LET pr_gemea[p_index].cod_peca_gemea = p_cod_peca_gemea
                 NEXT FIELD cod_peca_gemea
              END IF
              SELECT UNIQUE cod_peca_princ
                INTO m_cod_peca_princ
                FROM peca_geme_man912
               WHERE cod_empresa    = p_cod_empresa
                 AND cod_peca_gemea = pr_gemea[p_index].cod_peca_gemea
              IF STATUS = 0 THEN
                 IF m_cod_peca_princ <> p_tela.cod_peca_princ THEN
                    ERROR "Peça ",pr_gemea[p_index].cod_peca_gemea,
                          " já Associada à Peça Principal ", m_cod_peca_princ
                    LET pr_gemea[p_index].cod_peca_gemea = p_cod_peca_gemea
                    NEXT FIELD cod_peca_gemea
                 END IF
              END IF
            END IF
            DISPLAY pr_gemea[p_index].den_peca_gemea TO 
                    sr_gemea[s_index].den_peca_gemea
         END IF
         
      BEFORE FIELD qtd_peca_gemea
         IF pr_gemea[p_index].qtd_peca_gemea IS NULL THEN
            LET pr_gemea[p_index].qtd_peca_gemea = 1
         END IF
      
      AFTER FIELD qtd_peca_gemea
         IF pr_gemea[p_index].qtd_peca_gemea IS NULL THEN
            ERROR 'Campo com preenhimento obrigatório!'
            NEXT FIELD qtd_peca_gemea
         END IF
      
      ON KEY (control-z)
         CALL pol0454_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   
   RETURN(p_retorno)
   
END FUNCTION

#-------------------------------#
FUNCTION pol0454_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_gemea[p_ind].cod_peca_gemea = pr_gemea[p_index].cod_peca_gemea THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0454_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM peca_geme_man912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_peca_princ = p_tela.cod_peca_princ

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF pr_gemea[p_ind].cod_peca_gemea IS NULL THEN
             CONTINUE FOR
          END IF
          
          INSERT INTO peca_geme_man912
          VALUES (p_cod_empresa,
                  p_tela.cod_peca_princ, 
                  pr_gemea[p_ind].cod_peca_gemea,
                  pr_gemea[p_ind].qtd_peca_gemea)
                  
          IF sqlca.sqlcode <> 0 THEN 
             LET p_houve_erro = TRUE
             MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
             EXIT FOR
          END IF
      END FOR
   END IF
         
   IF NOT p_houve_erro THEN
      CALL log085_transacao("COMMIT")	      
      LET p_retorno = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("GRAVAÇÃO","peca_geme_man912")
      LET p_retorno = FALSE
   END IF      
   WHENEVER ERROR STOP
   
END FUNCTION

#-------------------------#
FUNCTION pol0454_informar() 
#-------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CONSTRUCT BY NAME where_clause ON 
      peca_geme_man912.cod_peca_princ

      ON KEY (control-z)
         CALL pol0454_popup()

   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0454

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION


#------------------------#
FUNCTION pol0454_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      DELETE FROM peca_geme_man912
        WHERE cod_empresa    = p_cod_empresa
          AND cod_peca_princ = p_tela.cod_peca_princ
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_tela.cod_peca_princ TO NULL
      ELSE
         CALL log085_transacao("ROLLBACK")
         CALL log003_err_sql("DELEÇÃO","PECA_GEME_man912")
      END IF
   END IF
   WHENEVER ERROR STOP
   RETURN(p_retorno)
   
END FUNCTION


#--------------------------#
 FUNCTION pol0454_consulta()
#--------------------------#

   LET p_cod_peca_princ = p_tela.cod_peca_princ
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   CONSTRUCT BY NAME where_clause ON 
      peca_geme_man912.cod_peca_princ

      ON KEY (control-z)
         CALL pol0454_popup()

   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0454

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_tela.cod_peca_princ = p_cod_peca_princ
      CALL pol0454_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_peca_princ FROM peca_geme_man912 ",
                  " WHERE ", where_clause CLIPPED,   
                  "   AND cod_empresa = '",p_cod_empresa,"' ",              
                  "ORDER BY cod_peca_princ"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0454_exibe_dados()
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0454_exibe_dados()
#-----------------------------------#

   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_peca_princ TO NULL
  
   SELECT den_item
     INTO p_den_peca_princ
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_tela.cod_peca_princ
   
   DISPLAY p_den_peca_princ TO den_peca_princ
   
   CALL pol0454_exibe_gemeas()
   
 END FUNCTION

#-------------------------------#
 FUNCTION pol0454_exibe_gemeas()
#-------------------------------#

   DECLARE cq_codigo CURSOR FOR 
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM peca_geme_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_peca_princ = p_tela.cod_peca_princ

   LET p_index = 1
   
   FOREACH cq_codigo INTO 
           pr_gemea[p_index].cod_peca_gemea,
           pr_gemea[p_index].qtd_peca_gemea

      INITIALIZE pr_gemea[p_index].den_peca_gemea TO NULL
      
      SELECT den_item
        INTO pr_gemea[p_index].den_peca_gemea
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = pr_gemea[p_index].cod_peca_gemea
   
      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_gemea WITHOUT DEFAULTS FROM sr_gemea.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0454_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_peca_princ = p_tela.cod_peca_princ
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            p_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            p_tela.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.cod_peca_princ = p_cod_peca_princ 
            EXIT WHILE
         END IF

         IF p_tela.cod_peca_princ = p_cod_peca_princ THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(cod_peca_princ) INTO p_count
         FROM peca_geme_man912
            WHERE cod_empresa    = p_cod_empresa
              AND cod_peca_princ = p_tela.cod_peca_princ
     
         IF p_count > 0 THEN  
            CALL pol0454_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0454_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   LET sql_stmt = "SELECT UNIQUE cod_peca_princ FROM peca_geme_man912 ",
                  " WHERE ", where_clause CLIPPED,  
                  "   AND cod_empresa = '",p_cod_empresa,"' ",               
                  "ORDER BY cod_peca_princ"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO p_cod_peca_princ
   
      INITIALIZE p_den_peca_princ TO NULL
      SELECT den_item INTO p_den_peca_princ
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_peca_princ

      OUTPUT TO REPORT pol0454_relat(p_cod_peca_princ) 
 
      LET p_count = p_count + 1
      
   END FOREACH


 
END FUNCTION 

#-------------------------------------#
 REPORT pol0454_relat(p_cod_peca_princ)
#-------------------------------------#

   DEFINE p_cod_peca_princ LIKE peca_geme_man912.cod_peca_princ

   DEFINE p_relat RECORD
          cod_peca_gemea LIKE peca_geme_man912.cod_peca_gemea,
          qtd_peca_gemea LIKE peca_geme_man912.qtd_peca_gemea,
          den_peca_gemea LIKE item.den_item
   END RECORD
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "pol0454                RELATORIO DE PECAS SIMETRICAS"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"

         PRINT
                           

      BEFORE GROUP OF p_cod_peca_princ

         PRINT
         PRINT COLUMN 001, "PECA PRINCIPAL: ", p_cod_peca_princ CLIPPED," - ", 
                            p_den_peca_princ[1,45]
                              
         PRINT
         PRINT COLUMN 001, "PECA SIMETRICA  QTD                      DESCRICAO"
               
         PRINT COLUMN 001, "--------------- --- ------------------------------------------------------------"
         
         PRINT
                           
      ON EVERY ROW

         DECLARE cq_gem CURSOR FOR
            SELECT a.cod_peca_gemea, a.qtd_peca_gemea, b.den_item
              FROM peca_geme_man912 a, item b
             WHERE a.cod_empresa    = p_cod_empresa
               AND a.cod_peca_princ = p_cod_peca_princ
               AND b.cod_empresa    = a.cod_empresa
               AND b.cod_item       = a.cod_peca_princ
             ORDER BY a.cod_peca_gemea
               
         FOREACH cq_gem INTO p_relat.*
         
            PRINT COLUMN 001, p_relat.cod_peca_gemea,
                  COLUMN 017, p_relat.qtd_peca_gemea USING '&&&',
                  COLUMN 021, p_relat.den_peca_gemea[1,60]
   
         END FOREACH
         
         PRINT
  
END REPORT


#-----------------------#
FUNCTION pol0454_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_peca_princ)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0454
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_peca_princ = p_codigo
           DISPLAY p_codigo TO cod_peca_princ
         END IF

         
      WHEN INFIELD(cod_peca_gemea)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0454
         IF p_codigo IS NOT NULL THEN
           LET pr_gemea[p_index].cod_peca_gemea = p_codigo
           DISPLAY p_codigo TO sr_gemea[s_index].cod_peca_gemea
         END IF

   END CASE

END FUNCTION 

#-----------------------#
 FUNCTION pol0454_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#


# PARA COMPILAR NO 4JS, INSIRA UMA CHAVE ({) NA LINHA A SEGUIR
{
#----------------------------------#
FUNCTION log085_transacao(p_transac)
#----------------------------------#

   DEFINE p_transac CHAR(08)

   CASE p_transac
      WHEN "BEGIN"    BEGIN WORK
      WHEN "COMMIT"   COMMIT WORK
      WHEN "ROLLBACK" ROLLBACK WORK
   END CASE
         
END FUNCTION 

#----------------------------------#
FUNCTION log0180_conecta_usuario()
#----------------------------------#

END FUNCTION