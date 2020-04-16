#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0648                                                 #
# OBJETIVO: CADASTRO DE LARGURA DE CHAPA                            #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 25/09/2007                                              #
# ALTERADO: 29/10/2007 por Ana Paula - versao 02                    #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(80),
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_retorno            SMALLINT,
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_den_item_reduz     CHAR(18),
          p_msg                CHAR(100)
          
   DEFINE p_largura_chapa_885   RECORD LIKE largura_chapa_885.*,
          p_largura_chapa_885a  RECORD LIKE largura_chapa_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0648-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0648.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0648_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0648_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0648") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0648 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0648_inclusao() THEN
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
            IF pol0648_modificacao() THEN
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
            IF pol0648_exclusao() THEN
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
         CALL pol0648_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0648_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0648_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0648","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0648_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0648.tmp'
                     START REPORT pol0648_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0648_relat TO p_nom_arquivo
               END IF
               CALL pol0648_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0648_relat   
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
         CALL func002_exibe_versao(p_versao)
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
   CLOSE WINDOW w_pol0648

END FUNCTION

#--------------------------#
 FUNCTION pol0648_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_largura_chapa_885.* TO NULL
   LET p_largura_chapa_885.cod_empresa = p_cod_empresa

   IF pol0648_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO largura_chapa_885 VALUES (p_largura_chapa_885.*)
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
 FUNCTION pol0648_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0648

   INPUT BY NAME p_largura_chapa_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD largura
      END IF 

      AFTER FIELD cod_item
      IF p_largura_chapa_885.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item
      ELSE
         {SELECT cod_item
           FROM largura_chapa_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_largura_chapa_885.cod_item

         IF SQLCA.sqlcode = 0 THEN
            ERROR "Iem já cadastrado no POL0648 !!!"
            NEXT FIELD cod_item
         END IF }
          
         SELECT den_item_reduz
           INTO p_den_item_reduz
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_largura_chapa_885.cod_item
        
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Item não Cadastrado na Tabela ITEM !!!"
            NEXT FIELD cod_item
         END IF 

         DISPLAY p_den_item_reduz TO den_item_reduz
      END IF

      AFTER FIELD largura
      IF p_largura_chapa_885.largura IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD largura
      ELSE
         SELECT *
           FROM largura_chapa_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_largura_chapa_885.cod_item
            AND largura  = p_largura_chapa_885.largura
            
      IF p_funcao <> 'MODIFICACAO' THEN 
         IF SQLCA.sqlcode = 0 THEN  
            ERROR 'Largura já cadastrada na Tabela LARGURA_CHAPA_885 !!!'
            NEXT FIELD largura
            END IF 
         END IF
      END IF

      ON KEY (control-z)
         CALL pol0648_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0648

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0648_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   DEFINE p_codigo CHAR(15)
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_largura_chapa_885a.* = p_largura_chapa_885.*

   CONSTRUCT BY NAME where_clause ON 
      largura_chapa_885.cod_item
      
      ON KEY(control-z)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         IF p_codigo IS NOT NULL THEN
           LET p_largura_chapa_885.cod_item = p_codigo
           CURRENT WINDOW IS w_pol0648
           DISPLAY p_largura_chapa_885.cod_item TO cod_item
         END IF

   END CONSTRUCT
         
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0648

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_largura_chapa_885.* = p_largura_chapa_885a.*
      CALL pol0648_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM largura_chapa_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_largura_chapa_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0648_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0648_exibe_dados()
#------------------------------#

   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_largura_chapa_885.cod_item

   DISPLAY BY NAME p_largura_chapa_885.*
   DISPLAY p_den_item_reduz TO den_item_reduz

END FUNCTION

#-----------------------------------#
 FUNCTION pol0648_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_largura_chapa_885.*                                              
     FROM largura_chapa_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_largura_chapa_885.cod_item
      AND largura     = p_largura_chapa_885.largura
   FOR UPDATE
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","largura_chapa_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0648_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0648_cursor_for_update() THEN
      LET p_largura_chapa_885a.* = p_largura_chapa_885.*
      IF pol0648_entrada_dados("MODIFICACAO") THEN
      
         UPDATE largura_chapa_885
            SET largura = p_largura_chapa_885.largura
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_largura_chapa_885.cod_item
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","LARGURA_CHAPA_885")
         END IF
      ELSE
         LET p_largura_chapa_885.* = p_largura_chapa_885a.*
         CALL pol0648_exibe_dados()
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
 FUNCTION pol0648_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0648_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM largura_chapa_885
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_largura_chapa_885.cod_item
           AND largura     = p_largura_chapa_885.largura
         
         IF STATUS = 0 THEN
            INITIALIZE p_largura_chapa_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","largura_chapa_885")
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
 FUNCTION pol0648_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_largura_chapa_885a.* = p_largura_chapa_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO p_largura_chapa_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_largura_chapa_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_largura_chapa_885.* = p_largura_chapa_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_largura_chapa_885.*
           FROM largura_chapa_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_largura_chapa_885.cod_item
            AND largura     = p_largura_chapa_885.largura
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0648_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0648_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_largura_chapa_885 CURSOR FOR
    SELECT * 
      FROM largura_chapa_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item
          
     FOREACH cq_largura_chapa_885 INTO p_largura_chapa_885.*
   
        SELECT den_item_reduz
          INTO p_den_item_reduz
          FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_largura_chapa_885.cod_item

      OUTPUT TO REPORT pol0648_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0648_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "CADASTRO DE LARGURA_CHAPA_885 DE PAPEL",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0648",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT                  
         PRINT COLUMN 005, " ITEM            DESCRIÇÂO           LARGURA"
         PRINT COLUMN 005, "---------------  ------------------  -------"
      
      ON EVERY ROW

         PRINT COLUMN 005, p_largura_chapa_885.cod_item,
               COLUMN 022, p_den_item_reduz,
               COLUMN 042, p_largura_chapa_885.largura
END REPORT

#-----------------------#
FUNCTION pol0648_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0648
         IF p_codigo IS NOT NULL THEN
           LET p_largura_chapa_885.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
   
END FUNCTION  


#-------------------------------- FIM DE PROGRAMA -----------------------------#

