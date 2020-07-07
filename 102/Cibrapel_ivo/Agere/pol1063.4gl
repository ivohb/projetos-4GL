#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol1063                                                 #
# OBJETIVO: CADASTRO DE EMAILS DOS REPRESENTANTES  -  CIBRAPEL      #
# AUTOR...: WILLIANS                                                #
# DATA....: 04/10/2010                                              #
#-------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_retorno            SMALLINT,
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
          p_caminho            CHAR(80),
          p_nom_usuario        CHAR(30),
          p_nom_repres         LIKE representante.nom_repres,
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01)
          
   DEFINE p_repres_email_885   RECORD LIKE repres_email_885.*,
          p_repres_email_885a  RECORD LIKE repres_email_885.*   

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1063-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1063.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1063_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1063_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1063") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1063 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela."
         IF pol1063_inclusao() THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela."
         IF NOT pol1063_consulta() THEN
            ERROR "Operação cancelada !!!"
            LET p_ies_cons = FALSE
         ELSE
            ERROR "Consulta efetuada com sucesso !!!"
            NEXT OPTION "Seguinte"
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta."
         IF p_ies_cons THEN
            CALL pol1063_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta."
         IF p_ies_cons THEN
            CALL pol1063_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1063_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela."
         IF p_ies_cons THEN
            IF pol1063_exclusao() THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão !!!"
         END IF 
      COMMAND "Listar" "Listagem dos dados da tabela."
         CALL pol1063_listagem()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1063

END FUNCTION

#--------------------------#
 FUNCTION pol1063_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_repres_email_885.* TO NULL

   IF pol1063_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO repres_email_885 VALUES (p_repres_email_885.*)
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Inserindo", "repres_email_885")
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
 FUNCTION pol1063_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)
    
   LET INT_FLAG = FALSE

   INPUT BY NAME p_repres_email_885.*
      WITHOUT DEFAULTS  
      
      BEFORE FIELD cod_repres
         IF p_funcao = 'M' THEN
            NEXT FIELD email
         END IF
      
      AFTER FIELD cod_repres
         IF p_repres_email_885.cod_repres IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_repres
         END IF
      
         LET p_count = 0                                     
                                                             
         SELECT MAX(sequencia)                           
           INTO p_count                                      
           FROM repres_email_885                             
          WHERE cod_repres = p_repres_email_885.cod_repres   
                                                             
         IF STATUS <> 0 THEN                                 
            CALL log003_err_sql("Lendo", "repres_email_885") 
            RETURN FALSE                                     
         END IF                                              
                                                             
         IF p_count = 0 OR p_count IS NULL THEN                                 
            LET p_count = 1                                  
         ELSE                                                
            LET p_count = p_count + 1                        
         END IF                                              
         
         LET p_repres_email_885.sequencia = p_count
                                                             
         SELECT nom_repres                                   
           INTO p_nom_repres                                 
           FROM representante                                
          WHERE cod_repres = p_repres_email_885.cod_repres   
                                                             
         IF STATUS = 100 THEN                                
            ERROR 'Representante não encontrado !!!'         
            NEXT FIELD cod_repres                            
         ELSE                                                
            IF STATUS <> 0 THEN                              
               CALL log003_err_sql("Lendo", "representante") 
               RETURN FALSE                                  
            END IF                                           
         END IF                                              
                                                             
         DISPLAY p_nom_repres                     TO nom_repres                  
         DISPLAY p_repres_email_885.sequencia TO sequencia               

      AFTER FIELD email
         IF p_repres_email_885.email IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD email
         END IF
      
      ON KEY (control-z)
         CALL pol1063_popup()

    END INPUT 

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol1063_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_repres)
         CALL log009_popup(8,15,"REPRESENTANTES","representante",
              "cod_repres","nom_repres","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1063
         IF p_codigo IS NOT NULL THEN
            LET p_repres_email_885.cod_repres = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_repres
         END IF
   
   END CASE

END FUNCTION

#--------------------------#
 FUNCTION pol1063_consulta()
#--------------------------#
   
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
   LET INT_FLAG              = FALSE
   LET p_repres_email_885a.* = p_repres_email_885.*

   CONSTRUCT BY NAME where_clause ON
        repres_email_885.cod_repres,
        repres_email_885.email
   
      ON KEY (control-z)
         CALL pol1063_popup()
         
   END CONSTRUCT
   
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_repres_email_885.* = p_repres_email_885a.*
         CALL pol1063_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_repres, sequencia, email",
                  "  FROM repres_email_885 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_repres, sequencia"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_consulta

   FETCH cq_consulta INTO p_repres_email_885.*

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1063_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE
        
END FUNCTION

#-----------------------------#
 FUNCTION pol1063_exibe_dados()
#-----------------------------#

   # Lê novamente os dados, pois os mesmos podem ter sido alterados
   # após a consulta
   
   SELECT email
     INTO p_repres_email_885.email
     FROM repres_email_885
    WHERE cod_repres = p_repres_email_885.cod_repres
      AND sequencia  = p_repres_email_885.sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "repres_email_885")
      RETURN FALSE
   END IF     
     
   SELECT nom_repres
     INTO p_nom_repres
     FROM representante
    WHERE cod_repres = p_repres_email_885.cod_repres
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo", "representante")
      RETURN FALSE
   END IF
      
   DISPLAY BY NAME p_repres_email_885.*
   DISPLAY p_nom_repres TO nom_repres
   
   RETURN TRUE
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol1063_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   IF p_ies_cons THEN
      
      LET p_repres_email_885a.* = p_repres_email_885.*
      
      WHILE TRUE
         CASE
            WHEN p_funcao = "S" FETCH NEXT cq_consulta INTO p_repres_email_885.*
                            
            WHEN p_funcao = "A" FETCH PREVIOUS cq_consulta INTO p_repres_email_885.*
                            
         END CASE

         IF STATUS = 100 THEN  #verifica se chegou no fim do cursor
            ERROR "Nao existem mais itens nesta direção !!!"
            LET p_repres_email_885.* = p_repres_email_885a.* 
            EXIT WHILE
         END IF

         #Leitura para verificar se o registro encontrado no FETCH (cursor)
         #ainda está na tabela
         
         SELECT COUNT(cod_repres)
           INTO p_count
           FROM repres_email_885
          WHERE cod_repres = p_repres_email_885.cod_repres
            AND sequencia  = p_repres_email_885.sequencia
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo", "repres_email_885")
            EXIT WHILE 
         END IF 
         
         IF p_count > 0 THEN
            CALL pol1063_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Não existe nenhuma consulta ativa !!!"
   END IF
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1063_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   
   DECLARE cq_padrao CURSOR WITH HOLD FOR

   SELECT cod_repres                                             
     FROM repres_email_885
    WHERE cod_repres = p_repres_email_885.cod_repres
      AND sequencia  = p_repres_email_885.sequencia
      FOR UPDATE 
   
   OPEN cq_padrao
   FETCH cq_padrao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo","repres_email_885")   
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1063_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1063_cursor_for_update() THEN
      IF pol1063_entrada_dados("M") THEN
         
         UPDATE repres_email_885
            SET email       = p_repres_email_885.email
          WHERE cod_repres  = p_repres_email_885.cod_repres
            AND sequencia   = p_repres_email_885.sequencia

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","repres_email_885")
         END IF
      ELSE
         CALL pol1063_exibe_dados() RETURNING p_status
      END IF
      CLOSE cq_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1063_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1063_cursor_for_update() THEN
      
      DELETE FROM repres_email_885
			 WHERE cod_repres = p_repres_email_885.cod_repres
			   AND sequencia  = p_repres_email_885.sequencia

      IF STATUS = 0 THEN               
         INITIALIZE p_repres_email_885 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("excluindo","repres_email_885")
      END IF
      CLOSE cq_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1063_listagem()
#--------------------------#     

   IF NOT pol1063_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1063_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM repres_email_885
     ORDER BY cod_repres, sequencia
   
   FOREACH cq_impressao INTO 
           p_repres_email_885.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT nom_repres
        INTO p_nom_repres
        FROM representante
       WHERE cod_repres = p_repres_email_885.cod_repres
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','representante')
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1063_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1063_relat   
   
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol1063_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1063.tmp"
         START REPORT pol1063_relat TO p_caminho
      ELSE
         START REPORT pol1063_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1063_le_empresa()
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
 REPORT pol1063_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, p_comprime, 
               COLUMN 095, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1063",
               COLUMN 031, "EMAILS DOS REPRESENTANTES",
               COLUMN 076, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, ' Codigo              Descricao               Sequencia                       Email'
         PRINT COLUMN 001, ' ------ ------------------------------------ --------- --------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_repres_email_885.cod_repres,
               COLUMN 009, p_nom_repres,
               COLUMN 049, p_repres_email_885.sequencia,
               COLUMN 056, p_repres_email_885.email 
         
      ON LAST ROW

        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 040, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#