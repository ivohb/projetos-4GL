#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0650                                                 #
# MODULOS.: pol0650-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE TOLERANCIA - CIBRAPEL                       #
# AUTOR...: POLO INFORMATICA - ANA PAULA                            #
# DATA....: 11/10/2007                                              #
# ALTERADO: 17/10/2007 por Ana Paula - versao 00                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_operacao       CHAR(50),
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
          p_msg                CHAR(500)
          
   DEFINE p_par_ega_logix_912   RECORD LIKE par_ega_logix_912.*,
          p_par_ega_logix_912a  RECORD LIKE par_ega_logix_912.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario() 
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0650-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0650.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0650_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0650_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0650") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0650 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol0650_consulta()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0650_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE "Parametros ja cadastrados na Tabela PAR_EGA_LOGIX_912 !!!"
            ERROR   "Operação cancelada !!!"
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0650_modificacao() THEN
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
            IF pol0650_exclusao() THEN
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
         CALL pol0650_consulta()
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 005
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0650","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0650_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0650.tmp'
                     START REPORT pol0650_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0650_relat TO p_nom_arquivo
               END IF
               CALL pol0650_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0650_relat   
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
         CALL pol0650_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 006
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0650

END FUNCTION

#--------------------------#
 FUNCTION pol0650_inclusao()
#--------------------------#


   SELECT * 
     INTO p_par_ega_logix_912.*                                              
     FROM par_ega_logix_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN 
      RETURN FALSE
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_par_ega_logix_912.* TO NULL
      LET p_par_ega_logix_912.cod_empresa = p_cod_empresa

      IF pol0650_entrada_dados("INCLUSAO") THEN
         CALL log085_transacao("BEGIN")
         WHENEVER ANY ERROR CONTINUE
         INSERT INTO par_ega_logix_912 VALUES (p_par_ega_logix_912.*)
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
   END IF
    
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0650_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0650

   INPUT BY NAME p_par_ega_logix_912.* 
      WITHOUT DEFAULTS  

      AFTER FIELD hist_auto_op_enc
      IF p_par_ega_logix_912.hist_auto_op_enc IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD hist_auto_op_enc
      END IF

      AFTER FIELD compati_op_lote
      IF p_par_ega_logix_912.compati_op_lote IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD compati_op_lote
      END IF
          
      AFTER FIELD ies_baixa_pc_rej
      IF p_par_ega_logix_912.ies_baixa_pc_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD ies_baixa_pc_rej
      END IF 
      
      BEFORE FIELD cod_oper_bx_pc_rej
      IF p_par_ega_logix_912.ies_baixa_pc_rej = 'N' THEN  
          EXIT INPUT
      END IF  
      
       AFTER FIELD cod_oper_bx_pc_rej
       IF p_par_ega_logix_912.cod_oper_bx_pc_rej IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_oper_bx_pc_rej
       ELSE 
        
        SELECT den_operacao
        INTO p_den_operacao  
        FROM estoque_operac
        WHERE cod_empresa  = p_cod_empresa
          AND cod_operacao = p_par_ega_logix_912.cod_oper_bx_pc_rej 
       
        
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Operação nao Cadastrado na Tabela estoque_operac !!!" 
            NEXT FIELD cod_oper_bx_pc_rej
         END IF 
         
         DISPLAY p_par_ega_logix_912.cod_oper_bx_pc_rej TO cod_oper_bx_pc_rej
         DISPLAY p_den_operacao TO den_operacao 
          
     END IF 
     
           ON KEY (control-z)
          CALL pol0650_popup()
          
   END INPUT 



   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0650

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0650_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_par_ega_logix_912a.* = p_par_ega_logix_912.*
   
   SELECT *
     INTO p_par_ega_logix_912.*
     FROM par_ega_logix_912
    WHERE cod_empresa = p_cod_empresa
    ORDER BY cod_empresa

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0650_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0650_exibe_dados()
#------------------------------#
        SELECT den_operacao
        INTO p_den_operacao  
        FROM estoque_operac
        WHERE cod_operacao = p_par_ega_logix_912.cod_oper_bx_pc_rej 

   DISPLAY BY NAME p_par_ega_logix_912.*
   DISPLAY p_den_operacao TO den_operacao 
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol0650_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_par_ega_logix_912.*                                              
     FROM par_ega_logix_912
    WHERE cod_empresa = p_cod_empresa
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","par_ega_logix_912")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0650_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0650_cursor_for_update() THEN
      LET p_par_ega_logix_912a.* = p_par_ega_logix_912.*
      IF pol0650_entrada_dados("MODIFICACAO") THEN
         UPDATE par_ega_logix_912
            SET hist_auto_op_enc   = p_par_ega_logix_912.hist_auto_op_enc,
                compati_op_lote    = p_par_ega_logix_912.compati_op_lote,
                ies_baixa_pc_rej   = p_par_ega_logix_912.ies_baixa_pc_rej,
                cod_oper_bx_pc_rej = p_par_ega_logix_912.cod_oper_bx_pc_rej
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","par_ega_logix_912")
         END IF
      ELSE
         LET p_par_ega_logix_912.* = p_par_ega_logix_912a.*
         CALL pol0650_exibe_dados()
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
 FUNCTION pol0650_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0650_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM par_ega_logix_912
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_par_ega_logix_912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","par_ega_logix_912")
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
 FUNCTION pol0650_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_par_ega_logix CURSOR FOR
    SELECT * 
      FROM par_ega_logix_912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_empresa
          
     FOREACH cq_par_ega_logix INTO p_par_ega_logix_912.*
   
      OUTPUT TO REPORT pol0650_relat() 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0650_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 035, "PARAMETROS EGA X LOGIX",
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0650",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "-----------------------------------------------------------------------------",
                           "---------------------------------------------"
         PRINT                  
         PRINT COLUMN 005, "EMPRESA  HISTORICO  LOTE   PEÇA REJEITADA   OPERAÇÃO "
         PRINT COLUMN 005, "-------  ---------  ----   --------------   -------- "
      
      ON EVERY ROW

         PRINT COLUMN 008, p_par_ega_logix_912.cod_empresa,
               COLUMN 017, p_par_ega_logix_912.hist_auto_op_enc,
               COLUMN 027, p_par_ega_logix_912.compati_op_lote,
               COLUMN 038, p_par_ega_logix_912.ies_baixa_pc_rej,
               COLUMN 050, p_par_ega_logix_912.cod_oper_bx_pc_rej
               
END REPORT

#-----------------------#
FUNCTION pol0650_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_oper_bx_pc_rej)
         CALL log009_popup(5,12,"CODIGO","estoque_operac",
              "cod_operacao","den_operacao","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0650
         IF p_codigo IS NOT NULL THEN
           LET p_par_ega_logix_912.cod_oper_bx_pc_rej = p_codigo
           DISPLAY p_codigo TO p_codigo 
         END IF
     END CASE 
     
     END FUNCTION    

#-----------------------#
 FUNCTION pol0650_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

