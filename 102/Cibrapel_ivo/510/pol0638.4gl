#-------------------------------------------------------------------#
# SISTEMA.: ADMINISTRATIVO                                          #
# PROGRAMA: pol0638                                                 #
# MODULOS.: pol0638-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
#           min0710.4go                                             #
# OBJETIVO: CADASTRO DE LISTA DE PRECO - CIBRAPEL                   #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 28/09/2007                                              #
# ALTERADO: 31/10/2007 por Ana Paula - versao 03                    #
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
          p_cod_tip_carteira   LIKE carteira_cli_885.cod_tip_carteira,
          p_cod_cliente        LIKE carteira_cli_885.cod_cliente,
          p_num_list_preco     LIKE carteira_cli_885.num_list_preco,
          p_den_tip_carteira   LIKE tipo_carteira.den_tip_carteira,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_nom_reduzido       LIKE clientes.nom_reduzido,
          p_den_list_preco     LIKE desc_preco_mest.den_list_preco,
          p_dat_fim_vig        LIKE desc_preco_mest.dat_fim_vig,
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_msg                CHAR(100)
  
   DEFINE p_carteira_cli_885  RECORD LIKE carteira_cli_885.*,
          p_carteira_cli_885a RECORD LIKE carteira_cli_885.*
    
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0638-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0638.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0638_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0638_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0638") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0638 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0638_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF      
      COMMAND "Modificar" "Modifica Dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0638_modificacao() THEN
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
            IF pol0638_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               #MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0638_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0638_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0638_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0638","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0638_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0638.tmp'
                     START REPORT pol0638_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0638_relat TO p_nom_arquivo
               END IF
               CALL pol0638_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0638_relat   
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
   CLOSE WINDOW w_pol0638

END FUNCTION

#--------------------------#
 FUNCTION pol0638_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_carteira_cli_885.* TO NULL
   LET p_carteira_cli_885.cod_empresa = p_cod_empresa

   IF pol0638_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO carteira_cli_885 VALUES (p_carteira_cli_885.*)
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
 FUNCTION pol0638_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   
   LET p_den_tip_carteira = NULL
   LET p_nom_cliente      = NULL
   LET p_den_list_preco   = NULL
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0638

   INPUT BY NAME p_carteira_cli_885.*
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_tip_carteira
         IF p_funcao = "MODIFICACAO" THEN
            NEXT FIELD cod_cliente
         END IF 

      AFTER FIELD cod_tip_carteira
         IF p_carteira_cli_885.cod_tip_carteira IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_tip_carteira
         ELSE
            SELECT den_tip_carteira
              INTO p_den_tip_carteira
              FROM tipo_carteira
             WHERE cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
             ORDER BY cod_tip_carteira
      
            IF SQLCA.sqlcode <> 0 THEN
               ERROR "Codigo da Carteira não Cadastrado na Tabela TIPO_CARTEIRA !!!"
               NEXT FIELD cod_tip_carteira
            END IF 
            DISPLAY p_den_tip_carteira TO den_tip_carteira
         END IF
       
      AFTER FIELD cod_cliente
            
       {  IF p_carteira_cli_885.cod_cliente IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cliente
         END IF     }   
         IF p_carteira_cli_885.cod_cliente > 0 THEN
            SELECT nom_cliente
              INTO p_nom_cliente
              FROM clientes
             WHERE cod_cliente = p_carteira_cli_885.cod_cliente
             ORDER BY cod_cliente
           
            IF SQLCA.sqlcode <> 0 THEN
               ERROR "Codigo do Cliente não Cadastrado na Tabela CLIENTES !!!"
               NEXT FIELD cod_cliente
            END IF 
            DISPLAY p_nom_cliente TO nom_cliente
        
            SELECT * 
              FROM carteira_cli_885
             WHERE cod_empresa = p_cod_empresa
               AND cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
               AND cod_cliente      = p_carteira_cli_885.cod_cliente
        IF p_funcao <> "MODIFICACAO" THEN    
            IF SQLCA.sqlcode = 0 THEN
               ERROR "Codigo ja cadastrado Tabela CARTEIRA_CLI_885 !!!"
               NEXT FIELD cod_cliente
            END IF 
         END IF
      END IF 
          
      AFTER FIELD num_list_preco
         IF p_carteira_cli_885.num_list_preco IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_list_preco
         ELSE 
            SELECT den_list_preco,
                   dat_fim_vig
              INTO p_den_list_preco,
                   p_dat_fim_vig
              FROM desc_preco_mest
             WHERE cod_empresa    = p_cod_empresa
               AND num_list_preco = p_carteira_cli_885.num_list_preco
             ORDER BY num_list_preco
             
        IF p_funcao <> "MODIFICACAO" THEN             
            IF SQLCA.sqlcode <> 0 THEN
               ERROR "Lista de preço nao cadastrada na TABELA DESC_PRECO_MEST !!!"
               NEXT FIELD num_list_preco
            ELSE
               IF p_dat_fim_vig < TODAY THEN
                  ERROR "Lista de preço nao esta Vigente !!!"
                  NEXT FIELD num_list_preco
               END IF      
            END IF 
            DISPLAY p_den_list_preco TO den_list_preco
         END IF
      END IF 
      
      ON KEY (control-z)
         CALL pol0638_popup()
       
    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0638

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0638_consulta()
#--------------------------#

   DEFINE p_codigo  CHAR(02)
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   CONSTRUCT BY NAME where_clause ON 
       carteira_cli_885.cod_tip_carteira,
       carteira_cli_885.cod_cliente
    
        ON KEY (control-z)
         CALL pol0638_popup()
          
        {LET p_codigo = pol0638_carrega_carteira()
         IF p_codigo IS NOT NULL THEN
            LET p_carteira_cli_885.cod_tip_carteira = p_codigo  CLIPPED
            CURRENT WINDOW IS w_pol0638
            DISPLAY p_carteira_cli_885.cod_tip_carteira TO cod_tip_carteira
         END IF}

   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0638

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_carteira_cli_885.* = p_carteira_cli_885a.*
      CALL pol0638_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM carteira_cli_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_tip_carteira,cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_carteira_cli_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0638_exibe_dados()
   END IF

 END FUNCTION
 
#-----------------------------------#   
 FUNCTION pol0638_carrega_carteira() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_tip_carteira LIKE carteira_cli_885.cod_tip_carteira,
         cod_cliente      LIKE carteira_cli_885.cod_cliente,
         num_list_preco   LIKE carteira_cli_885.num_list_preco
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06381") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06381 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_tip_carteira,
           cod_cliente,
           num_list_preco
      FROM carteira_cli_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_tip_carteira, cod_cliente

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_tip_carteira,
                         pr_lista[pr_index].cod_cliente,
                         pr_lista[pr_index].num_list_preco

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0638

   LET p_carteira_cli_885.cod_cliente    = pr_lista[p_index].cod_cliente
   LET p_carteira_cli_885.num_list_preco = pr_lista[p_index].num_list_preco
   
   RETURN pr_lista[pr_index].cod_tip_carteira
      
END FUNCTION 

#------------------------------#
 FUNCTION pol0638_exibe_dados()
#------------------------------#

   LET p_den_tip_carteira = NULL
   LET p_nom_cliente      = NULL
   LET p_den_list_preco   = NULL
   
   SELECT den_tip_carteira
     INTO p_den_tip_carteira
     FROM tipo_carteira
    WHERE cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira

   DISPLAY p_den_tip_carteira TO den_tip_carteira

   IF p_carteira_cli_885.cod_cliente > 0 THEN
      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_carteira_cli_885.cod_cliente
       
      DISPLAY p_nom_cliente      TO nom_cliente
   END IF
   
   SELECT den_list_preco
     INTO p_den_list_preco
     FROM desc_preco_mest
    WHERE cod_empresa    = p_cod_empresa
      AND num_list_preco = p_carteira_cli_885.num_list_preco
   DISPLAY p_den_list_preco   TO den_list_preco

   DISPLAY BY NAME p_carteira_cli_885.*
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0638_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_carteira_cli_885.*                                              
     FROM carteira_cli_885
    WHERE cod_empresa      = p_cod_empresa
      AND cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
      AND (cod_cliente      = p_carteira_cli_885.cod_cliente
      OR cod_cliente IS NULL)
   FOR UPDATE
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","CARTEIRA_CLI_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0638_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0638_cursor_for_update() THEN
      LET p_carteira_cli_885a.* = p_carteira_cli_885.*
      
      IF pol0638_entrada_dados("MODIFICACAO") THEN
         UPDATE carteira_cli_885
            SET cod_cliente      = p_carteira_cli_885.cod_cliente,
                num_list_preco   = p_carteira_cli_885.num_list_preco
          WHERE cod_empresa      = p_cod_empresa
            AND cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
            AND (cod_cliente      = p_carteira_cli_885.cod_cliente
            OR cod_cliente IS NULL )
            
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","CARTEIRA_CLI_885")
         END IF
      ELSE
         LET p_carteira_cli_885.* = p_carteira_cli_885a.*
         CALL pol0638_exibe_dados()
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
 FUNCTION pol0638_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0638_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM carteira_cli_885
          WHERE cod_empresa      = p_cod_empresa
            AND cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
            AND (cod_cliente      = p_carteira_cli_885.cod_cliente
            OR cod_cliente IS NULL)
         
         IF STATUS = 0 THEN
            INITIALIZE p_carteira_cli_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","CARTEIRA_CLI_885")
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
 FUNCTION pol0638_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_carteira_cli_885a.* =  p_carteira_cli_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_carteira_cli_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_carteira_cli_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_carteira_cli_885.* = p_carteira_cli_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_carteira_cli_885.*
           FROM carteira_cli_885
          WHERE cod_empresa      = p_cod_empresa
            AND cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
            AND (cod_cliente      =  p_carteira_cli_885.cod_cliente
            OR  cod_cliente IS NULL )
           ORDER BY cod_tip_carteira,cod_cliente
           
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0638_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0638_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_imp CURSOR FOR 
    SELECT *
      FROM carteira_cli_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_tip_carteira

   FOREACH cq_imp INTO p_carteira_cli_885.*
   
      INITIALIZE p_den_tip_carteira,
                 p_nom_cliente,
                 p_den_list_preco TO NULL
   
      SELECT den_tip_carteira
        INTO p_den_tip_carteira
        FROM tipo_carteira
       WHERE cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira

      SELECT nom_reduzido
        INTO p_nom_reduzido
        FROM clientes
       WHERE cod_cliente = p_carteira_cli_885.cod_cliente

      SELECT den_list_preco
        INTO p_den_list_preco
        FROM desc_preco_mest
       WHERE cod_empresa    = p_cod_empresa
         AND num_list_preco = p_carteira_cli_885.num_list_preco

      OUTPUT TO REPORT pol0638_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#---------------------#
 REPORT pol0638_relat()
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
         PRINT COLUMN 001, "POL0368              RELATORIO DE LISTA DE PRECO"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "CARTEIRA              CLIENTE                                 LISTA DE PRECO"   
         PRINT COLUMN 001, "--------------------  ---------------------------------  --------------------------"

      ON EVERY ROW

         PRINT COLUMN 001, p_carteira_cli_885.cod_tip_carteira,
               COLUMN 004, "- ", p_den_tip_carteira,
               COLUMN 023, p_carteira_cli_885.cod_cliente,
               COLUMN 039,"- ",p_nom_reduzido,
               COLUMN 059, p_carteira_cli_885.num_list_preco,
               COLUMN 064, "- ", p_den_list_preco 
         
END REPORT

#-----------------------#
FUNCTION pol0638_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_tip_carteira)
         CALL log009_popup(8,25,"TIPO CARTEIRA","tipo_carteira",
                      "cod_tip_carteira","den_tip_carteira","pol0638","S","") 
             RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0638
         IF p_codigo IS NOT NULL THEN
            LET p_carteira_cli_885.cod_tip_carteira = p_codigo CLIPPED
            SELECT den_tip_carteira
              INTO p_den_tip_carteira
              FROM tipo_carteira
             WHERE cod_tip_carteira = p_carteira_cli_885.cod_tip_carteira
             
            DISPLAY p_carteira_cli_885.cod_tip_carteira TO cod_tip_carteira
            DISPLAY p_den_tip_carteira TO den_tip_carteira
         END IF

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0638
         IF p_codigo IS NOT NULL THEN
            LET p_carteira_cli_885.cod_cliente = p_codigo
            SELECT nom_reduzido
              INTO p_nom_reduzido
              FROM clientes
             WHERE cod_cliente = p_carteira_cli_885.cod_cliente
             
            DISPLAY p_carteira_cli_885.cod_cliente TO cod_cliente
            DISPLAY p_nom_reduzido TO nom_cliente
         END IF

      WHEN INFIELD(num_list_preco)
         CALL log009_popup(8,25,"LISTA DE PRECO","desc_preco_mest",
                     "num_list_preco","den_list_preco","pol0638","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)
         CURRENT WINDOW IS w_pol0638
         IF p_codigo IS NOT NULL THEN
            LET p_carteira_cli_885.num_list_preco = p_codigo CLIPPED
            SELECT den_list_preco
              INTO p_den_list_preco
              FROM desc_preco_mest
             WHERE cod_empresa    = p_cod_empresa
               AND num_list_preco = p_carteira_cli_885.num_list_preco            
               
            DISPLAY p_carteira_cli_885.num_list_preco TO num_list_preco
            DISPLAY p_den_list_preco TO den_list_preco
         END IF

   END CASE

END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#
{
 

 }
