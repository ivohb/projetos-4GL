#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0959                                                 #
# OBJETIVO: MOVIMENTAÇÃO DE APONTAMENTOS PARA O HISTÓRICO           #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 01/09/09                                                #
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
         
  
   DEFINE p_apont_trim_885     RECORD LIKE apont_trim_885.*
   DEFINE p_apont_hist_885     RECORD LIKE apont_hist_885.*
   
   DEFINE p_num_ordem          LIKE ordens.num_ordem,
          p_ies_situa          LIKE ordens.ies_situa,
          p_dat_today          DATE,
          p_dat_fim            LIKE apont_trim_885.fim,
          p_dat_extend         DATE 
          
   DEFINE pr_erro              ARRAY[50] OF RECORD
          num_ordem            LIKE ordens.num_ordem
   END RECORD 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0959-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0959_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0959_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0959") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0959 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   IF NOT pol0959_le_empresa_ger() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa
    
   LET p_dat_today = TODAY  
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta de ordens com problemas no histórico !!!"
         CALL pol0959_consultar()
      COMMAND "Processar" "Movimenta apontamentos para o histórico !!!"
         IF pol0959_processar() THEN 
            ERROR "Processamento efetuado com sucesso !!!"
         ELSE
            ERROR "Operação cancelada !!!"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0959

END FUNCTION

#-----------------------------#
 FUNCTION pol0959_deleta_erro()
#-----------------------------#
   
   DELETE FROM ordem_erro_885
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('excluindo','ordem_erro_885')
   END IF 
   
END FUNCTION 

#--------------------------------#
 FUNCTION pol0959_le_empresa_ger()
#--------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
   LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ger
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#---------------------------#
 FUNCTION pol0959_processar()
#---------------------------#
   
   CALL pol0959_deleta_erro()
   
   DECLARE cq_apont CURSOR WITH HOLD FOR
    SELECT numordem
      FROM apont_trim_885
     WHERE codempresa = p_cod_empresa
  GROUP BY numordem
  ORDER BY numordem
  
    FOREACH cq_apont INTO 
           p_num_ordem 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','apont_trim_885')
         RETURN FALSE
      END IF 
      
      MESSAGE 'OP:', p_num_ordem
      
      SELECT ies_situa
        INTO p_ies_situa
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem
         
      IF STATUS <> 0 THEN
         INSERT INTO ordem_erro_885
            VALUES(p_num_ordem)
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('inserindo','ordem_erro_885')
               RETURN FALSE 
            END IF 
         CONTINUE FOREACH 
      END IF
      
      IF p_ies_situa < 5 THEN 
         CONTINUE FOREACH
      END IF
      
      SELECT MAX(fim)
        INTO p_dat_fim
        FROM apont_trim_885
       WHERE codempresa = p_cod_empresa
         AND numordem   = p_num_ordem
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','apont_trim_885')
         RETURN FALSE
      END IF
      
      SELECT COUNT(statusregistro)
        INTO p_count 
        FROM apont_trim_885
       WHERE codempresa     = p_cod_empresa
         AND numordem       = p_num_ordem
         AND statusregistro = '2'
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','apont_trim_885')
         RETURN FALSE
      END IF
      
      IF p_count > 0 THEN 
         CONTINUE FOREACH 
      END IF 
      
      LET p_dat_extend = EXTEND(p_dat_fim, YEAR TO DAY)
      
      LET p_dat_extend = p_dat_extend + 60
      
      IF p_dat_today >= p_dat_extend THEN 
      ELSE
         CONTINUE FOREACH
      END IF 
      
      CALL log085_transacao("BEGIN")
      
      IF pol0959_insere_hist() THEN 
         IF pol0959_exclui_trim() THEN
            CALL log085_transacao("COMMIT")
         ELSE
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE 
         END IF 
      ELSE
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE 
      END IF 
      
   END FOREACH
      
   RETURN TRUE 
  
END FUNCTION 

#---------------------------#
 FUNCTION pol0959_consultar()
#---------------------------#
   
   SELECT COUNT(num_ordem)
     INTO p_count
     FROM ordem_erro_885
     
   IF p_count = 0 THEN 
      CALL log0030_mensagem("Não há dados a serem exibidos !!!","Exclamation")
      RETURN 
   END IF  
      
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09591") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09591 AT 8,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_index = 1
   INITIALIZE pr_erro TO NULL
   
   DECLARE cq_erro CURSOR FOR 
    SELECT num_ordem
      FROM ordem_erro_885
     ORDER BY num_ordem
    
   FOREACH cq_erro INTO 
           pr_erro[p_index].num_ordem 
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","Cursor:cq_erro")
         EXIT FOREACH  
      END IF    
    
      LET p_index = p_index + 1
       
      IF p_index > 1000 THEN
         ERROR 'Limite de Grades ultrapassado'
         EXIT FOREACH
      END IF
       
   END FOREACH
   
   CALL SET_COUNT(P_index - 1)
    
   DISPLAY ARRAY pr_erro TO sr_erro.* 
   
   CLOSE WINDOW w_pol09591
   
END FUNCTION
               
#-----------------------------#
 FUNCTION pol0959_insere_hist()
#-----------------------------# 

   INSERT INTO apont_hist_885
   SELECT *
     FROM apont_trim_885
    WHERE codempresa = p_cod_empresa
      AND numordem   = p_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','apont_hist_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 

#-----------------------------#
 FUNCTION pol0959_exclui_trim()
#-----------------------------#

   DELETE FROM apont_trim_885
    WHERE codempresa = p_cod_empresa
      AND numordem   = p_num_ordem 
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Excluindo','apont_trim_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#        