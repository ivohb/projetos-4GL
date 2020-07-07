#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1030                                                 #
# OBJETIVO: MENSAGENS Á SEREM IMPRESSAS NA OP ATÉ QUE HAJA REVISÃO  #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 09/04/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT
         
  
   DEFINE p_txt_revisao_item_547     RECORD LIKE txt_revisao_item_547.*
   
   DEFINE p_txt_revisao_item_547_ant RECORD LIKE txt_revisao_item_547.*
             
   DEFINE p_nom_funcionario          LIKE usuarios.nom_funcionario,
          p_den_familia              LIKE familia.den_familia,
          p_texto_1                  CHAR(50),
          p_texto_2                  CHAR(50),
          p_texto_3                  CHAR(50),
          p_texto_4                  CHAR(50),
          p_texto_5                  CHAR(50),
          p_cod_item                 LIKE item.cod_item,
          p_ies_revisto              LIKE revisao_item_547.ies_revisto
                    
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1030-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1030_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1030_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1030") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1030 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1030_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1030_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1030_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1030_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1030_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1030_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_txt_revisao_item_547.cod_familia TO cod_familia
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1030_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1030_listagem()   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1030_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1030

END FUNCTION

#-----------------------#
 FUNCTION pol1030_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1030_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1030_inclusao()
#--------------------------#
   
   IF pol1030_edita_dados("I") THEN
      IF NOT pol1030_busca_revisao() THEN 
         RETURN FALSE
      END IF 
      CALL log085_transacao("BEGIN")
      INSERT INTO txt_revisao_item_547 VALUES (p_txt_revisao_item_547.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","txt_revisao_item_547")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         IF NOT pol1030_grava_revisao_item_547() THEN 
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
            RETURN TRUE
         END IF 
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1030_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE  
   
   IF p_funcao = "I" THEN 
      
      CALL pol1030_limpa_tela()
      INITIALIZE p_txt_revisao_item_547.* TO NULL
      LET p_txt_revisao_item_547.cod_empresa = p_cod_empresa
      LET p_txt_revisao_item_547.cod_usuario = p_user

      SELECT nom_funcionario
        INTO p_nom_funcionario
        FROM usuarios
       WHERE cod_usuario = p_txt_revisao_item_547.cod_usuario
       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "usuarios")
         RETURN FALSE
      END IF 
      
      DISPLAY p_nom_funcionario TO nom_funcionario  
   
   END IF
         
   INPUT BY NAME p_txt_revisao_item_547.* WITHOUT DEFAULTS      
            
      AFTER FIELD dat_solict_revi
         IF p_txt_revisao_item_547.dat_solict_revi IS NULL THEN 
            ERROR "Campo com prenchimento obrigatório !!!"
            NEXT FIELD dat_solict_revi
         END IF

      BEFORE FIELD cod_familia
         IF p_funcao = "M" THEN 
            NEXT FIELD texto
         END IF 
      
      AFTER FIELD cod_familia
         IF p_txt_revisao_item_547.cod_familia IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_familia   
         END IF
                    
         SELECT den_familia
           INTO p_den_familia
           FROM familia
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_txt_revisao_item_547.cod_familia
            
         IF STATUS = 100 THEN 
            ERROR "Família não encontrada na tabela familia !!!"
            NEXT FIELD cod_familia
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("lendo", "familia")
               RETURN FALSE
            END IF 
         END IF 
         
         DISPLAY p_den_familia TO den_familia
         
      AFTER FIELD texto
         IF p_txt_revisao_item_547.texto IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD texto   
         END IF
                        
         ON KEY (control-z)
            CALL pol1030_popup()
            
   END INPUT  
  
   IF INT_FLAG THEN
      CALL pol1030_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1030_busca_revisao()
#-------------------------------#

   LET p_count = 0
   
   SELECT COUNT (num_revisao)
     INTO p_count
     FROM txt_revisao_item_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_txt_revisao_item_547.cod_familia
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "txt_revisao_item_547")
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN 
      LET p_txt_revisao_item_547.num_revisao = 1
   ELSE
   
      SELECT MAX (num_revisao)
        INTO p_txt_revisao_item_547.num_revisao
        FROM txt_revisao_item_547
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_txt_revisao_item_547.cod_familia
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "txt_revisao_item_547")
         RETURN FALSE
      END IF 
  
      LET p_txt_revisao_item_547.num_revisao = p_txt_revisao_item_547.num_revisao + 1
   
   END IF
   
   DISPLAY p_txt_revisao_item_547.num_revisao TO num_revisao
   
   RETURN TRUE 
   
END FUNCTION   

#----------------------------------------#
 FUNCTION pol1030_grava_revisao_item_547()
#----------------------------------------#

   DECLARE cq_revisao_item_547 CURSOR FOR 
   
   SELECT cod_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_txt_revisao_item_547.cod_familia
    ORDER BY cod_item
      
   FOREACH cq_revisao_item_547 INTO p_cod_item
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "item")
         RETURN FALSE
      END IF 
      
      SELECT cod_item
        FROM revisao_item_547
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND num_revisao = p_txt_revisao_item_547.num_revisao
         
      IF STATUS <> 100 THEN 
         CALL log003_err_sql("Lendo", "revisao_item_547")
         RETURN FALSE
      END IF 
         
      LET p_ies_revisto = "N"
         
      INSERT INTO revisao_item_547
          VALUES( p_cod_empresa,
                  p_txt_revisao_item_547.dat_solict_revi,
                  p_cod_item,
                  p_ies_revisto,
                  p_user,
                  p_txt_revisao_item_547.num_revisao,"")
                     
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Inserindo", "revisao_item_547")
         RETURN FALSE
      END IF
                  
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 
             
#-----------------------#
 FUNCTION pol1030_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_familia)
         CALL log009_popup(8,10,"FAMÌLIAS","familia",
                     "cod_familia","den_familia","","N","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_txt_revisao_item_547.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF
   END CASE 
   
END FUNCTION 
  
#--------------------------#
 FUNCTION pol1030_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1030_limpa_tela()
      
   LET p_txt_revisao_item_547_ant.* = p_txt_revisao_item_547.*
   LET INT_FLAG                     = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      txt_revisao_item_547.dat_solict_revi,
      txt_revisao_item_547.cod_familia,
      txt_revisao_item_547.texto
      
      ON KEY (control-z)
        CALL pol1030_popup()
   
   END CONSTRUCT 
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_txt_revisao_item_547.* = p_txt_revisao_item_547_ant.*
         CALL pol1030_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT *",
                  "  FROM txt_revisao_item_547 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_familia, dat_solict_revi"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_txt_revisao_item_547.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1030_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1030_exibe_dados()
#------------------------------#

   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_txt_revisao_item_547.cod_usuario
       
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "usuarios")
      RETURN FALSE
   END IF
   
   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_txt_revisao_item_547.cod_familia
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'familia')
      RETURN FALSE 
   END IF
   
   DISPLAY p_txt_revisao_item_547.cod_empresa     TO cod_empresa
   DISPLAY p_txt_revisao_item_547.cod_usuario     TO cod_usuario
   DISPLAY p_nom_funcionario                      TO nom_funcionario
   DISPLAY p_txt_revisao_item_547.dat_solict_revi TO dat_solict_revi
   DISPLAY p_txt_revisao_item_547.cod_familia     TO cod_familia
   DISPLAY p_den_familia                          TO den_familia
   DISPLAY p_txt_revisao_item_547.texto           TO texto
   DISPLAY p_txt_revisao_item_547.num_revisao     TO num_revisao
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1030_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_txt_revisao_item_547_ant.* = p_txt_revisao_item_547.*

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_txt_revisao_item_547.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_txt_revisao_item_547.*
         
      END CASE

      IF STATUS = 0 THEN
         SELECT dat_solict_revi,
                texto
           INTO p_txt_revisao_item_547.dat_solict_revi,
                p_txt_revisao_item_547.texto
           FROM txt_revisao_item_547
          WHERE cod_empresa = p_cod_empresa 
            AND cod_familia = p_txt_revisao_item_547.cod_familia
            AND num_revisao = p_txt_revisao_item_547.num_revisao
             
         IF STATUS = 0 THEN
            CALL pol1030_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_txt_revisao_item_547.* = p_txt_revisao_item_547_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1030_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_familia 
      FROM txt_revisao_item_547  
     WHERE cod_empresa = p_cod_empresa 
       AND cod_familia = p_txt_revisao_item_547.cod_familia
       AND num_revisao = p_txt_revisao_item_547.num_revisao
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","txt_revisao_item_547")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1030_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1030_prende_registro() THEN
      IF pol1030_edita_dados("M") THEN
         
         UPDATE txt_revisao_item_547
            SET dat_solict_revi = p_txt_revisao_item_547.dat_solict_revi,
                texto           = p_txt_revisao_item_547.texto
          WHERE cod_empresa     = p_cod_empresa 
            AND cod_familia     = p_txt_revisao_item_547.cod_familia
            AND num_revisao     = p_txt_revisao_item_547.num_revisao
             
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","txt_revisao_item_547")
         END IF
      ELSE
         CALL pol1030_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1030_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1030_prende_registro() THEN
      
      DELETE FROM txt_revisao_item_547
			WHERE cod_empresa = p_cod_empresa 
        AND cod_familia = p_txt_revisao_item_547.cod_familia
        AND num_revisao = p_txt_revisao_item_547.num_revisao
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_txt_revisao_item_547 TO NULL
         CALL pol1030_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","txt_revisao_item_547")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1030_listagem()
#--------------------------#     

   IF NOT pol1030_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1030_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_index = 1
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM txt_revisao_item_547
     ORDER BY cod_familia, dat_solict_revi
   
   FOREACH cq_impressao INTO 
           p_txt_revisao_item_547.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','txt_revisao_item_547:cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT nom_funcionario
        INTO p_nom_funcionario
        FROM usuarios
       WHERE cod_usuario = p_txt_revisao_item_547.cod_usuario
       
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "usuarios")
         RETURN FALSE
      END IF
   
      SELECT den_familia
        INTO p_den_familia
        FROM familia
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_txt_revisao_item_547.cod_familia
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo', 'familia')
         RETURN FALSE 
      END IF
      
      OUTPUT TO REPORT pol1030_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1030_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1030_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1030.tmp"
         START REPORT pol1030_relat TO p_caminho
      ELSE
         START REPORT pol1030_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1030_le_empresa()
#---------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol1030_relat()
#---------------------#
   
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1030",
               COLUMN 014, "MENSAGENS A SEREM IMPRESSAS NA OP",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
                             
      ON EVERY ROW
         
         IF p_index > 3 THEN 
            LET p_index = 1
            SKIP TO TOP OF PAGE
         END IF
                  
         CALL substr(p_txt_revisao_item_547.texto,50,5,'S') 
              RETURNING p_texto_1,
                        p_texto_2,
                        p_texto_3,
                        p_texto_4,
                        p_texto_5
         
         PRINT
         PRINT COLUMN 015, "Usuario: ", p_txt_revisao_item_547.cod_usuario, " - ", p_nom_funcionario 
         PRINT
         PRINT COLUMN 003, "Data solic. revisao: ", p_txt_revisao_item_547.dat_solict_revi 
         PRINT 
         PRINT COLUMN 007, "Familia do item: ", p_txt_revisao_item_547.cod_familia, " - ", p_den_familia
         PRINT     
         PRINT COLUMN 017, "Texto: ", p_texto_1 
         PRINT COLUMN 024, p_texto_2
         PRINT COLUMN 024, p_texto_3
         PRINT COLUMN 024, p_texto_4
         PRINT COLUMN 024, p_texto_5
         PRINT
         PRINT COLUMN 005, "Numero da revisao: ", p_txt_revisao_item_547.num_revisao USING "##########"
         PRINT
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         
         LET p_index = p_index + 1
                                 
     ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#