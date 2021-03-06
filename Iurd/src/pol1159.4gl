#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1159                                                 #
# OBJETIVO: GERA��O DA GRADE DE APROVACAO P/ NFE                    #
#                                                                   #
# PROCEDIMENTO: LE NFE SEM PEDIDO DE COMPRA E SETA O CAMPO          #
#           NF_SUP.IES_INCL_CAP COM X, P/ EVITAR QUE A NF SEJA      #
#           INTEGRADA COM O CAP. QUANDO A NF FOR LIBERADA, ESSE     #
#           CAMPO RECEBER� DE VOLTA SEU COMTE�DO ORIGINAL. A NF     #
#           LIDA E MARCADA SER� INSERIDA NA TABELA NFE_APROV_265    #
#           O PROGRAMA TAMB�M GERA A GRADE DE APROVA��O DA NFE, A   #
#           PARTIR DA UNIDADE FUNCIONAL DA PRIMEIRA SEQUENCIA DO AR #
#           GRAVADO NA TABELA DEST_AVISO_REC CAMPO COD_SECAO_RECEB  #
#                                                                   #
# AUTOR...: IVO HB BL                                               #
# DATA....: 09/08/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_user           LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_ver_prog           CHAR(09),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_caminho_jar        CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_texto              CHAR(10),
          p_linha              CHAR(30),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT

   DEFINE p_num_ar             INTEGER,
          p_dat_ini_process    DATETIME YEAR TO DAY,
          p_hor_ini_process    DATETIME HOUR TO SECOND,
          p_erro               CHAR(10),
          p_unid_funcional     CHAR(10),
          p_ies_incl_cap       CHAR(01),
          p_hor_inclusao       CHAR(08),
          p_dat_inclusao       DATE,
          p_ies_nf_aguard_nfe  CHAR(01),
          p_user_de            CHAR(08),
          p_user_para          CHAR(08),
          p_den_user           CHAR(40),
          p_den_email          CHAR(40),
          p_email_emit         CHAR(40),
          p_imp_linha          CHAR(80),
          p_titulo             CHAR(40),
          p_nome_de            CHAR(40),
          p_nome_para          CHAR(40),
          p_cod_uni_funcio     CHAR(15),
          p_despresa           SMALLINT

   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD

   DEFINE pr_erro              ARRAY[3000] OF RECORD  
          cod_empresa          CHAR(02),
          num_aviso_rec        INTEGER,
          den_erro             CHAR(76)
   END RECORD

END GLOBALS

DEFINE p_parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
END RECORD

DEFINE m_cod_empresa  CHAR(02), 
       m_num_ar       INTEGER
  
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   LET p_versao = "pol1159-10.02.53"
   LET p_ver_prog = "10.02.53"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   #CALL log001_acessa_usuario("ESPEC999","")
   #   RETURNING p_status, p_cod_empresa, p_user
   
   LET p_status = 0
   LET p_cod_empresa = '25'
   LET p_user = 'admvic'

   LET p_parametro.num_programa = 'POL1159'
   LET p_parametro.usuario = 'pol1159'
   
   IF p_status = 0 THEN
      CALL pol1159_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1159_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa = '25' #l_param1_empresa
   LET p_user = 'admvic'  #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1159_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1159_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1159") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1159 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET pr_men[1].mensagem = 'LENDO VERSAO DO PROGRAMA'
   CALL pol1159_exib_mensagem()

   CALL pol1159_le_versao() 

   SELECT parametro_texto
     INTO p_email_emit
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'E-MAIL DO EMITENTE'
   
   IF STATUS <> 0 THEN
      LET p_email_emit = 'naoresponda@universal.org.br'
   END IF

   #IF NOT pol1159_checa_proces() THEN
   #   LET p_houve_erro = TRUE
   #   RETURN
   #END IF

   DELETE FROM integ_cos_logix a where a.num_nf
     IN ( SELECT b.num_nf FROM integ_cos_logix b
     WHERE a.num_nf=b.num_nf
       AND a.ser_nf=b.ser_nf
       AND a.ssr_nf=b.ssr_nf 
       AND a.cod_fornecedor=b.cod_fornecedor  
       AND b.cod_empresa='ZZ')       
       AND a.cod_empresa<>'ZZ'
      
   CALL log085_transacao("BEGIN")

   IF NOT pol1159_processa() THEN
      CALL log085_transacao("ROLLBACK")
      LET pr_men[1].mensagem = 'PROCESSAMENTO COM ERRO. CONSULTE TABELA ERRO_POL1159_265'
      LET p_houve_erro = TRUE
   ELSE
      CALL log085_transacao("COMMIT")
      LET pr_men[1].mensagem = 'PROCESSAMENTO EFETUADO C/ SUCESSO'
      LET p_houve_erro = FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1159_del_grade() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   DECLARE cq_corrige CURSOR FOR
    SELECT cod_empresa, num_aviso_rec
      FROM nf_sup a  
     WHERE a.ies_incl_cap='N' 
       AND a.num_aviso_rec IN (
           SELECT b.num_aviso_rec 
             FROM aprov_ar_265 b 
            WHERE a.cod_empresa = b.cod_empresa 
              AND a.num_aviso_rec = b.num_aviso_rec
              AND b.dat_aprovacao IS NULL )
   FOREACH cq_corrige INTO p_cod_empresa, p_num_ar

      IF STATUS <> 0 THEN   
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR cq_corrige'
         LET p_num_ar = NULL
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
      UPDATE nf_sup
         SET ies_incl_cap = 'X'
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_num_ar
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA NF_SUP COM X'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
   END FOREACH

   DELETE FROM integ_cos_logix a where a.num_nf
     IN ( SELECT b.num_nf FROM integ_cos_logix b
     WHERE a.num_nf=b.num_nf
       AND a.ser_nf=b.ser_nf
       AND a.ssr_nf=b.ssr_nf 
       AND a.cod_fornecedor=b.cod_fornecedor  
       AND b.cod_empresa='ZZ')       
       AND a.cod_empresa<>'ZZ'

   CALL pol1159_grava_erro()
   
   CALL pol1159_exib_mensagem()
      
END FUNCTION

#------------------------------#
FUNCTION pol1159_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#---------------------------#
FUNCTION pol1159_le_versao()#
#---------------------------#
   
   DEFINE p_num_versao    CHAR(09),
          p_dat_alteracao DATE

   LET p_dat_alteracao = TODAY
   
   SELECT num_versao
     INTO p_num_versao
     FROM log_versao_prg
    WHERE num_programa = 'POL1159'

   IF STATUS = 100 THEN
      LET p_num_versao = p_ver_prog
      INSERT INTO log_versao_prg(
         num_programa,
         num_versao,
         dat_alteracao)
      VALUES('POL1159',p_ver_prog,p_dat_alteracao)
   ELSE
      IF STATUS = 0 THEN
         UPDATE log_versao_prg
            SET num_versao = p_ver_prog,
                dat_alteracao = p_dat_alteracao
          WHERE num_programa = 'POL1159'
      END IF
   END IF

   LET pr_men[1].mensagem = 'VERSAO DO PROGRAMA: POL1159-', p_num_versao
   CALL pol1159_exib_mensagem()

END FUNCTION
      
#------------------------------#
FUNCTION pol1159_checa_proces()#
#------------------------------#

   DEFINE	p_hor_atu              DATETIME HOUR TO SECOND,
          p_hor_proces           CHAR(08),
          p_h_m_s                CHAR(10),
          p_qtd_segundo          INTEGER,
          p_data                 DATETIME YEAR TO DAY,
          p_hora                 DATETIME HOUR TO SECOND,
          p_processa             SMALLINT,
          p_encontrou            SMALLINT,
          p_hh                   INTEGER,
          p_mm                   INTEGER,
          p_ss                   INTEGER,
          p_hoje                 DATE

   LET p_processa = FALSE
   LET p_encontrou = FALSE
   LET p_hor_atu = CURRENT HOUR TO SECOND
   
   DECLARE cq_audit CURSOR FOR
    SELECT data,
           hora
      FROM audit_logix
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = 'pol1159'
     ORDER BY data desc, hora DESC

   FOREACH cq_audit INTO p_data, p_hora
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_audit')
         RETURN FALSE
      END IF

      LET p_encontrou = TRUE

  
      IF p_hora > p_hor_atu THEN
         LET p_h_m_s = '24:00:00' - (p_hora - p_hor_atu)
      ELSE
         LET p_h_m_s = (p_hor_atu - p_hora)
      END IF
   
      LET p_hor_proces = p_h_m_s[2,9]
   
      LET p_hh = p_hor_proces[1,2]
      LET p_mm = p_hor_proces[4,5]
      LET p_ss = p_hor_proces[7,8]
      
      LET p_qtd_segundo = (p_hh * 3600) + (p_mm * 60) + p_ss
         
      IF p_qtd_segundo > 60 THEN
         LET p_processa = TRUE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   IF p_encontrou THEN
      IF NOT p_processa THEN
         RETURN FALSE
      END IF
   END IF 

   LET p_msg = 'GERA��O DA GRADE DE APROVACAO P/ NFE'
   
   LET p_hoje = TODAY
   LET p_hor_proces = p_hor_atu
   
   INSERT INTO audit_logix
    VALUES(p_cod_empresa,
           p_msg,
           'pol1159',
           p_hoje,
           p_hor_proces,
           p_user)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_logix')
      RETURN FALSE
   END IF
   
   LET p_dat_ini_process = p_hoje
   LET p_hor_ini_process = p_hor_proces
   LET p_dat_inclusao = p_hoje
   LET p_hor_inclusao = p_hor_proces
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1159_guarda_erro()#
#-----------------------------#

   LET p_ind = p_ind + 1
   LET pr_erro[p_ind].cod_empresa = p_cod_empresa
   LET pr_erro[p_ind].num_aviso_rec = p_num_ar
   LET pr_erro[p_ind].den_erro = p_msg

END FUNCTION   

#----------------------------#
FUNCTION pol1159_grava_erro()#
#----------------------------#

   FOR p_index = 1 to p_ind
     
     IF pr_erro[p_index].cod_empresa IS NOT NULL THEN
        INSERT INTO erro_pol1159_265
         VALUES(pr_erro[p_index].cod_empresa,
                pr_erro[p_index].num_aviso_rec,
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
FUNCTION pol1159_processa()#
#--------------------------#
   
   DEFINE p_dat_entrada DATE,
          p_cod_secao_receb CHAR(10)
   
   LET p_num_ar = NULL
   LOCK TABLE erro_pol1159_265 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' BLOQUEANDO TABELA ERRO_POL1159_265'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF

   IF NOT pol1159_cria_temp() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE pr_erro TO NULL
   LET p_ind = 0
   LET p_dat_entrada =  '10/10/2012'
   
   DECLARE cq_proces CURSOR FOR
    SELECT DISTINCT a.num_aviso_rec, a.cod_empresa, 
                    b.ies_incl_cap, b.ies_nf_aguard_nfe 
      FROM aviso_rec a, nf_sup b, empresa_proces_265 c  
     WHERE (a.num_pedido IS NULL OR a.num_pedido = 0)
       AND b.cod_empresa = c.cod_empresa
       AND b.dat_entrada_nf >= c.dat_corte
       AND b.ies_especie_nf in ('NF', 'NFS', 'REC', 'NFE', 'DOC', 'NFM', 'CON', 'NFF')
       AND b.cod_empresa = a.cod_empresa 
       AND b.num_aviso_rec = a.num_aviso_rec 
       AND b.ies_incl_cap IN ('N','X')
       AND a.num_aviso_rec NOT IN
           (SELECT c.num_aviso_rec FROM nfe_aprov_265 c
             WHERE c.cod_empresa = a.cod_empresa
               AND c.num_aviso_rec = a.num_aviso_rec)
       AND b.cnd_pgto_nf NOT IN 
           (SELECT cnd_pgto FROM cond_pgto_cap WHERE ies_pagamento = '3')
        
   FOREACH cq_proces INTO 
           p_num_ar, p_cod_empresa, p_ies_incl_cap, p_ies_nf_aguard_nfe
       
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_PROCES'
         LET p_num_ar = NULL
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
      SELECT num_nf FROM gi_ad_912
       WHERE cod_empresa = p_cod_empresa
         AND num_ar = p_num_ar

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_PROCES'
            LET p_num_ar = NULL
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF
      END IF
      
      DELETE FROM erro_pol1159_265
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_num_ar

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' DELETANDO AR ', p_num_ar, ' DA ERRO_POL1159_265'
         CALL pol1159_guarda_erro() 
      END IF
      
      INITIALIZE p_unid_funcional TO NULL

      DECLARE cq_dest CURSOR FOR
       SELECT parametro_texto 
         FROM sup_par_ar 
        WHERE empresa = p_cod_empresa
          AND aviso_recebto = p_num_ar
          AND seq_aviso_recebto = 0 
          AND parametro = 'secao_resp_aprov'
     
      FOREACH cq_dest INTO p_cod_secao_receb

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA DEST_AVISO_REC:CQ_DEST'
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF
         
         LET p_unid_funcional = p_cod_secao_receb
         EXIT FOREACH
      
      END FOREACH                     
      
      IF p_unid_funcional IS NULL OR p_unid_funcional = ' ' THEN
         LET p_erro = p_num_ar
         LET p_msg = 'AR ',p_erro CLIPPED, ' SEM UNIDADE FUNCIONAL NA TABELA DEST_AVISO_REC'
         CALL pol1159_guarda_erro() 
         IF NOT pol1159_atualiza_nf_sup('X') THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF

      SELECT cod_uni_funcio
        FROM unid_isenta_265
       WHERE empresa = p_cod_empresa
         AND cod_uni_funcio = p_unid_funcional

      IF STATUS = 0 THEN
         IF NOT pol1159_atualiza_nf_sup('N') THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA UNID_ISENTA_265'
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1159_atualiza_nf_sup('X') THEN
         RETURN FALSE
      END IF
         
      LET p_count = 0     
     
      IF NOT pol1159_insere_grade() THEN
         RETURN FALSE
      END IF

      IF p_count = 0 THEN
         LET p_msg = 'UNID FUNCIONAL ',p_unid_funcional CLIPPED, 
                     ' SEM APROVANTES - CONSULTE OS PROGS: POL1163/POL1164/POL1165'
         CALL pol1159_guarda_erro() 
         CONTINUE FOREACH
      END IF

      IF NOT pol1159_ins_ctrl_leitura() THEN
         RETURN FALSE
      END IF
     
   END FOREACH

   CALL pol1159_envia_email() RETURNING p_status
   CURRENT WINDOW IS w_pol1159
    
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1159_insere_grade()#
#------------------------------#

   DEFINE p_cod_niv_autorid CHAR(02),
          p_hierarquia      INTEGER,
          p_env_email       SMALLINT

   LET p_env_email = FALSE     
   
   DECLARE cq_niv_aut CURSOR FOR
    SELECT a.nivel_autoridade, 
           a.hierarquia, 
           b.nom_usuario
      FROM nivel_hierarq_265 a,               # sup_niv_autorid_complementar
           nivel_usuario_265 b,               # usuario_nivel_aut
           unid_aprov_265 c
     WHERE c.cod_empresa = p_cod_empresa
       AND c.cod_uni_funcio = p_unid_funcional
       AND b.cod_empresa = c.cod_empresa
       AND b.ies_versao_atual = 'S'
       AND b.nom_usuario = c.nom_usuario
       AND a.empresa = b.cod_empresa
       AND a.nivel_autoridade = b.cod_nivel_autorid
     ORDER BY a.hierarquia DESC

   FOREACH cq_niv_aut INTO p_cod_niv_autorid, p_hierarquia, p_user_para
   
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_NIV_AUT'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF

      LET p_count = p_count + 1
      
      SELECT cod_empresa
        FROM aprov_ar_265
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_num_ar
         AND hierarquia = p_hierarquia
         AND cod_nivel_autorid = p_cod_niv_autorid
      
      IF STATUS = 100 THEN
         INSERT INTO aprov_ar_265(
           cod_empresa,
           num_aviso_rec,
           hierarquia,
           cod_nivel_autorid,
           usuario_inclusao,
           dat_inclusao,
           hor_inclusao)      
          VALUES(p_cod_empresa,
                 p_num_ar,
                 p_hierarquia,
                 p_cod_niv_autorid,
                 p_user,
                 p_dat_inclusao,
                 p_hor_inclusao)
   
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO NA TABELA APROV_AR_265'
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO DADOS DA TABELA APROV_AR_265'
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF
      END IF
      
      IF NOT p_env_email THEN
         LET p_env_email = TRUE
         IF NOT pol1159_ins_email_temp() THEN 
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH       

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1159_ins_email_temp()#
#--------------------------------#
   
   DEFINE p_usuario  CHAR(08),
          p_email_de CHAR(40)
{   
   LET p_user_de = NULL
   
   DECLARE cq_audit CURSOR FOR
    SELECT nom_usuario  
      FROM audit_ar
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_num_ar
       AND ies_tipo_auditoria = '1'
       AND num_seq = 0
   
   FOREACH cq_audit INTO p_usuario

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO USUARIO EMITENTE DA NOTA'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
      LET p_user_de = p_usuario
      EXIT FOREACH
   
   END FOREACH
   
   IF p_user_de IS NULL THEN
      LET p_msg = 'NAO FOI POSSIVEL LER USUARIO EMITENTE DA NOTA'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF
   
   CALL pol1159_le_usuario(p_user_de) 
   LET p_email_de = p_den_email
   LET p_nome_de  = p_den_user
}
   LET p_user_de  = "pol1159"
   LET p_email_de = p_email_emit
   LET p_nome_de  = "Aprovacao de AR"

   CALL pol1159_le_usuario(p_user_para) 

   INSERT INTO email_temp_265 (
	    num_docum,   
	    cod_empresa,   
	    cod_usuario,   
	    email_usuario, 
	    nom_usuario,   
	    cod_emitente,  
	    email_emitente,
	    nom_emitente)  
   VALUES(p_num_ar,
          p_cod_empresa,
          p_user_para,
          p_den_email,
          p_den_user,
          p_user_de,
          p_email_de,
          p_nome_de)
                
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO USUARIO PARA ENVIO DE EMAIL'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#------------------------------------#
FUNCTION pol1159_le_usuario(p_codido)#
#------------------------------------#

   DEFINE p_codido CHAR(08)

   SELECT e_mail,
          nom_funcionario
     INTO p_den_email,
          p_den_user
     FROM usuarios
    WHERE cod_usuario = p_codido

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO EMAIL DO USUARIO ', p_codido
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF

END FUNCTION        
   
#---------------------------#
FUNCTION pol1159_cria_temp()#
#---------------------------# 
  
   DROP TABLE email_temp_265
   
   CREATE TEMP TABLE email_temp_265(
	    num_docum      CHAR(10),
	    cod_empresa    CHAR(02),
	    cod_usuario    CHAR(10),
	    email_usuario  CHAR(50),
	    nom_usuario    CHAR(50),
	    cod_emitente   CHAR(10),
	    email_emitente CHAR(50),
	    nom_emitente   CHAR(50)
	 )

	 IF STATUS <> 0 THEN 
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' CRIANDO TABELA EMAIL_TEMP_265'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION   

#-----------------------------------------------#
FUNCTION pol1159_atualiza_nf_sup(p_ies_incl_cap)#
#-----------------------------------------------#
   
   DEFINE p_ies_incl_cap CHAR(01),
          p_incl_salvo   CHAR(01),
          p_dat_atu      DATE,
          p_hor_atu      CHAR(08),
          p_texto        CHAR(80)
           
   UPDATE nf_sup
      SET ies_incl_cap = p_ies_incl_cap
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA NF_SUP'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF

   SELECT ies_incl_cap
     INTO p_incl_salvo
     FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA NF_SUP'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF

   IF p_incl_salvo <> p_ies_incl_cap THEN
      LET p_msg = 'NAO FOI POSSIVEL ATUALIZAR NF_SUP.IES_INC_CAP'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   LET p_erro = p_num_ar
   LET p_texto = 'AR:', p_erro
   LET p_texto = 'AR: ', p_texto CLIPPED, 
                 '. ATUALIZACAO DO CAMPO NF_SUP.IES_INCL_CAP PARA ', p_ies_incl_cap   
   
   INSERT INTO audit_logix
    VALUES(p_cod_empresa,
           p_texto,
           'pol1159',
           p_dat_atu,
           p_hor_atu,
           p_user)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TA AUDIT_LOGIX'
      CALL pol1159_guarda_erro() 
   END IF
   
   IF p_ies_incl_cap = 'X' THEN
      IF NOT pol1159_atu_integ() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1159_atu_integ()#
#---------------------------#
   
   DEFINE l_num_nf         LIKE nf_sup.num_nf,        
          l_ser_nf         LIKE nf_sup.ser_nf,        
          l_ssr_nf         LIKE nf_sup.ssr_nf,        
          l_cod_fornecedor LIKE nf_sup.cod_fornecedor 
   
   SELECT num_nf, 
          ser_nf, 
          ssr_nf, 
          cod_fornecedor
    INTO  l_num_nf,        
          l_ser_nf,        
          l_ssr_nf,        
          l_cod_fornecedor
    FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO DADOS DA NF_SUP P/ AR ', p_num_ar
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF
   
   SELECT num_ad
     FROM integ_cos_logix 
    WHERE cod_empresa = p_cod_empresa 
      AND num_nf = l_num_nf
      AND ser_nf = l_ser_nf
      AND ssr_nf = l_ssr_nf
      AND cod_fornecedor = l_cod_fornecedor
   
   IF STATUS = 0 THEN   
      DELETE FROM integ_cos_logix
       WHERE cod_empresa = 'ZZ' 
         AND num_nf = l_num_nf
         AND ser_nf = l_ser_nf
         AND ssr_nf = l_ssr_nf
         AND cod_fornecedor = l_cod_fornecedor
      
      UPDATE integ_cos_logix SET cod_empresa = 'ZZ'
       WHERE cod_empresa = p_cod_empresa 
         AND num_nf = l_num_nf
         AND ser_nf = l_ser_nf
         AND ssr_nf = l_ssr_nf
         AND cod_fornecedor = l_cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO DADOS DA INTEG_COS_LOGIX'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 100 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO DADOS DA INTEG_COS_LOGIX'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1159_ins_ctrl_leitura()#
#----------------------------------#
   
   DEFINE p_ies_ar_cs CHAR(10)
   
   IF p_ies_nf_aguard_nfe = 'S' THEN
      LET p_ies_ar_cs = 'CONTRATO'
   ELSE
      LET p_ies_ar_cs = 'NOTA'
   END IF
      
   INSERT INTO nfe_aprov_265
    VALUES(p_cod_empresa, 
           p_num_ar, 
           p_ies_incl_cap, 
           p_ies_ar_cs)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA NFE_APROV_265'
      CALL pol1159_guarda_erro() 
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1159_envia_email()#
#-----------------------------#

   DEFINE p_user_de       CHAR(08),
          p_email_de      CHAR(40),
          p_user_para     CHAR(08),  
          p_email_para    CHAR(40),  
          p_assunto       CHAR(20),   
          p_num_docum     CHAR(08), 
          p_empresa       CHAR(02),
          p_den_comando   CHAR(80),
          p_arquivo       CHAR(30)
            
   LET p_assunto = 'Aprovacao de Notas'
   LET p_titulo = 'NFE aguardando sua aprova��o:'

   DECLARE cq_le_de CURSOR FOR
    SELECT DISTINCT 
           cod_emitente,  
           email_emitente,
           nom_emitente  
      FROM email_temp_265
     ORDER BY cod_emitente
   
   FOREACH cq_le_de INTO p_user_de, p_email_de, p_nome_de

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = ' ENVIANDO EMAIL - ERRO ',p_erro CLIPPED, ' LENDO EMAIL_TEMP_265:1'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
      {IF p_email_de IS NULL OR p_email_de = ' ' THEN
         LET p_msg = ' Usuario ',p_user_de CLIPPED, ' sem email cadastrado.'
         CALL pol1159_guarda_erro() 
         CONTINUE FOREACH
      END IF}
      
      DECLARE cq_le_para CURSOR FOR
       SELECT DISTINCT 
              cod_usuario,  
              email_usuario,
              nom_usuario  
         FROM email_temp_265
        WHERE cod_emitente = p_user_de
        ORDER BY cod_usuario
   
      FOREACH cq_le_para INTO p_user_para, p_email_para, p_nome_para

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = ' ENVIANDO EMAIL - ERRO ',p_erro CLIPPED, ' LENDO EMAIL_TEMP_265:2'
            CALL pol1159_guarda_erro() 
            RETURN FALSE
         END IF

         IF p_email_para IS NULL OR p_email_para = ' ' THEN
            LET p_msg = ' USUARIO ',p_user_para CLIPPED, ' SEM EMAIL CADASTRADO NA TABELA USUARIOS'
            CALL pol1159_guarda_erro() 
            CONTINUE FOREACH
         END IF

         SELECT nom_caminho
           INTO p_den_comando
           FROM log_usu_dir_relat 
          WHERE usuario = p_user_para
            AND empresa = p_cod_empresa 
            AND sistema_fonte = 'LST' 
            #AND ambiente = g_ies_ambiente
         
         IF STATUS = 100 THEN
            LET p_msg = ' USUARIO ',p_user_para CLIPPED, ' SEM CADASTRO NA TABELA LOG_USU_DIR_RELAT'
            CALL pol1159_guarda_erro() 
            CONTINUE FOREACH
         ELSE            
            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = ' ENVIANDO EMAIL - ERRO ',p_erro CLIPPED, ' LENDO LOG_USU_DIR_RELAT'
               CALL pol1159_guarda_erro() 
               CONTINUE FOREACH
            END IF
         END IF

         LET p_arquivo = p_user_de CLIPPED, '-', p_user_para CLIPPED, '.lst'
         LET p_den_comando = p_den_comando CLIPPED, p_arquivo
            
         START REPORT pol1159_relat TO p_den_comando
      
         DECLARE cq_le_docs CURSOR FOR
          SELECT num_docum,
                 cod_empresa
            FROM email_temp_265
           WHERE cod_emitente = p_user_de
             AND cod_usuario  = p_user_para
           ORDER BY cod_empresa, num_docum     

         FOREACH cq_le_docs INTO p_num_docum, p_empresa

            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = ' ENVIANDO EMAIL - ERRO ',p_erro CLIPPED, ' LENDO EMAIL_TEMP_265:3'
               CALL pol1159_guarda_erro() 
               RETURN FALSE
            END IF
                  
            LET p_imp_linha = 'Empresa: ',p_empresa CLIPPED, ' Nota: ', p_num_docum CLIPPED
         
            OUTPUT TO REPORT pol1159_relat() 
      
         END FOREACH
      
         FINISH REPORT pol1159_relat  
      
         CALL log5600_envia_email(p_email_de, p_email_para, p_assunto, p_den_comando, 2)
      
      END FOREACH
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol1159_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, 'A/C. ', p_nome_para
         PRINT
         PRINT COLUMN 001, p_titulo
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 001, p_nome_de
        
END REPORT

#---------------------------#
FUNCTION pol1159_del_grade()#
#---------------------------#

   DEFINE c_num_ar CHAR(10)
   
   LET pr_men[1].mensagem = 'DELETANDO GRADE DE AR EXCLUIDO'
   CALL pol1159_exib_mensagem()

   DECLARE cq_del_grade CURSOR FOR
    SELECT DISTINCT
           aprov_ar_265.cod_empresa, 
           aprov_ar_265.num_aviso_rec 
      FROM aprov_ar_265
     WHERE aprov_ar_265.num_aviso_rec NOT IN (
           SELECT nf_sup.num_aviso_rec 
             FROM nf_sup 
            WHERE nf_sup.cod_empresa = aprov_ar_265.cod_empresa 
              AND nf_sup.num_aviso_rec = aprov_ar_265.num_aviso_rec)

   FOREACH cq_del_grade INTO p_cod_empresa, p_num_ar
      
      IF STATUS <> 0 THEN   
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_DEL_GRADE'
         LET p_num_ar = NULL
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
      
      LET c_num_ar = p_num_ar

      DELETE FROM aprov_ar_265
        WHERE cod_empresa = p_cod_empresa
          AND num_aviso_rec = p_num_ar

      IF STATUS <> 0 THEN   
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' DELETANDO AR DA TAB APROV_AR_265'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF

      DELETE FROM nfe_aprov_265
        WHERE cod_empresa = p_cod_empresa
          AND num_aviso_rec = p_num_ar

      IF STATUS <> 0 THEN   
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' DELETANDO AR DA TAB NFE_APROV_265'
         CALL pol1159_guarda_erro() 
         RETURN FALSE
      END IF
                
      LET p_parametro.cod_empresa = p_cod_empresa
      LET p_parametro.texto = 'EXCLUSAO DO AR ', c_num_ar CLIPPED, ' DA GRADE DE APROVACAO'
      CALL pol1161_grava_auadit(p_parametro) RETURNING p_status
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#---------FIM DO PROGRAMA BL-------------#
{ALTERA��ES

- 17/09/2012: GERAR GRADE DE APROVA��O, A PARTIR DOS NIVEIS DE AUTORIDADE ESPEC�FICOS
- 18/10/2012: Ler s� notas da empresa 25
- 31/10/2012: enviar email para o 1� aprovante
- 26/09/2013: Deletar AR da grade que foram excluidos no sup3760