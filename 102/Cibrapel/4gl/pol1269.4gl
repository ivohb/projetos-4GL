#---------------------------------------------------------------#
#Objetivo...: Integração de apontamento TrimBox e Logix         #
#Autor......: Ivo HB                                            #
#Funções....: FUNC002                                           #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,         
          p_status             SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          sql_stmt             CHAR(900),
          p_caminho            CHAR(080),
          p_msg                CHAR(150),
          p_qtd_trim           DECIMAL(10,3),
          p_item_trim          CHAR(15),
          p_ordem_trim         INTEGER,
          p_mensagem           CHAR(150),
          p_qtd_criticado      INTEGER,
          p_qtd_apontado       INTEGER,
          p_statusRegistro     CHAR(01), 
          p_tipoRegistro       CHAR(01),
          p_criticou           SMALLINT,
          p_qtd_estoque        DECIMAL(10,3),
          p_transac_consumo    INTEGER,
          p_num_trans_atual    INTEGER,
          p_num_seq_orig       INTEGER,   
          p_cod_tip_apon       CHAR(01),
          p_ies_tip_movto      CHAR(01),
          p_transac_apont      INTEGER,
          p_num_seq_apo_mestre INTEGER, 
          p_num_seq_apo_oper   INTEGER,
          p_ies_implant        CHAR(01),
          p_tip_operacao       CHAR(01),
          p_cod_operacao       CHAR(05),
          p_tot_apont          DECIMAL(10,3),
          p_ck_compon          SMALLINT,
          p_ies_relac          CHAR(01),
          p_ies_onduladeira    CHAR(01),
          p_necessidade        INTEGER
          
   DEFINE p_man                RECORD LIKE man_apont_885.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_parametros_885     RECORD LIKE parametros_885.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*

   DEFINE p_num_seq_apont         INTEGER,
          p_num_ordem             INTEGER,
          p_num_docum             CHAR(15),
          p_cod_item              CHAR(15),
          p_num_lote              CHAR(15),
          p_ies_situa             CHAR(01),
          p_dat_abert             DATE,
          p_cod_grupo_item        CHAR(15),
          p_tipo_item             CHAR(02),
          p_count                 INTEGER,    
          p_ind                   SMALLINT,   
          p_index                 SMALLINT,   
          p_nom_tela              CHAR(200),  
          p_nom_help              CHAR(200),  
          p_houve_erro            SMALLINT,  
          p_ies_proces            CHAR(01),
          p_erro                  CHAR(10),
          p_dat_ini               DATETIME YEAR TO SECOND,
          p_dat_fim               DATETIME YEAR TO SECOND,
          p_grava_oplote          CHAR(01),
          p_ies_oper_final        CHAR(01),
          p_cod_local_orig        CHAR(15),
          p_ctr_estoque           CHAR(01),
          p_ctr_lote              CHAR(01),
          p_sobre_baixa           CHAR(01),
          p_dat_movto             DATE,
          p_dat_proces            DATE,
          p_hor_operac            CHAR(08),
          p_tip_movto             CHAR(01),
          p_qtd_movto             DECIMAL(10,3),
          p_ies_chapa             SMALLINT,
          p_ies_tabuleiro         SMALLINT,
          p_ies_caixa             SMALLINT

DEFINE p_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,    
       p_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup,     
       p_ies_largura         LIKE item_ctr_grade.ies_largura,
       p_ies_altura          LIKE item_ctr_grade.ies_altura,
       p_ies_diametro        LIKE item_ctr_grade.ies_diametro,
       p_ies_comprimento     LIKE item_ctr_grade.ies_comprimento,
       p_ies_serie           LIKE item_ctr_grade.reservado_2,
       p_ies_dat_producao    LIKE item_ctr_grade.ies_dat_producao,
       p_cod_cent_cust       LIKE de_para_maq_885.cod_cent_cust,
       p_cod_familia         LIKE item.cod_familia,                 
       p_ies_tip_item        LIKE item.ies_tip_item,
       p_cod_lin_prod        LIKE item.cod_lin_prod,
       p_pct_desc_valor      LIKE desc_nat_oper_885.pct_desc_valor,
       p_ies_apontado        LIKE desc_nat_oper_885.ies_apontado,
       p_pct_desc_qtd        LIKE desc_nat_oper_885.pct_desc_qtd

DEFINE p_qtd_baixar         LIKE estoque_trans.qtd_movto,        
       p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,        
       p_cod_compon         LIKE ord_compon.cod_item_compon,       
       p_cod_local_baixa    LIKE ord_compon.cod_local_baixa 

DEFINE p_cod_oper_sp         LIKE par_pcp.cod_estoque_sp,        
       p_cod_oper_rp         LIKE par_pcp.cod_estoque_rp,           
       p_cod_oper_sucata     LIKE par_pcp.cod_estoque_rn,   
       p_cod_local_refug     LIKE item.cod_local_estoq,             
       p_cod_local_sucat     LIKE item.cod_local_estoq,             
       p_cod_local_retrab    LIKE item.cod_local_estoq,             
       p_cod_local_div_qtd   LIKE item.cod_local_estoq

END GLOBALS

DEFINE p_cons_trim          RECORD LIKE consumo_trimbox_885.*

DEFINE p_ies_processando    CHAR(01),
       p_cod_local_estoq    CHAR(10),
       p_ies_ctr_lote       CHAR(01),
       m_num_pedido         INTEGER,
       m_num_seq            INTEGER,
       m_apont_manual       SMALLINT
       
MAIN                  

   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol1269-12.00.07  ' 
   CALL func002_versao_prg(p_versao)

   WHENEVER ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 90
      DEFER INTERRUPT

   LET p_caminho = log140_procura_caminho('pol1269.iem')

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '01'; LET p_user = 'pol1269'; LET p_status = 0

  IF p_status = 0  THEN
     CALL pol1269_controle() RETURNING p_status
  END IF

END MAIN       

#------------------------------#
FUNCTION pol1269_job(l_rotina) #
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
   LET p_user = 'pol1269'  #l_param2_user
      
   CALL pol1269_controle() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1269_controle()
#--------------------------#
   
   DEFINE l_param LIKE min_par_modulo.parametro_texto
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1269") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1269 AT 4,2 WITH FORM p_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_qtd_apontado = 0   
   LET p_qtd_criticado = 0
      
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_qtd_criticado TO qtd_criticado
   DISPLAY p_qtd_apontado TO qtd_apontado
  #lds CALL LOG_refresh_display()	

   LET m_apont_manual = FALSE

   SELECT parametro_texto
     INTO l_param
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa
      AND parametro = 'APONTAMENTO_MANUAL'
   
   IF STATUS = 0 THEN
      IF l_param[1] = 'S' THEN
         LET m_apont_manual = TRUE
      END IF
   END IF

   CALL pol1269_processa() RETURNING p_status   
   CALL pol1269_grava_msg()
   
   IF NOT p_status THEN
      CALL pol1269_grava_apont_trim() RETURNING p_status
   END IF
   
   UPDATE proces_apont_885 
      SET ies_proces = p_ies_processando
    WHERE cod_empresa = p_cod_empresa
   
   CLOSE WINDOW w_pol1269
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1269_processa()#
#--------------------------#

   DISPLAY 'Aguarde... Processando.' TO mensagem
     #lds CALL LOG_refresh_display()	

   LET p_ies_processando = 'N'
   
   IF NOT pol1269_checa_proces() THEN
      RETURN FALSE
   END IF
   
   IF p_ies_processando = 'S' THEN
      LET p_ies_processando = 'N'
      RETURN TRUE
   END IF

   IF NOT pol1269_le_parametros() THEN
      RETURN FALSE
   END IF
  
   CALL log085_transacao("BEGIN")  

   DELETE FROM apont_erro_885
    WHERE codempresa = p_cod_empresa
   DELETE FROM apont_msg_885
    WHERE cod_empresa = p_cod_empresa    
    
   CALL pol1269_del_tabs_lote()
   CALL log085_transacao("COMMIT")  
   
   CALL pol1269_proces_apto() RETURNING p_status

   CALL pol1269_del_tabs_lote()
   
   RETURN p_status
   
END FUNCTION

#---------------------------#
FUNCTION pol1269_grava_msg()#
#---------------------------#
   
   DEFINE p_dat_hor DATETIME YEAR TO SECOND
   
   LET p_dat_hor = CURRENT
   
   INSERT INTO apont_msg_885
    VALUES(p_cod_empresa, p_dat_hor, p_msg)

   IF p_mensagem IS NOT NULL THEN
      CALL pol1269_insere_erro() RETURNING p_status
      CALL pol1269_grava_apont_trim() RETURNING p_status
   END IF

END FUNCTION      

#------------------------------#
FUNCTION pol1269_checa_proces()#
#------------------------------#

   SELECT ies_proces
     INTO p_ies_proces
     FROM proces_apont_885
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS = 100 THEN
      INSERT INTO proces_apont_885
       VALUES(p_cod_empresa, 'S')
   ELSE
      IF STATUS = 0 THEN
         IF p_ies_proces = 'N' THEN
            UPDATE proces_apont_885
               SET ies_proces = 'S'
             WHERE cod_empresa = p_cod_empresa
         ELSE
            LET p_ies_processando = 'S'
            LET p_msg = 'JA EXISTE UM PROCESSO DE APONTAMENTO EM EXECUCAO'
         END IF
      ELSE
         LET p_msg = 'ERRO(',STATUS,' ) LENDO proces_apont_885'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION

#-------------------------------#
FUNCTION pol1269_del_tabs_lote()#
#-------------------------------#

   DELETE FROM estoque_lote 
    WHERE qtd_saldo <= 0 
      AND cod_empresa = p_cod_empresa
      
   DELETE FROM estoque_lote_ender 
    WHERE qtd_saldo <= 0 
      AND cod_empresa = p_cod_empresa

END FUNCTION

#-----------------------------#
FUNCTION pol1269_proces_apto()#
#-----------------------------#
   
   #Elimina os apontamentos sem número de sequencia
   
   UPDATE apont_trim_885
      SET statusregistro = 'E'
    WHERE codempresa = p_cod_empresa
      AND statusregistro = '0'
      AND numsequencia IS NULL
       OR numsequencia = ' '

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TABELA APONT_TRIM_885'
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")  
   
   IF NOT pol1269_elimina_estorno() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")    

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1269_classif_apont() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   IF m_apont_manual THEN
   ELSE
      DISPLAY 'Apontando chapas' TO mensagem
     #lds CALL LOG_refresh_display()	
   
      IF NOT pol1269a_aponta_chapa() THEN
         RETURN FALSE
      END IF

      DISPLAY 'Apontando caixas e acessórios' TO mensagem
     #lds CALL LOG_refresh_display()	

      IF NOT pol1269c_aponta_outros() THEN
         RETURN FALSE
      END IF
   END IF
   
   DISPLAY 'Sucateando produto.' TO mensagem
  #lds CALL LOG_refresh_display()	

   IF NOT pol1269d_transf_devolucao() THEN
      RETURN FALSE
   END IF
   
   LET p_msg = 'APONTAMENTO EFETUADO COM SUCESSO'
   
   RETURN TRUE

END FUNCTION

#Lê os apontamentos e, se tiver estornos correspondentes,
#elimina oa apontamento e também o estorno.

#---------------------------------#
FUNCTION pol1269_elimina_estorno()#
#---------------------------------#

   INITIALIZE p_man TO NULL
   
   DECLARE cq_elimina CURSOR FOR
    SELECT numsequencia,
           numpedido,
           coditem,
           numordem,
           codmaquina,
           inicio,
           fim,
           qtdprod,
           tipmovto
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')
       AND qtdprod > 0

   FOREACH cq_elimina INTO
           p_man.num_seq_apont,
           p_man.num_pedido,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_dat_fim,
           p_man.qtd_movto,
           p_man.tip_movto

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO ESTORNOS DE APONTAMENTO'
         RETURN FALSE
      END IF      
            
      DISPLAY p_man.ordem_producao TO num_ordem
      #lds CALL LOG_refresh_display()
      
      DECLARE cq_repetidos CURSOR FOR
       SELECT numsequencia
         FROM apont_trim_885
        WHERE codempresa     = p_cod_empresa
          AND numpedido      = p_man.num_pedido
          AND coditem        = p_man.item
          AND numordem       = p_man.ordem_producao
          AND codmaquina     = p_man.cod_recur
          AND inicio         = p_dat_ini
          AND fim            = p_dat_fim
          AND tipmovto       = p_man.tip_movto
          AND qtdprod        = -p_man.qtd_movto
          AND tiporegistro   <> '1'
          AND StatusRegistro IN ('0','2')
      
      FOREACH cq_repetidos INTO p_num_seq_apont

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REGISTROS REPETIDOS'
            RETURN FALSE
         END IF         
         
         UPDATE apont_trim_885
            SET statusregistro = 'I'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_man.num_seq_apont
      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO REGISTROS REPETIDOS'
            RETURN FALSE
         END IF         

         UPDATE apont_trim_885
            SET statusregistro = 'I'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO REGISTROS REPETIDOS'
            RETURN FALSE
         END IF         
      
         EXIT FOREACH
         
      END FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#Classifica os apontamentos da tabela apont_trim_885, como
#apontamento de caixa (1), chapa (2) ou tabuleiros (3)

#-------------------------------#
FUNCTION pol1269_classif_apont()#
#-------------------------------#
   
   INSERT INTO apont_hist_885
    SELECT apont_trim_885.* FROM apont_trim_885
     WHERE apont_trim_885.codempresa = p_cod_empresa
       AND apont_trim_885.numsequencia NOT IN
     (SELECT apont_hist_885.numsequencia
        FROM apont_hist_885
       WHERE apont_hist_885.codempresa = p_cod_empresa)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA APONT_HIST_885'
      RETURN FALSE
   END IF         

   LET p_statusRegistro = '2'
   LET p_tipoRegistro = 'I'

   DECLARE cq_sequenc CURSOR FOR
    SELECT numsequencia,
           numordem,
           tipmovto
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')
       AND iesdevolucao = 'N'
   
   FOREACH cq_sequenc INTO p_num_seq_apont, p_num_ordem
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') CLASSIFICANDO APONTAMENTOS - CQ_SEQUENC'
         RETURN FALSE
      END IF       
      
      LET p_man.num_seq_apont = p_num_seq_apont
      LET p_man.ordem_producao = p_num_ordem

      SELECT cod_item,
             num_docum
        INTO p_cod_item,
             p_num_docum
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = p_num_ordem

      IF STATUS = 100 THEN
         LET p_msg = 'ORDEM ',p_num_ordem CLIPPED, ' NAO EXISTE NO LOGIX '
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
         IF NOT pol1269_grava_apont_trim() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS.COD_ITEM'
            RETURN FALSE
         END IF         
      END IF
      
	    SELECT cod_familia
	      INTO p_cod_familia
	      FROM item
	     WHERE cod_empresa = p_cod_empresa
	       AND cod_item    = p_cod_item

      IF STATUS = 100 THEN
         LET p_msg = 'ITEM ',p_cod_item CLIPPED, ' NAO EXISTE NO LOGIX '
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
         IF NOT pol1269_grava_apont_trim() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ITEM.COD_FAMILIA'
            RETURN FALSE
         END IF         
      END IF

      IF p_cod_familia = '202' THEN
         LET p_tipo_item = 'TB'
      ELSE
         IF NOT pol1269_le_tipo() THEN
            RETURN FALSE
         END IF
      END IF
         
      UPDATE apont_trim_885
         SET tipoitem = p_tipo_item
       WHERE codempresa = p_cod_empresa
         AND numsequencia = p_num_seq_apont
         AND numordem = p_num_ordem

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TABELA APONT_TRIM_885.TIPOITEM '
         RETURN FALSE
      END IF
   
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1269_le_tipo()#
#-------------------------#

   DEFINE p_tipo    CHAR(02)
   
   CALL pol1269_pega_pedido()
   
   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM item_chapa_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ITEM_CHAPA_885'
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_tipo_item = 'CH'
      RETURN TRUE
   END IF
   
   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM item_caixa_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND num_sequencia = m_num_seq
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ITEM_CAIXA_885'
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_tipo_item = 'CX'
   END IF

   RETURN TRUE

END FUNCTION

#rotinas que serão chamadas pelos rpogramas auxiliares

#------------------------------#
FUNCTION pol1269_le_operacoes()#
#------------------------------#

   SELECT cod_estoque_sp,
          cod_estoque_rp,
          cod_estoque_rn
     INTO p_cod_oper_sp,
          p_cod_oper_rp,
          p_cod_oper_sucata
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA PARAMETROS_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1269_le_parametros()#
#-------------------------------#

   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO TABELA PARAMETROS_885'
      RETURN FALSE
   END IF
      
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA PAR_ESTOQUE'
      RETURN FALSE
   END IF

   SELECT val_parametro
     INTO p_ies_relac
     FROM log_val_parametro 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'gera_est_trans_relac'

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA LOG_VAL_PARAMETRO'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1269_grava_apont_trim()
#---------------------------------#

   UPDATE apont_trim_885
      SET StatusRegistro = p_statusRegistro,
          tiporegistro   = p_tipoRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_man.num_seq_apont
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A APONT_TRIM_885'
      RETURN FALSE
   END IF

   UPDATE apont_hist_885
      SET StatusRegistro = p_statusRegistro,
          tiporegistro   = p_tipoRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_man.num_seq_apont
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A APONT_HIST_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1269_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO apont_erro_885
      VALUES (p_cod_empresa,
              p_man.num_seq_apont,
              p_man.ordem_producao,
              p_msg)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA APONT_ERRO_885:3'
      RETURN FALSE
   END IF                                           

   LET p_qtd_criticado = p_qtd_criticado + 1
   DISPLAY p_qtd_criticado TO qtd_criticado   
   #lds CALL LOG_refresh_display()
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1269_ck_sequencia()#
#------------------------------#

   SELECT COUNT(num_seq_apont)
     INTO p_count
     FROM apont_trans_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_seq_apont = p_man.num_seq_apont

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_TRANS_885'
      RETURN FALSE
   END IF

   IF p_count > 0 THEN
      LET p_statusRegistro = '1' 
      LET p_tipoRegistro = '1'
      LET p_criticou = TRUE
   
      {LET p_msg = 'NUMERO DE SEQUENCIA JA APONTADO NO LOGIX: ',       
                  'ESSE REGISTRO JA FOI APONTADO NO LOGIX. ', 
                  'E NAO PODE SER DUPLICADO '                        
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF}
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1269_ck_consumo()#
#----------------------------#

   DEFINE l_trim_mandou SMALLINT
   
   LET l_trim_mandou = FALSE
   
   DECLARE cq_ck_cons_trim CURSOR FOR
    SELECT *
      FROM consumo_trimbox_885
     WHERE codempresa = p_cod_empresa
       AND numsequencia = p_man.num_seq_apont

   FOREACH cq_ck_cons_trim INTO p_cons_trim.*

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB CONSUMO_TRIMBOX_885:cq_ck_cons_trim'  
         RETURN FALSE
      END IF  
      
      LET l_trim_mandou = TRUE
      
      IF p_cons_trim.coditem IS NULL THEN
         LET p_msg = 'O CONPONENTE CONSUMIDO ENVIDO NÃO É VALIDO'    
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_cons_trim.qtdconsumida IS NULL OR p_cons_trim.qtdconsumida = 0 THEN
         LET p_msg = 'A QUANTIDADE CONSUMIDA ENVIDA NÃO É VALIDA'    
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF      

   END FOREACH

   IF NOT l_trim_mandou THEN
      LET p_msg = 'O TRIM NAO ENVIOU O CONSUMO DE PAPEL: ESTORNE ESSE ', 
                  'REGISTRO E ENVIE OUTRO JUNTO COM O CONSUMO DE BOBINA'       
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1269_ck_ordem()#
#--------------------------#

   SELECT num_docum,
          cod_item,
          num_lote,
          ies_situa,
          dat_abert,
          cod_local_prod
     INTO p_num_docum,
          p_cod_item,
          p_num_lote,
          p_ies_situa,
          p_dat_abert,
          p_man.local
	   FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS = 100 THEN
      LET p_msg = 'A OP ', p_man.ordem_producao,  ' ENVIADA PELO TRIM NAO EXISTE: ',
                  'ESTORNE ESSE APONTAMENTO E ENVIE OUTRO COM A OP CORRETA'        
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS.NUM.DOCUM'
         RETURN FALSE
      ELSE
         IF NOT pol1269_ck_status_op() THEN
            RETURN FALSE
         END IF
         CALL pol1269_pega_pedido()
         LET p_man.item = p_cod_item
         LET p_man.lote = p_num_lote
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1269_pega_pedido()#
#-----------------------------#

   DEFINE p_carac       CHAR(01),
          p_numpedido   CHAR(6),
          p_numseq      CHAR(3)

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_man.num_seq_pedido = p_numseq
   LET m_num_pedido = p_numpedido
   LET m_num_seq = p_numseq

END FUNCTION

#------------------------------#
FUNCTION pol1269_ck_status_op()#
#------------------------------#

   IF p_ies_situa <> '4' THEN
      IF p_ies_situa = '5' THEN
         LET p_msg = 'A OP ENVIADA PELO TRIM ESTA ENCERRADA E ',
                     'NAO PODE MAIS RECEBER APONTAMENTOS'
      ELSE
         IF p_ies_situa = '9' THEN
            LET p_msg = 'A OP ENVIADA PELO TRIM ESTA CANCELADA E ',
                        'NAO PODE MAIS RECEBER APONTAMENTOS'
         ELSE
            LET p_msg = 'A OP ENVIADA PELO TRIM AINDA NAO FOI LIBERADA: ',
                        'CONSULTE-A NO MAN0515 E PROCESSE SUA LIBERACAO.'
         END IF
      END IF
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1269_pega_turno()#
#----------------------------#

   DEFINE p_minutos    SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04)
   
   LET p_hora = EXTEND(p_dat_ini, HOUR TO MINUTE)
   LET p_minutos = (p_hora[1,2] * 60) + p_hora[4,5]

   IF STATUS <> 0 THEN
      LET p_msg = 'A HORA DE INICIO DA PRODUCAO NAO E VALIDA'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   LET p_msg = 'HORA DE INICIO DO APONTAMENTO ENVIADA PELO TRIM ',
               'NAO ESTA DENTRO DE UM TURNO DE PRODUCAO CADASTRADO NO LOGIX'
   
   DECLARE cq_turno CURSOR FOR
    SELECT cod_turno,
           hor_ini_normal,
           hor_fim_normal
     FROM turno
    WHERE cod_empresa = p_cod_empresa

   FOREACH cq_turno INTO 
           p_man.turno,
           p_hor_ini,
           p_hor_fim

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA TURNO DO LOGIX'
         RETURN FALSE
      END IF
      
      LET p_min_ini = (p_hor_ini[1,2] * 60) + p_hor_ini[3,4]   
      LET p_min_fim = (p_hor_fim[1,2] * 60) + p_hor_fim[3,4]   
      
      IF p_min_fim < p_min_ini THEN
         LET p_min_fim = p_min_fim + 1440
         IF p_minutos < p_min_ini THEN
            LET p_minutos = p_minutos + 1440
         END IF
      END IF
      
      IF p_minutos >= p_min_ini AND p_minutos < p_min_fim THEN
         LET p_msg = NULL
         EXIT FOREACH
      END IF

   END FOREACH

   IF p_msg IS NOT NULL THEN
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1269_ck_movto()#
#--------------------------#
   
   IF p_man.tip_movto MATCHES "[FRS]" THEN
   ELSE
      LET p_msg = 'O TIPO DE APONTAMENTO ENVIADO PELO TRIM NAO E VALIDO: ',
                  'NA INTEGRACAO TRIM X LOGIX SOMENTE ESTAO PREVISTOS ',
                  'OS TIPOS F/R/S'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF p_man.tip_movto = "R" THEN
      IF p_man.peso_teorico IS NULL OR p_man.peso_teorico = 0 THEN
         LET p_msg = 'ENVIO DE APONTAMENTO DE REFUGO SEM PESO TEORICO: ',      
                     'PARA APONTAR UM REFUGO, O LOGIX PRECISA SABER O PESO ',  
                     'EM KG, O QUAL DEVE SER ENVIADO PELO TRIM.'               
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF 
   
   IF p_man.qtd_movto IS NULL OR p_man.qtd_movto = 0 THEN
		  LET p_msg = 'QUANTIDADE A APONTAR ESTA NULA OU COM ZERO: ',  
		              'VERIFIQUE O CAMPO QTD PRODUZIDA. O MESMO DEVE ',
		              'ESTAR NULO OU COM VALOR ZERO'                   
		  IF NOT pol1269_insere_erro() THEN
		     RETURN FALSE
		  END IF
	 END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1269_ck_datas()#
#--------------------------#

   IF p_dat_ini IS NULL THEN
      LET p_msg = 'O TRIM NAO ENVIOU A DATA INICIAL DA PRODUCAO'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fim IS NULL THEN
      LET p_msg = 'O TRIM NAO ENVIOU A DATA FINAL DA PRODUCAO'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_ini IS NOT NULL AND p_dat_fim IS NOT NULL THEN
      IF NOT pol1269_valida_datas() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1269_valida_datas()#
#------------------------------#
   
   LET p_man.dat_ini_producao = EXTEND(p_dat_ini, YEAR TO DAY)
   LET p_man.dat_fim_producao = EXTEND(p_dat_fim, YEAR TO DAY)
   LET p_man.hor_inicial = '00:00:00'
   LET p_man.hor_fim = '00:00:00'
   
   IF p_man.dat_ini_producao > p_man.dat_fim_producao THEN
      LET p_msg = 'A DATA INICIAL DA PRODUCAO ESTA MAIOR QUE DATA FINAL '
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.dat_fim_producao > TODAY THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO ESTA MAIOR QUE DATA ATUAL'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_man THEN
         LET p_msg = 'DATA DE PRODUCAO INVALIDA - MANUFATRUA JA FECHADA - VER C/ SETOR FISCAL'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_man.dat_fim_producao < p_dat_fecha_ult_sup THEN
         LET p_msg = 'DATA DE PRODUCAO INVALIDA - ESTOQUE JA FECHADO - VER C/ SETOR FISCAL'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol1269_le_item_ctr_grade(p_cod_item)
#--------------------------------------------#

   DEFINE p_cod_item   LIKE item.cod_item,
          p_achou      SMALLINT

   LET p_achou = FALSE
   
   DECLARE cq_ctr CURSOR FOR
    SELECT ies_largura,
           ies_altura,
           ies_diametro,
           ies_comprimento,
           reservado_2,
           ies_dat_producao
      FROM item_ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = p_cod_item

   FOREACH cq_ctr INTO
           p_ies_largura,
           p_ies_altura,
           p_ies_diametro,
           p_ies_comprimento,
           p_ies_serie,
           p_ies_dat_producao

      IF STATUS <> 0 THEN
         LET p_msg = p_cod_item CLIPPED,'ERRO:(',STATUS, ') LENDO ITEM_CTR_GRADE'  
         RETURN FALSE
      END IF

      LET p_achou = TRUE
      EXIT FOREACH

   END FOREACH
   
   IF NOT p_achou THEN
      LET p_ies_largura      = 'N'
      LET p_ies_altura       = 'N'
      LET p_ies_diametro     = 'N'
      LET p_ies_comprimento  = 'N'
      LET p_ies_dat_producao = 'N'
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1269_ck_estorno()#
#----------------------------#
     
   INITIALIZE p_num_seq_orig TO NULL
   
   LET p_qtd_trim = p_qtd_trim * (-1)
   
   DECLARE cq_cec_est CURSOR FOR
    SELECT numsequencia
      FROM apont_trim_885
     WHERE codempresa = p_cod_empresa
       AND numpedido  = p_man.num_pedido
       AND coditem    = p_item_trim
       AND numordem   = p_ordem_trim
       AND codmaquina = p_man.cod_recur
       AND inicio     = p_dat_ini
       AND fim        = p_dat_fim
       AND qtdprod    = p_qtd_trim
       AND tipmovto   = p_man.tip_movto
       AND statusregistro = '1'
       AND numsequencia IN 
           (SELECT DISTINCT num_seq_apont
              FROM apont_trans_885
             WHERE cod_empresa   = p_cod_empresa
               AND cod_tip_apon  = 'A'           #A=Apontamento B=Baixa do material
               AND cod_tip_movto = 'N')          #N=Movimento normal R=Reversão

   FOREACH cq_cec_est INTO p_num_seq_orig
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTORNO - CURSOR CQ_CEC_EST'
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
            
   IF p_num_seq_orig IS NULL THEN
      LET p_msg = 'ESTORNO DE APONTAMENTO NAO ENVIADO AO LOGIX: ',
                  'O TRIM ENVIOU UM ESTORNO DE UM APONTAMENTO INEXISTENTE'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT consumorefugo
        INTO p_man.consumo_refugo
        FROM apont_trim_885
       WHERE codempresa   = p_cod_empresa
         AND numsequencia = p_num_seq_orig
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_TRIM_885'
         RETURN FALSE
      END IF
            
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1269_checa_apont()#
#-----------------------------#

   DEFINE p_seq_txt     CHAR(15)

   SELECT empresa
     FROM man_apo_mestre
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_num_seq_apo_mestre

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_num_seq_apo_mestre
      LET p_mensagem = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
              ' NAO ENCONTRADO NA TAB MAN_APO_MESTRE'
      LET p_msg = p_mensagem
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONTAMEMNTO NA TABELA MAN_APO_MESTRE'  
         RETURN FALSE
      END IF
   END IF

   SELECT cod_empresa
     FROM apo_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = p_num_seq_apo_oper

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_num_seq_apo_oper
      LET p_mensagem = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
                  ' NAO ENCONTRADO NA TAB APO_OPER'
      LET p_msg = p_mensagem
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONTAMEMNTO NA TABELA APO_OPER'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
                   
#------------------------------------#
FUNCTION pol1269_le_recursos(p_apont)#
#------------------------------------#
  
   DEFINE p_parametro  LIKE consumo.parametro,
          p_apont      CHAR(01),
          l_achou      SMALLINT
   
   SELECT cod_operac,
          cod_cent_trab,
          cod_cent_cust,
          cod_arranjo,
          ies_onduladeira
     INTO p_man.operacao,
          p_man.centro_trabalho,
          p_man.centro_custo,
          p_man.arranjo,
          p_ies_onduladeira
     FROM de_para_maq_885 
    WHERE cod_empresa = p_cod_empresa
      AND cod_maq_trim = p_man.cod_recur

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO RECURSOS DA TABELA DE_PARA_MAQ_885'
      RETURN FALSE
   END IF
   
   IF p_ies_onduladeira IS NULL OR p_ies_onduladeira = ' ' THEN
      LET p_ies_onduladeira = 'N'
   END IF

   IF p_apont = 'O' THEN
      IF p_ies_onduladeira = 'S' THEN
         IF NOT pol1269_troca_of() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_man.cod_roteiro IS NULL OR p_man.cod_roteiro = ' ' THEN
      LET p_msg = 'ROTEIRO DA TABELA ORDENS ESTA NULO: CONSULTE O OP NO MAN0515'
      RETURN FALSE
   END IF
   
   IF p_man.altern_roteiro IS NULL OR p_man.altern_roteiro = ' ' THEN
      LET p_msg = 'ROTEIRO ALTERNATIVO DA TABELA ORDENS ESTA NULO: CONSULTE O OP NO MAN0515'
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   
   DECLARE cq_consumo CURSOR FOR
   SELECT seq_operacao, operacao_final
     FROM man_processo_item
    WHERE empresa             = p_cod_empresa
      AND item                = p_man.item
      AND operacao            = p_man.operacao
      AND roteiro             = p_man.cod_roteiro 
      AND roteiro_alternativo = p_man.altern_roteiro
   
   FOREACH cq_consumo INTO 
           p_man.sequencia_operacao,
           p_ies_oper_final
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA MAN_PROCESSO_ITEM'
         RETURN FALSE
      END IF
      
      LET l_achou = TRUE
      
      EXIT FOREACH
   
   END FOREACH

   IF NOT l_achou THEN
      LET p_msg = 'OPERACAO ', p_man.operacao CLIPPED, ' INEXISTENTE NA TAB MAN_PROCESSO_ITEM'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1269_troca_of()#
#--------------------------#
   
   DEFINE op_chapa     LIKE ordens.num_ordem,
          it_chapa     LIKE ordens.cod_item,
          rot_chapa    LIKE ordens.cod_roteiro,
          alt_chapa    LIKE ordens.num_altern_roteiro,
          p_achou      SMALLINT
   
   SELECT DISTINCT num_docum
     INTO p_num_docum
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_man.ordem_producao
     
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO NUM. DOCUM. DA TABELA ORDEM'
      RETURN FALSE
   END IF  
   
   LET p_achou = FALSE
   
   DECLARE cq_chapa CURSOR FOR
    SELECT num_ordem,
           cod_item,
           cod_roteiro,
           num_altern_roteiro
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND num_docum = p_num_docum
       AND cod_item_pai = p_man.item
   
   FOREACH cq_chapa INTO 
          op_chapa,
          it_chapa,
          rot_chapa,
          alt_chapa
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO OP DA CHAPA DA TABELA ORDEM'
         RETURN FALSE
      END IF  
      
      IF NOT pol1269_le_item_vdp(it_chapa) THEN
         RETURN FALSE
      END IF
            
      IF p_ies_chapa THEN
         LET p_achou = TRUE
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_msg = 'NAO FOI LOCALIZADA A OP DA CHAPA, PARA O PEDIDO ', p_num_docum
      RETURN FALSE
   END IF   
   
   LET p_man.ordem_producao = op_chapa
   LET p_man.item = it_chapa
   LET p_man.cod_roteiro = rot_chapa
   LET p_man.altern_roteiro = alt_chapa
   LET p_man.qtd_movto = p_man.peso_teorico

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1269_le_item_vdp(p_cod_item)#
#---------------------------------------#
   
   DEFINE p_cod_item       LIKE item.cod_item,
          p_cod_grupo_item LIKE item_vdp.cod_grupo_item,
          p_cod_tipo       LIKE grupo_produto_885.cod_tipo
   
   LET p_ies_chapa = FALSE

	  SELECT cod_grupo_item
	    INTO p_cod_grupo_item
	    FROM item_vdp
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM_VDP ', p_cod_item
      RETURN FALSE
   END IF

   SELECT cod_tipo
     INTO p_cod_tipo
     FROM grupo_produto_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_grupo   = p_cod_grupo_item

   IF STATUS = 100 THEN
      RETURN TRUE
   END IF
	  
	 IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO GRUPO_PRODUTO_885'
      RETURN FALSE
   END IF

   IF p_cod_tipo = '2' THEN
      LET p_ies_chapa = TRUE
   END IF	 
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1269_le_item_man(p_item)#
#-----------------------------------#
   
   DEFINE p_item CHAR(15)
   
   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.cod_familia,
          b.ies_sofre_baixa,
          a.ies_tip_item,
          a.cod_lin_prod
     INTO p_cod_local_orig,
          p_ctr_estoque,
          p_ctr_lote,
          p_cod_familia,
          p_sobre_baixa,
          p_ies_tip_item,
          p_cod_lin_prod
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_item
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM/ITEM_MAN'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol1269_le_estoque(p_item, p_local)#
#-------------------------------------------#
   
   DEFINE p_item              CHAR(15),
          p_local             CHAR(10),
          p_saldo_ender       DECIMAL(10,3),
          p_saldo_lote        DECIMAL(10,3),
          p_saldo_estoque     DECIMAL(10,3),
          p_qtd_reservada     DECIMAL(10,3)
          
   SELECT SUM(qtd_saldo)
     INTO p_saldo_ender
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
	    AND cod_local     = p_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT SUM(qtd_saldo)
     INTO p_saldo_lote
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
	    AND cod_local     = p_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT qtd_liberada - qtd_reservada
     INTO p_saldo_estoque
     FROM estoque
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item
      AND cod_local   = p_local
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  
            
   IF p_saldo_ender IS NULL THEN
      LET p_saldo_ender = 0
   END IF

   IF p_saldo_lote IS NULL THEN
      LET p_saldo_lote = 0
   END IF      
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   IF p_saldo_ender < p_saldo_lote THEN
      LET p_qtd_estoque = p_saldo_ender
   ELSE
      LET p_qtd_estoque = p_saldo_lote
   END IF
   
   IF p_qtd_estoque < p_saldo_estoque THEN
      LET p_qtd_estoque = p_saldo_estoque
   END IF
   
   LET p_qtd_estoque = p_qtd_estoque - p_qtd_reservada
   
   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
FUNCTION pol1269_le_saldo(p_item, p_local, p_lote)#
#-------------------------------------------------#
   
   DEFINE p_item              CHAR(15),
          p_local             CHAR(10),
          p_lote              CHAR(15),
          p_saldo_ender       DECIMAL(10,3),
          p_saldo_lote        DECIMAL(10,3),
          p_saldo_estoque     DECIMAL(10,3),
          p_qtd_reservada     DECIMAL(10,3)
          
   SELECT SUM(qtd_saldo)
     INTO p_saldo_ender
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
	    AND cod_local     = p_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT SUM(qtd_saldo)
     INTO p_saldo_lote
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
	    AND cod_local     = p_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT qtd_liberada - qtd_reservada
     INTO p_saldo_estoque
     FROM estoque
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = p_item
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
      RETURN FALSE
   END IF  

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item
      AND cod_local   = p_local
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  
            
   IF p_saldo_ender IS NULL THEN
      LET p_saldo_ender = 0
   END IF

   IF p_saldo_lote IS NULL THEN
      LET p_saldo_lote = 0
   END IF      
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   IF p_saldo_ender < p_saldo_lote THEN
      LET p_qtd_estoque = p_saldo_ender
   ELSE
      LET p_qtd_estoque = p_saldo_lote
   END IF
   
   IF p_qtd_estoque < p_saldo_estoque THEN
      LET p_qtd_estoque = p_saldo_estoque
   END IF
   
   LET p_qtd_estoque = p_qtd_estoque - p_qtd_reservada
   
   RETURN TRUE

END FUNCTION

#Checar existencia de material dos itens que não são papéis, 
#pois esses itens serão enviados pelo trim juntamemto com o 
#apontamento. É um papel o item cuja familia seja igual a 001
#Descartar também componentes que não sobfrem baixa
#A Luciana pediu para não inconsistir itens comprados

#-----------------------------#
FUNCTION pol1269_ck_material()#
#-----------------------------#
   
   DECLARE cq_ck_mat CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao
       AND qtd_necessaria > 0

   FOREACH cq_ck_mat INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:cq_ck_mat'  
         RETURN FALSE
      END IF  

      IF NOT pol1269_le_item_man(p_cod_compon) THEN
         RETURN FALSE
      END IF
      
      IF p_cod_familia = '001' THEN    #descartar bobinas
         CONTINUE FOREACH
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto

      IF p_qtd_baixar <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_ies_tip_item MATCHES '[CT]' THEN
         CONTINUE FOREACH
      END IF

      IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
         
      IF NOT pol1269_le_estoque(p_cod_compon, p_cod_local_baixa) THEN
         RETURN FALSE
      END IF

      IF p_qtd_estoque < p_qtd_baixar THEN
         LET p_msg = 'ITEM: ',p_cod_compon CLIPPED, ' SALDO ', p_qtd_estoque USING '<<<<<<<.<<<',
                     ' NECES ', p_qtd_baixar USING '<<<<<<<.<<<'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF        
   
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1269_baixa_consumo_trim()#
#------------------------------------#
   
   DEFINE p_cons_unit       DECIMAL(17,7)
   
   LET p_necessidade = 0
   LET p_cod_tip_apon = 'B'

   DECLARE cq_cons_trim CURSOR FOR
    SELECT *
      FROM consumo_trimbox_885
     WHERE codempresa = p_cod_empresa
       AND numsequencia = p_man.num_seq_apont

   FOREACH cq_cons_trim INTO p_cons_trim.*

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB CONSUMO_TRIMBOX_885:CQ_CONS_TRIM'  
         RETURN FALSE
      END IF  

      IF p_ck_compon THEN
         IF NOT pol1269_ck_compon() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1269_le_item_man(p_cons_trim.coditem) THEN
         RETURN FALSE
      END IF
      
      LET p_cod_local_baixa = p_cod_local_orig
      LET p_cod_compon = p_cons_trim.coditem
      LET p_cons_unit = p_cons_trim.qtdconsumida / p_tot_apont
      LET p_qtd_baixar = p_man.qtd_movto * p_cons_unit
      
      IF p_qtd_baixar > 0 THEN
         LET p_necessidade = p_necessidade+ 1
         IF NOT pol1269_bx_pelo_fifo() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1269_ck_compon()#
#---------------------------#

   DEFINE p_tem_compon SMALLINT

   LET p_tem_compon = FALSE                                                            
                                                                                          
   DECLARE cq_tem_compon CURSOR FOR                                                       
   SELECT qtd_necessaria                                                                  
     FROM ord_compon                                                                      
    WHERE cod_empresa = p_cod_empresa                                                     
      AND num_ordem = p_man.ordem_producao                                                
      AND cod_item_compon = p_cons_trim.coditem                                           
                                                                                          
   FOREACH cq_tem_compon INTO p_qtd_necessaria                                            
                                                                                       
      IF STATUS <> 0 THEN                                                                 
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_TEM_COMPON'              
         RETURN FALSE                                                                     
      END IF                                                                              
                                                                                          
      LET p_tem_compon = TRUE                                                             
                                                                                          
      EXIT FOREACH                                                                        
                                                                                          
   END FOREACH                                                                            
                                                                                          
   IF p_tem_compon THEN     
      RETURN TRUE
   END IF

   SELECT COUNT(*)
     INTO p_count
     FROM item_altern
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_pai = p_man.item
      AND cod_item_compon = p_cons_trim.coditemorig
      AND cod_item_altern = p_cons_trim.coditem
      
   IF STATUS <> 0 THEN                                                              
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM_ALTERN:CQ_COMPON_ORIG'           
      RETURN FALSE                                                                  
   END IF                                                                           
      
   IF p_count > 0 THEN
      RETURN TRUE
   END IF
                                                             
   DECLARE cq_compon_orig CURSOR FOR                                                   
    SELECT qtd_necessaria                                                               
      FROM ord_compon                                                                   
     WHERE cod_empresa = p_cod_empresa                                                  
       AND num_ordem = p_man.ordem_producao                                             
       AND cod_item_compon = p_cons_trim.coditemorig                                    
                                                                                          
   FOREACH cq_compon_orig INTO p_qtd_necessaria                                        
                                                                                       
      IF STATUS <> 0 THEN                                                              
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_COMPON_ORIG'           
         RETURN FALSE                                                                  
      END IF                                                                           
                                                                                          
      LET p_tem_compon = TRUE                                                          
      EXIT FOREACH                                                                     
                                                                                          
   END FOREACH                                                                         
                                                                                          
   IF NOT p_tem_compon THEN  
      LET p_mensagem = 'ITEM PREVISTO ', p_cons_trim.coditemorig CLIPPED, ' ',
                       'ITEM UTILIZADO ', p_cons_trim.coditem CLIPPED, '.',
                       'ITEM PREVISTO NAO ESTA NA ESTRUTURA DA OP. USE O POL0647 P/ CORRIGIR'    
      LET p_msg = p_mensagem                                                           
      RETURN FALSE                                                                     
   END IF

   INSERT INTO item_altern(                                                            
          cod_empresa,                                                                     
         cod_item_pai,                                                                    
         cod_item_compon,                                                                 
         cod_item_altern,                                                                 
         qtd_necessaria,                                                                  
         pct_refug,                                                                       
         tmp_ressup_sobr) VALUES(                                                         
         p_cod_empresa,                                                                   
         p_man.item,                                                                      
         p_cons_trim.coditemorig,                                                         
         p_cons_trim.coditem,                                                             
         p_qtd_necessaria,0,0)                                                            
                                                                                       
   IF STATUS <> 0 THEN                                                              
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO ALTERNATIVO NA TAB ITEM_ALTERN'     
      RETURN FALSE                                                                  
   END IF                                                                           

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1269_baixa_material()#
#---------------------------------#
   
   LET p_cod_tip_apon = 'B'

   DECLARE cq_structure CURSOR FOR
    SELECT cod_item_pai,
           cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao

   FOREACH cq_structure INTO 
           p_necessidade,
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa
           

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_STRUCTURE'  
         RETURN FALSE
      END IF  

      IF NOT pol1269_le_item_man(p_cod_compon) THEN
         RETURN FALSE
      END IF

      IF p_cod_familia = '001' THEN    #descartar bobinas
         CONTINUE FOREACH              #pois o Trim envia
      END IF
      
      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto

      
      IF p_ies_tip_item = 'T' THEN
         CONTINUE FOREACH
      END IF

      IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF

      IF p_qtd_baixar <= 0 THEN
         LET p_qtd_baixar = 0.001
      END IF
      
      IF p_qtd_baixar > 0 THEN
         IF NOT pol1269_bx_pelo_fifo() THEN
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1269_bx_pelo_fifo()#
#------------------------------#   
   
   DEFINE p_qtd_reservada   DECIMAL(10,3), 
          p_qtd_saldo       DECIMAL(10,3),
          p_baixa_do_lote   DECIMAL(10,3),
          p_sdo_lote        DECIMAL(10,3)

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
   
   IF p_ctr_lote = 'S' THEN
    DECLARE cq_fifo CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_cod_compon
       AND cod_local = p_cod_local_baixa
       AND ies_situa_qtd = 'L'
       AND qtd_saldo > 0
       AND num_lote IS NOT NULL
       AND num_lote <> ' '
     ORDER BY dat_hor_producao     
   ELSE
    DECLARE cq_fifo CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = p_cod_compon
       AND cod_local = p_cod_local_baixa
       AND ies_situa_qtd = 'L'
       AND qtd_saldo > 0
       AND (num_lote IS NULL OR num_lote = ' ')
     ORDER BY dat_hor_producao     
   END IF
         
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER/CQ_FIFO'  
         RETURN FALSE
      END IF
      
      IF p_ctr_lote = 'S' THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND num_lote = p_estoque_lote_ender.num_lote
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND (num_lote IS NULL OR num_lote = ' ')
      END IF
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER/CQ_FIFO'  
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada

      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
      END IF
      
      IF p_ctr_lote = 'S' THEN
         SELECT qtd_saldo
           INTO p_sdo_lote
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND num_lote = p_estoque_lote_ender.num_lote
            AND ies_situa_qtd = 'L'
      ELSE
         SELECT qtd_saldo
           INTO p_sdo_lote
           FROM estoque_lote
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND (num_lote IS NULL OR num_lote = ' ')
            AND ies_situa_qtd = 'L'
      END IF
      
      IF STATUS = 100 THEN
         LET p_sdo_lote = 0
      ELSE      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE/CQ_FIFO - ', p_estoque_lote_ender.cod_item
            RETURN FALSE
         END IF
      END IF  
      
      LET p_sdo_lote = p_sdo_lote - p_qtd_reservada

      IF p_sdo_lote < p_baixa_do_lote THEN
         CONTINUE FOREACH
      END IF
      
      SELECT qtd_liberada - qtd_reservada
        INTO p_sdo_lote
        FROM estoque
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_estoque_lote_ender.cod_item
      
      IF STATUS = 100 THEN
         LET p_sdo_lote = 0
      ELSE     
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE/CQ_FIFO - ', p_estoque_lote_ender.cod_item
            RETURN FALSE
         END IF
      END IF  
        
      IF p_sdo_lote < p_baixa_do_lote THEN
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_baixa_do_lote
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
         LET p_qtd_baixar = 0
      END IF
      
      #Carrega record p_item, para chamada da func005, a qual
      #irá fazer a saída do material
      
      LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
      LET p_item.cod_item      = p_estoque_lote_ender.cod_item
      LET p_item.cod_local     = p_estoque_lote_ender.cod_local
      LET p_item.num_lote      = p_estoque_lote_ender.num_lote
      LET p_item.comprimento   = p_estoque_lote_ender.comprimento
      LET p_item.largura       = p_estoque_lote_ender.largura    
      LET p_item.altura        = p_estoque_lote_ender.altura     
      LET p_item.diametro      = p_estoque_lote_ender.diametro   
      LET p_item.cod_operacao  = p_cod_oper_sp
      LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
      LET p_item.qtd_movto     = p_baixa_do_lote

      IF p_item.qtd_movto = 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET p_item.dat_movto     = p_dat_movto
      LET p_item.ies_tip_movto = 'N'
      LET p_item.dat_proces    = p_dat_proces
      LET p_item.hor_operac    = p_hor_operac
      LET p_item.num_prog      = p_man.nom_prog
      LET p_item.num_docum     = p_man.ordem_producao
      LET p_item.num_seq       = 0
      LET p_item.tip_operacao  = 'S' #Saída
      LET p_item.usuario       = p_man.nom_usuario
      LET p_item.cod_turno     = p_man.turno
      LET p_item.trans_origem  = 0
      LET p_item.ies_ctr_lote  = p_ctr_lote
   
      IF NOT func005_insere_movto(p_item) THEN
         RETURN FALSE
      END IF
      
      LET p_tip_movto = 'S'
      LET p_qtd_movto = p_baixa_do_lote
      LET p_transac_consumo = p_num_trans_atual
      
      IF NOT pol1269b_insere_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

      IF NOT pol1269b_insere_man_consumo() THEN            
         RETURN FALSE                                        
      END IF                                 
      
      IF p_ies_relac = 'S' THEN                      
         IF NOT pol1269b_insere_relac() THEN            
            RETURN FALSE                                        
         END IF
      END IF                                 

      LET p_transac_apont = p_num_trans_atual

      IF NOT pol1269_ins_transacoes() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      IF p_ies_tip_item = 'C' THEN         
         
         SELECT cod_empresa FROM baixas_pendentes_885
          WHERE cod_empresa = p_cod_empresa
            AND num_sequencia = p_man.num_seq_apont
            AND cod_compon = p_cod_compon
            AND num_neces = p_necessidade
         
         IF STATUS <> 0 THEN
            INSERT INTO baixas_pendentes_885    
             VALUES (p_cod_empresa,           
                     p_man.num_seq_apont,     
                     p_man.ordem_producao,    
                     p_dat_movto,            
                     p_cod_compon,
                     p_qtd_baixar,
                     'SEM SALDO P/ BAIXAR',
                     p_necessidade)

            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TAB BAIXAS_PENDENTES_885'  
               RETURN FALSE
            END IF  
         END IF
      ELSE
         LET p_mensagem = 'ITEM: ', p_cod_compon CLIPPED, 
                     ' SEM SALDO SUFICIENTE P/ A BAIXAR'
         LET p_msg = p_mensagem
         RETURN FALSE
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1269_baixa_necessidade()#
#-----------------------------------#
   
   DEFINE p_num_neces      INTEGER
   
   DECLARE cq_neces CURSOR FOR
    SELECT cod_item_pai,
           qtd_necessaria
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao
       AND qtd_necessaria > 0

   FOREACH cq_neces INTO 
           p_num_neces, 
           p_qtd_necessaria

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_NECES'  
         RETURN FALSE
      END IF  

      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto

      UPDATE necessidades
         SET qtd_saida = qtd_saida + p_qtd_baixar
       WHERE cod_empresa = p_cod_empresa
         AND num_neces = p_num_neces    

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB NECESSIDADES'  
         RETURN FALSE
      END IF  
   
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1269_le_desconto()#
#-----------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd, 
          ies_apontado
     INTO p_pct_desc_valor,
          p_pct_desc_qtd,
          p_ies_apontado
    FROM desc_nat_oper_885
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_man.num_pedido
            
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA DESC_NAT_OPER_885'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1269_movto_estoque()#
#-------------------------------#   
   
   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
               
      #Carrega record p_item, para chamada da func005, a qual
      #irá fazer a saída do apontamento de refugo
      
   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO p_cod_local_estoq,
          p_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_man.empresa
      AND cod_item = p_man.item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO LOCAL DA TABELA ITEM: ', p_man.item 
      RETURN FALSE
   END IF
      
   LET p_item.cod_empresa   = p_man.empresa
   LET p_item.cod_item      = p_man.item
   LET p_item.cod_local     = p_cod_local_estoq
   
   IF p_ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   ELSE
      LET p_item.num_lote = p_man.lote
   END IF
      
   LET p_item.comprimento   = p_man.comprimento
   LET p_item.largura       = p_man.largura    
   LET p_item.altura        = p_man.altura     
   LET p_item.diametro      = p_man.diametro  
    
   LET p_item.cod_operacao  = p_cod_operacao
   
   LET p_item.ies_situa     = p_ies_situa
   LET p_item.qtd_movto     = p_qtd_movto
   LET p_item.dat_movto     = p_dat_movto
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.num_docum     = p_man.ordem_producao
   LET p_item.num_seq       = 0
   
   LET p_item.tip_operacao  = p_tip_operacao
   
   LET p_item.trans_origem  = 0
   LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.turno
   LET p_item.num_prog      = p_man.nom_prog
   
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF

   LET p_transac_apont = p_num_trans_atual

   IF NOT pol1269_ins_transacoes() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1269_ins_transacoes()#
#--------------------------------#

   INSERT INTO apont_trans_885        #será utilizada na rotina de estorno
      VALUES(p_cod_empresa,
             p_man.num_seq_apont,
             p_transac_apont,
             p_cod_tip_apon,
             p_ies_tip_movto,
             p_ies_implant)
             
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA APONT_TRANS_885'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1269_ins_apont()#
#---------------------------#

   LET p_man.empresa = p_cod_empresa
   LET p_man.dat_atualiz = CURRENT YEAR TO SECOND
   LET p_man.nom_prog = 'POL1269'
   LET p_man.nom_usuario = p_user
   LET p_man.num_versao = 1
   LET p_man.versao_atual = 'S'
   LET p_man.cod_status = '0'
   LET p_man.qtd_hor = 0         #não apontar tempo
   LET p_man.unid_produtiva = ' '
   
   SELECT ies_ctr_lote
     INTO p_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_man.item
   
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS DA TANBELA ITEM'
      RETURN FALSE
   END IF
   
   IF p_ctr_lote = 'N' THEN
      LET p_man.lote = NULL
   END IF

   LET p_man.operacao = ' '
   LET p_man.centro_trabalho = ' '
   LET p_man.centro_custo = NULL
   LET p_man.arranjo = ' '
   LET p_man.sequencia_operacao = 0
   
   INSERT INTO man_apont_885
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TANBELA man_apont_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1269_insere_relac()#
#------------------------------#
   
   LET p_est_trans_relac.cod_empresa = p_cod_empresa
   LET p_est_trans_relac.num_nivel = 0
   LET p_est_trans_relac.dat_movto = p_dat_movto
      
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto)
   VALUES(p_est_trans_relac.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA EST_TRANS_RELAC'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------FIM DO PROGRAMA--------------#
