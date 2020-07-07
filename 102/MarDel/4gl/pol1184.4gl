#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1184                                                 #
# OBJETIVO: CADASTRO DE PARÂMETROS GERAIS                           #
# AUTOR...: JUCÉLIO C. SILVA                                        #
# DATA....: 07/01/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
  
   DEFINE p_par_geral_912      RECORD LIKE par_geral_912.*

   DEFINE p_consulta           RECORD
          cod_parametro        LIKE par_geral_912.cod_parametro,
          den_parametro        LIKE par_geral_912.den_parametro,
          par_tipo             LIKE par_geral_912.par_tipo,
          par_dec              LIKE par_geral_912.par_dec,
          par_int              LIKE par_geral_912.par_int,
          par_dat              LIKE par_geral_912.par_dat,
          par_txt              LIKE par_geral_912.par_txt
   END RECORD

         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1184-10.03.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1184_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1184_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1184") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1184 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1184_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1184_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1184_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1184_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1184_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_consulta.cod_parametro TO cod_parametro
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1184_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1184_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1184_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1184

END FUNCTION

#--------------------------#
 FUNCTION pol1184_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_par_geral_912.* TO NULL
   LET p_par_geral_912.cod_empresa = p_cod_empresa
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1184_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_geral_912 VALUES (p_par_geral_912.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","par_geral_912")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1184_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_par_geral_912.*
      WITHOUT DEFAULTS
   
      BEFORE FIELD cod_parametro
      IF p_funcao = "M" THEN
         NEXT FIELD den_parametro
      END IF
      
      AFTER FIELD cod_parametro
      IF p_par_geral_912.cod_parametro IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_parametro   
      END IF
          
      SELECT cod_parametro
        FROM par_geral_912
       WHERE cod_empresa   = p_cod_empresa
         AND cod_parametro = p_par_geral_912.cod_parametro
         
      IF STATUS = 0 THEN 
         ERROR 'Parâmetro já cadastrado !!!'
         NEXT FIELD cod_parametro
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','par_geral_912')
            RETURN FALSE
         END IF 
      END IF  
      
      AFTER FIELD den_parametro
      IF p_par_geral_912.den_parametro IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_parametro   
      END IF
      
      AFTER FIELD par_tipo
      IF p_par_geral_912.par_tipo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD par_tipo   
      END IF
      
      IF NOT p_par_geral_912.par_tipo MATCHES '[FIDC]' THEN
         ERROR "Valor ilegal para o campo em questão !!!"
         NEXT FIELD par_tipo
      END IF
      
      IF p_par_geral_912.par_tipo = 'F' THEN
         NEXT FIELD par_dec
      ELSE
         IF p_par_geral_912.par_tipo = 'I' THEN
            NEXT FIELD par_int
         ELSE
            IF p_par_geral_912.par_tipo = 'D' THEN 
               NEXT FIELD par_dat
            ELSE
               NEXT FIELD par_txt
            END IF
         END IF
      END IF
      
      AFTER INPUT
      IF NOT INT_FLAG THEN
         IF p_par_geral_912.cod_parametro IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_parametro   
         END IF
         
         IF p_par_geral_912.den_parametro IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD den_parametro   
         END IF   
         
         IF p_par_geral_912.par_tipo IS NULL THEN
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD par_tipo
         ELSE
            
            IF p_par_geral_912.par_tipo = 'F' THEN
               
               IF p_par_geral_912.par_dec IS NULL THEN
                  ERROR "Campo com preenchimento obrigatório !!!"
                  NEXT FIELD par_dec
               ELSE
                  LET p_par_geral_912.par_int = NULL
                  LET p_par_geral_912.par_dat = NULL
                  LET p_par_geral_912.par_txt = NULL
                  
                  DISPLAY p_par_geral_912.par_int TO par_int
                  DISPLAY p_par_geral_912.par_dat TO par_dat
                  DISPLAY p_par_geral_912.par_txt TO par_txt
               END IF
            
            ELSE
               IF p_par_geral_912.par_tipo = 'I' THEN
                
                  IF p_par_geral_912.par_int IS NULL THEN
                     ERROR "Campo com preenchimento obrigatório !!!"
                     NEXT FIELD par_int
                  ELSE
                     LET p_par_geral_912.par_dec = NULL
                     LET p_par_geral_912.par_dat = NULL
                     LET p_par_geral_912.par_txt = NULL
                  
                     DISPLAY p_par_geral_912.par_dec TO par_dec
                     DISPLAY p_par_geral_912.par_dat TO par_dat
                     DISPLAY p_par_geral_912.par_txt TO par_txt
                  END IF
               
               ELSE
                  IF p_par_geral_912.par_tipo = 'D' THEN 
                     
                     IF p_par_geral_912.par_dat IS NULL THEN
                        ERROR "Campo com preenchimento obrigatório !!!"
                        NEXT FIELD par_dat
                     ELSE
                        LET p_par_geral_912.par_dec = NULL
                        LET p_par_geral_912.par_int = NULL
                        LET p_par_geral_912.par_txt = NULL
                  
                        DISPLAY p_par_geral_912.par_dec TO par_dec
                        DISPLAY p_par_geral_912.par_int TO par_int
                        DISPLAY p_par_geral_912.par_txt TO par_txt
                     END IF
                     
                  ELSE
                     
                     IF p_par_geral_912.par_txt IS NULL THEN
                        ERROR "Campo com preenchimento obrigatório !!!"
                        NEXT FIELD par_txt
                     ELSE
                        LET p_par_geral_912.par_dec = NULL
                        LET p_par_geral_912.par_int = NULL
                        LET p_par_geral_912.par_dat = NULL
                  
                        DISPLAY p_par_geral_912.par_dec TO par_dec
                        DISPLAY p_par_geral_912.par_int TO par_int
                        DISPLAY p_par_geral_912.par_dat TO par_dat
                     END IF
                     
                  END IF
               END IF
            END IF
         END IF
      END IF
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1184_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   INITIALIZE p_par_geral_912.* TO NULL
   LET p_par_geral_912.cod_empresa = p_cod_empresa
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_consulta_ant.* = p_consulta.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      par_geral_912.cod_parametro,
      par_geral_912.den_parametro,
      par_geral_912.par_tipo,
      par_geral_912.par_dec,
      par_geral_912.par_int,
      par_geral_912.par_dat,
      par_geral_912.par_txt  
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_consulta.* = p_consulta_ant.*
            CALL pol1184_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_parametro, den_parametro, par_tipo, par_dec, par_int, par_dat, par_txt ",
                  "  FROM par_geral_912 ",
                  " WHERE ", where_clause CLIPPED,
                  "   and cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_parametro"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_consulta.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1184_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1184_exibe_dados()
#------------------------------#
   
   DISPLAY BY NAME p_consulta.*             
         
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1184_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_consulta_ant.* = p_consulta.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_consulta.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_consulta.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_parametro,
                den_parametro,
                par_tipo,
                par_dec,
                par_int,
                par_dat,
                par_txt
           INTO p_consulta.*
           FROM par_geral_912
          WHERE cod_empresa   = p_cod_empresa
            AND cod_parametro = p_consulta.cod_parametro
            
         IF STATUS = 0 THEN
            CALL pol1184_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_consulta.* = p_consulta_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1184_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_parametro 
      FROM par_geral_912  
     WHERE cod_empresa   = p_cod_empresa
       AND cod_parametro = p_consulta.cod_parametro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","par_geral_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1184_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_par_geral_912.cod_parametro = p_consulta.cod_parametro 
   LET p_par_geral_912.den_parametro = p_consulta.den_parametro
   LET p_par_geral_912.par_tipo      = p_consulta.par_tipo
   LET p_par_geral_912.par_dec       = p_consulta.par_dec
   LET p_par_geral_912.par_int       = p_consulta.par_int
   LET p_par_geral_912.par_dat       = p_consulta.par_dat
   LET p_par_geral_912.par_txt       = p_consulta.par_txt
   
   IF pol1184_prende_registro() THEN
      IF pol1184_edita_dados("M") THEN
         
         UPDATE par_geral_912
            SET den_parametro = p_par_geral_912.den_parametro,
                par_tipo      = p_par_geral_912.par_tipo,
                par_dec       = p_par_geral_912.par_dec,
                par_int       = p_par_geral_912.par_int,
                par_dat       = p_par_geral_912.par_dat,
                par_txt       = p_par_geral_912.par_txt  
          WHERE cod_empresa   = p_cod_empresa
            AND cod_parametro = p_consulta.cod_parametro
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "par_geral_912")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1184_exibe_dados() RETURNING p_status
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
 FUNCTION pol1184_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1184_prende_registro() THEN
      DELETE FROM par_geral_912
			 WHERE cod_empresa   = p_cod_empresa
			   AND cod_parametro = p_consulta.cod_parametro

      IF STATUS = 0 THEN               
         INITIALIZE p_consulta.* TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","par_geral_912")
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
 FUNCTION pol1184_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1184_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1184_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT cod_parametro,
          den_parametro,
          par_tipo,     
          par_dec,      
          par_int,      
          par_dat,      
          par_txt      
     FROM par_geral_912
 ORDER BY cod_parametro                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1184_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1184_relat   
   
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

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1184_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1184.tmp"
         START REPORT pol1184_relat TO p_caminho
      ELSE
         START REPORT pol1184_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1184_le_den_empresa()
#--------------------------------#

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
 REPORT pol1184_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 179, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1184",
               COLUMN 071, "PARÂMETROS PARA INTEGRAÇÃO COM SISTEMA OMC",
               COLUMN 160, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '             PARAMETRO                                               DESCRICAO                                  TIPO     V. DECIMAL     V. INTEIRO  V. DATA             V. TEXTO'
         PRINT COLUMN 002, '---------------------------------------- ---------------------------------------------------------------------- ---- ------------------ ---------- ---------- ------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_relat.cod_parametro,
               COLUMN 043, p_relat.den_parametro,
               COLUMN 114, p_relat.par_tipo,
               COLUMN 119, p_relat.par_dec USING "############.&&&&&",
               COLUMN 138, p_relat.par_int USING "##########",
               COLUMN 149, p_relat.par_dat,
               COLUMN 160, p_relat.par_txt
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 065, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1184_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#