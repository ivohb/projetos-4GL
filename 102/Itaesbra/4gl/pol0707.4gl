#-------------------------------------------------------------------#
#                                                                   #
# PROGRAMA: pol0707                                                 #
# MODULOS.: pol0707-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: RECURSO POR GRUPO - ITAESBRA                            #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 26/12/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_descricao_grupo    LIKE grupo_desc_970.descricao_grupo,
          p_recurso            LIKE recurso.den_recur,
          p_cod_grupo          LIKE grupo_desc_970.cod_grupo,
          p_cod_recurso        LIKE recurso.cod_recur,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_caminho            CHAR(080),
          p_ies_cons           SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          tip_trim             CHAR(01),
          p_msg                CHAR(500)
      #    tip_trim2            CHAR(01)
          
          
          
   DEFINE p_grupo_recurso_970   RECORD LIKE grupo_recurso_970.*,
          p_grupo_recurso_970a  RECORD LIKE grupo_recurso_970.* 
          
          
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0707-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0707.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0707_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0707_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0707") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0707 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
          IF pol0707_inclusao() THEN
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
            IF pol0707_modificacao() THEN
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
            IF pol0707_exclusao() THEN
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
         CALL pol0707_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0707_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0707_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0707","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0707_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0707.tmp'
                     START REPORT pol0707_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0707_relat TO p_nom_arquivo
               END IF
               CALL pol0707_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0707_relat   
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
         CALL pol0707_sobre()
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
   CLOSE WINDOW w_pol0707

END FUNCTION

#--------------------------#
 FUNCTION pol0707_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_grupo_recurso_970.* TO NULL
   LET p_grupo_recurso_970.cod_empresa = p_cod_empresa
   
   IF pol0707_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO grupo_recurso_970 VALUES (p_grupo_recurso_970.*)

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
 FUNCTION pol0707_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0707

   INPUT BY NAME p_grupo_recurso_970.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_grupo
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_recurso
      END IF 
            
      AFTER FIELD cod_grupo
        IF p_grupo_recurso_970.cod_grupo IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_grupo
      ELSE  
         SELECT descricao_grupo
         INTO p_descricao_grupo
         FROM grupo_desc_970
         WHERE cod_empresa = p_cod_empresa 
         AND cod_grupo = p_grupo_recurso_970.cod_grupo
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do GRUPO nao Cadastrado na Tabela GRUPO_RECURSO_970 !!!" 
            NEXT FIELD cod_grupo
         END IF
               
         DISPLAY p_grupo_recurso_970.cod_grupo TO cod_grupo         
         DISPLAY p_descricao_grupo TO descricao_grupo
   
       IF STATUS = 0 THEN
          NEXT FIELD cod_recurso
       END IF
   
       END IF
                           
      AFTER FIELD cod_recurso
        IF p_grupo_recurso_970.cod_recurso IS NULL THEN 
          ERROR "Campo com preenchimento obrigatório !!!"
          NEXT FIELD cod_recurso
      ELSE  
         SELECT den_recur
         INTO p_recurso
         FROM recurso
         WHERE cod_empresa = p_cod_empresa 
         AND cod_recur = p_grupo_recurso_970.cod_recurso
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Recurso nao Cadastrado na Tabela RECURSO !!!" 
            NEXT FIELD cod_recurso
         END IF       
         
        SELECT cod_recurso,cod_grupo
        FROM grupo_recurso_970
        WHERE cod_empresa = p_cod_empresa 
        AND cod_grupo = p_grupo_recurso_970.cod_grupo 
         AND cod_recurso   = p_grupo_recurso_970.cod_recurso 
         
      IF STATUS = 0 THEN
         ERROR "Código da GRUPO/RECURSO já Cadastrada na Tabela grupo_recurso_970 !!!"
         NEXT FIELD cod_recurso
      END IF         
      
      SELECT cod_recurso,cod_grupo
        FROM grupo_recurso_970
        WHERE cod_empresa = p_cod_empresa
         AND cod_grupo = p_grupo_recurso_970.cod_grupo 
         AND cod_recurso   = p_grupo_recurso_970.cod_recurso 
         
      IF p_grupo_recurso_970.cod_recurso = p_grupo_recurso_970.cod_grupo THEN
         ERROR "Empresa Gerencial/Oficial Iguais!!"
         NEXT FIELD cod_recur
      END IF 
         
         DISPLAY p_grupo_recurso_970.cod_recurso TO cod_recurso         
         DISPLAY p_recurso TO den_recur
         
     IF SQLCA.sqlcode <> 0 THEN
       
     END IF
                    
     END IF 
                              
      ON KEY (control-z)
          CALL pol0707_popup()
                          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0707

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0707_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_grupo_recurso_970.* TO NULL
   LET p_grupo_recurso_970a.* = p_grupo_recurso_970.*

   CONSTRUCT BY NAME where_clause ON grupo_recurso_970.cod_grupo,grupo_recurso_970.cod_recurso 
  
      ON KEY (control-z)
   #   CALL pol0707_popup()
             LET p_cod_grupo = pol0707_carrega_empresa() 
               DISPLAY p_descricao_grupo TO descricao_grupo 
            IF p_cod_grupo IS NOT NULL THEN
               LET p_grupo_recurso_970.cod_grupo = p_cod_grupo CLIPPED
               CURRENT WINDOW IS w_pol0707
         DISPLAY p_grupo_recurso_970.cod_grupo TO cod_grupo         
         DISPLAY p_descricao_grupo TO descricao_grupo
            END IF
         
           LET p_cod_recurso = pol0707_carrega_oficial()
             IF p_cod_recurso IS NOT NULL THEN
                LET p_grupo_recurso_970.cod_recurso = p_cod_recurso CLIPPED
                CURRENT WINDOW IS w_pol0707
         DISPLAY p_grupo_recurso_970.cod_recurso TO cod_recurso         
         DISPLAY p_recurso TO den_recur
            END IF  
          
          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0707

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_grupo_recurso_970.* = p_grupo_recurso_970a.*
      CALL pol0707_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM grupo_recurso_970 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_grupo "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_grupo_recurso_970.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0707_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#   
 FUNCTION pol0707_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_grupo          LIKE grupo_recurso_970.cod_grupo,
         descricao_grupo    LIKE grupo_desc_970.descricao_grupo
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07071") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07071 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_grupo
        FROM grupo_recurso_970
        ORDER BY cod_grupo

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_grupo 
                         
        SELECT descricao_grupo
        INTO pr_empresa[pr_index].descricao_grupo
        FROM grupo_desc_970
       WHERE cod_grupo = pr_empresa[pr_index].cod_grupo                                

      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_empresa TO sr_empresa.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0707
  
   RETURN pr_empresa[pr_index].cod_grupo
      
END FUNCTION 


#-----------------------------------#   
 FUNCTION pol0707_carrega_oficial() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_recurso      LIKE grupo_recurso_970.cod_recurso,
         den_recur        LIKE recurso.den_recur
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07072") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07072 AT 5,17 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_recurso
      FROM grupo_recurso_970
      WHERE cod_grupo = p_cod_grupo
       ORDER BY cod_recurso

   LET pr_index2 = 1

   FOREACH cq_lista INTO pr_lista[pr_index2].cod_recurso 
   
   SELECT den_recur
        INTO pr_lista[pr_index2].den_recur
        FROM recurso
       WHERE cod_recur = pr_lista[pr_index2].cod_recurso

    LET pr_index2 = pr_index2 + 1
      IF pr_index2 > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index2 - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index2 = ARR_CURR()
   LET sr_index2 = SCR_LINE() 
      
   CLOSE WINDOW w_pol0707

   LET p_grupo_recurso_970.cod_recurso = pr_lista[pr_index2].cod_recurso
             
  RETURN pr_lista[pr_index2].cod_recurso

      
END FUNCTION 

#------------------------------#
 FUNCTION pol0707_exibe_dados()
#------------------------------#
   SELECT descricao_grupo
     INTO p_descricao_grupo
     FROM grupo_desc_970
    WHERE cod_empresa = p_cod_empresa 
    AND cod_grupo = p_grupo_recurso_970.cod_grupo
    
    SELECT den_recur
     INTO p_recurso
     FROM recurso
     WHERE cod_empresa = p_cod_empresa 
     AND cod_recur = p_grupo_recurso_970.cod_recurso

   DISPLAY BY NAME p_grupo_recurso_970.*
   DISPLAY p_descricao_grupo TO descricao_grupo
   DISPLAY p_recurso TO den_recur
   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0707_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_grupo_recurso_970.*                                              
     FROM grupo_recurso_970
    WHERE cod_empresa = p_cod_empresa
    AND  cod_grupo = p_grupo_recurso_970.cod_grupo
    AND cod_recurso = p_grupo_recurso_970.cod_recurso
        
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","grupo_recurso_970")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0707_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0707_cursor_for_update() THEN
      LET p_grupo_recurso_970a.* = p_grupo_recurso_970.*
      IF pol0707_entrada_dados("MODIFICACAO") THEN
         UPDATE grupo_recurso_970
            SET cod_grupo   = p_grupo_recurso_970.cod_grupo,
                cod_recurso = p_grupo_recurso_970.cod_recurso
              WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","grupo_recurso_970")
         END IF
      ELSE
         LET p_grupo_recurso_970.* = p_grupo_recurso_970a.*
         CALL pol0707_exibe_dados()
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
 FUNCTION pol0707_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0707_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM grupo_recurso_970
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_grupo_recurso_970.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","grupo_recurso_970")
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
 FUNCTION pol0707_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_grupo_recurso_970a.* = p_grupo_recurso_970.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_grupo_recurso_970.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_grupo_recurso_970.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_grupo_recurso_970.* = p_grupo_recurso_970a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_grupo_recurso_970.*
           FROM grupo_recurso_970
          WHERE cod_empresa = p_cod_empresa 
          AND cod_grupo = p_grupo_recurso_970.cod_grupo 
          AND  cod_recurso = p_grupo_recurso_970.cod_recurso 
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0707_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0707_emite_relatorio()
#-----------------------------------#

   
   DECLARE cq_grupo_recurso_970 CURSOR FOR
    SELECT * 
      FROM grupo_recurso_970
     ORDER BY cod_grupo
     
     FOREACH cq_grupo_recurso_970 INTO p_grupo_recurso_970.*
         
   SELECT descricao_grupo
     INTO p_descricao_grupo
     FROM grupo_desc_970
    WHERE cod_empresa = p_cod_empresa 
    AND cod_grupo = p_grupo_recurso_970.cod_grupo
    
    SELECT den_recur
     INTO p_recurso
     FROM recurso
     WHERE cod_empresa = p_cod_empresa 
     AND cod_recur = p_grupo_recurso_970.cod_recurso
           
        OUTPUT TO REPORT pol0707_relat() 
        LET p_count = p_count + 1
      
      
   END FOREACH
  
END FUNCTION 




#---------------------#
 REPORT pol0707_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT COLUMN 001, "RECURSO POR GRUPO ",
               COLUMN 025, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 055, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "                RELATORIO RECURSO POR GRUPO                        "
         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "                                                                   "
         PRINT COLUMN 001, "       GRUPO/DESCRICAO                  RECURSO/DESCRIÇÃO          "       
         PRINT COLUMN 001, "-------------------------------- ----------------------------------"

      ON EVERY ROW

         PRINT COLUMN 001, p_grupo_recurso_970.cod_grupo,"-",p_descricao_grupo[1,25],"   ",
               COLUMN 020, p_grupo_recurso_970.cod_recurso,"-",p_recurso[1,25]
              
         
END REPORT



#-----------------------#
FUNCTION pol0707_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_grupo)
         CALL log009_popup(5,12,"GRUPO","grupo_desc_970",
              "cod_grupo","descricao_grupo","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0707
         IF p_codigo IS NOT NULL THEN
           LET p_grupo_recurso_970.cod_grupo = p_codigo
           SELECT den_empresa
              INTO p_descricao_grupo
              FROM grupo_desc_970
             WHERE cod_empresa = p_cod_empresa 
             AND cod_grupo = p_grupo_recurso_970.cod_grupo
            
           DISPLAY p_grupo_recurso_970.cod_grupo TO cod_grupo 
           DISPLAY p_descricao_grupo TO descricao_grupo
           
         END IF
         
         
            WHEN INFIELD(cod_recurso)
         CALL log009_popup(5,12,"RECURSO","recurso",
              "cod_recur","den_recur","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0707
         IF p_codigo IS NOT NULL THEN
           LET p_grupo_recurso_970.cod_recurso = p_codigo
           SELECT den_recur
              INTO p_recurso
              FROM recurso
             WHERE cod_empresa = p_cod_empresa 
             AND cod_recurso = p_grupo_recurso_970.cod_recurso
            
           DISPLAY p_grupo_recurso_970.cod_recurso TO cod_recurso 
           DISPLAY p_recurso TO den_recur
           
         END IF
         
            END CASE 
END FUNCTION 

#-----------------------#
 FUNCTION pol0707_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#