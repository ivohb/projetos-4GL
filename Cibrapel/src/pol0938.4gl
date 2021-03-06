#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0938                                                 #
# OBJETIVO: CADASTRO DE FAM�LIAS                                    #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 27/05/09                                                #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
         
  
   DEFINE p_familia_baixar_885  RECORD LIKE familia_baixar_885.*

   DEFINE p_cod_familia      LIKE familia_baixar_885.cod_familia,
          p_cod_familia_ant  LIKE familia_baixar_885.cod_familia
          
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0938-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0938_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol0938_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0938") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0938 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol0938_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0938_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o"
         END IF  
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol0938_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela!!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0938_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0938_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0938

END FUNCTION

#--------------------------#
 FUNCTION pol0938_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_familia_baixar_885.* TO NULL
   LET p_familia_baixar_885.cod_empresa = p_cod_empresa

   IF pol0938_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO familia_baixar_885 VALUES (p_familia_baixar_885.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","familia_baixar_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0938_edita_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_familia_baixar_885.* WITHOUT DEFAULTS
   
      AFTER FIELD cod_familia
      IF p_familia_baixar_885.cod_familia IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_familia   
      END IF
          
      SELECT den_familia
        INTO p_den_familia
        FROM familia
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_familia_baixar_885.cod_familia
         
      IF STATUS = 100 THEN 
         ERROR 'Fam�lia n�o cadastrada na tabela familia!!!'
         NEXT FIELD cod_familia
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','familia')
            NEXT FIELD cod_familia
         END IF 
      END IF  
     
      SELECT cod_familia
        FROM familia_baixar_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_familia_baixar_885.cod_familia
      
      IF STATUS = 0 THEN
         ERROR "C�digo j� cadastrado"
         NEXT FIELD cod_familia
      ELSE 
         IF STATUS = 100 THEN 
         ELSE   
            CALL log003_err_sql('lendo','familia_baixar_885')
            NEXT FIELD cod_familia
         END IF 
      END IF    
      
      DISPLAY p_den_familia TO den_familia
      
      ON KEY (control-z)
         CALL pol0938_popup()
           
   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0938_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_familia)
         CALL log009_popup(8,10,"FAMILIAS","familia",
              "cod_familia","den_familia","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_familia_baixar_885.cod_familia = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_familia
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol0938_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_familia_ant = p_cod_familia
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      familia_baixar_885.cod_familia
      
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_familia = p_cod_familia_ant
         CALL pol0938_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_familia ",
                  "  FROM familia_baixar_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_familia"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_familia

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol0938_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol0938_exibe_dados()
#------------------------------#

   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','familia')
      RETURN FALSE 
   END IF
   
   IF STATUS = 0 THEN
      DISPLAY p_cod_familia TO cod_familia
      DISPLAY p_den_familia TO den_familia
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0938_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_familia_ant = p_cod_familia

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_familia
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_familia
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_familia
           FROM familia_baixar_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_cod_familia
            
         IF STATUS = 0 THEN
            CALL pol0938_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o"
            LET p_cod_familia = p_cod_familia_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol0938_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM familia_baixar_885  
     WHERE cod_empresa = p_cod_empresa
       AND cod_familia = p_cod_familia
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","familia_baixar_885")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0938_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0938_prende_registro() THEN
      DELETE FROM familia_baixar_885
			WHERE cod_empresa = p_cod_empresa
    		AND cod_familia = p_cod_familia

      IF STATUS = 0 THEN               
         INITIALIZE p_familia_baixar_885 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","familia_baixar_885")
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



#-------------------------------- FIM DE PROGRAMA -----------------------------#