#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0956                                                 #
# OBJETIVO: Data limite para programação Kanban                     #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 14/07/09                                                #
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT
         
  
   DEFINE p_tela               RECORD
          cod_parametro        LIKE par_vdp_pad.cod_parametro,
          den_parametro        LIKE par_vdp_pad.den_parametro,
          par_data             LIKE par_vdp_pad.par_data
   END RECORD      

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0956-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0956_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol0956_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0956") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0956 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         IF pol0956_checa_inclusao() THEN 
            CALL pol0956_inclusao() RETURNING p_status
            IF p_status THEN
               LET p_ies_cons = FALSE
               ERROR 'Inclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE 
            ERROR 'Operação cancelada !!!'
            NEXT OPTION "Consultar"
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol0956_consulta() THEN
             LET p_ies_cons = TRUE 
             ERROR 'Consulta efetuada com sucesso !!!'
          ELSE
             LET p_ies_cons = FALSE
             ERROR 'Operação cancela!!!'
          END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            IF pol0956_modificacao() THEN  
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
            NEXT OPTION "Consultar"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0956_exclusao() RETURNING p_status
            IF p_status THEN
               LET p_ies_cons = FALSE
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
            NEXT OPTION "Consultar"
         END IF  
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0956_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0956

END FUNCTION

#--------------------------------#
 FUNCTION pol0956_checa_inclusao()
#--------------------------------#
   
   SELECT cod_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "dat_lim_pgm_Kamban"
      
   IF STATUS = 0 THEN 
      CALL log0030_mensagem("O parâmetro (dat_lim_pgm_Kamban) já foi incluido na empresa corrente !!!", "exclamation")
      RETURN FALSE 
   ELSE 
      IF STATUS <> 100 THEN 
         CALL log003_err_sql("lendo","par_vdp_pad")
         RETURN FALSE 
      END IF 
   END IF 
   
   RETURN TRUE

END FUNCTION  
   
#--------------------------#
 FUNCTION pol0956_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela.* TO NULL
   
   IF pol0956_edita_dados() THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_vdp_pad 
       VALUES (p_cod_empresa, 
               p_tela.cod_parametro, 
               p_tela.den_parametro, 
               NULL, NULL, NULL, NULL, 
               p_tela.par_data)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","par_vdp_pad")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION


#------------------------------#
 FUNCTION pol0956_edita_dados()
#------------------------------#

   LET INT_FLAG = FALSE 
   LET p_tela.cod_parametro = "dat_lim_pgm_Kamban"
   DISPLAY p_tela.cod_parametro TO cod_parametro

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_parametro
      NEXT FIELD den_parametro
      
      
      AFTER FIELD den_parametro
      IF p_tela.den_parametro IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_parametro   
      END IF
      
      AFTER FIELD par_data
      IF p_tela.par_data IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD par_data   
      END IF    
      
   END INPUT 

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0956_consulta()
#--------------------------#
   
   SELECT den_parametro,
          par_data
     INTO p_tela.den_parametro,
          p_tela.par_data
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "dat_lim_pgm_Kamban"
      
   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!", "Exclamation")
      RETURN FALSE 
   ELSE 
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("lendo", "par_vdp_pad")
         RETURN FALSE 
      END IF 
   END IF 
   
   DISPLAY "dat_lim_pgm_Kamban" TO cod_parametro 
   DISPLAY p_tela.den_parametro TO den_parametro   
   DISPLAY p_tela.par_data      TO par_data
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0956_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM par_vdp_pad  
     WHERE cod_empresa   = p_cod_empresa
       AND cod_parametro = "dat_lim_pgm_Kamban"
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","par_vdp_pad")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0956_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF pol0956_prende_registro() THEN
      IF pol0956_edita_dados() THEN
         UPDATE par_vdp_pad
            SET den_parametro = p_tela.den_parametro,
                par_data      = p_tela.par_data
          WHERE cod_empresa   = p_cod_empresa
            AND cod_parametro = "dat_lim_pgm_Kamban"

         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Atualizando", "par_vdp_pad")
         ELSE
            LET p_retorno = TRUE
         END IF 
      ELSE
         CALL pol0956_consulta() RETURNING p_status
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
 FUNCTION pol0956_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0956_prende_registro() THEN
      DELETE FROM par_vdp_pad
			WHERE cod_empresa   = p_cod_empresa
    		AND cod_parametro = "dat_lim_pgm_Kamban"

      IF STATUS = 0 THEN               
         INITIALIZE p_tela TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","par_vdp_pad")
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
 FUNCTION pol0956_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#