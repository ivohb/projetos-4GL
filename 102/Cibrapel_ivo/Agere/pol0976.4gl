#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0976                                                 #
# OBJETIVO: ATUALIZAÇÃO DO HISTÓRICO                                #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 25/09/09                                                #
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
         
  
   DEFINE p_estoque            RECORD LIKE estoque.*
   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*
   DEFINE p_estoque_trans_end  RECORD LIKE estoque_trans_end.*
   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*
   DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*
    
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0976-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0976_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0976_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0976") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0976 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   IF NOT pol0976_le_empresa_ger() THEN
      RETURN
   END IF
   
   DISPLAY p_cod_empresa TO cod_empresa
    
   MENU "OPCAO"
      COMMAND "Processar" "Atualiza o estoque !!!"
         IF pol0976_processar() THEN 
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
   CLOSE WINDOW w_pol0976

END FUNCTION

#--------------------------------#
 FUNCTION pol0976_le_empresa_ger()
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
         LET p_cod_emp_ger = p_cod_empresa
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#---------------------------#
 FUNCTION pol0976_processar()
#---------------------------#
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("BEGIN")
   
   
   IF pol0976_deleta_estoque() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF pol0976_atualiza_estoque() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   
   
   IF pol0976_deleta_estoque_trans() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF pol0976_atualiza_estoque_trans() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   
   IF pol0976_deleta_estoque_trans_end() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF pol0976_atualiza_estoque_trans_end() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   
   IF pol0976_deleta_estoque_lote() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF pol0976_atualiza_estoque_lote() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   
   
   IF pol0976_deleta_estoque_lote_ender() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF pol0976_atualiza_estoque_lote_ender() THEN 
   ELSE 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE 
   END IF
      
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE 
  
END FUNCTION 

#--------------------------------#
 FUNCTION pol0976_deleta_estoque()
#--------------------------------#
   
   DELETE FROM estoque
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 
    
#----------------------------------#
 FUNCTION pol0976_atualiza_estoque()
#----------------------------------#
   
   DECLARE cq_estoque CURSOR WITH HOLD FOR
    
    SELECT *
      FROM estoque
     WHERE cod_empresa = p_cod_emp_ofic
  ORDER BY cod_item
  
   FOREACH cq_estoque INTO 
           p_estoque.* 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque')
         RETURN FALSE
      END IF 
      
   IF pol0967_inserindo_estoque() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0967_inserindo_estoque()
#-----------------------------------#

   LET p_estoque.cod_empresa = p_cod_empresa
   
   INSERT INTO estoque 
          VALUES(p_estoque.*)
          
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('inserindo', 'estoque')
         RETURN FALSE 
      END IF 
      
   RETURN TRUE 
   
END FUNCTION  

#--------------------------------------#
 FUNCTION pol0976_deleta_estoque_trans()
#--------------------------------------#
   
   DELETE FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_trans')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 
    
#----------------------------------------#
 FUNCTION pol0976_atualiza_estoque_trans()
#----------------------------------------#
   
   DECLARE cq_estoque_trans CURSOR WITH HOLD FOR
    
    SELECT *
      FROM estoque_trans
     WHERE cod_empresa = p_cod_emp_ofic
  ORDER BY num_transac
  
   FOREACH cq_estoque_trans INTO 
           p_estoque_trans.* 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_trans')
         RETURN FALSE
      END IF 
      
   IF pol0967_inserindo_estoque_trans() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 

#-----------------------------------------#
 FUNCTION pol0967_inserindo_estoque_trans()
#-----------------------------------------#

   LET p_estoque_trans.cod_empresa = p_cod_empresa
   
   INSERT INTO estoque_trans 
          VALUES(p_estoque_trans.*)
          
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('inserindo', 'estoque_trans')
         RETURN FALSE 
      END IF 
      
   RETURN TRUE 
   
END FUNCTION  

#------------------------------------------#
 FUNCTION pol0976_deleta_estoque_trans_end()
#------------------------------------------#
   
   DELETE FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_trans_end')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 
    
#--------------------------------------------#
 FUNCTION pol0976_atualiza_estoque_trans_end()
#--------------------------------------------#
   
   DECLARE cq_estoque_trans_end CURSOR WITH HOLD FOR
    
    SELECT *
      FROM estoque_trans_end
     WHERE cod_empresa = p_cod_emp_ofic
  ORDER BY num_transac
  
   FOREACH cq_estoque_trans_end INTO 
           p_estoque_trans_end.* 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_trans_end')
         RETURN FALSE
      END IF 
      
   IF pol0967_inserindo_estoque_trans_end() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 

#---------------------------------------------#
 FUNCTION pol0967_inserindo_estoque_trans_end()
#---------------------------------------------#

   LET p_estoque_trans_end.cod_empresa = p_cod_empresa
   
   INSERT INTO estoque_trans_end 
          VALUES(p_estoque_trans_end.*)
          
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('inserindo', 'estoque_trans_end')
         RETURN FALSE 
      END IF 
      
   RETURN TRUE 
   
END FUNCTION  

#-------------------------------------#
 FUNCTION pol0976_deleta_estoque_lote()
#-------------------------------------#
   
   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 
    
#---------------------------------------#
 FUNCTION pol0976_atualiza_estoque_lote()
#---------------------------------------#
   
   DECLARE cq_estoque_lote CURSOR WITH HOLD FOR
    
    SELECT *
      FROM estoque_lote
     WHERE cod_empresa = p_cod_emp_ofic
  ORDER BY cod_item
  
   FOREACH cq_estoque_lote INTO 
           p_estoque_lote.* 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_lote')
         RETURN FALSE
      END IF 
      
   IF pol0967_inserindo_estoque_lote() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 

#----------------------------------------#
 FUNCTION pol0967_inserindo_estoque_lote()
#----------------------------------------#

   LET p_estoque_lote.cod_empresa = p_cod_empresa
   
   INSERT INTO estoque_lote 
          VALUES(p_estoque_lote.*)
          
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('inserindo', 'estoque_lote')
         RETURN FALSE 
      END IF 
      
   RETURN TRUE 
   
END FUNCTION  

#-------------------------------------------#
 FUNCTION pol0976_deleta_estoque_lote_ender()
#-------------------------------------------#
   
   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   RETURN TRUE 
   
END FUNCTION 
    
#---------------------------------------------#
 FUNCTION pol0976_atualiza_estoque_lote_ender()
#---------------------------------------------#
   
   DECLARE cq_estoque_lote_ender CURSOR WITH HOLD FOR
    
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_emp_ofic
  ORDER BY cod_item
  
   FOREACH cq_estoque_lote_ender INTO 
           p_estoque_lote_ender.* 
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_lote_ender')
         RETURN FALSE
      END IF 
      
   IF pol0967_inserindo_estoque_lote_ender() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   END FOREACH 
   
   RETURN TRUE 
   
END FUNCTION 

#----------------------------------------------#
 FUNCTION pol0967_inserindo_estoque_lote_ender()
#----------------------------------------------#

   LET p_estoque_lote_ender.cod_empresa = p_cod_empresa
   
   INSERT INTO estoque_lote_ender 
          VALUES(p_estoque_lote_ender.*)
          
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('inserindo', 'estoque_lote_ender')
         RETURN FALSE 
      END IF 
      
   RETURN TRUE 
   
END FUNCTION  

#-------------------------------- FIM DE PROGRAMA -----------------------------#        