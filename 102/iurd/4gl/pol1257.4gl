#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1257                                                 #
# OBJETIVO: USUARIOS PARA GRADE DE APROVAÇÃO EM iPED/iFONE          #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 25/02/14                                                #
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
          
   DEFINE p_cod_usuario        LIKE user_aprov_265.cod_usuario,
          p_cod_usuario_ant    LIKE user_aprov_265.cod_usuario,
          p_nom_funcionario    LIKE usuarios.nom_funcionario
   
   DEFINE p_senha_cript        CHAR(24)

   DEFINE p_tela               RECORD
          cod_usuario          char(08),
          senha                char(10),
          confirmacao          char(10)
   END RECORD

   DEFINE pr_tempo             ARRAY[1] OF RECORD    
          tempo                CHAR(03)
   END RECORD
             
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1257-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1257_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1257_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1257") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1257 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1257_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1257_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1257_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1257_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1257_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1257_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1257

END FUNCTION

#-----------------------#
 FUNCTION pol1257_sobre()
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
FUNCTION pol1257_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1257_inclusao()
#--------------------------#

   CALL pol1257_limpa_tela()
   
   INITIALIZE p_tela TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF NOT pol1257_edita_dados("I") THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1257_criptografa() THEN
      LET p_msg = 'A comunicação com o servidor\n de criptografia falhou!'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   INSERT INTO user_aprov_265
    VALUES(p_tela.cod_usuario, p_senha_cript)
   
   IF STATUS <> 0 THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
           
   RETURN TRUE
      
END FUNCTION
   
#-----------------------------#
FUNCTION pol1257_criptografa()#
#-----------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1257a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1257a AT 08,25 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1158_integra_java() RETURNING p_status

   CLOSE WINDOW w_pol1257a
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1158_integra_java()#
#------------------------------#
   
   DEFINE p_comando   CHAR(600),
          p_param     CHAR(300),
          p_arquivo   CHAR(300)

   LET p_count = 30

   LET pr_tempo[1].tempo = p_count
   CALL pol1257_exib_tempo()
   
   LET p_arquivo = p_caminho CLIPPED, p_user CLIPPED, '.txt'

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
   
   LET p_param = p_arquivo CLIPPED, ';', p_tela.senha CLIPPED, ';'
   LET p_comando = 'java -jar ', p_caminho CLIPPED, 'cripta.jar ',  p_param
   
   CALL conout(p_comando)
   CALL runOnClient(p_comando)
   
   LET p_count = 29
   
   WHILE p_count > 0
      
      LET pr_tempo[1].tempo = p_count
      CALL pol1257_exib_tempo()
      
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
FUNCTION pol1257_exib_tempo()#
#----------------------------#

   INPUT ARRAY pr_tempo
      WITHOUT DEFAULTS FROM sr_tempo.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
         
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION
       
#--------------------------#
FUNCTION pol1257_le_param()#
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
FUNCTION pol1257_cria_temp()#
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
#-------------------------------------#
 FUNCTION pol1257_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   IF NOT pol1257_le_param() THEN
      RETURN FALSE
   END IF

   IF NOT pol1257_cria_temp() THEN
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
                       
      BEFORE FIELD cod_usuario
         
         IF p_funcao = "M" THEN
            NEXT FIELD senha
         END IF
      
      AFTER FIELD cod_usuario
      
         IF p_tela.cod_usuario IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_usuario   
         END IF
          
         SELECT nom_funcionario
           INTO p_nom_funcionario
           FROM usuarios
          WHERE cod_usuario = p_tela.cod_usuario
         
         IF STATUS = 100 THEN 
            ERROR 'Usuário inexistente no Logix.'
            NEXT FIELD cod_usuario
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','usuarios')
               RETURN FALSE
            END IF 
         END IF  
     
      SELECT cod_usuario
        FROM user_aprov_265
       WHERE cod_usuario = p_tela.cod_usuario
      
      IF STATUS = 0 THEN
         ERROR "Usuário já cadastrado no POL1257."
         NEXT FIELD cod_usuario
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','user_aprov_265')
            RETURN FALSE
         END IF 
      END IF    
      
      DISPLAY p_nom_funcionario TO nom_funcionario

      AFTER FIELD senha
      
         IF p_tela.senha IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD senha   
         END IF          
         
         DISPLAY p_tela.senha TO senha

      AFTER FIELD confirmacao
      
         IF p_tela.confirmacao IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD confirmacao   
         END IF          
         
         DISPLAY p_tela.confirmacao TO confirmacao

      AFTER INPUT
      
         IF NOT INT_FLAG THEN
           
            IF p_tela.senha IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD senha   
            END IF
            IF LENGTH(p_tela.senha) < 6 THEN 
               ERROR "A senha deve possuir entre 6 e 10 caracteres !!!"
               NEXT FIELD senha   
            END IF
            IF p_tela.confirmacao IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD confirmacao   
            END IF
            IF p_tela.confirmacao <> p_tela.senha THEN 
               ERROR "Confirmação de senha inválida"
               NEXT FIELD confirmacao   
            END IF

         END IF
      
      ON KEY (control-z)
         CALL pol1257_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1257_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(8,10,"usuarios","usuarios",
              "cod_usuario","nom_funcionario","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1257_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1257_limpa_tela()
   
   LET p_cod_usuario_ant = p_cod_usuario
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      user_aprov_265.cod_usuario
      
      ON KEY (control-z)
         CALL pol1257_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1257_limpa_tela()
         ELSE
            LET p_cod_usuario = p_cod_usuario_ant
            CALL pol1257_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT cod_usuario ",
                  "  FROM user_aprov_265 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_usuario"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_usuario

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1257_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1257_exibe_dados()
#------------------------------#
   
   CALL pol1257_limpa_tela()
   
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

#-----------------------------------#
 FUNCTION pol1257_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_usuario_ant = p_cod_usuario
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_usuario
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_usuario
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_usuario
           FROM user_aprov_265
          WHERE cod_usuario = p_cod_usuario
            
         IF STATUS = 0 THEN
            CALL pol1257_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_usuario = p_cod_usuario_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1257_prende_registro()
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

#--------------------------#
 FUNCTION pol1257_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1257_prende_registro() THEN
      DELETE FROM user_aprov_265
			WHERE cod_usuario = p_cod_usuario

      IF STATUS = 0 THEN               
         CALL pol1257_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","user_aprov_265")
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
{

