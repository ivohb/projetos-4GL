#-------------------------------------------------------------------#
# SISTEMA.: EMBALAGEM                                               #
# PROGRAMA: pol0418                                                 #
# OBJETIVO: CADASTRO DE EMBALAGENS                                  #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 26/01/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_embal          LIKE embalagem.cod_embal,
          p_den_embal          LIKE embalagem.den_embal,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_den_item           LIKE item.den_item,
          p_cod_item           LIKE item.cod_item,
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
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),  
          p_msg                CHAR(500)
          

   DEFINE p_embal_plast_regina RECORD LIKE embal_plast_regina.*

   DEFINE p_tela          RECORD
          cod_embal       LIKE embalagem.cod_embal
   END RECORD
   
   DEFINE pr_item         ARRAY[90] OF RECORD
          cod_item        LIKE embal_plast_regina.cod_item,
          den_item_reduz  LIKE item.den_item_reduz,
          qtd_embal       LIKE embal_plast_regina.qtd_embal,
          pre_unit        LIKE embal_plast_regina.pre_unit
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0418-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0418.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0418_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0418_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0418") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0418 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0418_incluir() RETURNING p_status
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
            CALL pol0418_modificar() RETURNING p_status
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
            IF p_tela.cod_embal IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
               CALL pol0418_excluir() RETURNING p_status
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
         CALL pol0418_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0418_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0418_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF NOT pol0418_informar() THEN 
            ERROR "Operação Cancelada !!!"
            CONTINUE MENU
         END IF
         IF log005_seguranca(p_user,"VDP","pol0418","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0418_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0418.tmp'
                     START REPORT pol0418_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0418_relat TO p_nom_arquivo
               END IF
               CALL pol0418_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0418_relat   
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
				CALL pol0418_sobre()
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
   CLOSE WINDOW w_pol0418

END FUNCTION

#-----------------------#
 FUNCTION pol0418_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Conversão para 10.02.00\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------#
FUNCTION pol0418_incluir()
#-----------------------#

   IF pol0418_aceita_chave() THEN 
      IF pol0418_aceita_itens() THEN
         CALL pol0418_grava_itens()
      END IF
   END IF
   RETURN(p_retorno)
   
END FUNCTION

#--------------------------#
FUNCTION pol0418_modificar()
#--------------------------#

   IF pol0418_aceita_itens() THEN
      CALL pol0418_grava_itens()
   ELSE
      CALL pol0418_exibe_codigos()
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#-----------------------------#
FUNCTION pol0418_aceita_chave()
#-----------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0418
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_den_embal TO NULL

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS  

      AFTER FIELD cod_embal

         IF p_tela.cod_embal IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD cod_embal
         END IF

         SELECT den_embal INTO p_den_embal
           FROM embalagem
          WHERE cod_embal = p_tela.cod_embal

          IF STATUS <> 0 THEN 
             ERROR "Embalagem Não Cadastrada no Logix !!!"
             NEXT FIELD cod_embal
          END IF

         SELECT COUNT(cod_embal) INTO p_count
           FROM embal_plast_regina
          WHERE cod_empresa = p_cod_empresa
            AND cod_embal = p_tela.cod_embal

          IF p_count > 0 THEN 
             ERROR "Código já Cadastrado !!!"
             NEXT FIELD cod_embal
          END IF

          DISPLAY p_den_embal TO den_embal

      ON KEY (control-z)
         CALL pol0418_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

#-----------------------------#
FUNCTION pol0418_aceita_itens()
#-----------------------------#

   DECLARE cq_item CURSOR FOR 
    SELECT cod_item, qtd_embal
      FROM embal_plast_regina
     WHERE cod_empresa = p_cod_empresa
       AND cod_embal   = p_tela.cod_embal
   
   LET p_index = 1
   
   FOREACH cq_item INTO pr_item[p_index].cod_item,
                        pr_item[p_index].qtd_embal
 
      INITIALIZE pr_item[p_index].den_item_reduz TO NULL
      
      SELECT den_item_reduz
        INTO pr_item[p_index].den_item_reduz
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = pr_item[p_index].cod_item
        
      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      BEFORE FIELD cod_item
         LET p_cod_item = pr_item[p_index].cod_item
         
      AFTER FIELD cod_item
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_item[p_index].cod_item IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_item[p_index].cod_item = p_cod_item
               NEXT FIELD cod_item
            END IF
         END IF
         IF pr_item[p_index].cod_item IS NOT NULL THEN
            IF pol0418_repetiu_cod() THEN
               ERROR "Código ",pr_item[p_index].cod_item," já Lançado !!!"
               LET pr_item[p_index].cod_item = p_cod_item
               NEXT FIELD cod_item
            ELSE
              SELECT den_item_reduz
                INTO pr_item[p_index].den_item_reduz
                FROM item
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item    = pr_item[p_index].cod_item
               IF STATUS = 0 THEN 
                  DISPLAY pr_item[p_index].den_item_reduz TO 
                          sr_item[s_index].den_item_reduz
               ELSE
                  ERROR "Item não Cadastrado no Logix !!!"
                  NEXT FIELD cod_item
               END IF
            END IF
         END IF
         
      BEFORE FIELD qtd_embal
         IF pr_item[p_index].qtd_embal IS NULL THEN
            LET pr_item[p_index].qtd_embal = 0
         END IF

      BEFORE FIELD pre_unit
         IF pr_item[p_index].pre_unit IS NULL THEN
            LET pr_item[p_index].pre_unit = 0
         END IF

      ON KEY (control-z)
         CALL pol0418_popup()
         
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
FUNCTION pol0418_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_item[p_ind].cod_item = pr_item[p_index].cod_item THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0418_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM embal_plast_regina
     WHERE cod_empresa = p_cod_empresa
       AND cod_embal   = p_tela.cod_embal

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF pr_item[p_ind].cod_item IS NULL THEN
             CONTINUE FOR
          END IF
          
          INSERT INTO embal_plast_regina
          VALUES (p_cod_empresa, p_tela.cod_embal, 
                  pr_item[p_ind].cod_item,
                  pr_item[p_ind].qtd_embal,
                  pr_item[p_ind].pre_unit)
                  
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
      CALL log003_err_sql("GRAVAÇÃO","embal_plast_regina")
      LET p_retorno = FALSE
   END IF      
   WHENEVER ERROR STOP
   
END FUNCTION

#-------------------------#
FUNCTION pol0418_informar() 
#-------------------------#


   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CONSTRUCT BY NAME where_clause ON 
      embal_plast_regina.cod_embal

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0418

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION


#------------------------#
FUNCTION pol0418_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      DELETE FROM embal_plast_regina
        WHERE cod_empresa = p_cod_empresa
          AND cod_embal = p_tela.cod_embal
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_tela.cod_embal TO NULL
      ELSE
         CALL log003_err_sql("DELEÇÃO","embal_plast_regina")
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   WHENEVER ERROR STOP
   RETURN(p_retorno)
   
END FUNCTION


#--------------------------#
 FUNCTION pol0418_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  
   LET p_cod_embal = p_tela.cod_embal
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   CONSTRUCT BY NAME where_clause ON 
      embal_plast_regina.cod_embal 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0418

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_tela.cod_embal = p_cod_embal
      CALL pol0418_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_embal FROM embal_plast_regina ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_embal"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0418_exibe_dados()
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0418_exibe_dados()
#-----------------------------------#

   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_embal TO NULL
   
   SELECT den_embal INTO p_den_embal
     FROM embalagem
    WHERE cod_embal = p_tela.cod_embal
   
   DISPLAY p_den_embal TO den_embal
   
   CALL pol0418_exibe_codigos()
   
 END FUNCTION

#-------------------------------#
 FUNCTION pol0418_exibe_codigos()
#-------------------------------#

   DECLARE cq_codigo CURSOR FOR 
    SELECT cod_item, qtd_embal, pre_unit
      FROM embal_plast_regina
     WHERE cod_empresa = p_cod_empresa
       AND cod_embal   = p_tela.cod_embal
   
   LET p_index = 1
   
   FOREACH cq_codigo INTO pr_item[p_index].cod_item,
                          pr_item[p_index].qtd_embal,
                          pr_item[p_index].pre_unit
 
       INITIALIZE pr_item[p_index].den_item_reduz TO NULL
      
      SELECT den_item_reduz
        INTO pr_item[p_index].den_item_reduz
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = pr_item[p_index].cod_item

      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_item WITHOUT DEFAULTS FROM sr_item.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0418_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_embal = p_tela.cod_embal
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            p_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            p_tela.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.cod_embal = p_cod_embal 
            EXIT WHILE
         END IF

         IF p_tela.cod_embal = p_cod_embal THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(cod_embal) INTO p_count
         FROM embal_plast_regina
            WHERE cod_empresa = p_cod_empresa
              AND cod_embal = p_tela.cod_embal
     
         IF p_count > 0 THEN  
            CALL pol0418_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0418_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   LET sql_stmt = "SELECT * FROM embal_plast_regina ",
                  " WHERE ", where_clause CLIPPED,                 
                  "ORDER BY cod_embal, cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO p_embal_plast_regina.*
   
      INITIALIZE p_den_embal TO NULL
      SELECT den_embal INTO p_den_embal
        FROM embalagem
       WHERE cod_embal = p_embal_plast_regina.cod_embal

      INITIALIZE p_den_item TO NULL
      SELECT den_item
        INTO p_den_item
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_embal_plast_regina.cod_item
           
      OUTPUT TO REPORT pol0418_relat(p_embal_plast_regina.*) 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0418_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD
          cod_empresa LIKE embal_plast_regina.cod_empresa,
          cod_embal   LIKE embal_plast_regina.cod_embal,
          cod_item    LIKE embal_plast_regina.cod_item,
          qtd_embal   LIKE embal_plast_regina.qtd_embal,
          pre_unit    LIKE embal_plast_regina.pre_unit
   END RECORD
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 034, "EMBALAGEM / COMPONENTES",
               COLUMN 060, TODAY, "  PAG.: ", PAGENO USING "#&"
         PRINT COLUMN 001, "*---------------------------------------",
                           "--------------------------------------*"

      BEFORE GROUP OF p_relat.cod_embal

         PRINT
         PRINT COLUMN 018, "Embalagem: ", p_relat.cod_embal,
                           " - ", p_den_embal
                              
         PRINT
         PRINT COLUMN 008, "ITEM",
               COLUMN 033, "DESCRICAO",
               COLUMN 056, "QUANT.",
               COLUMN 066, "PRECO UNIT."
         PRINT COLUMN 003, "---------------",
               COLUMN 020, "----------------------------------",
               COLUMN 056, "------",
               COLUMN 064, "---------------"
                           
      ON EVERY ROW

         PRINT COLUMN 003, p_relat.cod_item,
               COLUMN 020, p_den_item[1,34],
               COLUMN 056, p_relat.qtd_embal USING "##&.&&",
               COLUMN 064, p_relat.pre_unit USING "###########&.&&"
   
      AFTER GROUP OF p_relat.cod_embal
      
         PRINT
   
END REPORT


#-----------------------#
FUNCTION pol0418_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_embal)
         CALL log009_popup(9,18,"EMBALAGENS","embalagem",
                     "cod_embal","den_embal"," ","","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0418
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_embal = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_embal
         END IF
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0418
         IF p_codigo IS NOT NULL THEN
           LET pr_item[p_index].cod_item = p_codigo
           DISPLAY p_codigo TO sr_item[s_index].cod_item
         END IF

   END CASE

END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#

