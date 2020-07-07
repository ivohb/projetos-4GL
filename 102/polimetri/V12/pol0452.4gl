#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO DO LOGIX x EGA - MAN912                      #
# PROGRAMA: pol0452                                                 #
# MODULOS.: pol0452-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: MANUTENCAO DA TABELA OPER_EGA_MAN912                    #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 12/06/2006                                              #
# ALTERADO: 12/12/2006 por ANA PAULA                                #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_operac         LIKE operacao.den_operac,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
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
          p_msg                CHAR(500)
          

   DEFINE p_oper_ega_man912   RECORD LIKE oper_ega_man912.*,
          p_oper_ega_man912a  RECORD LIKE oper_ega_man912.* 

   DEFINE pr_operac   ARRAY[3000] OF RECORD
          cod_operac  LIKE operacao.cod_operac,
          den_operac  LIKE operacao.den_operac
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0452-12.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0452.iem") RETURNING p_nom_help
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
      CALL pol0452_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0452_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0452") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0452 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0452_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0452_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0452_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0452_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0452_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0452_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0452","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0452_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0452.tmp'
                     START REPORT pol0452_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0452_relat TO p_nom_arquivo
               END IF
               CALL pol0452_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0452_relat   
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
         CALL pol0452_sobre()
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
   CLOSE WINDOW w_pol0452

END FUNCTION

#--------------------------#
 FUNCTION pol0452_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0452_entrada_dados("INCLUSAO") THEN
      LET p_oper_ega_man912.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO oper_ega_man912 VALUES (p_oper_ega_man912.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","oper_ega_man912")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_oper_ega_man912.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0452_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0452
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_oper_ega_man912.* TO NULL
      CALL pol0452_exibe_dados()
      LET p_oper_ega_man912.cod_empresa = p_cod_empresa
   END IF

   INPUT BY NAME p_oper_ega_man912.* 
      WITHOUT DEFAULTS  

       BEFORE FIELD cod_operac
          IF p_funcao = 'MODIFICACAO' THEN
             NEXT FIELD cod_operac_ega
          END IF
          
       AFTER FIELD cod_operac
          IF p_oper_ega_man912.cod_operac IS NULL OR 
             p_oper_ega_man912.cod_operac = " " THEN 
             ERROR 'Informe uma Operação...'
             NEXT FIELD cod_operac
          ELSE
             IF pol0452_verifica_operacao() = FALSE THEN
                ERROR 'Operação não cadastrada.'
                NEXT FIELD cod_operac
             ELSE
                IF pol0452_verifica_duplicidade() THEN
                   ERROR 'Operação já Cadastrada.'
                   NEXT FIELD cod_operac
                END IF 
             END IF    
          END IF 
       
       AFTER FIELD cod_operac_ega
          IF p_oper_ega_man912.cod_operac_ega IS NULL OR 
             p_oper_ega_man912.cod_operac_ega = " " THEN 
             ERROR 'Informe uma Operação EGA...'
             NEXT FIELD cod_operac_ega
          ELSE
             IF pol0452_verifica_duplic_maq_ega(p_funcao) THEN
                ERROR 'Operação EGA já Cadastrada.'
                NEXT FIELD cod_operac_ega
             END IF    
          END IF 

       ON KEY (f4,control-z)
          CALL pol0452_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0452

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0452_verifica_operacao()
#-----------------------------------#
   SELECT den_operac
     INTO p_den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac  = p_oper_ega_man912.cod_operac
   
   IF SQLCA.sqlcode = 0 THEN
      DISPLAY p_den_operac TO den_operac
      RETURN TRUE
   ELSE
      RETURN FALSE 
   END IF
   
END FUNCTION 
 
#--------------------------------------#
 FUNCTION pol0452_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE cod_operac
     FROM oper_ega_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = p_oper_ega_man912.cod_operac
   
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 
 
#--------------------------------------------------#
 FUNCTION pol0452_verifica_duplic_maq_ega(p_funcao)
#--------------------------------------------------#

   DEFINE p_funcao      CHAR(30)
   DEFINE p_cod_operac LIKE oper_ega_man912.cod_operac


   SELECT UNIQUE cod_operac
     INTO p_cod_operac
     FROM oper_ega_man912
    WHERE cod_empresa     = p_cod_empresa
      AND cod_operac_ega  = p_oper_ega_man912.cod_operac_ega
   
   IF SQLCA.sqlcode = 0 THEN
      IF p_funcao = 'INCLUSAO' THEN
         RETURN TRUE
      ELSE
         IF p_cod_operac <> p_oper_ega_man912.cod_operac THEN
            RETURN TRUE
         ELSE
            RETURN FALSE
         END IF
      END IF
   ELSE 
      RETURN FALSE
   END IF 



END FUNCTION

#--------------------------#
 FUNCTION pol0452_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_oper_ega_man912a.* = p_oper_ega_man912.*

 CONSTRUCT BY NAME where_clause ON oper_ega_man912.cod_operac,
                                   oper_ega_man912.cod_operac_ega

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0452

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_oper_ega_man912.* = p_oper_ega_man912a.*
      CALL pol0452_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM oper_ega_man912 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_operac "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_oper_ega_man912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0452_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0452_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_oper_ega_man912.*
   DISPLAY p_cod_empresa TO cod_empresa
   
   INITIALIZE p_den_operac TO NULL
   SELECT den_operac
     INTO p_den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac  = p_oper_ega_man912.cod_operac
   DISPLAY p_den_operac TO den_operac
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0452_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_oper_ega_man912.*                                              
      FROM oper_ega_man912  
         WHERE cod_empresa = p_oper_ega_man912.cod_empresa
           AND cod_operac = p_oper_ega_man912.cod_operac
             FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","oper_ega_man912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0452_modificacao()
#-----------------------------#

   IF pol0452_cursor_for_update() THEN
      LET p_oper_ega_man912a.* = p_oper_ega_man912.*
      IF pol0452_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE oper_ega_man912 
            SET cod_operac_ega = p_oper_ega_man912.cod_operac_ega
                WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","oper_ega_man912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_oper_ega_man912.* = p_oper_ega_man912a.*
         ERROR "Modificacao Cancelada"
         CALL pol0452_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0452_exclusao()
#--------------------------#

   IF pol0452_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM oper_ega_man912
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_oper_ega_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","oper_ega_man912")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0452_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_oper_ega_man912a.* = p_oper_ega_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_oper_ega_man912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_oper_ega_man912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_oper_ega_man912.* = p_oper_ega_man912a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_oper_ega_man912.* 
         FROM oper_ega_man912
            WHERE cod_empresa = p_oper_ega_man912.cod_empresa
              AND cod_operac = p_oper_ega_man912.cod_operac
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0452_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0452_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM oper_ega_man912
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_operac
   
   FOREACH cq_oper INTO p_oper_ega_man912.*
 
      INITIALIZE p_den_operac TO NULL
      SELECT den_operac
        INTO p_den_operac
        FROM operacao
      WHERE cod_empresa = p_cod_empresa
        AND cod_operac  = p_oper_ega_man912.cod_operac
   
      OUTPUT TO REPORT pol0452_relat(p_oper_ega_man912.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0452_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD 
      cod_empresa     LIKE oper_ega_man912.cod_empresa,
      cod_operac      LIKE oper_ega_man912.cod_operac,          
      cod_operac_ega  LIKE oper_ega_man912.cod_operac_ega
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0452",
               COLUMN 030, "OPERACOES LOGIX - EGA",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 009, "COD OPER LOGIX  COD OPER EGA             DESCRICAO"
         PRINT COLUMN 009, "--------------  ------------  ------------------------------"
      

      ON EVERY ROW

         PRINT COLUMN 015, p_relat.cod_operac,
               COLUMN 031, p_relat.cod_operac_ega,
               COLUMN 039, p_den_operac
   
END REPORT

#-----------------------#
 FUNCTION pol0452_popup()
#-----------------------#
   
   DEFINE p_codigo CHAR(05)
   CASE
      WHEN INFIELD(cod_operac)
         CALL pol0452_popup_operac() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0452
         IF p_codigo IS NOT NULL THEN
            LET p_oper_ega_man912.cod_operac = p_codigo
            DISPLAY BY NAME p_oper_ega_man912.cod_operac
         END IF
   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol0452_popup_operac()
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04521") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04521 AT 7,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1

   DECLARE cq_operac CURSOR FOR
    SELECT cod_operac,
           den_operac
      FROM operacao
    WHERE cod_empresa = p_cod_empresa
    ORDER BY 2   

   FOREACH cq_operac INTO pr_operac[p_index].*
   
      LET p_index = p_index + 1
      
   END FOREACH

   CALL SET_COUNT(p_index - 1)
   

   DISPLAY ARRAY pr_operac TO  sr_operac.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
   
  RETURN pr_operac[p_index].cod_operac

END FUNCTION

#-----------------------#
 FUNCTION pol0452_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

