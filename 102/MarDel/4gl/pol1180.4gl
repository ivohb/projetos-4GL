#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1180                                                 #
# OBJETIVO: IMPORTAÇÃO DE TÍTULOS DA FOLHA RM                       #
# AUTOR...: IVO BJB                                                 #
# DATA....: 21/1/2012                                               #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE 
      p_cod_empresa        LIKE empresa.cod_empresa,
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

DEFINE p_cod_hist_deb_ap    LIKE tipo_despesa.cod_hist_deb_ap


DEFINE p_num_seq            SMALLINT,                
       p_rowid              INTEGER,                   
       p_index              SMALLINT,                  
       s_index              SMALLINT,                  
       p_ind                SMALLINT,                  
       s_ind                SMALLINT,                  
       p_count              SMALLINT,                  
       p_houve_erro         SMALLINT,                  
       p_nom_tela           CHAR(200),                 
       p_ies_cons           SMALLINT,                  
       p_msg                CHAR(500),                 
       p_opcao              CHAR(01),                   
       p_dat_ini_process    DATETIME YEAR TO DAY,
       p_hor_ini_process    DATETIME HOUR TO SECOND,
       p_hor_inclusao       CHAR(08),
       p_dat_inclusao       DATE,
       p_erro               CHAR(10),
       p_ies_processado     CHAR(01),
       p_dat_hor_proces     DATETIME YEAR TO SECOND,
       p_dat_proces         DATETIME YEAR TO DAY,
       p_hor_proces         CHAR(08),
       p_cod_fornecedor     CHAR(15),
       p_num_tit_rm         CHAR(07),
       p_num_ad             INTEGER,
       p_num_ap             INTEGER,
       p_cod_emp_ad         CHAR(02),
       p_cod_cnd_pgto       INTEGER,
       p_texto              CHAR(200),
       p_num_conta_cred     CHAR(23),
       p_num_conta_deb      CHAR(23),
       p_instancia          CHAR(23),
       sql_stmt             CHAR(2000)
       
DEFINE pr_erro              ARRAY[1000] OF RECORD  
       cod_empresa          CHAR(02),
       num_tit_rm           CHAR(07),
       den_erro             CHAR(75)
END RECORD

DEFINE pr_men               ARRAY[1] OF RECORD    
       mensagem             CHAR(60)
END RECORD

DEFINE p_finan    RECORD
   cod_empresa    char(02),
   num_tit_rm	    char(07),
   tip_operacao   char(01),
   cod_cent_custo	decimal(4,0), 
   cod_fornecedor	char(15),
   dat_vencto     datetime year to day,
   val_tot_titulo decimal(15,2),
   cod_moeda	    decimal(2,0),
   cod_tip_desp	  Decimal(4,0),
   cod_lin_prod  	Decimal (2,0),
   cod_lin_recei  Decimal (2,0),
   cod_seg_merc   Decimal (2,0),
   cod_cla_uso    Decimal (2,0),
   val_cent_custo decimal(15,2),
   ies_processado char(01),
   dat_hor_proces datetime year to second,
   nom_usuario    char(08),
   num_tit_logix  decimal(6,0)
END RECORD

DEFINE p_ad_mestre          RECORD LIKE ad_mestre.*,
       p_ap                 RECORD LIKE ap.*,
       p_lanc_cont_cap      RECORD LIKE lanc_cont_cap.*
  
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1180-10.02.22"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   #CALL log001_acessa_usuario("ESPEC999","")
   #   RETURNING p_status, p_cod_empresa, p_user
   
   LET p_status = 0
   LET p_cod_empresa = '01'
   LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol1180_controle()
   END IF

END MAIN

#------------------------------#
FUNCTION pol1180_job(l_rotina) #
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
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'admlog'  #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol1180_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1180_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1180") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1180 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET pr_men[1].mensagem = 'CHECANDO ÚLTIMO PROCESSAMENTO'
   CALL pol1180_exib_mensagem()

   #IF NOT pol1180_checa_proces() THEN
   #   LET p_houve_erro = TRUE
   #   RETURN
   #END IF
   
   LET p_dat_hor_proces = CURRENT YEAR TO SECOND
   LET p_dat_proces = CURRENT YEAR TO DAY
   LET p_hor_proces = TIME
   
   IF NOT pol1180_processa() THEN
      LET p_houve_erro = TRUE
   ELSE
      LET p_houve_erro = FALSE
   END IF
   
   IF p_msg IS NULL THEN
      LET pr_men[1].mensagem = 'PROCESSAMENTO CONCLUIDO!'
   ELSE
      LET pr_men[1].mensagem = p_msg
   END IF
   
   CALL pol1180_exib_mensagem()
   SLEEP 3
   
END FUNCTION

#------------------------------#
FUNCTION pol1180_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#------------------------------#
FUNCTION pol1180_checa_proces()#
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
       AND num_programa = 'pol1180'
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

   LET p_msg = 'GERAÇÃO DA GRADE DE APROVACAO P/ NFE'
   
   LET p_hoje = TODAY
   LET p_hor_proces = p_hor_atu
   
   INSERT INTO audit_logix
    VALUES(p_cod_empresa,
           p_msg,
           'pol1180',
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

#----------------------------#
FUNCTION pol1180_insere_erro()#
#----------------------------#
   
   LET p_ies_processado = 'C'
   LET p_num_seq = p_num_seq + 1
   
   INSERT INTO finan_erro_5054
   VALUES(p_finan.cod_empresa,
          p_finan.num_tit_rm,
          p_num_seq,
          p_msg)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
                
#--------------------------#
FUNCTION pol1180_processa()#
#--------------------------#

   SELECT parametro_texto
     INTO p_instancia
     FROM min_par_modulo
    WHERE empresa = '01'
      AND parametro = 'INSTANCIA_RM'
   
   IF STATUS = 100 THEN
      LET p_instancia = ''
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF
   
   LET p_instancia = log9900_conversao_minusculo(p_instancia)

   LET sql_stmt =
   " SELECT * FROM ", p_instancia CLIPPED, "finan_rm_5054 ",
   "  WHERE cod_empresa IS NOT NULL ",
   "    AND num_tit_rm IS NOT NULL  ",
   "    AND ies_processado IN ('N','C') ",
   "  ORDER BY dat_hor_proces "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_proces CURSOR WITH HOLD FOR var_query
                      
   FOREACH cq_proces INTO p_finan.*

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO CURSOR CQ_PROCES'
         LET p_num_seq = 0
         LET p_finan.cod_empresa = NULL
         LET p_finan.num_tit_rm = NULL
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
      
      LET p_ies_processado = 'S'

      LET pr_men[1].mensagem = 'CONSISTINDO TITULO'
      CALL pol1180_exib_mensagem()

      IF NOT pol1180_consiste() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_processado = 'S' THEN
         CALL log085_transacao("BEGIN")
         IF NOT pol1180_importa_finan() THEN
            CALL log085_transacao("ROLLBACK")
            CALL pol1180_insere_erro()  RETURNING p_status
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
         END IF
      END IF

      LET pr_men[1].mensagem = 'ATUALUZANDO FINAN_RM_5054'
      CALL pol1180_exib_mensagem()

      LET sql_stmt = "UPDATE ", p_instancia CLIPPED,"finan_rm_5054 ",
      " SET ies_processado = '",p_ies_processado,"',",
      "     dat_hor_proces = '",p_dat_hor_proces,"' ",
      "     cod_usuario    = '",p_user,"' ",
      "     num_tit_logix  = '",p_num_ad,"' ",
      " WHERE cod_empresa  = '",p_finan.cod_empresa,"' ",
      "   AND num_tit_rm   = '",p_finan.num_tit_rm,"' ",
      "   AND tip_operacao = '",p_finan.tip_operacao,"' "
  
      PREPARE var_upd FROM sql_stmt
      EXECUTE var_upd
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA FINAN_RM_5054'
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
     
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1180_consiste()#
#--------------------------#

   LET p_num_seq = 0
   
   DELETE FROM finan_erro_5054
    WHERE cod_empresa = p_finan.cod_empresa
      AND num_tit_rm = p_finan.num_tit_rm

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' DELETANDO MATRICULA ', 
                  p_finan.num_tit_rm, ' DA TAB FINAN_ERRO_5054'
      CALL pol1180_insere_erro()  RETURNING p_status
      RETURN FALSE
   END IF
   
   IF p_finan.tip_operacao MATCHES '[IC]' THEN
   ELSE
      LET p_msg = 'TIPO DE OPRACAO INVALIDO - ESPERADO I/C'
      CALL pol1180_insere_erro()  RETURNING p_status
   END IF

   LET p_cod_emp_ad = pol1180_le_emp_orig_dest()
   
   IF p_finan.cod_cent_custo IS NOT NULL AND
         p_finan.cod_cent_custo <> 0 THEN
      SELECT nom_cent_cust
        FROM cad_cc
       WHERE cod_empresa   = p_cod_emp_ad
         AND cod_cent_cust = p_finan.cod_cent_custo

      IF STATUS = 100 THEN
         LET p_msg = 'CENTRO DE CUSTO INEXISTENTE NO LOGIX'
         CALL pol1180_insere_erro()  RETURNING p_status
      ELSE
         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                     p_finan.cod_cent_custo CLIPPED, ' NA TAB CAD_CC'
            CALL pol1180_insere_erro()  RETURNING p_status
            RETURN FALSE
         END IF
      END IF
   END IF
   
   SELECT raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_finan.cod_fornecedor

   IF STATUS = 100 THEN
      LET p_msg = 'FORNECEDOR INEXISTENTE NO LOGIX'
      CALL pol1180_insere_erro()  RETURNING p_status
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_finan.cod_fornecedor CLIPPED, ' NA TABELA FORNECEDOR'
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
   
   SELECT den_moeda
     FROM moeda
    WHERE cod_moeda = p_finan.cod_moeda

   IF STATUS = 100 THEN
      LET p_msg = 'MOEDA INEXISTENTE NO LOGIX'
      CALL pol1180_insere_erro()  RETURNING p_status
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_finan.cod_moeda CLIPPED, ' NA TABELA MOEDA'
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF
   
   SELECT num_conta_deb,
          num_conta_cred,
          cod_hist_deb_ap
     INTO p_num_conta_deb,
          p_num_conta_cred,
          p_cod_hist_deb_ap
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_emp_ad
      AND cod_tip_despesa = p_finan.cod_tip_desp

   IF STATUS = 100 THEN
      LET p_msg = 'TIPO DE DESPESA INEXISTENTE NO LOGIX'
      CALL pol1180_insere_erro()  RETURNING p_status
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO COD ', 
                  p_finan.cod_tip_desp CLIPPED, ' NA TABELA TIPO_DESPESA'
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      ELSE
         IF p_num_conta_deb IS NULL THEN
            LET p_msg = 'NUM CONTA DEBITO ESTA NULA PARA O TIPO DESPESA ', p_finan.cod_tip_desp
            CALL pol1180_insere_erro()  RETURNING p_status
         END IF
         IF p_num_conta_cred IS NULL THEN
            LET p_msg = 'NUM CONTA CREDITO ESTA NULA PARA O TIPO DESPESA ', p_finan.cod_tip_desp
            CALL pol1180_insere_erro()  RETURNING p_status
         END IF
      END IF
   END IF
   
   IF p_finan.val_tot_titulo <= 0 THEN
      LET p_msg = 'VALOR TOTAL DO TITULO INVALIDO'
      CALL pol1180_insere_erro()  RETURNING p_status
   END IF

   IF p_finan.val_cent_custo <= 0 THEN
      LET p_msg = 'VALOR POR CENTRO DE CUSTO INVALIDO'
      CALL pol1180_insere_erro()  RETURNING p_status
   END IF

   SELECT num_tit_logix
     INTO p_num_ad
     FROM tit_rm_logix_5054
    WHERE cod_empresa = p_cod_emp_ad
      AND num_tit_rm  = p_finan.num_tit_rm
   
   IF STATUS = 100 THEN
      LET p_num_ad = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TITULO ', 
                     p_finan.num_tit_rm, ' NA TAB TIT_RM_LOGIX_5054'
         CALL pol1180_insere_erro()  RETURNING p_status
         RETURN FALSE
      END IF
   END IF

   IF p_finan.tip_operacao = 'I' AND p_num_ad IS NOT NULL THEN
      LET p_msg = 'INCLUSAO DE TITULO JA EXISTENTE NO LOGIX'
      CALL pol1180_insere_erro()  RETURNING p_status
   END IF
   
   IF p_finan.tip_operacao = 'C' AND p_num_ad IS NULL THEN
      LET p_msg = 'CANCELAMENTO DE TITULO INEXISTENTE NO LOGIX'
      CALL pol1180_insere_erro()  RETURNING p_status
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1180_importa_finan()#
#------------------------------#

   LET p_msg = NULL

   IF p_finan.tip_operacao = 'C' THEN
      IF NOT pol1180_cancela() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1180_adiciona() THEN
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1180_adiciona()#
#--------------------------#

   IF NOT pol1180_le_par_ad() THEN 
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO TITULO '
   CALL pol1180_exib_mensagem()

   IF NOT pol1180_ad_mestre() THEN
      RETURN FALSE
   END IF

   IF NOT pol1180_lanc_cont_cap() THEN
      RETURN FALSE
   END IF

   LET pr_men[1].mensagem = 'INSERINDO AP'
   CALL pol1180_exib_mensagem()

   IF NOT pol1180_ap() THEN
      RETURN FALSE
   END IF
   
   INSERT INTO tit_rm_logix_5054
    VALUES(p_cod_emp_ad,
           p_finan.num_tit_rm,
           p_ad_mestre.num_ad)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TITULO ',p_finan.num_tit_rm,
                  ' NA TABELA TIT_RM_LOGIX_5054'
      RETURN FALSE
   END IF
           
   RETURN TRUE

END FUNCTION      

#----------------------------------#
FUNCTION pol1180_le_emp_orig_dest()
#----------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT cod_empresa_destin
     INTO p_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_finan.cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_empresa = p_finan.cod_empresa
   END IF

   RETURN (p_empresa)

END FUNCTION

#---------------------------#
FUNCTION pol1180_le_par_ad()
#---------------------------#

   SELECT ult_num_ad
     INTO p_num_ad
     FROM par_ad 
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ad = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO PROXIMO NUMERO DA AD DA TAB PAR_AD '
         RETURN FALSE
      END IF
   END IF
   
   LET p_num_ad = p_num_ad + 1
   
   UPDATE par_ad SET ult_num_ad = p_num_ad
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO PROXIMO NUMERO DA AD DA TAB PAR_AD '
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1180_ad_mestre()#
#---------------------------#

   LET p_cod_cnd_pgto = 1  #a vista
   
   LET p_ad_mestre.cod_empresa       = p_cod_emp_ad
   LET p_ad_mestre.num_ad            = p_num_ad
   LET p_ad_mestre.cod_tip_despesa   = p_finan.cod_tip_desp 
   LET p_ad_mestre.ser_nf            = NULL
   LET p_ad_mestre.ssr_nf            = NULL
   LET p_ad_mestre.num_nf            = ' '
   LET p_ad_mestre.dat_emis_nf       = p_finan.dat_vencto
   LET p_ad_mestre.dat_rec_nf        = NULL
   LET p_ad_mestre.cod_empresa_estab = NULL
   LET p_ad_mestre.mes_ano_compet    = NULL
   LET p_ad_mestre.num_ord_forn      = NULL
   LET p_ad_mestre.cnd_pgto          = p_cod_cnd_pgto
   LET p_ad_mestre.dat_venc          = p_finan.dat_vencto
   LET p_ad_mestre.cod_fornecedor    = p_finan.cod_fornecedor
   LET p_ad_mestre.cod_portador      = NULL
   LET p_ad_mestre.val_tot_nf        = p_finan.val_cent_custo
   LET p_ad_mestre.val_saldo_ad      = p_finan.val_cent_custo
   LET p_ad_mestre.cod_moeda         = p_finan.cod_moeda
   LET p_ad_mestre.set_aplicacao     = NULL
   LET p_ad_mestre.cod_lote_pgto     = 1
   LET p_ad_mestre.observ            = NULL
   LET p_ad_mestre.cod_tip_ad        = 5
   LET p_ad_mestre.ies_ap_autom      = 'S'
   LET p_ad_mestre.ies_sup_cap       = 'N'
   LET p_ad_mestre.ies_fatura        = 'N'
   LET p_ad_mestre.ies_ad_cont       = 'S'
   LET p_ad_mestre.num_lote_transf   = 0
   LET p_ad_mestre.ies_dep_cred      = 'N'
   LET p_ad_mestre.num_lote_pat      = 0
   LET p_ad_mestre.cod_empresa_orig  = p_finan.cod_empresa

   INSERT INTO ad_mestre
      VALUES(p_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA TAB AD_MESTRE'
      RETURN FALSE
   END IF

   LET p_texto = p_ad_mestre.num_ad
   LET p_texto = 'POL1180 - INCLUSAO DA AD NUMERO ', p_texto CLIPPED

   IF NOT pol1180_audit_cap(p_ad_mestre.num_ad, '1') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION        

#-------------------------------#
FUNCTION pol1180_lanc_cont_cap()#
#-------------------------------#
   
   DEFINE p_sequencia INTEGER
   
   LET p_sequencia = 1
   LET p_lanc_cont_cap.cod_empresa        = p_ad_mestre.cod_empresa
   LET p_lanc_cont_cap.num_ad_ap          = p_ad_mestre.num_ad
   LET p_lanc_cont_cap.ies_ad_ap          = '1'
   LET p_lanc_cont_cap.num_seq            = p_sequencia
   LET p_lanc_cont_cap.cod_tip_desp_val   = p_finan.cod_tip_desp
   LET p_lanc_cont_cap.ies_desp_val       = 'D'
   LET p_lanc_cont_cap.ies_man_aut        = 'A'
   LET p_lanc_cont_cap.ies_tipo_lanc      = 'D'
   LET p_lanc_cont_cap.num_conta_cont     = p_num_conta_deb
   LET p_lanc_cont_cap.val_lanc           = p_finan.val_cent_custo
   LET p_lanc_cont_cap.tex_hist_lanc      = 'IMPORTACAO DA FOLHA RM'
   LET p_lanc_cont_cap.ies_cnd_pgto       = 'S'
   LET p_lanc_cont_cap.num_lote_lanc      = 0
   LET p_lanc_cont_cap.ies_liberad_contab = 'S'
   LET p_lanc_cont_cap.num_lote_transf    = p_ad_mestre.num_lote_transf
   LET p_lanc_cont_cap.dat_lanc           = p_dat_proces

   INSERT INTO lanc_cont_cap
      VALUES(p_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO CONTA DEBITO P/ TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA LANC_CONT_CAP'
      RETURN FALSE
   END IF

   LET p_lanc_cont_cap.ies_tipo_lanc  = 'C'
   LET p_lanc_cont_cap.num_conta_cont = p_num_conta_cred
   LET p_sequencia = p_sequencia + 1
   LET p_lanc_cont_cap.num_seq        = p_sequencia
   LET p_lanc_cont_cap.ies_ad_ap      = '1'

   INSERT INTO lanc_cont_cap
      VALUES(p_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO CONTA CREDITO P/ TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA LANC_CONT_CAP'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------#
FUNCTION pol1180_ap()#
#--------------------#

   IF NOT pol1180_le_par_ap() THEN 
      RETURN FALSE
   END IF

   LET p_ap.cod_empresa       = p_cod_emp_ad
   LET p_ap.num_ap            = p_num_ap
   LET p_ap.num_versao        = 1
   LET p_ap.ies_versao_atual  = 'S'
   LET p_ap.num_parcela       = 1
   LET p_ap.cod_portador      = NULL
   LET p_ap.cod_bco_pagador   = NULL
   LET p_ap.num_conta_banc    = NULL
   LET p_ap.cod_fornecedor    = p_finan.cod_fornecedor
   LET p_ap.cod_banco_for     = NULL
   LET p_ap.num_agencia_for   = NULL
   LET p_ap.num_conta_bco_for = NULL
   LET p_ap.num_nf            = p_ad_mestre.num_nf
   LET p_ap.num_duplicata     = NULL
   LET p_ap.num_bl_awb        = NULL
   LET p_ap.compl_docum       = NULL
   LET p_ap.val_nom_ap        = p_finan.val_cent_custo
   LET p_ap.val_ap_dat_pgto   = 0
   LET p_ap.cod_moeda         = p_finan.cod_moeda
   LET p_ap.val_jur_dia       = 0
   LET p_ap.taxa_juros        = NULL
   LET p_ap.cod_formula       = NULL
   LET p_ap.dat_emis          = p_dat_proces
   LET p_ap.dat_vencto_s_desc = p_finan.dat_vencto
   LET p_ap.dat_vencto_c_desc = NULL
   LET p_ap.val_desc          = NULL
   LET p_ap.dat_pgto          = NULL
   LET p_ap.dat_proposta      = NULL
   LET p_ap.cod_lote_pgto     = 1
   LET p_ap.num_docum_pgto    = NULL
   LET p_ap.ies_lib_pgto_cap  = 'N'
   LET p_ap.ies_lib_pgto_sup  = 'S'
   LET p_ap.ies_baixada       = 'N'
   LET p_ap.ies_docum_pgto    = NULL
   LET p_ap.ies_ap_impressa   = 'N'
   LET p_ap.ies_ap_contab     = 'N'
   LET p_ap.num_lote_transf   = p_ad_mestre.num_lote_transf
   LET p_ap.ies_dep_cred      = p_ad_mestre.ies_dep_cred
   LET p_ap.data_receb        = NULL
   LET p_ap.num_lote_rem_escr = 0
   LET p_ap.num_lote_ret_escr = 0
   LET p_ap.dat_rem           = NULL
   LET p_ap.dat_ret           = NULL
   LET p_ap.status_rem        = 0
   LET p_ap.ies_form_pgto_escr= NULL
   
   INSERT INTO ap
      VALUES(p_ap.*)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA TAB AP'
      RETURN FALSE
   END IF
   
   INSERT INTO ap_tip_desp
    VALUES(p_ap.cod_empresa,
           p_ap.num_ap,
           p_num_conta_cred,
           p_cod_hist_deb_ap,
           p_finan.cod_tip_desp,
           p_ap.val_nom_ap)
           
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA TAB AP_TIP_DESP'
      RETURN FALSE
   END IF
      
   INSERT INTO ad_ap
      VALUES(p_ap.cod_empresa,
             p_ad_mestre.num_ad,
             p_ap.num_ap,
             p_ap.num_lote_transf)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TITULO ', 
                  p_finan.num_tit_rm CLIPPED, ' NA TAB AD_AP'
      RETURN FALSE
   END IF

   LET p_texto = p_ap.num_ap
   LET p_texto = 'POL1180 - INCLUSAO DA AP NUMERO ', p_texto CLIPPED

   IF NOT pol1180_audit_cap(p_ap.num_ap, '2') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1180_le_par_ap()
#---------------------------#

   SELECT ult_num_ap 
     INTO p_num_ap
     FROM par_ap
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ap = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO PROXIMO NUMERO DA AP NA TAB PAR_AP '
         RETURN FALSE
      END IF
   END IF
   
   LET p_num_ap = p_num_ap + 1
   
   UPDATE par_ap SET ult_num_ap = p_num_ap
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO PROXIMO NUMERO DA AP NA TAB PAR_AP  '
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1180_cancela()#
#-------------------------#

   SELECT *
     INTO p_ad_mestre.*
     FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad = p_num_ad

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO AD ', p_num_ad,
                  ' DA TABELA AD_MESTRE'
      RETURN FALSE
   END IF
     
   DELETE FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad = p_num_ad
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ', p_num_ad,
                  ' DA TABELA AD_MESTRE'
      RETURN FALSE
   END IF

   SELECT num_ap
     INTO p_num_ad
     FROM ad_ap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad = p_num_ad

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO NUM AP DA TABELA AD_AP  '
      RETURN FALSE
   END IF

   DELETE FROM ad_ap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad = p_num_ad
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ', p_num_ad,
                  ' DA TABELA AD_AP'
      RETURN FALSE
   END IF

   DELETE FROM ap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap = p_num_ap
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ', p_num_ap,
                  ' DA TABELA AP'
      RETURN FALSE
   END IF

   DELETE FROM lanc_cont_cap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad_ap = p_num_ad
      AND tex_hist_lanc = 'IMPORTACAO DA FOLHA RM'
      AND ies_ad_ap = '1'
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ', p_num_ad,
                  ' DA TABELA LANC_CONT_CAP'
      RETURN FALSE
   END IF

   DELETE FROM ap_tip_desp
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap = p_num_ap
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ', p_num_ap,
                  ' DA TABELA AP_TIP_DESP'
      RETURN FALSE
   END IF

   DELETE FROM tit_rm_logix_5054
    WHERE cod_empresa = p_cod_emp_ad
      AND num_tit_rm  = p_finan.num_tit_rm
      AND num_tit_logix = p_ad_mestre.num_ad
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' EXCLUINDO TITULO ',p_finan.num_tit_rm,
                  ' DA TABELA TIT_RM_LOGIX_5054'
      RETURN FALSE
   END IF

   LET p_texto = p_ad_mestre.num_ad
   LET p_texto = 'POL1180 - EXCLUSAO DA AD NUMERO ', p_texto CLIPPED

   IF NOT pol1180_audit_cap(p_ad_mestre.num_ad, '1') THEN
      RETURN FALSE
   END IF

   LET p_texto = p_num_ap
   LET p_texto = 'POL1180 - EXCLUSAO DA AP NUMERO ', p_texto CLIPPED

   IF NOT pol1180_audit_cap(p_ad_mestre.num_ad, '2') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------------#
FUNCTION pol1180_audit_cap(p_docum, p_ies_ad_ap)#
#-----------------------------------------------#

   DEFINE p_docum   INTEGER,
          p_num_seq INTEGER,
          p_ies_ad_ap CHAR(01)

   SELECT MAX(num_seq)
     INTO p_num_seq
     FROM audit_cap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad_ap = p_docum
      AND ies_ad_ap = p_ies_ad_ap

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO SEQUENCIA DA TABELA AUDIT_CAP'
      RETURN FALSE
   END IF

   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF
   
   LET p_num_seq = p_num_seq + 1
         
   INSERT INTO audit_cap
      VALUES(p_ad_mestre.cod_empresa,
             '1',
             p_user,
             p_docum,
             p_ies_ad_ap,
             p_ad_mestre.num_nf,
             p_ad_mestre.ser_nf,
             p_ad_mestre.ssr_nf,
             p_ad_mestre.cod_fornecedor,
             'I',
             p_num_seq,
             p_texto,
             p_dat_proces,
             p_hor_proces,
             p_ad_mestre.num_lote_transf)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO DADOS NA TAB AUDIT_CAP'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   

#---------FIM DO PROGRAMA BJB-------------#
{ALTERAÇÕES

