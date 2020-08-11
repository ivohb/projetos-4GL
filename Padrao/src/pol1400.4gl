#-------------------------------------------------------------------#
# SISTEMA.: LOGIX - CRE                                             #
# PROGRAMA: pol1400                                                 #
# OBJETIVO: PARÂMETROS PARA ENVIO DE COBRANÇA                       #
#           ENVIO DE COBRANÇA PARA TITULOS VENCIDOS                 #
#           ENVIO DE LEMBRETES PARA TITULOS A VENCER                #
# AUTOR...: IVO                                                     #
# DATA....: 03/08/20                                                #
#-------------------------------------------------------------------#
# OBS: Os emails dos clientes devem estar cadastrados no POL1399 ou #
#      no VDP1325                                                   #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           p_cod_empresa   CHAR(02)
END GLOBALS

DEFINE m_den_empresa     CHAR(02),
       p_caminho         CHAR(150),
       m_dat_de          DATE,
       m_dat_ate         DATE,
       m_dat_vencto      DATE,
       m_repet_env_apos  DECIMAL(3,0),
       m_enviar_email    CHAR(01),
       m_repet_envio     CHAR(01),
       m_cod_empresa     CHAR(02),
       m_cod_cliente     VARCHAR(15),
       m_limite_saldo    DECIMAL(12,2),
       m_emitente_email  VARCHAR(08),
       m_dat_prorrogada  DATE,
       m_erro            VARCHAR(10),
       m_msg             VARCHAR(120),
       m_dias_atraso     DECIMAL(4,0),
       m_id_registro     INTEGER,
       m_dat_envio       DATE,
       m_dat_enviado     DATE,
       m_hor_envio       VARCHAR(08),
       m_tem_docum       SMALLINT,
       m_count           INTEGER,  
       m_cnpj            CHAR(20),         
       m_email_cliente   CHAR(250),        
       m_den_munic       CHAR(40),         
       m_uni_feder       CHAR(02),
       p_cod_cliente     CHAR(15),
       m_le_param        SMALLINT,
       m_tip_envio       CHAR(01),
       m_email_ok        SMALLINT

DEFINE p_remetente               CHAR(08),
       p_email_remetente         CHAR(50),
       p_nom_remetente           CHAR(36),
       p_imp_linha               CHAR(86),
       p_nom_destinatario        CHAR(36),
       p_destinatario            CHAR(08),
       p_email_destinatario      CHAR(400),
       p_arquivo                 CHAR(40),
       p_den_comando             CHAR(110),
       p_total                   DECIMAL(12,2),
       p_num_nf                  CHAR(09),
       p_num_docum               CHAR(15),       
       p_dat_vencto              CHAR(10),
       p_valor                   CHAR(12),
       p_val_saldo               DECIMAL(12,2),
       p_assunto                 CHAR(30),
       p_titulo1                 CHAR(100),       
       p_titulo2                 CHAR(100),    
       p_mensa_1                 VARCHAR(120),
       p_mensa_2                 VARCHAR(120),
       p_mensa_3                 VARCHAR(120)
       
DEFINE mr_docum          RECORD   
       num_docum         CHAR(15),        
       ies_tip_docum     CHAR(05),             
       dat_emis          DATE,                  
       dat_vencto_s_desc DATE,            
       cod_cliente       CHAR(15)               
END RECORD

DEFINE mr_param                  RECORD
       cod_cliente          VARCHAR(15),  
       vencidos_de          DECIMAL(3,0), 
       vencidos_ate         DECIMAL(3,0), 
       enviar_cobranca      VARCHAR(01),  
       repetir_cobranca     VARCHAR(01),  
       repetir_cob_apos     DECIMAL(3,0), 
       limite_saldo         DECIMAL(12,2),
       enviar_lembrete      VARCHAR(01),  
       repetir_lembrete     VARCHAR(01),  
       repetir_lemb_apos    DECIMAL(3,0), 
       vencer_ate           DECIMAL(3,0), 
       emitente_email       VARCHAR(08),  
       email1_cliente       VARCHAR(50),  
       email2_cliente       VARCHAR(50),  
       email3_cliente       VARCHAR(50)   
END RECORD                

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_user = ARG_VAL(2)
      
      IF LOG_connectDatabase("DEFAULT") THEN
         #CALL pol1396_proc_consistencia()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
   
   #CALL pol1396_exibe_tela()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   CALL log0030_mensagem(p_cod_empresa, 'info')
   CALL log0030_mensagem(p_user, 'info')

      LET m_msg = 'Exwcucao manual.'
      CALL pol1400_ins_mensagem() RETURNING p_status      
   
   IF p_status = 0 THEN    
      #CALL pol1400_job()
   END IF

   #CLOSE WINDOW w_pol1396
         
END MAIN

#------------------------------#
FUNCTION pol1400_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   LET m_dat_envio = TODAY
   LET m_hor_envio = TIME
   
   CALL log0030_mensagem(p_cod_empresa,'info')
   
   LET m_cod_empresa = l_param1_empresa
   CALL log0030_mensagem(m_cod_empresa,'info')
   
   LET p_user = l_param2_user
   CALL log0030_mensagem(p_user,'info')
   
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF

      LET m_msg = 'Execucao pela JOB0003.'
      CALL pol1400_ins_mensagem() RETURNING p_status      
RETURN

   IF m_cod_empresa IS NULL THEN
      LET m_msg = 'Empresa não parametrizada na JOB0003.'
      CALL pol1400_ins_mensagem() RETURNING p_status      
      RETURN FALSE
   END IF
      
   IF NOT pol1400_processa() THEN
      IF m_msg IS NOT NULL THEN
         CALL pol1400_ins_mensagem() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1400_processa()#
#--------------------------#
   
   DEFINE l_dat_agora      DATE,
          l_dat_corte      DATE
       
   DELETE FROM docum_enviado_912 
    WHERE cod_empresa = m_cod_empresa
      AND ies_enviado = 'N'

   CALL pol1400_le_empresa()
   CALL pol1400_set_mensa_cob()

   LET l_dat_agora = TODAY  
   LET l_dat_corte = '01/01/2017'        

   DECLARE cq_docum CURSOR FOR
    SELECT DISTINCT cod_cliente
      FROM docum
     WHERE cod_empresa = m_cod_empresa
       AND ies_situa_docum NOT IN ('C','E')
       AND val_saldo >= 0
       AND DATE(dat_vencto_s_desc) < l_dat_agora
       AND DATE(dat_vencto_s_desc) >= l_dat_corte

   FOREACH cq_docum INTO m_cod_cliente
      
      IF STATUS <> 0 THEN      
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' lendo clientes da tabela docum.'
         RETURN FALSE
      END IF
      
      LET m_le_param = TRUE
      LET m_tip_envio = 'C'
   
      CALL log085_transacao("BEGIN")

      IF NOT pol1400_le_docum_cob() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF

      LET m_le_param = TRUE
      LET m_tip_envio = 'C'
   
      CALL log085_transacao("BEGIN")

      IF NOT pol1400_le_docum_lembre() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION


#--------------------------------------------#
FUNCTION pol1400_proces_cobranca(lr_cobranca)#
#--------------------------------------------#

   DEFINE lr_cobranca       RECORD
          cod_empresa       CHAR(02),
          cod_cliente       CHAR(15),     
          nom_cliente       CHAR(36),        
          vencidos_de       DECIMAL(3,0),  
          vencidos_ate      DECIMAL(3,0),
          enviar_cobranca   VARCHAR(01),
          repetir_cobranca  VARCHAR(01),
          repetir_cob_apos  DECIMAL(3,0),
          limite_saldo      DECIMAL(12,2),
          emitente_email    VARCHAR(08)
   END RECORD
   
   LET m_cod_empresa = lr_cobranca.cod_empresa
   LET m_cod_cliente = lr_cobranca.cod_cliente
   LET m_dat_de = TODAY - lr_cobranca.vencidos_de
   LET m_dat_ate = TODAY - lr_cobranca.vencidos_ate
   LET m_enviar_email = lr_cobranca.enviar_cobranca
   LET m_repet_envio = lr_cobranca.repetir_cobranca
   LET m_repet_env_apos = lr_cobranca.repetir_cob_apos
   LET m_limite_saldo = lr_cobranca.limite_saldo
   LET m_emitente_email = lr_cobranca.emitente_email

   LET m_dat_envio = TODAY
   LET m_hor_envio = TIME
   LET m_msg = NULL
   LET m_le_param = FALSE
   LET m_tip_envio = 'C'
   
   CALL pol1400_le_empresa()
   CALL pol1400_set_mensa_cob()

   CALL log085_transacao("BEGIN")

   IF NOT pol1400_le_docum_cob() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN m_msg

END FUNCTION

#--------------------------------------------#
FUNCTION pol1400_proces_lembrete(lr_lembrete)#
#--------------------------------------------#

   DEFINE lr_lembrete       RECORD
       cod_empresa       CHAR(02),
       cod_cliente       CHAR(15),     
       nom_cliente       CHAR(36),   
       enviar_lembrete   CHAR(01),  
       repetir_lembrete  CHAR(01),  
       repetir_lemb_apos DECIMAL(3,0),   
       vencer_ate        DECIMAL(3,0),
       emitente_email    VARCHAR(08)
   END RECORD

   LET m_cod_empresa = lr_lembrete.cod_empresa
   LET m_cod_cliente = lr_lembrete.cod_cliente
   LET m_enviar_email = lr_lembrete.enviar_lembrete
   LET m_repet_envio = lr_lembrete.repetir_lembrete
   LET m_repet_env_apos = lr_lembrete.repetir_lemb_apos
   LET m_dat_ate = TODAY + lr_lembrete.vencer_ate 
   LET m_emitente_email = lr_lembrete.emitente_email
   LET m_dat_de = TODAY
   LET m_dat_envio = m_dat_de
   LET m_hor_envio = TIME
   LET m_msg = NULL
   LET m_le_param = FALSE 
   LET m_tip_envio = 'L'

   CALL pol1400_le_empresa()
   CALL pol1400_set_mensa_lembre(lr_lembrete.vencer_ate)

   CALL log085_transacao("BEGIN")

   IF NOT pol1400_le_docum_lembre() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN m_msg

END FUNCTION

#----------------------------#
 FUNCTION pol1400_le_empresa()
#----------------------------#

   SELECT den_empresa,
          den_munic,
          uni_feder
     INTO m_den_empresa,
          m_den_munic,
          m_uni_feder
     FROM empresa
    WHERE cod_empresa = m_cod_empresa
   
   IF STATUS <> 0 THEN
      LET m_den_empresa = ''
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1400_set_mensa_cob()#
#-------------------------------#
Não identificamos em nosso sistema o pagamento dos seguintes documentos vencidos: seguintes documentos dfd dd
Não identificamos em nosso sistema o pagamento dos seguintes documentos: segui fasdf fadfa daf fddd
Caso o(s) pagamento(s) tenham sido efetuado(s), solicitamos a gentileza de nos enviar o(s) comprovante(s) por e-mail.
Parâmetros padrões a serem usados em todos os clientes que não estejam cadastrad
   LET p_titulo2 = 'Não identificamos em nosso sistema o pagamento dos seguintes documentos:'
   LET p_mensa_1 = 'Caso o(s) pagamento(s) tenham sido efetuado(s), solicitamos a gentileza de nos enviar o(s) comprovante(s) por e-mail.'
   LET p_mensa_2 = 'Caso ainda estejam em aberto, favor entrar em contato para negociação do(s)  débito(s)  através dos  telefones'       
   LET p_mensa_3 = '0800-7701010/ (19) 3666.6111/ 3666.6112/ 3666.6121 ou  através  do  e-mail : sandraj@cairucp.com.br'

END FUNCTION

#----------------------------------------#
FUNCTION pol1400_set_mensa_lembre(l_dias)#
#----------------------------------------#
   
   DEFINE l_dias      VARCHAR(03)
   
   LET p_titulo2 = 'Para sua comodidade, enviamos relação do documentos a vencerem nos próximos ', l_dias, ' dias'
   LET p_mensa_1 = ''
   LET p_mensa_2 = ''       
   LET p_mensa_3 = ''

END FUNCTION

#------------------------------#
FUNCTION pol1400_le_docum_cob()#
#------------------------------#
   
   DEFINE l_dia_repete    DECIMAL(3,0)
   
   IF m_le_param THEN
      IF NOT pol1400_le_padrao() THEN
         RETURN FALSE
      END IF
      IF m_enviar_email = 'N' THEN
         RETURN TRUE
      END IF
   END IF

   LET m_email_ok = TRUE
   
   IF NOT pol1400_prepara_email() THEN
      RETURN FALSE
   END IF
   
   IF NOT m_email_ok THEN
      RETURN TRUE
   END IF   
   
   LET m_tem_docum = FALSE
   
   DECLARE cq_docum_cob CURSOR FOR
    SELECT num_docum, 
           ies_tip_docum, 
           dat_emis, 
           dat_vencto_s_desc, 
           cod_cliente,
           dat_prorrogada
      FROM docum
     WHERE cod_empresa = m_cod_empresa
       AND ies_situa_docum NOT IN ('C','E')
       AND val_saldo >= m_limite_saldo
       AND DATE(dat_vencto_s_desc) < m_dat_de
       AND DATE(dat_vencto_s_desc) >= m_dat_ate
       AND cod_cliente = m_cod_cliente
       	
   FOREACH cq_docum_cob INTO
      mr_docum.num_docum,        
      mr_docum.ies_tip_docum,    
      mr_docum.dat_emis,         
      mr_docum.dat_vencto_s_desc,
      mr_docum.cod_cliente,
      m_dat_prorrogada     
      
      IF STATUS <> 0 THEN      
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' lendo titulos da tabela docum.'
         RETURN FALSE
      END IF

      IF m_dat_prorrogada IS NOT NULL THEN
         LET mr_docum.dat_vencto_s_desc = m_dat_prorrogada
      END IF
      
      IF mr_docum.dat_vencto_s_desc > m_dat_de OR mr_docum.dat_vencto_s_desc < m_dat_ate THEN
         CONTINUE FOREACH
      END IF
      
      LET m_dat_enviado = NULL
      
      IF NOT pol1400_ve_envio() THEN
         RETURN FALSE
      END IF
      
      IF m_dat_enviado IS NOT NULL THEN
         IF m_repet_envio = 'N' THEN
            CONTINUE FOREACH
         END IF
         
         LET l_dia_repete = m_dat_envio - m_dat_enviado
         IF l_dia_repete < m_repet_env_apos THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      IF NOT pol1400_ins_docum() THEN
         RETURN FALSE
      END IF   
      
      LET m_tem_docum = TRUE
      
   END FOREACH
   
   IF m_tem_docum THEN      
      IF NOT pol1400_envia_email() THEN
         RETURN FALSE
      END IF
   ELSE
      LET m_msg = 'Cliente não possui titulos em atraso\n',
                  'ou já recebeu a cobraça recentemete.'
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1400_le_docum_lembre()#
#---------------------------------#
   
   DEFINE l_dia_repete    DECIMAL(3,0)
   
   IF m_le_param THEN
      IF NOT pol1400_le_padrao() THEN
         RETURN FALSE
      END IF
      IF m_enviar_email = 'N' THEN
         RETURN TRUE
      END IF
   END IF

   LET m_email_ok = TRUE
   
   IF NOT pol1400_prepara_email() THEN
      RETURN FALSE
   END IF
   
   IF NOT m_email_ok THEN
      RETURN TRUE
   END IF   
   
   LET m_tem_docum = FALSE
   
   DECLARE cq_docum_lembre CURSOR FOR
    SELECT num_docum, 
           ies_tip_docum, 
           dat_emis, 
           dat_vencto_s_desc, 
           cod_cliente,
           dat_prorrogada
      FROM docum
     WHERE cod_empresa = m_cod_empresa
       AND ies_situa_docum NOT IN ('C','E')
       AND DATE(dat_vencto_s_desc) >= m_dat_de
       AND DATE(dat_vencto_s_desc) <= m_dat_ate
       AND cod_cliente = m_cod_cliente
       	
   FOREACH cq_docum_lembre INTO
      mr_docum.num_docum,        
      mr_docum.ies_tip_docum,    
      mr_docum.dat_emis,         
      mr_docum.dat_vencto_s_desc,
      mr_docum.cod_cliente,
      m_dat_prorrogada     
      
      IF STATUS <> 0 THEN      
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' lendo titulos da tabela docum.'
         RETURN FALSE
      END IF

      IF m_dat_prorrogada IS NOT NULL THEN
         LET mr_docum.dat_vencto_s_desc = m_dat_prorrogada
      END IF
      
      IF mr_docum.dat_vencto_s_desc < m_dat_de OR mr_docum.dat_vencto_s_desc > m_dat_ate THEN
         CONTINUE FOREACH
      END IF
      
      LET m_dat_enviado = NULL
      
      IF NOT pol1400_ve_envio() THEN
         RETURN FALSE
      END IF
      
      IF m_dat_enviado IS NOT NULL THEN
         IF m_repet_envio = 'N' THEN
            CONTINUE FOREACH
         END IF
         
         LET l_dia_repete = m_dat_envio - m_dat_enviado
         IF l_dia_repete < m_repet_env_apos THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      IF NOT pol1400_ins_docum() THEN
         RETURN FALSE
      END IF   
      
      LET m_tem_docum = TRUE
      
   END FOREACH
   
   IF m_tem_docum THEN      
      IF NOT pol1400_envia_email() THEN
         RETURN FALSE
      END IF
   ELSE
      LET m_msg = 'Cliente não possui titulos a vencer\n',
                  'ou já recebeu o lembrete recentemete.'
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1400_le_padrao()#
#---------------------------#   

   SELECT vencidos_de,  
          vencidos_ate,    
          enviar_cobranca, 
          repetir_cobranca,
          repetir_cob_apos,
          limite_saldo,
          emitente_email    
     INTO mr_param.vencidos_de,     
          mr_param.vencidos_ate,                              
          mr_param.enviar_cobranca,                                   
          mr_param.repetir_cobranca,
          mr_param.repetir_cob_apos,
          mr_param.limite_saldo,                            
          mr_param.emitente_email
     FROM param_cobranca_912                                     
    WHERE cod_cliente = m_cod_cliente                 
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo PARAMETROS PADRÃO da tabela param_cobranca_912.'      
      RETURN FALSE                                              
   END IF  
   
   IF STATUS = 100 THEN   
      SELECT vencidos_de,               
             vencidos_ate,              
             enviar_cobranca,           
             repetir_cobranca,          
             repetir_cob_apos,          
             limite_saldo,              
             emitente_email             
        INTO mr_param.vencidos_de,      
             mr_param.vencidos_ate,                           
             mr_param.enviar_cobranca,                                
             mr_param.repetir_cobranca, 
             mr_param.repetir_cob_apos, 
             mr_param.limite_saldo,                         
             mr_param.emitente_email    
        FROM param_cobranca_912                                  
       WHERE cod_cliente IS NULL               
                                                             
      IF STATUS <> 0 AND STATUS <> 100 THEN                       
         LET m_erro = STATUS                                       
         LET m_msg = 'Erro ', m_erro CLIPPED,                      
             ' lendo PARAMETROS PADRÃO da tabela param_cobranca_912.'      
         RETURN FALSE                                              
      END IF  
      
   END IF

   LET m_dat_de = TODAY - mr_param.vencidos_de
   LET m_dat_ate = TODAY - mr_param.vencidos_ate
   LET m_enviar_email = mr_param.enviar_cobranca
   LET m_repet_envio = mr_param.repetir_cobranca
   LET m_repet_env_apos = mr_param.repetir_cob_apos
   LET m_limite_saldo = mr_param.limite_saldo
   LET m_emitente_email = mr_param.emitente_email
   LET m_dat_envio = TODAY
      
   RETURN TRUE

END FUNCTION                                               
 
#-------------------------------#
FUNCTION pol1400_prepara_email()#
#-------------------------------#
      
   IF NOT pol1400_email_de() THEN                                                   
      RETURN FALSE                                                                     
   END IF                                                                              
                                                                                    
   IF p_email_remetente IS NULL THEN                                                   
      LET m_msg = 'Email do remetente ', p_remetente, ' esta nulo no logix'            
      CALL pol1400_ins_mensagem() RETURNING p_status                                      
      LET m_email_ok = FALSE
   END IF                                                                              
                                                                                    
   IF NOT pol1400_email_para() THEN                                                    
      RETURN FALSE                                                                     
   END IF                                                                              
                                                                                       
   IF p_email_destinatario IS NULL THEN                                                
      LET m_msg = 'O cliente ', m_cod_cliente, ' não possui email cadastrado'            
      CALL pol1400_ins_mensagem() RETURNING p_status                                      
      LET m_email_ok = FALSE
   END IF                                                                              
                                                                                    
   LET p_titulo1 = 'Prezado Sr.(a): ', p_nom_destinatario CLIPPED, ' CNPJ:',m_cnpj     
                                                                                    
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1400_email_de()#
#--------------------------#

   SELECT emitente_email                                       
     INTO p_remetente                                      
     FROM param_cobranca_912                                     
    WHERE cod_cliente = m_cod_cliente
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo emitente de e-mail da tabela param_cobranca_912.'      
      RETURN FALSE                                              
   END IF      
   
   IF STATUS = 100 THEN
      LET p_remetente = NULL
   END IF
   
   IF p_remetente IS NULL THEN
      LET p_remetente = m_emitente_email                                              
   END IF

   SELECT e_mail,
          nom_funcionario
     INTO p_email_remetente,
          p_nom_remetente
     FROM usuarios
    WHERE cod_usuario = p_remetente

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo e_mail do remetente ', p_remetente CLIPPED,
          ' da tabela usuarios.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1400_email_para()#
#----------------------------#
   
   DEFINE l_grupo_email     LIKE vdp_cliente_grupo.grupo_email,
          l_email           LIKE vdp_cli_grp_email.email,
          l_email1_cliente  VARCHAR(50),
          l_email2_cliente  VARCHAR(50),
          l_email3_cliente  VARCHAR(50)
   
   SELECT nom_cliente,
          num_cgc_cpf
     INTO p_nom_destinatario,
          m_cnpj
     FROM clientes
    WHERE cod_cliente = m_cod_cliente

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo nome/cnpj do cliente ', m_cod_cliente CLIPPED,
          ' na tabela clientes.'
      RETURN FALSE
   END IF      

   SELECT email1_cliente,
          email2_cliente
          email3_cliente                            
     INTO l_email1_cliente,
          l_email2_cliente,
          l_email3_cliente
     FROM param_cobranca_912                                     
    WHERE cod_cliente = m_cod_cliente                    
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo e-mail da tabela param_cobranca_912.'      
      RETURN FALSE                                              
   END IF      
   
   IF STATUS = 100 THEN
      LET m_email_cliente = ''
   ELSE
      IF l_email1_cliente IS NOT NULL THEN
         LET m_email_cliente = m_email_cliente CLIPPED, l_email1_cliente CLIPPED,';'
      END IF
      IF l_email2_cliente IS NOT NULL THEN
         LET m_email_cliente = m_email_cliente CLIPPED, l_email2_cliente CLIPPED,';'
      END IF
      IF l_email3_cliente IS NOT NULL THEN
         LET m_email_cliente = m_email_cliente CLIPPED, l_email3_cliente CLIPPED,';'
      END IF      
   END IF
    
   DECLARE cq_grupo CURSOR FOR
    SELECT DISTINCT grupo_email 
      FROM vdp_cliente_grupo  
     WHERE tip_registro = 'C' 
       AND cliente = m_cod_cliente

   FOREACH cq_grupo INTO l_grupo_email
     
      IF STATUS <> 0 THEN                        
         LET m_erro = STATUS                                       
         LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo tabela vdp_cliente_grupo.'      
         RETURN FALSE   
      END IF      
      
      LET m_count = 0
       
      DECLARE cq_email CURSOR FOR
       SELECT email         
         FROM vdp_cli_grp_email      
        WHERE cliente = m_cod_cliente
          AND grupo_email = l_grupo_email
          AND tip_registro = 'C'
          AND email IS NOT NULL
        ORDER BY seq_email

      FOREACH cq_email INTO l_email
     
         IF STATUS <> 0 THEN                        
            LET m_erro = STATUS                                       
            LET m_msg = 'Erro ', m_erro CLIPPED,                      
               ' lendo tabela vdp_cli_grp_email.'      
            RETURN FALSE   
         END IF   
         
         IF l_email IS NOT NULL THEN
            LET m_email_cliente = m_email_cliente CLIPPED, l_email CLIPPED, ';'
         END IF
         
         LET m_count = m_count + 1
         
         IF m_count >= 3 THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      EXIT FOREACH
      
   END FOREACH
   
   LET p_email_destinatario = m_email_cliente CLIPPED
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1400_ve_envio()#
#--------------------------#
   
   SELECT MAX(dat_envio)
     INTO m_dat_enviado                                     
     FROM client_enviado_912                                
    WHERE cod_empresa = m_cod_empresa                      
      AND cod_cliente = m_cod_cliente   
      AND tip_envio = m_tip_envio                   
                                                           
   IF STATUS <> 0 THEN                   
      LET m_erro = STATUS                                  
      LET m_msg = 'Erro ', m_erro CLIPPED,                 
          ' lendo tabela client_enviado_912:dat_cobranca'   
      RETURN FALSE                                         
   END IF                                                  
      
   RETURN TRUE

END FUNCTION                             

#---------------------------#
FUNCTION pol1400_ins_docum()#
#---------------------------#   
   
   SELECT MAX(id_registro)
     INTO m_id_registro
     FROM docum_enviado_912
   
   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo tabela docum_enviado_912:max'
      RETURN FALSE
   END IF

   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1
   LET m_dias_atraso = m_dat_envio - mr_docum.dat_vencto_s_desc
   
   INSERT INTO docum_enviado_912
    VALUES(m_id_registro, 
           m_cod_empresa, 
           mr_docum.cod_cliente,
           m_emitente_email,
           mr_docum.num_docum, 
           mr_docum.dat_vencto_s_desc,
           m_dat_envio ,
           m_dias_atraso, 'N', m_tip_envio)

   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' inserindo dados na tabela docum_enviado_912'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1400_envia_email()#
#-----------------------------#
   
   DEFINE l_ret     SMALLINT,
          l_valor   CHAR(17),
          l_nota    CHAR(15),
          l_docum   CHAR(25),
          l_vencto  CHAR(22),
          l_dat_atu CHAR(19),
          l_hor_atu CHAR(08)
          
          
   LET l_dat_atu = EXTEND(CURRENT, YEAR TO DAY)
   LET l_hor_atu = EXTEND(CURRENT, HOUR TO SECOND)
   LET l_dat_atu = l_dat_atu CLIPPED,'-',l_hor_atu[1,2],l_hor_atu[4,5],l_hor_atu[7,8]
   
   CALL log150_procura_caminho("LST") RETURNING p_caminho
   
   LET p_assunto = 'Titulos em atraso'
   
   DECLARE cq_le_clientes CURSOR FOR
    SELECT DISTINCT 
           cod_cliente            
      FROM docum_enviado_912
     WHERE cod_empresa = m_cod_empresa
       AND cod_cliente = m_cod_cliente
       AND ies_enviado = 'N'
       AND tip_envio = m_tip_envio
       
   FOREACH cq_le_clientes INTO p_cod_cliente

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, ' lendo tabela docum_enviado_912:cq_le_clientes'
         RETURN FALSE
      END IF
                     
      LET p_arquivo = p_cod_cliente CLIPPED,l_dat_atu,'.lst'
      LET p_den_comando = p_caminho CLIPPED, p_arquivo CLIPPED   
               
      START REPORT pol1400_relat TO p_den_comando
      LET p_total = 0
     
      DECLARE cq_le_docs CURSOR FOR
       SELECT num_docum,
              dat_vencto
         FROM docum_enviado_912
        WHERE cod_empresa = m_cod_empresa
          AND ies_enviado = 'N'
          AND cod_cliente = p_cod_cliente
          AND tip_envio = m_tip_envio

      FOREACH cq_le_docs INTO p_num_docum, p_dat_vencto

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'Erro ', m_erro CLIPPED, 
                ' lendo titulos  da tabela titulo_cobrado_912:cq_le_docs'
            RETURN FALSE
         END IF
                  
         IF p_dat_vencto[3,3] MATCHES '[0123456789]' THEN 
            LET p_dat_vencto = p_dat_vencto[9,10],'/',p_dat_vencto[6,7],'/',p_dat_vencto[1,4]
         END IF
                  
         SELECT val_saldo,
                num_docum_origem
           INTO p_val_saldo, 
                p_num_nf
           FROM docum
          WHERE cod_empresa = m_cod_empresa
            AND num_docum = p_num_docum 
            AND cod_cliente = p_cod_cliente

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'Erro ', m_erro CLIPPED, 
                ' lendo docum origem  da tabela docum'
            RETURN FALSE
         END IF
         
         LET p_total = p_total + p_val_saldo
         
         IF p_num_nf IS NULL OR p_num_nf = ' ' THEN
            LET l_nota = '-'
         ELSE
            LET l_nota = '- NF: ', p_num_nf
         END IF
         
         LET l_docum = 'Documento: ',p_num_docum CLIPPED
         LET l_valor = 'Valor: ', p_val_saldo USING '######&.&&'
         LET l_vencto = 'Vencimento: ',p_dat_vencto

         INITIALIZE p_imp_linha TO NULL
         LET p_imp_linha[1,15] = l_nota
         LET p_imp_linha[18,42] = l_docum
         LET p_imp_linha[45,61] = l_valor
         LET p_imp_linha[65,86] = l_vencto
         
         OUTPUT TO REPORT pol1400_relat() 
      
      END FOREACH

      FINISH REPORT pol1400_relat  

      UPDATE docum_enviado_912
         SET ies_enviado = 'S'
       WHERE cod_empresa = m_cod_empresa
         AND cod_cliente = p_cod_cliente
         AND ies_enviado = 'N'
         AND tip_envio = m_tip_envio

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' atualizando registro na tabela titulo_cobrado_912'
         RETURN FALSE
      END IF
                   
   END FOREACH

   #CALL log5600_envia_email(p_email_remetente, p_email_destinatario, p_assunto, p_den_comando, 2)

   IF NOT pol1400_atu_cli_cob() THEN
      RETURN FALSE
   END IF
   
   LET m_msg = ''
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1400_atu_cli_cob()#
#-----------------------------#

   SELECT 1
     FROM client_enviado_912
    WHERE cod_empresa = m_cod_empresa
      AND cod_cliente = p_cod_cliente
      AND tip_envio = m_tip_envio
      
   IF STATUS <> 0 AND STATUS <> 100 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo a tabela client_enviado_912 '
      RETURN FALSE
   END IF

   IF STATUS = 100 THEN
      INSERT INTO client_enviado_912
       VALUES(m_cod_empresa, p_cod_cliente, m_dat_envio, m_tip_envio)
   ELSE
      UPDATE client_enviado_912 
         SET dat_envio = m_dat_envio
       WHERE cod_empresa = m_cod_empresa
         AND cod_cliente = p_cod_cliente
         AND tip_envio = m_tip_envio
   END IF
   
   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' Atualizando a tabela client_enviado_912 '
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION

#------------------------------#
FUNCTION pol1400_ins_mensagem()#
#------------------------------#
      
   INSERT INTO mensagem_envio_912
    VALUES(m_cod_empresa, p_user, m_dat_envio, m_hor_envio,  m_msg)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' inserindo registro na tabela mensagem_envio_912.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------#
 REPORT pol1400_relat()
#---------------------#
   
   DEFINE l_total CHAR(100),
          l_data  CHAR(100)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, p_titulo1
         PRINT
         PRINT COLUMN 001, p_titulo2
         PRINT

                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        
        INITIALIZE p_imp_linha TO NULL
        LET l_total = '- Total.................................... Valor: ',p_total USING '######&.&&'
        LET p_imp_linha[1,61] = l_total
        LET l_data = m_den_munic CLIPPED,'/',m_uni_feder CLIPPED,', ',TODAY
                    
        PRINT COLUMN 001, p_imp_linha
        PRINT
        PRINT
        PRINT COLUMN 001, p_mensa_1
        PRINT COLUMN 001, p_mensa_2
        PRINT COLUMN 001, p_mensa_3
        PRINT
        PRINT
        PRINT COLUMN 001, 'Atenciosamente,'
        PRINT
        PRINT
        PRINT COLUMN 001, 'Departamento de Cobrança,'
        PRINT
        PRINT COLUMN 001, m_den_empresa
        PRINT COLUMN 001, '       GROOVE e TITO' 
        PRINT COLUMN 001, l_data

        
END REPORT
   

   