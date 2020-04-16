#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0617                                                 #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 19/02/2007                                              #
# ALTERADO: 26/11/2007 por Ana Paula - versao 06                    #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
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
          p_nom_telapol        CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80),
          p_den_item_reduz     CHAR(18),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_msg                CHAR(100)
          
   DEFINE p_gramatura_885  RECORD LIKE gramatura_885.*,
          p_gramatura_885a RECORD LIKE gramatura_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0617-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0617.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0617_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0617_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_telapol TO NULL 
   CALL log130_procura_caminho("pol0617") RETURNING p_nom_telapol
   LET p_nom_telapol = p_nom_telapol CLIPPED 
   OPEN WINDOW w_pol0617 AT 2,2 WITH FORM p_nom_telapol
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0617_inclusao() THEN
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
            IF pol0617_modificacao() THEN
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
            IF pol0617_exclusao() THEN
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
         CALL pol0617_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0617_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0617_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0617","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0617_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0617.tmp'
                     START REPORT pol0617_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0617_relat TO p_nom_arquivo
               END IF
               CALL pol0617_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0617_relat   
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
   CLOSE WINDOW w_pol0617

END FUNCTION

#--------------------------#
 FUNCTION pol0617_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_gramatura_885.* TO NULL
   LET p_gramatura_885.cod_empresa = p_cod_empresa

   IF pol0617_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO gramatura_885 VALUES (p_gramatura_885.cod_empresa,
                                        p_gramatura_885.cod_item,
                                        p_gramatura_885.gramatura,
                                        p_gramatura_885.peso_minimo * 1000)
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
 FUNCTION pol0617_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   INPUT BY NAME p_gramatura_885.* WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD gramatura
      END IF 

      AFTER FIELD cod_item
      IF p_gramatura_885.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item
      ELSE
         SELECT den_item_reduz
           INTO p_den_item_reduz
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_gramatura_885.cod_item
        
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Item não Cadastrado na Tabela Item !!!"
            NEXT FIELD cod_item
         END IF 

         SELECT cod_item
           FROM gramatura_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_gramatura_885.cod_item

         IF STATUS = 0 THEN  
            ERROR 'Código do Item já Cadastrado na Tabela GRAMATURA_885 !!!'
            NEXT FIELD cod_item
         END IF
         DISPLAY p_den_item_reduz TO den_item_reduz
      END IF

      AFTER FIELD gramatura
      IF p_gramatura_885.gramatura IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD gramatura
      END IF

      AFTER FIELD peso_minimo
      IF p_gramatura_885.peso_minimo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD peso_minimo
       END IF
      
 #     DISPLAY p_gramatura_885.peso_minimo  TO peso_minimo

      ON KEY (control-z)
         CALL pol0617_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0617_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   DEFINE p_codigo CHAR(15)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_gramatura_885a.* = p_gramatura_885.*

   CONSTRUCT BY NAME where_clause ON gramatura_885.cod_item

      ON KEY(control-z)
         #LET p_codigo = pol0617_carrega_item()
         LET p_codigo = vdp373_popup_item(p_cod_empresa)         
         IF p_codigo IS NOT NULL THEN
            LET p_gramatura_885.cod_item = p_codigo
            CURRENT WINDOW IS w_pol0617
            DISPLAY p_gramatura_885.cod_item TO cod_item
         END IF

   END CONSTRUCT
      
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0617

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_gramatura_885.* = p_gramatura_885a.*
      CALL pol0617_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM gramatura_885 ",
                   " where cod_empresa = '",p_cod_empresa,"' ",
                   " and ", where_clause CLIPPED,                 
                   "ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","GRAMATURA_885")
      LET p_ies_cons = FALSE
      RETURN
   END IF
   OPEN cq_padrao
   FETCH cq_padrao INTO p_gramatura_885.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0617_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#   
 FUNCTION pol0617_carrega_item() 
#-------------------------------#
 
  DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_item       LIKE item_vdp.cod_item,
         den_item_reduz LIKE item.den_item_reduz
     END RECORD

 DEFINE p_cod_item   LIKE item_vdp.cod_item
 
   INITIALIZE p_nom_telapol TO NULL 
   CALL log130_procura_caminho("pol06171") RETURNING p_nom_telapol
   LET p_nom_telapol = p_nom_telapol CLIPPED 
   OPEN WINDOW w_pol06171 AT 5,4 WITH FORM p_nom_telapol
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item1 CURSOR FOR 
    SELECT cod_item 
      FROM gramatura_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item

   LET pr_index = 1

   FOREACH cq_item1 INTO pr_item[pr_index].cod_item
   
      SELECT den_item_reduz
        INTO pr_item[pr_index].den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_item[pr_index].cod_item

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

      LET pr_index = ARR_CURR()
      LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0617
   
   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 

#------------------------------#
 FUNCTION pol0617_exibe_dados()
#------------------------------#

   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_gramatura_885.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","GRAMATURA_885")
      LET p_ies_cons = FALSE
      RETURN
   END IF

   DISPLAY p_gramatura_885.cod_empresa        TO cod_empresa
   DISPLAY p_gramatura_885.cod_item           TO cod_item
   DISPLAY p_gramatura_885.gramatura          TO gramatura
   DISPLAY p_gramatura_885.peso_minimo/1000   TO peso_minimo
   DISPLAY p_den_item_reduz TO den_item_reduz

END FUNCTION

#-----------------------------------#
 FUNCTION pol0617_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT *
     FROM gramatura_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_gramatura_885.cod_item
   FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","gramatura_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0617_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0617_cursor_for_update() THEN
      LET p_gramatura_885a.* = p_gramatura_885.*
      
      IF pol0617_entrada_dados("MODIFICACAO") THEN
      
         UPDATE gramatura_885
            SET gramatura    = p_gramatura_885.gramatura,
                peso_minimo  = p_gramatura_885.peso_minimo * 1000
           WHERE cod_empresa = p_cod_empresa
             AND cod_item    = p_gramatura_885.cod_item 
          
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","GRAMATURA_885")
         END IF
      ELSE
         LET p_gramatura_885.* = p_gramatura_885a.*
         CALL pol0617_exibe_dados()
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
 FUNCTION pol0617_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0617_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         
         DELETE FROM gramatura_885
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_gramatura_885.cod_item
           
         IF STATUS = 0 THEN
            INITIALIZE p_gramatura_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","gramatura_885")
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
 FUNCTION pol0617_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_gramatura_885a.* =  p_gramatura_885.*

      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_padrao INTO p_gramatura_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO p_gramatura_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_gramatura_885.* = p_gramatura_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_gramatura_885.*
           FROM gramatura_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_gramatura_885.cod_item
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0617_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0617_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_gramatura CURSOR FOR
    SELECT * 
      FROM gramatura_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item
     
     FOREACH cq_gramatura INTO p_gramatura_885.*
   
      OUTPUT TO REPORT pol0617_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0617_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "CADASTRO DE GRAMATURA DE PAPEL",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0617",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "----------------------------------------",
                           "----------------------------------------"
         PRINT                  
         PRINT COLUMN 005, " ITEM              GRAMATURA  PESO MINIMO"
         PRINT COLUMN 005, "---------------    ---------  -----------"
      
      ON EVERY ROW

         PRINT COLUMN 005, p_gramatura_885.cod_item,
               COLUMN 022, p_gramatura_885.gramatura,
               COLUMN 034, p_gramatura_885.peso_minimo / 1000
   
END REPORT

#-----------------------#
FUNCTION pol0617_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = vdp373_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0617
         IF p_codigo IS NOT NULL THEN
            LET p_gramatura_885.cod_item = p_codigo
            DISPLAY p_codigo TO cod_item
         END IF

   END CASE
   
END FUNCTION  
{
#-----------------------------#
 FUNCTION pol0617_popup_item()
#-----------------------------#

  DEFINE pr_item        ARRAY[3000]
     OF RECORD
         cod_item       LIKE item_vdp.cod_item,
         den_item_reduz LIKE item.den_item_reduz
     END RECORD

 DEFINE p_cod_item   LIKE item_vdp.cod_item
 
   INITIALIZE p_nom_telapol TO NULL 
   CALL log130_procura_caminho("pol06171") RETURNING p_nom_telapol
   LET p_nom_telapol = p_nom_telapol CLIPPED 
   OPEN WINDOW w_pol06171 AT 5,4 WITH FORM p_nom_telapol
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item CURSOR FOR 
    SELECT cod_item 
      FROM item_vdp
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item
     
   LET pr_index = 1

   FOREACH cq_item INTO pr_item[pr_index].cod_item
   
      SELECT den_item_reduz
        INTO pr_item[pr_index].den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = pr_item[pr_index].cod_item

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

      LET pr_index = ARR_CURR()
      LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0617
   
   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 
}

#-------------------------------- FIM DE PROGRAMA -----------------------------#


