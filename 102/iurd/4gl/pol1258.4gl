#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1258                                                 #
# OBJETIVO: ALTERAÇÃO DE SENHA - GRADE DE APROVAÇÃO iPED/iFONE      #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 28/02/14                                                #
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
                       
END GLOBALS

DEFINE p_cod_usuario        LIKE user_aprov_265.cod_usuario,
       p_cod_usuario_ant    LIKE user_aprov_265.cod_usuario,
       p_nom_funcionario    LIKE usuarios.nom_funcionario
   
DEFINE p_senha_cript        CHAR(24),
       p_senha_atual        CHAR(24)

DEFINE p_tela               RECORD
       cod_usuario          char(08),
       senha_atual          char(10),
       senha_nova           char(10),
       confirmacao          char(10)
END RECORD

DEFINE pr_tempo             ARRAY[1] OF RECORD    
       tempo                CHAR(03)
END RECORD

DEFINE p_comando   CHAR(600),
       p_param     CHAR(300),
       p_arquivo   CHAR(300)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1258-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol1258_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1258_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1258") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1258 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Modificar" "Modifica senha do usuário logado"
         IF pol1258_modificar() THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1258_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1258_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1258

END FUNCTION

#-----------------------#
 FUNCTION pol1258_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               "   Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br.com\n\ ",
               "  (11) 9-4179-6633 Vivo \n\n",
               "      LOGIX 10.02\n",
               "   www.grupoaceex.com.br\n",
               "     (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1258_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1258_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1258_limpa_tela()
     
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_usuario ",
                  "  FROM user_aprov_265 ",
                  " WHERE cod_usuario = '",p_user,"' "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_usuario

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1258_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1258_exibe_dados()
#------------------------------#
   
   CALL pol1258_limpa_tela()
   
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_cod_usuario
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','usuarios')
      RETURN FALSE 
   END IF
   
   DISPLAY p_cod_usuario     TO cod_usuario
   DISPLAY p_nom_funcionario TO nom_funcionario
      
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1258_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_usuario 
      FROM user_aprov_265  
     WHERE cod_usuario = p_cod_usuario
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","user_aprov_265")
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
 FUNCTION pol1258_modificar()#
#----------------------------#

   CALL pol1258_limpa_tela()

   IF NOT pol1258_consulta() THEN
      RETURN FALSE         
   END IF
   
   INITIALIZE p_tela TO NULL
   LET p_tela.cod_usuario = p_cod_usuario
   
   LET INT_FLAG  = FALSE
   
   IF pol1258_prende_registro() THEN
      IF pol1258_edita_dados() THEN
         IF pol1258_criptografa() THEN
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

#------------------------------#
 FUNCTION pol1258_edita_dados()#
#------------------------------#

   IF NOT pol1258_le_param() THEN
      RETURN FALSE
   END IF

   IF NOT pol1258_cria_temp() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
                             
      AFTER FIELD senha_atual
      
         IF p_tela.senha_atual IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD senha_atual   
         END IF          
         
         DISPLAY p_tela.senha_atual TO senha_atual

      AFTER FIELD senha_nova
      
         IF p_tela.senha_nova IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD senha_nova   
         END IF          
         
         DISPLAY p_tela.senha_nova TO senha_nova

      AFTER FIELD confirmacao
      
         IF p_tela.confirmacao IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD confirmacao   
         END IF          
         
         DISPLAY p_tela.confirmacao TO confirmacao
         
      AFTER INPUT
      
         IF NOT INT_FLAG THEN
           
            IF p_tela.senha_nova IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD senha_nova   
            END IF
            IF LENGTH(p_tela.senha_nova) < 6 THEN 
               ERROR "A senha deve possuir entre 6 e 10 caracteres !!!"
               NEXT FIELD senha_nova   
            END IF
            IF p_tela.confirmacao IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD confirmacao   
            END IF
            IF p_tela.confirmacao <> p_tela.senha_nova THEN 
               ERROR "Confirmação de senha inválida"
               NEXT FIELD confirmacao   
            END IF

         END IF
      
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1258_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1258_criptografa()#
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1258a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1258a AT 08,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_count = 30

   LET p_arquivo = p_caminho CLIPPED, p_user CLIPPED, '.txt'

   CALL pol1258_checa_senhas() RETURNING p_status
   
   CLOSE WINDOW w_pol1258a

   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1258_checa_senhas()#
#------------------------------#

   IF NOT pol1258_del_arq_txt() THEN
      RETURN FALSE
   END IF

   LET p_param = p_arquivo CLIPPED, ';', p_tela.senha_atual CLIPPED, ';'

   IF NOT pol1158_integra_java() THEN
      RETURN FALSE
   END IF
   
   SELECT senha
     INTO p_senha_atual
     FROM user_aprov_265
    WHERE cod_usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','user_aprov_265')
      RETURN FALSE
   END IF
   
   IF p_senha_cript <> p_senha_atual THEN
      LET p_msg = 'A snha atual informada não\n confere com a cadastrada.'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF

   IF NOT pol1258_del_arq_txt() THEN
      RETURN FALSE
   END IF

   LET p_param = p_arquivo CLIPPED, ';', p_tela.senha_nova CLIPPED, ';'

   IF NOT pol1158_integra_java() THEN
      RETURN FALSE
   END IF
   
   UPDATE user_aprov_265
      SET senha = p_senha_cript
    WHERE cod_usuario = p_user

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','user_aprov_265')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1258_del_arq_txt()#
#-----------------------------#

   LET pr_tempo[1].tempo = p_count
   CALL pol1258_exib_tempo()

   IF g_ies_ambiente = 'W' THEN
      LET p_comando = 'del ', p_arquivo CLIPPED
   ELSE
      LET p_comando = 'rm ', p_arquivo CLIPPED
   END IF
         
   RUN p_comando RETURNING p_status

   LOAD FROM p_arquivo INSERT INTO senha_temp_265

   IF STATUS = 0  THEN 
      LET p_msg = 'Não foi possivel remover arquivo:\n', p_arquivo
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   DELETE FROM senha_temp_265

   LET p_count = p_count - 1
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1158_integra_java()#
#------------------------------#
      
   LET p_comando = 'java -jar ', p_caminho CLIPPED, 'cripta.jar ',  p_param
   
   CALL conout(p_comando)
   CALL runOnClient(p_comando)
   
   WHILE p_count > 0
      
      LET pr_tempo[1].tempo = p_count
      CALL pol1258_exib_tempo()
      
      LOAD FROM p_arquivo INSERT INTO senha_temp_265

      IF STATUS <> 0 AND STATUS <> -805 THEN 
         CALL log003_err_sql("LOAD","senha_temp_265")
         RETURN FALSE
      END IF
      
      IF STATUS = 0 THEN
         
         SELECT senha_cript
           INTO p_senha_cript
           FROM senha_temp_265
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','senha_temp_265')
            RETURN FALSE
         END IF
      
         IF p_senha_cript IS NULL OR p_senha_cript = ' ' THEN
         ELSE
            RETURN TRUE
         END IF
         
      END IF

      SLEEP(1)
      
      LET p_count = p_count - 1
               
   END WHILE
   
   RETURN FALSE

END FUNCTION

#----------------------------#
FUNCTION pol1258_exib_tempo()#
#----------------------------#

   INPUT ARRAY pr_tempo
      WITHOUT DEFAULTS FROM sr_tempo.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
         
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION
       
#--------------------------#
FUNCTION pol1258_le_param()#
#--------------------------#
   
   INITIALIZE p_caminho TO NULL
   
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = 'JAR'
      AND ies_ambiente = g_ies_ambiente
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema JAR não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol1258_cria_temp()#
#---------------------------# 
  
   DROP TABLE senha_temp_265
   
   CREATE TEMP TABLE senha_temp_265(
	    senha_cript    CHAR(24)
	 )

	 IF STATUS <> 0 THEN 
	    DELETE FROM senha_temp_265
	    SELECT COUNT(senha_cript)
	      INTO p_count
	      FROM senha_temp_265
	    IF p_count > 0 THEN
         LET p_msg = 'Não foi possivel limpar a tabela\n',
                     'temporária senha_temp_265.'
         CALL log0030_mensagem(p_msg,'info')
         RETURN FALSE
      END IF
	 END IF

   RETURN TRUE

END FUNCTION  
   

#-------------------------------- FIM DE PROGRAMA -----------------------------#
{

