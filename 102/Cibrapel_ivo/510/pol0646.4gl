#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0646                                                 #
# MODULOS.: pol0646-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE EMPRESAS - CIBRAPEL                         #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 29/10/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_den_reduz          LIKE empresa.den_reduz,
          p_cod_emp_gerencial  LIKE empresas_885.cod_emp_gerencial,
          p_cod_emp_oficial    LIKE empresas_885.cod_emp_oficial,
          p_user               LIKE usuario.nom_usuario,
        #  tip_trim2            LIKE empresas_885.tip_trim,
          tip_trim             LIKE empresas_885.tip_trim,   
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
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_ies_cons           SMALLINT,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_msg                CHAR(100)
      #    tip_trim             CHAR(01)
      #    tip_trim2            CHAR(01)
          
   DEFINE p_cabec               RECORD
         tip_trim2             LIKE empresas_885.tip_trim
          
   END RECORD
          
          
          
   DEFINE p_empresas_885   RECORD LIKE empresas_885.*,
          p_empresas_885a  RECORD LIKE empresas_885.* 
          
          
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0646-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0646.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0646_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0646_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0646") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0646 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
          IF pol0646_inclusao() THEN
            MESSAGE 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Opera��o cancelada !!!' 
          END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0646_modificacao() THEN
               MESSAGE 'Modifica��o efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0646_exclusao() THEN
               MESSAGE 'Exclus�o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0646_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0646_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0646_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0646_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 006
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0646","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0646_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0646.tmp'
                     START REPORT pol0646_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0646_relat TO p_nom_arquivo
               END IF
               CALL pol0646_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0646_relat   
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
         HELP 007
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0646

END FUNCTION

#--------------------------#
 FUNCTION pol0646_inclusao()
#--------------------------#

   CLEAR FORM
   INITIALIZE p_empresas_885.* TO NULL
   
   IF pol0646_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO empresas_885 VALUES (p_empresas_885.*)

      IF SQLCA.SQLCODE <> 0 THEN 
            CALL log085_transacao("ROLLBACK")
      ELSE
            CALL log085_transacao("COMMIT")
            RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
   END IF 
     RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0646_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0646

   

   INPUT BY NAME p_empresas_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_emp_gerencial
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD tip_trim
      END IF 
      
      BEFORE FIELD cod_emp_oficial
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD tip_trim
      END IF 
      
      AFTER FIELD cod_emp_gerencial
        IF p_empresas_885.cod_emp_gerencial IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_emp_gerencial
      ELSE  
         SELECT den_empresa
         INTO p_den_empresa
         FROM empresa
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         
    {     IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Empresa nao Cadastrado na Tabela EMPRESA !!!" 
            NEXT FIELD cod_emp_gerencial
         END IF}
               
         DISPLAY p_empresas_885.cod_emp_oficial TO cod_empresa         
         DISPLAY p_den_empresa TO den_empresa
   
       IF STATUS = 0 THEN
          NEXT FIELD cod_emp_oficial
       END IF
   
       END IF
                           
      AFTER FIELD cod_emp_oficial
        IF p_empresas_885.cod_emp_oficial IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_emp_oficial
      ELSE  
         SELECT den_reduz
         INTO p_den_reduz
         FROM empresa
         WHERE cod_empresa = p_empresas_885.cod_emp_oficial
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Empresa nao Cadastrado na Tabela EMPRESA !!!" 
            NEXT FIELD cod_emp_oficial
         END IF       
         
        SELECT cod_emp_oficial,cod_emp_gerencial
        FROM empresas_885
        WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial 
         AND cod_emp_oficial   = p_empresas_885.cod_emp_oficial 
         
      IF STATUS = 0 THEN
         ERROR "C�digo da Empresa Gerencial/Oficial j� Cadastrada na Tabela EMPRESAS_885 !!!"
         NEXT FIELD cod_emp_oficial
      END IF         
      
      SELECT cod_emp_oficial,cod_emp_gerencial
        FROM empresas_885
        WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial 
         AND cod_emp_oficial   = p_empresas_885.cod_emp_oficial 
         
      IF p_empresas_885.cod_emp_oficial = p_empresas_885.cod_emp_gerencial THEN
         ERROR "Empresa Gerencial/Oficial Iguais!!"
         NEXT FIELD cod_emp_oficial
      END IF 
         
         DISPLAY p_empresas_885.cod_emp_oficial TO cod_empresa         
         DISPLAY p_den_reduz TO den_reduz
         
     IF SQLCA.sqlcode <> 0 THEN
       NEXT FIELD tip_trim
     END IF
                    
     END IF 
          
  {        BEFORE INPUT
       AFTER FIELD tip_trim
      
    IF  p_empresas_885.tip_trim = 'S' THEN
         ERROR "Cadastrado como Box"
        #  NEXT FIELD tip_trim
     EXIT INPUT         
       END IF  
       
  {   IF SQLCA.sqlcode <> 0 THEN
       NEXT FIELD tip_trim2
     END IF }
                
   {     AFTER FIELD tip_trim2         
      IF p_cabec.tip_trim2 = 'S' THEN
         ERROR "Cadastrado como Papel"
          NEXT FIELD tip_trim2
         END IF 
       EXIT INPUT   }      
                
      AFTER FIELD tip_trim
        IF p_empresas_885.tip_trim IS NULL THEN 
           ERROR "Campo com preenchimento obrigat�rio !!!"
           NEXT FIELD tip_trim
        END IF  
     
    # DISPLAY p_den_reduz AT 5,1
     
{     IF p_empresas_885.tip_trim='Papel' THEN 
        LET p_empresas_885.tip_trim='P'
      END IF 
      
      IF p_empresas_885.tip_trim='Box' THEN 
        LET p_empresas_885.tip_trim='B'
        END IF 
        
        
        SELECT tip_trim
         FROM empresas_885
         WHERE tip_trim = p_empresas_885.tip_trim
              
      IF p_empresas_885.tip_trim != 'P' AND
         p_empresas_885.tip_trim != 'B' THEN
         ERROR "Campo invalido tipo deve ser P ou B!!!" 
         NEXT FIELD tip_trim
      END IF  }
                    
      ON KEY (control-z)
          CALL pol0646_popup()
                          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0646

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0646_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   INITIALIZE p_empresas_885.* TO NULL
   LET p_empresas_885a.* = p_empresas_885.*

   CONSTRUCT BY NAME where_clause ON empresas_885.cod_emp_gerencial,empresas_885.cod_emp_oficial 
  
      ON KEY (control-z)
             LET p_cod_emp_gerencial = pol0646_carrega_empresa() 
               DISPLAY p_den_empresa TO den_empresa 
            IF p_cod_emp_gerencial IS NOT NULL THEN
               LET p_empresas_885.cod_emp_gerencial = p_cod_emp_gerencial CLIPPED
               CURRENT WINDOW IS w_pol0646
               DISPLAY p_empresas_885.cod_emp_gerencial TO cod_emp_gerencial
               DISPLAY p_den_empresa TO den_empresa
            END IF
         
           LET p_cod_emp_oficial = pol0646_carrega_oficial()
             IF p_cod_emp_oficial IS NOT NULL THEN
                LET p_empresas_885.cod_emp_oficial = p_cod_emp_oficial CLIPPED
                CURRENT WINDOW IS w_pol0646
                DISPLAY p_empresas_885.cod_emp_oficial TO cod_emp_oficial
                DISPLAY p_den_reduz TO den_reduz
            END IF
          
          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0646

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_empresas_885.* = p_empresas_885a.*
      CALL pol0646_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM empresas_885 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_emp_gerencial "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_empresas_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0646_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#   
 FUNCTION pol0646_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_emp_gerencial  LIKE empresas_885.cod_emp_gerencial,
         den_empresa        LIKE empresa.den_empresa
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06461") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06461 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_emp_gerencial
        FROM empresas_885
        ORDER BY cod_emp_gerencial

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_emp_gerencial 
                         
        SELECT den_empresa
        INTO pr_empresa[pr_index].den_empresa
        FROM empresa
       WHERE cod_empresa = pr_empresa[pr_index].cod_emp_gerencial                                

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
      
   CLOSE WINDOW w_pol0646
  
   RETURN pr_empresa[pr_index].cod_emp_gerencial
      
END FUNCTION 


#-----------------------------------#   
 FUNCTION pol0646_carrega_oficial() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_emp_oficial  LIKE empresas_885.cod_emp_oficial,
         den_reduz        LIKE empresa.den_reduz
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06462") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06462 AT 5,17 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_emp_oficial
      FROM empresas_885
      WHERE cod_emp_gerencial = p_cod_emp_gerencial 
      ORDER BY cod_emp_oficial

   LET pr_index2 = 1

   FOREACH cq_lista INTO pr_lista[pr_index2].cod_emp_oficial 
   
   SELECT den_reduz
        INTO pr_lista[pr_index2].den_reduz
        FROM empresa
       WHERE cod_empresa = pr_lista[pr_index2].cod_emp_oficial

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
      
   CLOSE WINDOW w_pol0646

   LET p_empresas_885.cod_emp_oficial = pr_lista[pr_index2].cod_emp_oficial
             
  RETURN pr_lista[pr_index2].cod_emp_oficial

      
END FUNCTION 

#------------------------------#
 FUNCTION pol0646_exibe_dados()
#------------------------------#
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
    
    SELECT den_reduz
     INTO p_den_reduz
     FROM empresa
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial

   DISPLAY BY NAME p_empresas_885.*
   DISPLAY p_den_empresa TO den_empresa
   DISPLAY p_den_reduz TO den_reduz
   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0646_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_empresas_885.*                                              
     FROM empresas_885
    WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial
    AND cod_emp_oficial = p_empresas_885.cod_emp_oficial
        
   # FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","EMPRESAS_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0646_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0646_cursor_for_update() THEN
      LET p_empresas_885a.* = p_empresas_885.*
      IF pol0646_entrada_dados("MODIFICACAO") THEN
         UPDATE empresas_885
            SET tip_trim = p_empresas_885.tip_trim
         WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial
         AND   cod_emp_oficial = p_empresas_885.cod_emp_oficial
             
             # WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","empresas_885")
         END IF
      ELSE
         LET p_empresas_885.* = p_empresas_885a.*
         CALL pol0646_exibe_dados()
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
 FUNCTION pol0646_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0646_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM empresas_885
        WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial
        AND   cod_emp_oficial = p_empresas_885.cod_emp_oficial
         
        # WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_empresas_885.* TO NULL
            CLEAR FORM
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","empresas_885")
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
 FUNCTION pol0646_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_empresas_885a.* = p_empresas_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_empresas_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_empresas_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_empresas_885.* = p_empresas_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_empresas_885.*
           FROM empresas_885
          WHERE cod_emp_gerencial = p_empresas_885.cod_emp_gerencial 
          AND  cod_emp_oficial = p_empresas_885.cod_emp_oficial 
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0646_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0646_emite_relatorio()
#-----------------------------------#

   
   DECLARE cq_empresas_885 CURSOR FOR
    SELECT * 
      FROM empresas_885
     ORDER BY cod_emp_gerencial,cod_emp_oficial
     
     FOREACH cq_empresas_885 INTO p_empresas_885.*
   
        SELECT den_empresa
          INTO p_den_empresa
          FROM empresa
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         
          SELECT den_reduz
          INTO p_den_reduz
          FROM empresa
         WHERE cod_empresa = p_empresas_885.cod_emp_oficial
         
         IF p_empresas_885.tip_trim = 'P' THEN
            LET p_trim = 'Papel'
         ELSE
            IF p_empresas_885.tip_trim = 'B' THEN
               LET p_trim = 'Box'
            END IF 
         END IF
           
        OUTPUT TO REPORT pol0646_relat() 
        LET p_count = p_count + 1
      
      
   END FOREACH
  
END FUNCTION 




#---------------------#
 REPORT pol0646_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT COLUMN 001, "EMPRESA GERENCIAL/OFICIAL ",
               COLUMN 025, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 055, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "POL0646  RELATORIO CADASTRO DE EMPRESA GERENCIAL/OFICIAL"
         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "                                                                   "
         PRINT COLUMN 001, "        EMPRESA GERENCIAL              EMPRESA OFICIAL    TIPO TRIM"       
         PRINT COLUMN 001, "------------------------------------   ---------------    ---------"

      ON EVERY ROW

         PRINT COLUMN 001, p_empresas_885.cod_emp_gerencial,"- ", p_den_empresa,
               COLUMN 023, p_empresas_885.cod_emp_oficial,"- ", p_den_reduz,"     ",
               COLUMN 053, p_trim
               
          #PRINT LINES 5, p_den_reduz
         
END REPORT







#-----------------------#
FUNCTION pol0646_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_emp_gerencial)
         CALL log009_popup(5,12,"EMPRESAS","empresa",
              "cod_empresa","den_empresa","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0646
         IF p_codigo IS NOT NULL THEN
           LET p_empresas_885.cod_emp_gerencial = p_codigo
           SELECT den_empresa
              INTO p_den_empresa
              FROM empresa
             WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
            
           DISPLAY p_empresas_885.cod_emp_gerencial TO cod_emp_gerencial 
           DISPLAY p_den_empresa TO den_empresa
           
         END IF
         
         
            WHEN INFIELD(cod_emp_oficial)
         CALL log009_popup(5,12,"EMPRESAS","empresa",
              "cod_empresa","den_reduz","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0646
         IF p_codigo IS NOT NULL THEN
           LET p_empresas_885.cod_emp_oficial = p_codigo
           SELECT den_reduz
              INTO p_den_reduz
              FROM empresa
             WHERE cod_empresa = p_empresas_885.cod_emp_oficial
            
           DISPLAY p_empresas_885.cod_emp_oficial TO cod_emp_oficial 
           DISPLAY p_den_reduz TO den_reduz
           
         END IF
         
            END CASE 
END FUNCTION 

#-----------------------#
 FUNCTION pol0646_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#