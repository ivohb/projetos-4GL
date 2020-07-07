#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1244                                                 #
# OBJETIVO: ENVIO DE EMAIL NA ABERTURA DE OS DA MANUT INDUSTRIAL    #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 19/11/13                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_last_row           SMALLINT

END GLOBALS

DEFINE p_num_os               LIKE os_ativ_osp.num_os,
       p_cod_equip            LIKE os_ativ_osp.cod_equip,
       p_dat_base             LIKE os_ativ_osp.dat_base,
       p_nom_usuario          LIKE usuario.nom_usuario,
       p_ies_tip_os           CHAR(01)
              
DEFINE p_rowid              INTEGER,        
       p_retorno            SMALLINT,      
       p_index              SMALLINT,      
       s_index              SMALLINT,      
       p_ind                SMALLINT,      
       s_ind                SMALLINT,      
       p_count              SMALLINT,      
       p_houve_erro         SMALLINT,      
       p_nom_tela           CHAR(200),     
       p_ies_cons           SMALLINT,      
       p_6lpp               CHAR(100),     
       p_8lpp               CHAR(100),     
       p_msg                CHAR(500),     
       p_opcao              CHAR(01),      
       p_num_transac        INTEGER,       
       p_dat_ini_process    DATE,          
       p_hor_ini_process    CHAR(08),
       p_dat_corte          DATE,
       p_remetente          CHAR(08),
       p_email_remetente    CHAR(50),
       p_nom_remetente      CHAR(50),
       p_destinatario       CHAR(08),
       p_email_destinatario CHAR(50),
       p_nom_destinatario   CHAR(50),
       p_documento          CHAR(10),
       p_data               CHAR(10),
       p_equipamento        CHAR(15),
       p_den_comando        CHAR(80),
       p_imp_linha          CHAR(80),
       p_erro               CHAR(10),
       p_titulo             CHAR(60),
       p_assunto            CHAR(30),
       p_arquivo            CHAR(30)         
       
DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE pr_erro              ARRAY[3000] OF RECORD  
       cod_empresa          CHAR(02),
       num_os               CHAR(10),
       den_erro             CHAR(500)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   LET p_versao = "pol1244-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'
   #LET p_user = 'admlog'
   #LET p_status = 0
   
   IF p_status = 0 THEN
      CALL pol1244_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1244_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   #CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   #CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   #CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'pol1244'   #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1244_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1244_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1244") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1244 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET p_dat_ini_process = TODAY
   LET p_hor_ini_process = TIME
   LET p_ind = 0
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1244_processa() THEN
      CALL log085_transacao("ROLLBACK")
      LET pr_men[1].mensagem = 'PROCESSAMENTO COM ERRO. CONSULTE TABELA ERRO_EMAIL_1099'
   ELSE
      CALL log085_transacao("COMMIT")
      LET pr_men[1].mensagem = 'PROCESSAMENTO EFETUADO C/ SUCESSO'
   END IF

   CALL pol1244_exib_mensagem()

   CALL pol1244_grava_erro()
     
END FUNCTION

#------------------------------#
FUNCTION pol1244_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#-----------------------------#
FUNCTION pol1244_guarda_erro()#
#-----------------------------#

   LET p_ind = p_ind + 1
   LET pr_erro[p_ind].cod_empresa = p_cod_empresa
   LET pr_erro[p_ind].num_os = p_num_os
   LET pr_erro[p_ind].den_erro = p_msg
   LET p_houve_erro = TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1244_grava_erro()#
#----------------------------#

   FOR p_index = 1 to p_ind
     
     IF pr_erro[p_index].cod_empresa IS NOT NULL THEN
        INSERT INTO erro_email_1099
         VALUES(pr_erro[p_index].cod_empresa,
                pr_erro[p_index].num_os,
                pr_erro[p_index].den_erro,
                p_dat_ini_process,
                p_hor_ini_process)

        IF STATUS <> 0 THEN
           EXIT FOR
        END IF
     END IF
     
   END FOR 
   
END FUNCTION
   
#--------------------------#
FUNCTION pol1244_processa()#
#--------------------------#
   
   IF NOT pol1244_cria_temp() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_emps CURSOR FOR
    SELECT cod_empresa,
           dat_corte,
           usuario_email
      FROM empresa_manut_ind_1099
   
   FOREACH cq_emps INTO p_cod_empresa, p_dat_corte, p_remetente                
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_EMPS'
         LET p_num_os = ''
         CALL pol1244_guarda_erro()
         RETURN FALSE
      END IF
      
      DECLARE cq_os CURSOR FOR
       SELECT num_os, 
              dat_solic,
              ies_tip_os
         FROM os_min 
        WHERE cod_empresa = p_cod_empresa
          AND dat_solic >= p_dat_corte
          AND num_os NOT IN
            (SELECT num_os FROM os_email_1099 WHERE cod_empresa = p_cod_empresa)

      FOREACH cq_os INTO p_num_os, p_dat_base, p_ies_tip_os

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_EMPS'
            LET p_num_os = ''
            CALL pol1244_guarda_erro()
            RETURN FALSE
         END IF
         
         LET pr_men[1].mensagem = 'Processando OS ', p_num_os
         CALL pol1244_exib_mensagem()
         
         CASE p_ies_tip_os
           WHEN 'N' 
             SELECT max(cod_equip) INTO p_cod_equip
               FROM ativ_osn WHERE cod_empresa = p_cod_empresa AND num_os = p_num_os
           WHEN 'P'
             SELECT max(cod_equip) INTO p_cod_equip
               FROM os_ativ_osp WHERE cod_empresa = p_cod_empresa AND num_os = p_num_os
           WHEN 'E'
             SELECT max(eqpto) INTO p_cod_equip
               FROM min_ordem_servico_especial WHERE empresa = p_cod_empresa AND ordem_servico = p_num_os
         END CASE
 
         INSERT INTO os_email_1099
          VALUES(p_cod_empresa, p_num_os, p_cod_equip, 
                 p_ies_tip_os, p_dat_base)

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA OS_EMAIL_1099'
            LET p_num_os = ''
            CALL pol1244_guarda_erro()
            RETURN FALSE
         END IF
         
         DECLARE cq_user_email CURSOR FOR
          SELECT nom_usuario
            FROM usuario_manut_ind_1099
           WHERE cod_empresa = p_cod_empresa
             AND ies_tip_os = p_ies_tip_os     

         FOREACH cq_user_email INTO p_nom_usuario

            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_USER_EMAIL'
               LET p_num_os = ''
               CALL pol1244_guarda_erro()
               RETURN FALSE
            END IF
            
            INSERT INTO email_temp_1099
             VALUES(p_cod_empresa, p_remetente, 
                    p_nom_usuario, p_num_os, 
                    p_dat_base, p_cod_equip)
             
            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = 'ERRO ', p_erro CLIPPED, ' INSERINDO DADOS NA TABELA EMAIL_TEMP_1099'
               LET p_num_os = ''
               CALL pol1244_guarda_erro()
               RETURN FALSE
            END IF
         
         END FOREACH
         
      END FOREACH
   
   END FOREACH
   
   IF NOT pol1244_envia_email() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1244_cria_temp()#
#---------------------------#

   DROP TABLE email_temp_1099

   CREATE  TABLE email_temp_1099(
      cod_empresa   CHAR(02), 
      remetente     CHAR(08), 
      destinatario  CHAR(08), 
      documento     CHAR(10), 
      data          CHAR(10), 
      equipamento   CHAR(15)
    );
         
   IF STATUS <> 0 THEN 
      LET p_erro = STATUS
      DELETE FROM email_temp_1099
   END IF

   SELECT COUNT(*)
     INTO p_count
     FROM email_temp_1099
   
   IF p_count > 0 THEN
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' CRIANDO A TABELA EMAIL_TEMP_1099'
      LET p_num_transac = 0
      CALL pol1244_guarda_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
#-----------------------------#
FUNCTION pol1244_envia_email()#
#-----------------------------#
 
   LET pr_men[1].mensagem = 'ENVIANDO EMAIL'
   CALL pol1244_exib_mensagem()

   LET p_assunto = 'Manutencao Industrial'
   
   DECLARE cq_le_remetente CURSOR FOR
    SELECT DISTINCT
           cod_empresa,
           remetente
      FROM email_temp_1099
     ORDER BY cod_empresa, remetente

   FOREACH cq_le_remetente INTO p_cod_empresa, p_remetente

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_LE_REMETENTE'
         LET p_num_os = ''
         CALL pol1244_guarda_erro()
         RETURN FALSE
      END IF
      
      IF NOT pol1244_email_de() THEN
         RETURN FALSE
      END IF

      LET p_titulo = 'Abertura de OS para manutencao industrial - Empresa: ', p_cod_empresa

      DECLARE cq_le_destinatario CURSOR FOR
       SELECT DISTINCT 
              destinatario
         FROM email_temp_1099
        WHERE cod_empresa = p_cod_empresa
          AND remetente = p_remetente
   
      FOREACH cq_le_destinatario INTO p_destinatario

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSOR CQ_LE_DESTINATARIO'
            LET p_num_os = ''
            CALL pol1244_guarda_erro()
            RETURN FALSE
         END IF
         
         LET p_num_os = p_documento

         IF NOT pol1244_email_para() THEN
            RETURN FALSE
         END IF

         SELECT nom_caminho
           INTO p_den_comando
           FROM log_usu_dir_relat 
          WHERE usuario = p_destinatario
            AND empresa = p_cod_empresa 
            AND sistema_fonte = 'LST' 
            AND ambiente = g_ies_ambiente

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO TABELA LOG_USU_DIR_RELAT - USUARIO ', p_destinatario
            CALL pol1244_guarda_erro()
            RETURN FALSE
         END IF
         
         LET p_arquivo = p_remetente CLIPPED, '-', p_destinatario CLIPPED, '.lst'
         LET p_den_comando = p_den_comando CLIPPED, p_arquivo
         
         START REPORT pol1244_email TO p_den_comando
      
         DECLARE cq_le_docs CURSOR FOR
          SELECT documento,
                 data,
                 equipamento
            FROM email_temp_1099
           WHERE cod_empresa = p_cod_empresa
             AND remetente = p_remetente
             AND destinatario = p_destinatario

         FOREACH cq_le_docs INTO p_documento, p_data, p_equipamento 

            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO CURSRO CQ_LE_DOCS'
               CALL pol1244_guarda_erro()
               RETURN FALSE
            END IF
                  
            LET p_imp_linha = 'OS: ', p_documento CLIPPED, ' DATA: ', p_data, ' EQPTO: ', p_equipamento
         
            OUTPUT TO REPORT pol1244_email() 
      
         END FOREACH

         FINISH REPORT pol1244_email  
      
         CALL log5600_envia_email(p_email_remetente, p_email_destinatario, p_assunto, p_den_comando, 2)

         LET pr_men[1].mensagem = 'ENVIANDO EMAIL PARA ', p_email_destinatario
         CALL pol1244_exib_mensagem()
            
      END FOREACH
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION


#---------------------#
 REPORT pol1244_email()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, 'A/C. ', p_nom_destinatario
         PRINT
         PRINT COLUMN 001, p_titulo
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 001, p_nom_remetente
        
END REPORT
   
 
#--------------------------#
FUNCTION pol1244_email_de()#
#--------------------------#

   SELECT e_mail,
          nom_funcionario
     INTO p_email_remetente,
          p_nom_remetente
     FROM usuarios
    WHERE cod_usuario = p_remetente

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO EMAIL DO REMETENTE ', p_remetente,
                  ' NA TABELA USUARIOS'
      LET p_num_os = ''
      CALL pol1244_guarda_erro()
      RETURN FALSE
   END IF

   IF p_email_remetente IS NULL THEN
      LET p_erro = ''
      LET p_msg = 'EMAIL DO REMETENTE ', p_remetente, ' ESTA NULO'
      LET p_num_os = ''
      CALL pol1244_guarda_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1244_email_para()#
#----------------------------#

   SELECT e_mail,
          nom_funcionario
     INTO p_email_destinatario,
          p_nom_destinatario
     FROM usuarios
    WHERE cod_usuario = p_destinatario

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' LENDO EMAIL DO DESTINATARIO ', p_destinatario,
                  ' NA TABELA USUARIOS'
      CALL pol1244_guarda_erro()
      RETURN FALSE
   END IF

   IF p_email_destinatario IS NULL THEN
      LET p_erro = ''
      LET p_msg = 'EMAIL DO DESTINATARIO ', p_destinatario, ' ESTA NULO'
      CALL pol1244_guarda_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

            
#----------FIM DO PROGRAMA--------------#
            
         