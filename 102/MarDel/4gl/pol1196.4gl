#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1196                                                 #
# OBJETIVO: CAMINHOS PARA GERAÇÃO DO EDI                            #
# AUTOR...: IVO BL                                                  #
# DATA....: 31/05/11                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        char(02),
          p_den_empresa        char(30),
          p_user               char(08),
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
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_nome_caminho       CHAR(40)
                 
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1196-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1196_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1196_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1196") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1196 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         if not pol1196_checa_tabela() then
            error 'Caminho já cadastrado para esta empresa !!!'
         else
            CALL pol1196_inclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Inclusão efetuada com sucesso !!!'
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1196_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            let p_ies_cons = true 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1196_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_empresa TO cod_empresa
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1196_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
               let p_ies_cons = false
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1196_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1196

END FUNCTION

#-----------------------#
 FUNCTION pol1196_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------#
 FUNCTION pol1196_checa_tabela()
#------------------------------#
   
   SELECT nom_caminho
     FROM caminho_5054
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo', 'caminho_5054')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
 FUNCTION pol1196_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_nome_caminho TO NULL
   LET INT_FLAG  = FALSE

   IF pol1196_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO caminho_5054 VALUES (p_cod_empresa, p_nome_caminho)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","caminho_5054")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1196_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_nome_caminho    
      WITHOUT DEFAULTS
         FROM nom_caminho  
      
      AFTER FIELD nom_caminho
      IF p_nome_caminho IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD nom_caminho   
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
 FUNCTION pol1196_consulta()
#--------------------------#
   
   SELECT nom_caminho
     INTO p_nome_caminho
     FROM caminho_5054
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Não há dados a\n serem exibidos !!!",'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'caminho_5054')
         RETURN FALSE
      END IF
   END IF
   
   DISPLAY p_nome_caminho TO nom_caminho
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1196_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM caminho_5054  
     WHERE cod_empresa = p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","caminho_5054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1196_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M" 
   
   IF pol1196_prende_registro() THEN
      IF pol1196_edita_dados("M") THEN
         
         UPDATE caminho_5054
            SET nom_caminho = p_nome_caminho
          WHERE cod_empresa = p_cod_empresa
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "caminho_5054")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1196_consulta() RETURNING p_status
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
 FUNCTION pol1196_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
      
   IF not log004_confirm(20,40) THEN      
      RETURN FALSE
   END IF   

   IF pol1196_prende_registro() THEN
      DELETE FROM caminho_5054
			WHERE cod_empresa = p_cod_empresa

      IF STATUS = 0 THEN               
         INITIALIZE p_nome_caminho TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","caminho_5054")
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