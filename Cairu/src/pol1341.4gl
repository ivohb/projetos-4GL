# PROGRAMA: pol1341                                                            #
# OBJETIVO: ENVIO DE EMAIL PARA CLIENTES C/ TITULOS EM ATRASO                  #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 16/04/2018                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#
# CRE3500

{
Pe�o que seja melhorado :
1-cobran�a de  �juros e multas devidos� , segue print da tela (EXCLUIR)
(OK) 2-Ano cobran�a a partir 2017 (excluir anos anteriores)
(ok) 3- seria poss�vel dar um espa�o entre as colunas e alinhamento (melhor visualiza��o)
(OK) 4- Na frente no nome , colocar CNPJ  (do cliente)
(ok) 5- No final da carta colocar meu:  e-mail  sandraj@cairucp.com.br ,
(ok) e telefones   0800-7701010 ou 19-3666.6121, 19-3666.6111, 19-3666.6112.
(ok) 6- totalizar a coluna valor do titulo
(ok) 7- Se titulo possuir data prorrogada, considerar ela.
}
  
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003),
          g_msg                  CHAR(150)         
END GLOBALS

DEFINE m_dat_atual               CHAR(19),
       m_dat_proces              CHAR(19),
       m_msg                     CHAR(150),
       m_erro                    CHAR(10),
       m_dialog                  CHAR(10),
       m_statusbar               CHAR(10),
       m_id_registro             INTEGER,
       m_dat_cobranca            DATE,
       m_dat_agora               DATE,
       m_dat_corte               DATE,
       m_dat_prorrogada          DATE,
       m_qtd_dias_envio          DECIMAL(3,0), 
       m_qtd_dias_renvio         DECIMAL(3,0), 
       m_dias_atraso             DECIMAL(18,0),
       m_dias_compara            DECIMAL(3,0),
       m_ies_enviar              CHAR(01),
       m_emitente_email          CHAR(08),
       m_ja_cobrou               SMALLINT,
       m_count                   INTEGER,
       m_cnpj                    CHAR(20),
       m_email_cliente           CHAR(150),
       m_den_munic               CHAR(40),
       m_uni_feder               CHAR(02)

DEFINE mr_param                  RECORD
       qtd_dias_envio            DECIMAL(3,0),         
       qtd_dias_renvio           DECIMAL(3,0),         
       ies_enviar                CHAR(01),             
       emitente_email            CHAR(08)              
END RECORD                
                
DEFINE mr_docum                  RECORD
       num_docum                 CHAR(15),
       ies_tip_docum             CHAR(05),     
       dat_emis                  DATE,          
       dat_vencto_s_desc         DATE, 
       cod_cliente               CHAR(15)       
END RECORD

DEFINE p_nom_destinatario        CHAR(36),
       p_destinatario            CHAR(08),
       p_email_destinatario      CHAR(150),
       p_remetente               CHAR(08),
       p_email_remetente         CHAR(50),
       p_nom_remetente           CHAR(36),
       p_imp_linha               CHAR(86),
       p_titulo1                 CHAR(100),       
       p_titulo2                 CHAR(100),       
       p_arquivo                 CHAR(40),
       p_cod_cliente             CHAR(15),
       p_nom_cliente             CHAR(36),
       p_den_comando             CHAR(110),
       p_assunto                 CHAR(30),
       p_num_docum               CHAR(15),       
       p_dat_vencto              CHAR(10),
       p_valor                   CHAR(12),
       p_total                   DECIMAL(12,2),
       p_num_nf                  CHAR(09),
       p_val_saldo               DECIMAL(12,2),
       m_proces                  CHAR(01),
       m_limite_saldo            DECIMAL(12,2)

       
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30
   LET p_versao = "pol1341-12.00.21  "
   CALL func002_versao_prg(p_versao)

   LET g_tipo_sgbd = LOG_getCurrentDBType()

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN      
      CALL pol1341_controle()                  
   END IF
   
END MAIN

#--------------------------#
FUNCTION pol1341_controle()#
#--------------------------#
   
   DEFINE l_msg    CHAR(80)
   
   LET m_msg = 'Processo manual'
   LET m_proces = 'M'

   CALL pol1341_exibe_tela()
   
   LET l_msg = 'Tem certeza que deseja executar o \n envio das Cartas de cobran�a?' 
   
   IF NOT LOG_question(l_msg) THEN
      RETURN 
   END IF   

   IF NOT pol1341_processa() THEN
      IF m_msg IS NOT NULL THEN
         CALL pol1341_ins_mensagem() RETURNING p_status
      END IF  
   ELSE
      LET m_msg = 'Processamento efetuado com sucesso.' 
   END IF
   
   CALL log0030_mensagem(m_msg,'info')

END FUNCTION

#----------------------------#
FUNCTION pol1341_exibe_tela()#
#----------------------------#

   DEFINE l_nom_tela        CHAR(200)

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1341") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1341 AT 5,10 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   #lds CALL LOG_refresh_display()


END FUNCTION

#------------------------------#
FUNCTION pol1341_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL pol1341_exibe_tela()

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF
         
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
   
   LET m_msg = 'Processo autom�tico'   
   LET m_proces = 'A'
   LET p_cod_cliente = NULL
   
   IF NOT pol1341_processa() THEN
      IF m_msg IS NOT NULL THEN
         CALL pol1341_ins_mensagem() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1341_processa()#
#--------------------------#

   LET m_dat_atual = CURRENT

   IF NOT pol1341_ins_mensagem() THEN
      RETURN FALSE
   END IF

   IF NOT pol1341_checa_proces() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1341_atu_proces('S') THEN
      RETURN FALSE
   END IF
   
   CALL pol1341_executa() RETURNING p_status
   
   LET m_dat_atual = CURRENT
   
   IF NOT pol1341_atu_proces('N') THEN
      RETURN FALSE
   END IF
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   LET m_msg = 'Processamento efetuado com sucesso.'
   
   IF NOT pol1341_ins_mensagem() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION      

#------------------------------#
FUNCTION pol1341_ins_mensagem()#
#------------------------------#

   INSERT INTO mensagem_pol1341
    VALUES(p_cod_empresa, p_user, m_dat_atual, m_msg)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' inserindo registro na tabela mensagem_pol1341.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION pol1341_checa_proces()#
#------------------------------#

   DEFINE l_procesando      CHAR(01)
      
   SELECT processando,
          dat_proces
     INTO l_procesando,
          m_dat_proces
     FROM proces_pol1341
    WHERE empresa = p_cod_empresa
   
   IF STATUS = 100 THEN

      INSERT INTO proces_pol1341
       VALUES(p_cod_empresa, 'N', m_dat_atual)

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' inserindo registro na tabela proces_pol1341.'
         RETURN FALSE
      END IF
      
   ELSE
   
      IF STATUS <> 0 THEN
      
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' lendo registro da tabela proces_pol1341.'
         RETURN FALSE
      
      ELSE  
             
         IF l_procesando = 'S' AND pol1341_retornar() THEN
            LET m_msg = 'O POL1341 est� em execu��o no momento'
            RETURN FALSE
         END IF            
      
      END IF
      
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1341_retornar()#
#--------------------------#

   DEFINE l_dat_atu          DATE,
          l_hor_atu          CHAR(08),
          l_temp_atu         INTEGER,
          l_temp_tab         INTEGER,
          l_temp_dif         INTEGER,
          l_hora             INTEGER,
          l_minuto           INTEGER,
          l_segundo          INTEGER
   
   LET l_dat_atu = TODAY
   LET l_hor_atu = TIME

   LET l_hora = l_hor_atu[1,2]
   LET l_minuto = l_hor_atu[4,5]
   LET l_segundo = l_hor_atu[7,8]
   LET l_temp_atu = (l_hora * 3600) + (l_minuto * 60) + l_segundo

   LET l_hora = m_dat_proces[12,13]
   LET l_minuto = m_dat_proces[15,16]
   LET l_segundo = m_dat_proces[18,19]
   LET l_temp_tab = (l_hora * 3600) + (l_minuto * 60) + l_segundo
   
   IF l_temp_atu < l_temp_tab THEN
      LET l_temp_atu = l_temp_atu + 86400
   END IF
   
   LET l_temp_dif = l_temp_atu - l_temp_tab
   
   IF l_temp_dif > 3600 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------------#
FUNCTION pol1341_atu_proces(l_proces)#
#------------------------------------#

   DEFINE l_proces    CHAR(01)
   
   UPDATE proces_pol1341
      SET processando = l_proces,
          dat_proces = m_dat_atual
    WHERE empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' atualizando registro na tabela proces_pol1341: ', l_proces
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1341_executa()#
#-------------------------#

   DEFINE l_progres     SMALLINT,
          l_ind         INTEGER

   IF NOT pol1341_le_padrao() THEN
      RETURN FALSE
   END IF

   DELETE FROM titulo_cobrado_912 
    WHERE cod_empresa = p_cod_empresa
      AND ies_enviado = 'N'

   LET m_dat_agora = TODAY  
   LET m_dat_corte = '01/12/2019'   #a pedido da Sandra      

   DECLARE cq_docum CURSOR FOR
    SELECT num_docum, 
           ies_tip_docum, 
           dat_emis, 
           dat_vencto_s_desc, 
           cod_cliente,
           dat_prorrogada
      FROM docum
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa_docum NOT IN ('C','E')
       AND val_saldo >= m_limite_saldo
       AND DATE(dat_vencto_s_desc) < m_dat_agora
       AND DATE(dat_vencto_s_desc) >= m_dat_corte

   FOREACH cq_docum INTO
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
   
      DISPLAY mr_docum.cod_cliente TO cod_cliente
      DISPLAY mr_docum.num_docum TO num_docum
      #lds CALL LOG_refresh_display()

      IF NOT pol1341_le_param_cli() THEN
         RETURN FALSE
      END IF
      
      IF m_ies_enviar = 'N' THEN
         CONTINUE FOREACH
      END IF

      LET m_ja_cobrou = FALSE
      
      IF NOT pol1341_le_envio() THEN
         RETURN FALSE
      END IF
      
      IF m_ja_cobrou THEN
         CONTINUE FOREACH
      END IF
            
      IF m_dat_prorrogada IS NOT NULL THEN
         LET mr_docum.dat_vencto_s_desc = m_dat_prorrogada
      END IF
      
      IF mr_docum.dat_vencto_s_desc >= m_dat_agora THEN
         CONTINUE FOREACH
      END IF
         
      LET m_dias_atraso = m_dat_agora - mr_docum.dat_vencto_s_desc
      
      IF m_dias_atraso < m_qtd_dias_envio THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1341_ins_docum() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   SELECT COUNT(*)
     INTO m_count
     FROM titulo_cobrado_912
    WHERE cod_empresa = p_cod_empresa
      AND ies_enviado = 'N'
      
   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' contando titulos a cobrar na tabela titulo_cobrado_912 '
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'N�o h� titulos a cobrar '
      IF m_proces = 'M' THEN
         CALL log0030_mensagem(m_msg,'info')
      END IF
      RETURN FALSE
   END IF

   IF NOT pol1341_envia_email() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1341_le_padrao()#
#---------------------------#   

   SELECT qtd_dias_envio,                                    
          qtd_dias_renvio,                                      
          ies_enviar,                                           
          emitente_email,
          limite_saldo                                       
     INTO mr_param.qtd_dias_envio,                                     
          mr_param.qtd_dias_renvio,                                    
          mr_param.ies_enviar,                                         
          mr_param.emitente_email,
          m_limite_saldo                                    
     FROM cliente_email_912                                     
    WHERE cod_cliente IS NULL                  
                                                             
   IF STATUS <> 0 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo PARAMETROS PADR�O da tabela cliente_email_912.'      
      RETURN FALSE                                              
   END IF  
   
   IF m_limite_saldo IS NULL OR m_limite_saldo < 0 THEN
      LET m_limite_saldo = 0
   END IF         
   
   RETURN TRUE

END FUNCTION                                               

#------------------------------#
FUNCTION pol1341_le_param_cli()#
#------------------------------#   

   SELECT qtd_dias_envio,                                    
          qtd_dias_renvio,                                      
          ies_enviar,                                           
          emitente_email
     INTO m_qtd_dias_envio,                                     
          m_qtd_dias_renvio,                                    
          m_ies_enviar,                                         
          m_emitente_email
     FROM cliente_email_912                                     
    WHERE cod_cliente = mr_docum.cod_cliente                    
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo PARAMETROS da tabela cliente_email_912.'      
      RETURN FALSE                                              
   END IF                                                       
                                                                
   IF STATUS = 100 THEN                                         
      LET m_qtd_dias_envio  =  mr_param.qtd_dias_envio 
      LET m_qtd_dias_renvio =  mr_param.qtd_dias_renvio
      LET m_ies_enviar      =  mr_param.ies_enviar     
      LET m_emitente_email  =  mr_param.emitente_email  
   END IF
   
   RETURN TRUE                                       

END FUNCTION

#--------------------------#
FUNCTION pol1341_le_envio()#
#--------------------------#   
   
   DEFINE l_dias_da_cobranca INTEGER
   
   SELECT dat_cobranca
     INTO m_dat_cobranca
     FROM cliente_cobrado_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_docum.cod_cliente
      
   IF STATUS <> 0 AND STATUS <> 100 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo data de cobranca da tabela cliente_cobrado_912 '
      RETURN FALSE
   END IF
   
   IF STATUS = 100 THEN
      LET m_dat_cobranca = NULL
   END IF
   
   IF m_dat_cobranca IS NOT NULL THEN
      LET l_dias_da_cobranca = m_dat_agora - m_dat_cobranca
      IF l_dias_da_cobranca <= m_qtd_dias_renvio THEN
         LET m_ja_cobrou = TRUE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1341_ins_docum()#
#---------------------------#   
   
   SELECT MAX(id_registro)
     INTO m_id_registro
     FROM titulo_cobrado_912
   
   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo tabela titulo_cobrado_912:max'
      RETURN FALSE
   END IF

   IF m_id_registro IS NULL THEN
      LET m_id_registro = 0
   END IF
   
   LET m_id_registro = m_id_registro + 1
   LET m_dat_cobranca = TODAY
   
   INSERT INTO titulo_cobrado_912
    VALUES(m_id_registro, 
           p_cod_empresa, 
           mr_docum.cod_cliente,
           m_emitente_email,
           mr_docum.num_docum, 
           mr_docum.dat_vencto_s_desc,
           m_dat_cobranca ,
           m_dat_agora, 
           m_dias_atraso, 'N')

   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' inserindo dados na tabela titulo_cobrado_912'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1341_envia_email()#
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
   
   CALL pol1341_le_empresa()

   CALL log150_procura_caminho("LST") RETURNING p_caminho
   
   LET p_assunto = 'Titulos em atraso'
   
   DECLARE cq_le_clientes CURSOR FOR
    SELECT DISTINCT 
           cod_cliente            
      FROM titulo_cobrado_912
     WHERE cod_empresa = p_cod_empresa
       AND ies_enviado = 'N'
       
   FOREACH cq_le_clientes INTO p_cod_cliente 

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' lendo cliente ', p_cod_cliente CLIPPED,
             ' da tabela titulo_cobrado_912.'
         RETURN FALSE
      END IF
            
      IF NOT pol1341_email_de() THEN
         RETURN FALSE
      END IF

      IF p_email_remetente IS NULL THEN
         LET m_msg = 'Email do remetente ', p_remetente, ' esta nulo no logix'
         CALL pol1341_ins_mensagem() RETURNING l_ret
         CONTINUE FOREACH
      END IF

      IF NOT pol1341_email_para() THEN
         RETURN FALSE
      END IF
      
      IF p_email_destinatario IS NULL THEN
         LET m_msg = 'Email do cliente ', p_cod_cliente, ' esta nulo no logix'
         CALL pol1341_ins_mensagem() RETURNING l_ret
         LET p_email_destinatario = 'sandraj@cairucp.com.br'
      END IF

      LET p_titulo1 = 'Prezado Sr.(a): ', p_nom_destinatario CLIPPED, ' CNPJ:',m_cnpj
      LET p_titulo2 = 'N�o identificamos em nosso sistema o pagamento dos seguintes documentos:'
         
      LET p_arquivo = p_cod_cliente CLIPPED,l_dat_atu,'.lst'
      LET p_den_comando = p_caminho CLIPPED, p_arquivo CLIPPED   
               
      START REPORT pol1341_relat TO p_den_comando
      LET p_total = 0
     
      DECLARE cq_le_docs CURSOR FOR
       SELECT num_docum,
              dat_vencto
         FROM titulo_cobrado_912
        WHERE cod_empresa = p_cod_empresa
          AND ies_enviado = 'N'
          AND cod_cliente = p_cod_cliente

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
         
         DISPLAY p_cod_cliente TO cod_cliente
         DISPLAY p_num_docum TO num_docum
         #lds CALL LOG_refresh_display()
         
         SELECT val_saldo,
                num_docum_origem
           INTO p_val_saldo, 
                p_num_nf
           FROM docum
          WHERE cod_empresa = p_cod_empresa
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
         
         OUTPUT TO REPORT pol1341_relat() 
      
      END FOREACH

      FINISH REPORT pol1341_relat  

      UPDATE titulo_cobrado_912 SET ies_enviado = 'S'
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente = p_cod_cliente
         AND ies_enviado = 'N'

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, 
             ' atualizando registro na tabela titulo_cobrado_912'
         RETURN FALSE
      END IF
      
      LET m_msg = p_email_destinatario CLIPPED,'-',
            p_cod_cliente CLIPPED,'-',p_nom_destinatario CLIPPED
      CALL pol1341_ins_mensagem() RETURNING l_ret
      
      #CALL log5600_envia_email(p_email_remetente, p_email_destinatario, p_assunto, p_den_comando, 2)

      IF NOT pol1341_atu_cliente() THEN
         RETURN FALSE
      END IF
       
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1341_atu_cliente()#
#-----------------------------#

   SELECT 1
     FROM cliente_cobrado_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = p_cod_cliente
      
   IF STATUS <> 0 AND STATUS <> 100 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo a tabela cliente_cobrado_912 '
      RETURN FALSE
   END IF

   IF STATUS = 100 THEN
      INSERT INTO cliente_cobrado_912
       VALUES(p_cod_empresa, p_cod_cliente, m_dat_agora)
   ELSE
      UPDATE cliente_cobrado_912 
         SET dat_cobranca = m_dat_agora
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente = p_cod_cliente
   END IF
   
   IF STATUS <> 0 THEN      
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' Atualizando a tabela cliente_cobrado_912 '
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION

#---------------------#
 REPORT pol1341_relat()
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
        PRINT COLUMN 001, 'Caso o(s) pagamento(s) tenham sido efetuado(s), solicitamos a gentileza de nos enviar o(s) comprovante(s) por e-mail.'
        PRINT COLUMN 001, 'Caso ainda estejam em aberto, favor entrar em contato para negocia��o do(s)  d�bito(s)  atrav�s dos  telefones'       
        PRINT COLUMN 001, '0800-7701010/ (19) 3666.6111/ 3666.6112/ 3666.6121 ou  atrav�s  do  e-mail : sandraj@cairucp.com.br'
        PRINT
        PRINT
        PRINT COLUMN 001, 'Atenciosamente,'
        PRINT
        PRINT
        PRINT COLUMN 001, 'Departamento de Cobran�a,'
        PRINT
        PRINT COLUMN 001, p_den_empresa
        PRINT COLUMN 001, '       GROOVE e TITO' 
        PRINT COLUMN 001, l_data

        
END REPORT
   

#----------------------------#
 FUNCTION pol1341_le_empresa()
#----------------------------#

   SELECT den_empresa,
          den_munic,
          uni_feder
     INTO p_den_empresa,
          m_den_munic,
          m_uni_feder
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_den_empresa = 'CAIRU PMA COMPONENTES P/BIC LTDA'
   END IF
   
END FUNCTION
 
#--------------------------#
FUNCTION pol1341_email_de()#
#--------------------------#

   SELECT emitente_email                                       
     INTO p_remetente                                      
     FROM cliente_email_912                                     
    WHERE cod_cliente = p_cod_cliente                    
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo emitente de e-mail da tabela cliente_email_912.'      
      RETURN FALSE                                              
   END IF      
   
   IF STATUS = 100 THEN
      LET p_remetente = NULL
   END IF
   
   IF p_remetente IS NULL THEN
      LET p_remetente = mr_param.emitente_email                                              
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
FUNCTION pol1341_email_para()#
#----------------------------#
   
   DEFINE l_grupo_email     LIKE vdp_cliente_grupo.grupo_email,
          l_email           LIKE vdp_cli_grp_email.email
   
   SELECT nom_cliente,
          num_cgc_cpf
     INTO p_nom_destinatario,
          m_cnpj
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, 
          ' lendo nome/cnpj do cliente ', p_cod_cliente CLIPPED,
          ' na tabela clientes.'
      RETURN FALSE
   END IF      

   SELECT email_cliente                                       
     INTO m_email_cliente                                      
     FROM cliente_email_912                                     
    WHERE cod_cliente = p_cod_cliente                    
                                                             
   IF STATUS <> 0 AND STATUS <> 100 THEN                        
      LET m_erro = STATUS                                       
      LET m_msg = 'Erro ', m_erro CLIPPED,                      
          ' lendo e-mail da tabela cliente_email_912.'      
      RETURN FALSE                                              
   END IF      
   
   IF STATUS = 100 THEN
      LET m_email_cliente = NULL
   END IF
    
   DECLARE cq_grupo CURSOR FOR
    SELECT DISTINCT grupo_email 
      FROM vdp_cliente_grupo  
     WHERE tip_registro = 'C' 
       AND cliente = p_cod_cliente

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
        WHERE cliente = p_cod_cliente
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
         
         IF m_email_cliente IS NULL THEN
            LET m_email_cliente = l_email
         ELSE
            LET m_email_cliente = m_email_cliente CLIPPED, ';',l_email
         END IF
         
         LET m_count = m_count + 1
         
         IF m_count >= 6 THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      EXIT FOREACH
      
   END FOREACH
   
   LET p_email_destinatario = m_email_cliente CLIPPED
   
   RETURN TRUE

END FUNCTION

   
   