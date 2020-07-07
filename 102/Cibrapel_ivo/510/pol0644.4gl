#-------------------------------------------------------------------#
# SISTEMA.: ADMINISTRATIVO                                          #
# PROGRAMA: pol0644                                                 #
# MODULOS.: pol0644-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
#           min0710.4go                                             #
# OBJETIVO: CADASTRO DE GRUPO DE PRODUTO - CIBRAPEL                 #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 01/10/2007                                              #
# ALTERADO: 26/10/2007 por Ana Paula - versao 02                    #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_empresa        CHAR(25),
          p_retorno            SMALLINT,
          p_ind                SMALLINT,
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
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          w_cod_grupo          LIKE grupo_produto_885.cod_grupo,
          p_cod_grupo          LIKE grupo_item.cod_grupo_item,
          p_den_grupo          LIKE grupo_item.den_grupo_item,
          p_cod_tipo           LIKE grupo_produto_885.cod_tipo,
          p_den_tipo           CHAR(05),
          p_msg                CHAR(100)

   DEFINE p_grupo_produto_885  RECORD LIKE grupo_produto_885.*,
          p_grupo_produto_885a RECORD LIKE grupo_produto_885.* 
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0644-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0644.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0644_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0644_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0644") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0644 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0644_inclusao() THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE "Operação Cancelada !!!"
         END IF
      COMMAND "Modificar" "Modifica Dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0644_modificacao() THEN
               MESSAGE 'Modificação efetuada com Sucesso !!!'
            ELSE
               ERROR "Operação cancelada !!!"
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao !!!"
         END IF
    COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0644_exclusao() THEN
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
         CALL pol0644_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0644_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0644_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0644","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0644_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0644.tmp'
                     START REPORT pol0644_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0644_relat TO p_nom_arquivo
               END IF
               CALL pol0644_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0644_relat   
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
         HELP 007
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0644

   END FUNCTION
   
#-------------------------#
FUNCTION pol0644_inclusao()
#-------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   INITIALIZE p_grupo_produto_885.* TO NULL
   LET p_grupo_produto_885.cod_empresa = p_cod_empresa
   
   IF pol0644_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO grupo_produto_885 VALUES (p_grupo_produto_885.*)
      
      IF SQLCA.sqlcode <> 0 THEN
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
   
#----------------------------------------#
FUNCTION pol0644_entrada_dados(p_funcao)
#----------------------------------------#

   DEFINE p_funcao CHAR(20)
  
   LET p_den_grupo = NULL
   LET p_den_tipo  = NULL
   LET w_cod_grupo = NULL 
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0644
   
   INPUT BY NAME p_grupo_produto_885.*
      WITHOUT DEFAULTS
      
      BEFORE FIELD cod_grupo
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD cod_tipo
         END IF
         
      AFTER FIELD cod_grupo
         IF p_grupo_produto_885.cod_grupo IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_grupo
         ELSE
            SELECT den_grupo_item
              INTO p_den_grupo
              FROM grupo_item
             WHERE cod_grupo_item = p_grupo_produto_885.cod_grupo
             ORDER BY cod_grupo_item
           
            IF SQLCA.sqlcode <> 0 THEN
               ERROR "Codigo do Grupo não cadastrado na Tabela GRUPO_ITEM !!!"
               NEXT FIELD cod_grupo
            END IF 
            
            SELECT cod_grupo
            INTO w_cod_grupo
            FROM grupo_produto_885
            WHERE cod_empresa = p_cod_empresa 
            AND   cod_grupo = p_grupo_produto_885.cod_grupo
            
            IF STATUS = 0 THEN 
            ERROR "Grupo Ja Cadastrado"
            NEXT FIELD cod_grupo
            END IF 
          
               DISPLAY p_den_grupo TO den_grupo
               NEXT FIELD cod_tipo            
         #   END IF
         END IF
          
       AFTER FIELD cod_tipo
          IF p_grupo_produto_885.cod_tipo IS NULL THEN 
             ERROR "Campo com preenchimento obrigatório !!!"
             NEXT FIELD cod_tipo
          END IF
           IF p_funcao <> 'MODIFICACAO' THEN 
          IF p_grupo_produto_885.cod_tipo IS NOT NULL THEN
             IF p_grupo_produto_885.cod_tipo <> '1' AND 
                p_grupo_produto_885.cod_tipo <> '2' AND
                p_grupo_produto_885.cod_tipo <> '3' THEN
                ERROR 'Valor inválido. Informe (1)Papel  /  (2)Chapa  /  (3)Caixa'
                NEXT FIELD cod_tipo
             END IF 
             IF p_grupo_produto_885.cod_tipo = '1' THEN
                LET p_den_tipo = 'Papel'
             ELSE
                IF p_grupo_produto_885.cod_tipo = '2' THEN
                   LET p_den_tipo = 'Chapa'
                ELSE
                   IF p_grupo_produto_885.cod_tipo = '3' THEN
                      LET p_den_tipo = 'Caixa'
                   END IF
                END IF
             END IF
                               
             SELECT *
               FROM grupo_produto_885
              WHERE cod_empresa = p_cod_empresa
                AND cod_grupo   = p_grupo_produto_885.cod_grupo
                AND cod_tipo    = p_grupo_produto_885.cod_tipo
              ORDER BY 1,2
                
             IF STATUS = 0 THEN
                ERROR "Grupo/Tipo já cadastrado na Tabela GRUPO_PRODUTO_885 !!!"
                NEXT FIELD cod_tipo
             ELSE
                DISPLAY p_den_tipo TO den_tipo                   
             END IF

          END IF
        END IF  
          ON KEY (control-z)
             CALL pol0644_popup()
   
   END INPUT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0644

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION   

#---------------------------#
 FUNCTION pol0644_consulta()
#---------------------------#
   DEFINE sql_stmt,
          where_clause CHAR(300)
          
   DEFINE p_codigo CHAR(03)
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_grupo_produto_885a.* = p_grupo_produto_885.*
   
   CONSTRUCT BY NAME where_clause ON grupo_produto_885.cod_grupo
      
      ON KEY (control-z)
           LET p_cod_grupo = pol0644_carrega_grupo()
             IF p_cod_grupo IS NOT NULL THEN
                LET p_grupo_produto_885.cod_grupo = p_cod_grupo
                SELECT den_grupo_item
                  INTO p_den_grupo
                  FROM grupo_item
                 WHERE cod_grupo_item = p_grupo_produto_885.cod_grupo
                 ORDER BY cod_grupo_item
             
                CURRENT WINDOW IS w_pol0644
                DISPLAY p_grupo_produto_885.cod_grupo TO cod_grupo
                DISPLAY p_den_grupo TO den_grupo
            END IF
   
   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0644

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0
      LET p_grupo_produto_885.* = p_grupo_produto_885a.*
      CALL pol0644_exibe_dados()
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM grupo_produto_885 ",
                  " WHERE ", where_clause CLIPPED,                 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_grupo"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_grupo_produto_885.*
   
   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE
      CALL pol0644_exibe_dados()
   END IF
   
   END FUNCTION

#--------------------------------#   
 FUNCTION pol0644_carrega_grupo() 
#--------------------------------#
 
  DEFINE pr_grupo       ARRAY[3000]
     OF RECORD
         cod_grupo  LIKE grupo_produto_885.cod_grupo
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06441") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06441 AT 5,17 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_grupo CURSOR FOR 
    SELECT UNIQUE cod_grupo  
      FROM grupo_produto_885
      ORDER BY cod_grupo

   LET pr_index = 1

   FOREACH cq_grupo INTO pr_grupo[pr_index].cod_grupo

    LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_grupo TO sr_grupo.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0644

   LET p_grupo_produto_885.cod_grupo = pr_grupo[pr_index].cod_grupo
             
  RETURN pr_grupo[pr_index].cod_grupo
  
END FUNCTION 

#-----------------------#
FUNCTION pol0644_popup()
#-----------------------#
   DEFINE p_codigo CHAR(03)

   CASE
      WHEN INFIELD(cod_grupo)
         CALL log009_popup(8,21,"GRUPO ITEM","grupo_item",
                     "cod_grupo_item","den_grupo_item","pol0644","N","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0644
         IF p_codigo IS NOT NULL THEN
            LET p_grupo_produto_885.cod_grupo = p_codigo CLIPPED
           SELECT den_grupo_item
              INTO p_den_grupo
              FROM grupo_item
             WHERE cod_grupo_item = p_grupo_produto_885.cod_grupo
             ORDER BY cod_grupo_item

            IF STATUS = 0 THEN              
               DISPLAY p_grupo_produto_885.cod_grupo TO cod_grupo
               DISPLAY p_den_grupo TO den_grupo
            END IF
         END IF
   END CASE

END FUNCTION

#------------------------------#
 FUNCTION pol0644_exibe_dados()
#------------------------------#

   LET p_den_grupo = NULL
   LET p_den_tipo  = NULL
      
   SELECT den_grupo_item
     INTO p_den_grupo
     FROM grupo_item
    WHERE cod_grupo_item = p_grupo_produto_885.cod_grupo
    
   IF p_grupo_produto_885.cod_tipo = '1' THEN
      LET p_den_tipo = 'Papel'
   ELSE
      IF p_grupo_produto_885.cod_tipo = '2' THEN
         LET p_den_tipo = 'Chapa'
      ELSE
         IF p_grupo_produto_885.cod_tipo = '3' THEN
            LET p_den_tipo = 'Caixa'
         END IF
      END IF
   END IF

   DISPLAY BY NAME p_grupo_produto_885.*
   DISPLAY p_den_grupo TO den_grupo
   DISPLAY p_den_tipo  TO den_tipo

END FUNCTION

#-----------------------------------#
 FUNCTION pol0644_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_grupo_produto_885.*                                              
     FROM grupo_produto_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_grupo   = p_grupo_produto_885.cod_grupo
      AND cod_tipo    = p_grupo_produto_885.cod_tipo
   FOR UPDATE
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","GRUPO_PRODUTO_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0644_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0644_cursor_for_update() THEN
      LET p_grupo_produto_885a.* = p_grupo_produto_885.*
      
      IF pol0644_entrada_dados("MODIFICACAO") THEN
         UPDATE grupo_produto_885
            SET cod_tipo  = p_grupo_produto_885.cod_tipo
           WHERE cod_empresa = p_cod_empresa
             AND cod_grupo   = p_grupo_produto_885.cod_grupo
             
          #WHERE CURRENT OF cm_padrao
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","GRUPO_PRODUTO_885")
         END IF
      ELSE
         LET p_grupo_produto_885.* = p_grupo_produto_885a.*
         CALL pol0644_exibe_dados()
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
 FUNCTION pol0644_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0644_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM grupo_produto_885
          WHERE cod_empresa = p_cod_empresa
          AND cod_grupo   = p_grupo_produto_885.cod_grupo
         # WHERE CURRENT OF cm_padrao
         
         IF STATUS = 0 THEN
            INITIALIZE p_grupo_produto_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","GRUPO_PRODUTO_885")
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
 FUNCTION pol0644_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_grupo_produto_885a.* =  p_grupo_produto_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_grupo_produto_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_grupo_produto_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_grupo_produto_885.* = p_grupo_produto_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_grupo_produto_885.*
           FROM grupo_produto_885
          WHERE cod_empresa  = p_cod_empresa
            AND cod_grupo    = p_grupo_produto_885.cod_grupo
            AND cod_tipo     = p_grupo_produto_885.cod_tipo
           
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0644_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0644_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_imp CURSOR FOR 
    SELECT *
      FROM grupo_produto_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_grupo

   FOREACH cq_imp INTO p_grupo_produto_885.*
   
      INITIALIZE p_den_grupo TO NULL
   
      SELECT den_grupo_item
        INTO p_den_grupo
        FROM grupo_item
       WHERE cod_grupo_item = p_grupo_produto_885.cod_grupo

      OUTPUT TO REPORT pol0644_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION  

#---------------------#
 REPORT pol0644_relat()
#---------------------#

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
         PRINT COLUMN 001, "POL0644           RELATORIO DE GRUPO DE PRODUTOS"
         PRINT COLUMN 001, "-------------------------------------------------------------"
         PRINT
         PRINT COLUMN 005, 'GRUPO  DESCRICAO                  TIPO'
         PRINT COLUMN 005, '-----  -------------------------  ----'

      ON EVERY ROW
      
         PRINT COLUMN 07, p_grupo_produto_885.cod_grupo,
               COLUMN 12, p_den_grupo,
               COLUMN 40, p_grupo_produto_885.cod_tipo         
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#