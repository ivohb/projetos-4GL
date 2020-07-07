#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0918                                                 #
# OBJETIVO: CADASTRO DE OPERAÇÕES P/ DEVOLUÇÃO DE KITS              #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 06/03/09                                                #
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100)
  
   DEFINE P_oper_dev_304       RECORD LIKE oper_dev_304.*

   DEFINE p_cod_oper_ent       LIKE oper_dev_304.cod_oper_ent,
          p_cod_oper_ent_ant   LIKE oper_dev_304.cod_oper_ent,
          p_den_operacao       LIKE estoque_operac.den_operacao,
          p_ies_tipo           LIKE estoque_operac.ies_tipo

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0918-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0918_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0918_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0918") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0918 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
    
   LET p_ies_cons  = FALSE
   CALL pol0918_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol0918_checa_inclusao()
         IF p_ies_inclu = TRUE THEN 
            ERROR 'Operação cancelada !!!'
         ELSE 
            CALL pol0918_inclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Inclusão efetuada com sucesso !!!'
            ELSE
               CALL pol0918_limpa_tela()
               ERROR 'Operação cancelada !!!'
            END IF 
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol0918_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               CALL pol0918_limpa_tela()
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0918_exclusao() RETURNING p_retorno
            IF p_retorno THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Consultar" "Consulta dados da tabela"
          CALL pol0918_consulta() RETURNING p_status
          IF p_status THEN
             IF p_ies_cons THEN
                ERROR 'Consulta efetuada com sucesso !!!'
                NEXT OPTION "Seguinte" 
             ELSE
                CALL pol0918_limpa_tela()
                ERROR 'Argumentos de pesquisa não encontrados !!!'
             END IF 
          ELSE
             CALL pol0918_limpa_tela()
             ERROR 'Operação cancelada!!!'
             NEXT OPTION 'Incluir'
          END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0918_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0918

END FUNCTION

#----------------------------#
 FUNCTION pol0918_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------------#
 FUNCTION pol0918_checa_inclusao()
#--------------------------------#
   
   LET p_ies_inclu = FALSE 
   
   SELECT cod_oper_ent
     FROM oper_dev_304
    WHERE cod_empresa   = p_cod_empresa
         
   IF STATUS = 0 THEN 
      CALL log0030_mensagem('Operação já cadastrada para a empresa atual!!!', 'excla')
      LET p_ies_inclu = TRUE 
   ELSE 
      IF STATUS <> 100 THEN 
         CALL log003_err_sql('lendo', 'oper_dev_304')
      END IF
   END IF 
  
END FUNCTION 

#--------------------------#
 FUNCTION pol0918_inclusao()
#--------------------------#

   CALL pol0918_limpa_tela()
   INITIALIZE P_oper_dev_304.* TO NULL
   LET P_oper_dev_304.cod_empresa = p_cod_empresa

   IF pol0918_edita_dados("I") THEN
      INSERT INTO oper_dev_304
       VALUES(p_oper_dev_304.*)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Inserindo", "oper_dev_304")   
      ELSE
         LET p_cod_empresa = p_oper_dev_304.cod_empresa         
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0918_edita_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME P_oper_dev_304.* WITHOUT DEFAULTS
   
      
      AFTER FIELD cod_oper_ent
      IF P_oper_dev_304.cod_oper_ent IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_oper_ent   
      END IF

      SELECT den_operacao,
             ies_tipo
        INTO p_den_operacao,
             p_ies_tipo
        FROM estoque_operac
       WHERE cod_empresa   = p_cod_empresa
         AND cod_operacao  = P_oper_dev_304.cod_oper_ent  
         
      IF STATUS = 100 THEN
         ERROR "Código não cadastrado !!!"
         NEXT FIELD cod_oper_ent
      ELSE 
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','estoque_operac')
            RETURN FALSE
         END IF  
      END IF    
                     
      IF p_ies_tipo <> 'E' THEN
         ERROR "Este código não é uma operação de entrada !!!"
         NEXT FIELD cod_oper_ent
      END IF  
              
      DISPLAY p_den_operacao TO den_oper_ent
      
      AFTER FIELD cod_oper_sai
      IF P_oper_dev_304.cod_oper_sai IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_oper_sai   
      END IF
      
      SELECT den_operacao,
             ies_tipo
        INTO p_den_operacao,
             p_ies_tipo
        FROM estoque_operac
       WHERE cod_empresa   = p_cod_empresa
         AND cod_operacao  = P_oper_dev_304.cod_oper_sai  
         
      IF STATUS = 100 THEN
         ERROR "Código não cadastrado !!!"
         NEXT FIELD cod_oper_sai
      ELSE 
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','estoque_operac')
            RETURN FALSE
         END IF  
      END IF    
                     
      IF p_ies_tipo <> 'S' THEN
         ERROR "Este código não é uma operação de saída !!!"
         NEXT FIELD cod_oper_sai
      END IF  
              
      DISPLAY p_den_operacao TO den_oper_sai
      
      ON KEY (control-z)
         CALL pol0918_popup()
       
   END INPUT 


   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol0918_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_oper_ent)
         CALL log009_popup(8,10,"OPERAÇÕES DE ENTRADA","estoque_operac",
                     "cod_operacao","den_operacao","ies_tipo","S",
                     " ies_tipo = 'E' order by cod_operacao") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET P_oper_dev_304.cod_oper_ent = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_oper_ent
         END IF
      
       WHEN INFIELD(cod_oper_sai)
         CALL log009_popup(8,10,"OPERAÇÕES DE SAÍDA","estoque_operac",
                     "cod_operacao","den_operacao","","S",
                     " ies_tipo = 'S' order by cod_operacao") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01",p_versao)
         IF p_codigo IS NOT NULL THEN
            LET P_oper_dev_304.cod_oper_sai = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_oper_sai
         END IF
   END CASE
   

END FUNCTION
            
#--------------------------#
 FUNCTION pol0918_consulta()
#--------------------------#
    
    CALL pol0918_limpa_tela() 
    LET p_ies_cons = FALSE
    
    SELECT cod_oper_ent,
           cod_oper_sai 
      INTO p_oper_dev_304.cod_oper_ent,
           p_oper_dev_304.cod_oper_sai
      FROM oper_dev_304
     WHERE cod_empresa = p_cod_empresa
     
    IF STATUS <> 0 THEN 
       IF STATUS <> 100 THEN 
          CALL log003_err_sql('lendo','oper_dev_304')
          RETURN FALSE
       ELSE 
          CALL log0030_mensagem(
             'A empresa corrente não possui parâmetros cadastrados!','excla')
          RETURN FALSE 
       END IF   
    END IF 
     
    SELECT den_operacao
      INTO p_den_operacao
      FROM estoque_operac
     WHERE cod_empresa   = p_cod_empresa
       AND cod_operacao  = P_oper_dev_304.cod_oper_ent
       AND ies_tipo      = 'E' 

    IF STATUS <> 0 THEN 
       CALL log003_err_sql('lendo','estoque_operac')
       RETURN FALSE
    END IF
    
    LET P_consulta_ent = p_den_operacao 
    
    SELECT den_operacao
      INTO p_den_operacao
      FROM estoque_operac
     WHERE cod_empresa   = p_cod_empresa
       AND cod_operacao  = P_oper_dev_304.cod_oper_sai
       AND ies_tipo      = 'S'  
   
    IF STATUS <> 0 THEN 
       CALL log003_err_sql('lendo','estoque_operac')
       RETURN FALSE
    END IF
       
    LET P_consulta_sai = p_den_operacao
    
    CALL pol0918_exibe_dados()
    LET p_ies_cons = TRUE
    RETURN TRUE 
   
END FUNCTION


#-----------------------------#
 FUNCTION pol0918_exibe_dados()
#-----------------------------#

    DISPLAY p_oper_dev_304.cod_oper_ent TO cod_oper_ent 
    DISPLAY P_consulta_ent              TO den_oper_ent
    DISPLAY p_oper_dev_304.cod_oper_sai TO cod_oper_sai
    DISPLAY P_consulta_sai              TO den_oper_sai
 
END FUNCTION



#----------------------------------#
 FUNCTION pol0918_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_empresa 
      FROM oper_dev_304  
     WHERE cod_empresa = p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","oper_dev_304")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0918_modificacao()
#-----------------------------#
 
   LET P_oper_dev_304.cod_empresa = p_cod_empresa
   LET p_retorno = FALSE

   IF pol0918_prende_registro() THEN
      IF pol0918_edita_dados("M") THEN
         UPDATE oper_dev_304
            SET cod_oper_ent  = P_oper_dev_304.cod_oper_ent,
                cod_oper_sai  = P_oper_dev_304.cod_oper_sai
          WHERE cod_empresa   = p_cod_empresa
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql("Modificando","oper_dev_304")
          ELSE
             LET p_retorno = TRUE
          END IF 
      ELSE
         CALL pol0918_exibe_dados()
      END IF
   END IF

   CLOSE cq_prende

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION


#--------------------------#
 FUNCTION pol0918_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0918_prende_registro() THEN
      DELETE FROM oper_dev_304
			WHERE cod_empresa = p_cod_empresa
    		

      IF STATUS = 0 THEN               
         INITIALIZE P_oper_dev_304 TO NULL
         CALL pol0918_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","oper_dev_304")
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

#-----------------------#
 FUNCTION pol0918_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#