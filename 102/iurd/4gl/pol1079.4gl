#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1079                                                 #
# CLIENTE.: IURD                                                    #
# OBJETIVO: TIPOS DE ACERTO                                         #
# AUTOR...: IVO                                                     #
# DATA....: 02/11/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_last_row           SMALLINT
         
   DEFINE pr_tipo              ARRAY[99] OF RECORD    
          cod_tipo             DECIMAL(2,0),
          den_tipo             CHAR(30)
   END RECORD
  
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1079-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1079_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1079_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1079") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1079 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Incluir dados da tabela"
         IF pol1079_incluir() THEN
            ERROR 'Operação efetuada com sucesso!'
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Consultar" "Consulta dados da tabela"
         CALL pol1079_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            LET p_ies_cons = TRUE
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada !!!'
            NEXT OPTION 'Incluir'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            IF pol1079_modificar() THEN
               ERROR 'Operação efetuada com sucesso!'
            ELSE
               ERROR 'Operação cancelada!'
            END IF
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1079_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1079

END FUNCTION

#-----------------------#
FUNCTION pol1079_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1079_consultar()
#---------------------------#

   INITIALIZE pr_tipo TO NULL
   CLEAR FORM 
   DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_index = 1
   
   DECLARE cq_cons CURSOR FOR 
    SELECT cod_tipo,
           den_tipo
      FROM tip_acerto_265
     ORDER BY cod_tipo

   FOREACH cq_cons INTO
           pr_tipo[p_index].cod_tipo,
           pr_tipo[p_index].den_tipo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cons')       
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 99 THEN
         LET p_msg = 'Limete de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Não existem dados a serem consultados!\n',
                  'Use a opção de inclusão!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_tipo WITHOUT DEFAULTS FROM sr_tipo.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1079_incluir()
#-------------------------#

   LET p_retorno = FALSE
   
   IF pol1079_edita_tipos() THEN
      IF pol1079_grava_dados() THEN
         LET p_retorno = TRUE
      END IF
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION


#----------------------------------#
 FUNCTION pol1079_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_tipo 
      FROM tip_acerto_265  
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","cq_prende")
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------#
FUNCTION pol1079_modificar()
#---------------------------#

   LET p_retorno = FALSE
   
   IF pol1079_prende_registro() THEN
      IF pol1079_edita_tipos() THEN
         IF pol1079_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
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

#-----------------------------#
FUNCTION pol1079_edita_tipos()
#-----------------------------#

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_tipo
      WITHOUT DEFAULTS FROM sr_tipo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = TRUE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_tipo

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_tipo[p_index].cod_tipo IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório!'
               NEXT FIELD cod_tipo
            END IF
            IF pol1079_repetiu_tipo() THEN
               ERROR "Tipo já informado !!!"                   
               NEXT FIELD cod_tipo
            END IF
         END IF
      
      BEFORE FIELD den_tipo
         
         IF pr_tipo[p_index].cod_tipo IS NULL THEN
            NEXT FIELD cod_tipo
         END IF
         
      AFTER FIELD den_tipo
         
         IF pr_tipo[p_index].den_tipo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD den_tipo
         END IF            

   END INPUT 

   IF INT_FLAG THEN
      CALL pol1079_consultar() RETURNING p_status
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1079_repetiu_tipo()
#------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()                                               
       IF p_ind <> p_index THEN                                                
          IF pr_tipo[p_ind].cod_tipo = pr_tipo[p_index].cod_tipo THEN
             RETURN TRUE                                             
          END IF                                                               
      END IF                                                                  
   END FOR                                                                    

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1079_grava_dados()
#-----------------------------#
     
   DELETE FROM tip_acerto_265
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "tip_acerto_265")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_tipo[p_ind].cod_tipo IS NOT NULL THEN
          
		       INSERT INTO tip_acerto_265
		       VALUES (pr_tipo[p_ind].cod_tipo,
		               pr_tipo[p_ind].den_tipo)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "tip_acerto_265")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
            
   RETURN TRUE
      
END FUNCTION
