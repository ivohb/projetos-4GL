#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1036                                                 #
# OBJETIVO: CADASTRO DE CONTAS                                      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 06/05/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
         
  
   DEFINE p_num_cta_errada     char(10),
          p_num_cta_errada_ant char(10)

   DEFINE p_troca_conta_912    RECORD
          num_cta_errada       char(10),
          num_cta_certa        char(10)
   END RECORD

          
   DEFINE p_den_conta          LIKE plano_contas.den_conta
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1036-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1036_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1036_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1036") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1036 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1036_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1036_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1036_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1036_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1036_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1036_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_num_cta_errada TO num_cta_errada
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1036_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1036_listagem()   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1036_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1036

END FUNCTION

#-----------------------#
FUNCTION pol1036_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1036_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1036_inclusao()
#--------------------------#
   
   IF pol1036_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO troca_conta_912 VALUES (p_troca_conta_912.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","troca_conta_912")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#--------------------------------------#
 FUNCTION pol1036_edita_dados(p_funcao)
#--------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE 
   
   IF p_funcao = "I" THEN 
      CALL pol1036_limpa_tela()
      INITIALIZE p_troca_conta_912.* TO NULL
   END IF 
   
   INPUT BY NAME p_troca_conta_912.* WITHOUT DEFAULTS
      
      BEFORE FIELD num_cta_errada
      IF p_funcao = "M" THEN 
         DISPLAY p_num_cta_errada TO num_cta_errada
         NEXT FIELD num_cta_certa
      END IF
         
      AFTER FIELD num_cta_errada
      IF p_troca_conta_912.num_cta_errada IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_cta_errada   
      END IF
          
      SELECT num_cta_errada
        FROM troca_conta_912
       WHERE num_cta_errada = p_troca_conta_912.num_cta_errada
          
      IF STATUS = 0 THEN 
         ERROR 'Conta já cadastrada na tabela troca_conta_912 !!!'
         NEXT FIELD num_cta_errada
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','troca_conta_912')
            RETURN FALSE
         END IF 
      END IF  
      
      AFTER FIELD num_cta_certa
      IF p_troca_conta_912.num_cta_certa IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_cta_certa   
      END IF
      
      SELECT den_conta
        INTO p_den_conta
        FROM plano_contas
       WHERE cod_empresa     = p_cod_empresa
         AND num_conta_reduz = p_troca_conta_912.num_cta_certa
         
      IF STATUS = 100 THEN 
         ERROR "Conta não encontrada na tabela plano_contas !!!"
         NEXT FIELD num_cta_certa
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','plano_contas')
            RETURN FALSE
         END IF 
      END IF
      
      DISPLAY p_den_conta TO den_conta
      
      ON KEY (control-z)
         CALL pol1036_popup()
        
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1036_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1036_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(num_cta_certa)
         CALL log009_popup(8,10,"CONTAS","plano_contas",
                     "num_conta_reduz","den_conta","","N","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_troca_conta_912.num_cta_certa = p_codigo CLIPPED
            DISPLAY p_codigo TO num_cta_certa
         END IF
   END CASE 
   
END FUNCTION
  
#--------------------------#
 FUNCTION pol1036_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1036_limpa_tela()
      
   LET p_num_cta_errada_ant = p_num_cta_errada
   LET INT_FLAG             = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      troca_conta_912.num_cta_errada,
      troca_conta_912.num_cta_certa
      
      ON KEY (control-z)
         CALL pol1036_popup()
         
   END CONSTRUCT 
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_num_cta_errada = p_num_cta_errada_ant
         CALL pol1036_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT num_cta_errada",
                  "  FROM troca_conta_912 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY num_cta_errada"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_cta_errada

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1036_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1036_exibe_dados()
#------------------------------#
   
   SELECT num_cta_certa
     INTO p_troca_conta_912.num_cta_certa
     FROM troca_conta_912
    WHERE num_cta_errada = p_num_cta_errada
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'troca_conta_912')
      RETURN FALSE 
   END IF
   
   SELECT den_conta
     INTO p_den_conta
     FROM plano_contas
    WHERE cod_empresa     = p_cod_empresa
      AND num_conta_reduz = p_troca_conta_912.num_cta_certa 
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'plano_contas')
      RETURN FALSE 
   END IF
   
   DISPLAY p_num_cta_errada                 TO num_cta_errada
   DISPLAY p_troca_conta_912.num_cta_certa  TO num_cta_certa
   DISPLAY p_den_conta                      TO den_conta
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1036_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_cta_errada_ant = p_num_cta_errada

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_cta_errada
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_cta_errada
         
      END CASE

      IF STATUS = 0 THEN
         SELECT num_cta_errada
           FROM troca_conta_912
          WHERE num_cta_errada = p_num_cta_errada
             
         IF STATUS = 0 THEN
            CALL pol1036_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_num_cta_errada = p_num_cta_errada_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1036_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT num_cta_errada 
      FROM troca_conta_912  
     WHERE num_cta_errada = p_num_cta_errada
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","troca_conta_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1036_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1036_prende_registro() THEN
      IF pol1036_edita_dados("M") THEN
         UPDATE troca_conta_912
            SET num_cta_certa   = p_troca_conta_912.num_cta_certa
          WHERE num_cta_errada  = p_num_cta_errada
             
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","troca_conta_912")
         END IF
      ELSE
         CALL pol1036_exibe_dados() RETURNING p_status
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
 FUNCTION pol1036_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1036_prende_registro() THEN
      DELETE FROM troca_conta_912
			WHERE num_cta_errada = p_num_cta_errada
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_troca_conta_912.* TO NULL
         CALL pol1036_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","troca_conta_912")
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

#-------------------------#
FUNCTION pol1036_listagem()
#-------------------------#     

   IF NOT pol1036_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1036_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT num_cta_errada,
           num_cta_certa
      FROM troca_conta_912
     ORDER BY num_cta_errada, num_cta_certa
   
   FOREACH cq_impressao INTO 
           p_troca_conta_912.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','troca_conta_912:cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT den_conta
        INTO p_den_conta
        FROM plano_contas
       WHERE cod_empresa     = p_cod_empresa
         AND num_conta_reduz = p_troca_conta_912.num_cta_certa
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','plano_contas')
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1036_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1036_relat   
   
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
FUNCTION pol1036_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1036.tmp"
         START REPORT pol1036_relat TO p_caminho
      ELSE
         START REPORT pol1036_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1036_le_empresa()
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
 REPORT pol1036_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1036",
               COLUMN 021, "CADASTRO DE CONTAS",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '  Conta errada Conta certa                   Descricao'
         PRINT COLUMN 001, '  ------------ ----------- --------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 005, p_troca_conta_912.num_cta_errada,
               COLUMN 017, p_troca_conta_912.num_cta_certa,
               COLUMN 028, p_den_conta 
         

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