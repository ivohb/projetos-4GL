#-------------------------------------------------------------------#
# SISTEMA.: ASSIST�NCIA T�CNICA                                     #
# PROGRAMA: pol0966                                                 #
# MODULOS.: pol0966-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: MANUTENCAO DA TABELA rovmaq_ega_man912                   #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 02/03/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_maquina        LIKE recurso.den_recur,
          p_den_equip          LIKE componente.des_compon,
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
          p_caminho            CHAR(080)
          

   DEFINE p_rovmaq_ega_man912   RECORD LIKE rovmaq_ega_man912.*,
          p_rovmaq_ega_man912a  RECORD LIKE rovmaq_ega_man912.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0966-12.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0966.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0966_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0966_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0966") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0966 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0966_inclusao() RETURNING p_status
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0966_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0966_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0966_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0966_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0966_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0966","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0966_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0966.tmp'
                     START REPORT pol0966_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0966_relat TO p_nom_arquivo
               END IF
               CALL pol0966_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0966_relat   
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
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0966

END FUNCTION

#--------------------------#
 FUNCTION pol0966_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0966_entrada_dados("INCLUSAO") THEN
      LET p_rovmaq_ega_man912.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO rovmaq_ega_man912 VALUES (p_rovmaq_ega_man912.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","rovmaq_ega_man912")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_rovmaq_ega_man912.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0966_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0966
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_rovmaq_ega_man912.* TO NULL
      CALL pol0966_exibe_dados()
      LET p_rovmaq_ega_man912.cod_empresa = p_cod_empresa
   END IF

    INPUT BY NAME p_rovmaq_ega_man912.* WITHOUT DEFAULTS 
       
       BEFORE FIELD cod_maquina
          IF p_funcao <> 'INCLUSAO' THEN
             NEXT FIELD cod_maquina_ega
          END IF
          
       AFTER FIELD cod_maquina
          IF p_rovmaq_ega_man912.cod_maquina IS NULL OR 
             p_rovmaq_ega_man912.cod_maquina = " " THEN 
             ERROR 'Informe uma Maquina...'
             NEXT FIELD cod_maquina
          ELSE
             IF pol0966_verifica_maquina() = FALSE THEN
                ERROR 'Maquina nao cadastrada.'
                NEXT FIELD cod_maquina
             ELSE
                IF pol0966_verifica_duplicidade() THEN
                   ERROR 'M�quina j� Cadastrada.'
                   NEXT FIELD cod_maquina
                END IF 
             END IF    
          END IF 
       
       AFTER FIELD cod_maquina_ega
          IF p_rovmaq_ega_man912.cod_maquina_ega IS NULL OR 
             p_rovmaq_ega_man912.cod_maquina_ega = " " THEN 
             ERROR 'Informe uma Maquina EGA...'
             NEXT FIELD cod_maquina_ega
          ELSE
             IF pol0966_verifica_duplic_maq_ega(p_funcao) THEN
                ERROR 'Maquina EGA ja Cadastrada.'
                NEXT FIELD cod_maquina_ega
             END IF    
          END IF 

       AFTER FIELD cod_equip
          IF p_rovmaq_ega_man912.cod_equip IS NULL OR 
             p_rovmaq_ega_man912.cod_equip = " " THEN 
             ERROR 'Informe o Equipamento...'
             NEXT FIELD cod_equip
          ELSE
             IF NOT pol0966_verifica_equipto() THEN
                ERROR 'Equipamento Inexistente !!!'
                NEXT FIELD cod_equip
             END IF    
          END IF 
                        
       ON KEY (f4,control-z)
          CALL pol0966_popup()

    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0966

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol0966_verifica_maquina()
#----------------------------------#
   
   SELECT den_recur
     INTO p_den_maquina
     FROM recurso
    WHERE cod_empresa = p_cod_empresa
      AND cod_recur   = p_rovmaq_ega_man912.cod_maquina
   
   IF SQLCA.sqlcode = 0 THEN
      DISPLAY p_den_maquina TO den_maquina
      RETURN TRUE
   ELSE
      RETURN FALSE 
   END IF
   
END FUNCTION 
 
#--------------------------------------#
 FUNCTION pol0966_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE cod_maquina
     FROM rovmaq_ega_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_maquina = p_rovmaq_ega_man912.cod_maquina
   
   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 
 
#-------------------------------------------------#
 FUNCTION pol0966_verifica_duplic_maq_ega(p_funcao)
#-------------------------------------------------#
   
   DEFINE p_funcao      CHAR(30)
   DEFINE p_cod_maquina LIKE rovmaq_ega_man912.cod_maquina
   
   SELECT UNIQUE cod_maquina
     INTO p_cod_maquina
     FROM rovmaq_ega_man912
    WHERE cod_empresa     = p_cod_empresa
      AND cod_maquina_ega = p_rovmaq_ega_man912.cod_maquina_ega
   
   IF SQLCA.sqlcode = 0 THEN
      IF p_funcao = 'INCLUSAO' THEN
         RETURN TRUE
      ELSE
         IF p_cod_maquina <> p_rovmaq_ega_man912.cod_maquina THEN
            RETURN TRUE
         ELSE
            RETURN FALSE
         END IF
      END IF
   ELSE 
      RETURN FALSE
   END IF 

END FUNCTION

#----------------------------------#
 FUNCTION pol0966_verifica_equipto()
#----------------------------------#

   SELECT des_compon
     INTO p_den_equip
     FROM componente
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon  = p_rovmaq_ega_man912.cod_equip
   
   IF SQLCA.sqlcode = 0 THEN
      DISPLAY p_den_equip TO den_equip
      RETURN TRUE
   ELSE
      RETURN FALSE 
   END IF
   
END FUNCTION 


#--------------------------#
 FUNCTION pol0966_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rovmaq_ega_man912a.* = p_rovmaq_ega_man912.*

 CONSTRUCT BY NAME where_clause ON rovmaq_ega_man912.cod_maquina,
                                   rovmaq_ega_man912.cod_maquina_ega

    ON KEY (f4,control-z)
       CALL pol0966_popup()
 
 END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0966

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_rovmaq_ega_man912.* = p_rovmaq_ega_man912a.*
      CALL pol0966_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM rovmaq_ega_man912 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_maquina "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_rovmaq_ega_man912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0966_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0966_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_rovmaq_ega_man912.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_maquina TO NULL
   SELECT den_recur
     INTO p_den_maquina
     FROM recurso
    WHERE cod_empresa = p_cod_empresa
      AND cod_recur   = p_rovmaq_ega_man912.cod_maquina
   DISPLAY p_den_maquina TO den_maquina
   
   INITIALIZE p_den_equip TO NULL
   SELECT des_compon
     INTO p_den_equip
     FROM componente
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon  = p_rovmaq_ega_man912.cod_equip
   
   DISPLAY p_den_equip TO den_equip
   
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0966_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_rovmaq_ega_man912.*                                              
      FROM rovmaq_ega_man912  
         WHERE cod_empresa = p_rovmaq_ega_man912.cod_empresa
           AND cod_maquina = p_rovmaq_ega_man912.cod_maquina
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
      OTHERWISE CALL log003_err_sql("LEITURA","rovmaq_ega_man912")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0966_modificacao()
#-----------------------------#

   IF pol0966_cursor_for_update() THEN
      LET p_rovmaq_ega_man912a.* = p_rovmaq_ega_man912.*
      IF pol0966_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE rovmaq_ega_man912 
            SET cod_maquina_ega = p_rovmaq_ega_man912.cod_maquina_ega,
                cod_equip       = p_rovmaq_ega_man912.cod_equip
                WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","rovmaq_ega_man912")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_rovmaq_ega_man912.* = p_rovmaq_ega_man912a.*
         ERROR "Modificacao Cancelada"
         CALL pol0966_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0966_exclusao()
#--------------------------#

   IF pol0966_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM rovmaq_ega_man912
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_rovmaq_ega_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","rovmaq_ega_man912")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0966_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rovmaq_ega_man912a.* = p_rovmaq_ega_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_rovmaq_ega_man912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_rovmaq_ega_man912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_rovmaq_ega_man912.* = p_rovmaq_ega_man912a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_rovmaq_ega_man912.* 
         FROM rovmaq_ega_man912
            WHERE cod_empresa = p_rovmaq_ega_man912.cod_empresa
              AND cod_maquina = p_rovmaq_ega_man912.cod_maquina
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0966_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0966_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM rovmaq_ega_man912
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_maquina
   
   FOREACH cq_oper INTO p_rovmaq_ega_man912.*
 
      INITIALIZE p_den_maquina TO NULL
      SELECT den_recur
        INTO p_den_maquina
        FROM recurso
       WHERE cod_empresa = p_cod_empresa
         AND cod_recur   = p_rovmaq_ega_man912.cod_maquina
   
      OUTPUT TO REPORT pol0966_relat(p_rovmaq_ega_man912.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0966_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD 
      cod_empresa      LIKE rovmaq_ega_man912.cod_empresa,
      cod_maquina      LIKE rovmaq_ega_man912.cod_maquina,          
      cod_maquina_ega  LIKE rovmaq_ega_man912.cod_maquina_ega,
      cod_equip        LIKE rovmaq_ega_man912.cod_equip
   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0966",
               COLUMN 030, "MAQUINAS LOGIX - EGA",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 001, "COD MAQ LOGIX  COD MAQ EGA            DESCRICAO             EQUIPAMENTO"
         PRINT COLUMN 001, "-------------  -----------  ------------------------------ ---------------"
      

      ON EVERY ROW

         PRINT COLUMN 007, p_relat.cod_maquina,
               COLUMN 021, p_relat.cod_maquina_ega,
               COLUMN 029, p_den_maquina,
               COLUMN 060, p_relat.cod_equip
               
   
END REPORT


#-----------------------#
 FUNCTION pol0966_popup()
#-----------------------#
   CASE

      WHEN INFIELD(cod_maquina)
         CALL log009_popup(6,20,"M�QUINAS","recurso",
                          "cod_recur","den_recur",
                          "MAN0060","S","") RETURNING p_rovmaq_ega_man912.cod_maquina
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0966
         DISPLAY BY NAME p_rovmaq_ega_man912.cod_maquina
         CALL pol0966_verifica_maquina() RETURNING p_status

      WHEN INFIELD(cod_equip)
         CALL log009_popup(6,20,"EQUIPAMENTOS","componente",
                          "cod_compon","des_compon",
                          "","S","") RETURNING p_rovmaq_ega_man912.cod_equip
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0966
         DISPLAY BY NAME p_rovmaq_ega_man912.cod_equip

   END CASE
   
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#


