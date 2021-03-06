#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1306                                                            #
# OBJETIVO: IMPORTA��O DE APONTAMENTOS DO PC_FACTORY                           #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/08/2016                                                         #
# ALTERADO:       www.resgatefacil.com.br                                      #
#------------------------------------------------------------------------------#
# Ver par�metros de exibi��o de tela e item sucata na LOG00087                 #
#------------------------------------------------------------------------------#
{
cDoc := GetSXENum("SC1","C1_NUM")
   SC1->(dbSetOrder(1))

   While SC1->(dbSeek(xFilial("SC1")+cDoc))
    ConfirmSX8()
    cDoc := GetSXENum("SC1","C1_NUM")
   EndDo


[MAIL] Falha na conexao com o servidor SMTP.

SERVER..: smtp.office365.com

PORT....: 587

USER....: nfe_albras@albras.com

TIMEOUT.: 30

AUTH....: TRUE

PROTOCOL: TLS

STATUS..: 54

DETAIL..: The HELLO command failed.



#Execu��o via bat-------------------------------------------------------------------------------#
# \\10.10.0.38\smartclient\totvssmartclient.exe -M -Q -P=pol1306.4GL -A=01 -C=tcp -E=logix_albras
#-----------------------------------------------------------------------------------------------#

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
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,
          g_msg                  CHAR(150)         
END GLOBALS

DEFINE    m_msg                  CHAR(150),
          m_erro                 CHAR(10),
          m_cod_empresa          CHAR(02),
          m_apont                SMALLINT,
          m_qtd_movto            DECIMAL(10,0),
          m_tip_movto            CHAR(01),
          m_terminado            CHAR(01),
          m_dtini_prod           DATE,
          m_dtfim_prod           DATE,
          m_hrini_prod           CHAR(08),
          m_hrfim_prod           CHAR(08),
          m_tip_integra          CHAR(01),
          m_integrado            INTEGER,
          m_cod_status           CHAR(01),
          m_qtd_tempo            INTEGER,
          m_dat_ini              DATE,
          m_dat_fim              DATE,
          m_dat_producao         DATE,
          m_hor_ini              CHAR(05),
          m_hor_fim              CHAR(05),
          m_qtd_hor              DECIMAL(10,2),
          m_qtd_estorno          DECIMAL(10,3),
          m_seq_reg_mestre       INTEGER,
          m_qtd_apont            DECIMAL(10,3),
          m_saldo_apont          DECIMAL(10,3),
          m_fat_conver           DECIMAL(12,5),
          m_qtd_conver           DECIMAL(15,3),
          m_tip_prod             CHAR(01),
          m_txt_resumo           CHAR(80),
          m_seq_processo         INTEGER,
          m_qtd_produzida        DECIMAL(10,3), 
          m_qtd_convertida       DECIMAL(10,3),
          m_mot_retrab           CHAR(15),
          m_mot_refugo           CHAR(15),
          m_ies_fecha_op         SMALLINT,
          m_cod_parada           CHAR(20),
          m_dat_proces           CHAR(20),
          m_chave_acesso         CHAR(19),
          m_dat_atu              CHAR(20)
          
DEFINE    m_cod_item             LIKE item.cod_item,
          m_num_ordem            LIKE ordens.num_ordem,
          m_ies_situa            LIKE ordens.ies_situa,
          m_ies_oper_final       LIKE ord_oper.ies_oper_final,
          m_cod_operac           LIKE ord_oper.cod_operac,
          m_num_seq_operac       LIKE ord_oper.num_seq_operac,
          m_num_docum            LIKE ordens.num_docum,
          m_cod_cent_cust        LIKE ord_oper.cod_cent_cust,
          m_ies_apontamento      LIKE ord_oper.ies_apontamento,
          m_cod_sucata           LIKE item.cod_item,
	        m_cod_local_prod       LIKE item.cod_local_estoq,
	        m_cod_local_estoq      LIKE item.cod_local_estoq,
	        m_pes_unit             LIKE item.pes_unit,
	        m_unid_item            LIKE item.cod_unid_med,
	        m_unid_sucata          LIKE item.cod_unid_med,
	        m_cod_motivo           LIKE defeito.cod_defeito
	        

DEFINE p_w_apont_prod   RECORD 													
   cod_empresa         char(2),                         
   cod_item            char(15), 
   num_ordem           integer, 
   num_docum           char(10), 
   cod_roteiro         char(15), 
   num_altern          dec(2,0), 
   cod_operacao        char(5), 
   num_seq_operac      dec(3,0), 
   cod_cent_trab       char(5), 
   cod_arranjo         char(5), 
   cod_equip           char(15), 
   cod_ferram          char(15), 
   num_operador        char(15), 
   num_lote            char(15), 
   hor_ini_periodo     datetime hour to minute, 
   hor_fim_periodo     datetime hour to minute, 
   cod_turno           dec(3,0), 
   qtd_boas            dec(10,3), 
   qtd_refug           dec(10,3), 
   qtd_total_horas     dec(10,2), 
   cod_local           char(10), 
   cod_local_est       char(10), 
   dat_producao        date, 
   dat_ini_prod        date, 
   dat_fim_prod        date, 
   cod_tip_movto       char(1), 
   estorno_total       char(1), 
   ies_parada          smallint, 
   ies_defeito         smallint, 
   ies_sucata          smallint, 
   ies_equip_min       char(1), 
   ies_ferram_min      char(1), 
   ies_sit_qtd         char(1), 
   ies_apontamento     char(1), 
   tex_apont           char(255), 
   num_secao_requis    char(10), 
   num_conta_ent       char(23), 
   num_conta_saida     char(23), 
   num_programa        char(8), 
   nom_usuario         char(8), 
   num_seq_registro    integer, 
   observacao          char(200), 
   cod_item_grade1     char(15), 
   cod_item_grade2     char(15), 
   cod_item_grade3     char(15), 
   cod_item_grade4     char(15), 
   cod_item_grade5     char(15), 
   qtd_refug_ant       dec(10,3), 
   qtd_boas_ant        dec(10,3), 
   tip_servico         char(1), 
   abre_transacao      smallint, 
   modo_exibicao_msg   smallint, 
   seq_reg_integra     integer, 
   endereco            integer, 
   identif_estoque     char(30), 
   sku                 char(25), 
   finaliza_operacao   char(1)
END RECORD

DEFINE l_parametro      RECORD
       cod_empresa      CHAR(02),
       num_ordem        INTEGER,
       qtd_apont        DECIMAL(10,3)
END RECORD

DEFINE m_cod_cent_trab  LIKE cent_trabalho.cod_cent_trab,
       m_den_cent_trab  LIKE cent_trabalho.den_cent_trab,
       m_ies_criticado  CHAR(01)

DEFINE m_qtd_erro       INTEGER,
       m_corte_periodo  INTEGER,
       m_tip_proces     CHAR(01),
       m_dat_criacao    DATETIME YEAR to second,
       m_hor_producao   char(05)

DEFINE p_nom_destinatario        CHAR(36),
       p_destinatario            CHAR(08),
       p_email_destinatario      CHAR(50),
       p_remetente               CHAR(08),
       p_email_remetente         CHAR(50),
       p_nom_remetente           CHAR(36),
       p_imp_linha               CHAR(80),
       p_titulo1                 CHAR(80),       
       p_titulo2                 CHAR(80),       
       p_arquivo                 CHAR(30),
       p_cod_cliente             CHAR(15),
       p_den_comando             CHAR(80),
       p_assunto                 CHAR(30),
       p_num_docum               CHAR(15),       
       p_dat_vencto              DATE,
       p_num_nf                  CHAR(10),
       p_val_saldo               DECIMAL(12,2),
       m_via_bat                 SMALLINT

   DEFINE l_nom_tela             CHAR(200)


MAIN   
   CALL log0180_conecta_usuario()
   
   CALL pol1306_exibe_tela()
         
   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_via_bat = TRUE
      LET m_tip_proces = 'B'
      LET m_ies_criticado = 'S'
      LET m_qtd_erro = 0

      INSERT INTO porc_pol1306_304
       VALUES(0,CURRENT,"PROCESSO VIA BAT",p_cod_empresa,p_user)   

      IF NOT pol1306_proc_manual() THEN
         RETURN
      END IF

      CALL pol1306_processa() RETURNING p_status            

   ELSE
      CALL log001_acessa_usuario("ESPEC999","")
         RETURNING p_status, p_cod_empresa, p_user
      
      LET m_via_bat = FALSE
      LET m_tip_proces = 'M'

      IF p_status <> 0 THEN
         RETURN
      END IF

      INSERT INTO porc_pol1306_304
       VALUES(0,CURRENT,"PROCESSO MANUAL",p_cod_empresa,p_user)      
      
      LET g_msg = NULL
      
      IF NOT pol1306_proc_manual() THEN
         CALL log0030_mensagem(g_msg,'info')
         RETURN
      END IF
      
      LET g_msg = NULL
      
      CALL pol1306_controle()

      UPDATE proces_export_factory
         SET proces_apont = 'N'
       WHERE cod_empresa = p_cod_empresa
      
      IF g_msg IS NOT NULL THEN
         CALL log0030_mensagem(g_msg,'info')         
      END IF
      
      CLOSE WINDOW w_pol1306
      
   END IF
          
   IF m_qtd_erro > 0  THEN
      CALL pol1306_envia_email()
      IF NOT m_via_bat THEN
         LET m_msg = 'Alguns apontamentos foram criticados\n',
                     'Consulte os erros pelo POL1308.'
         CALL log0030_mensagem(m_msg,'info')
      END IF
   END IF
   
   CLOSE WINDOW w_pol1306
         
END MAIN

#------------------------------#
FUNCTION pol1306_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL pol1306_exibe_tela()

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   INSERT INTO porc_pol1306_304
    VALUES(0,CURRENT,"Automatico",l_param1_empresa,l_param2_user)

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF

   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF      
   
   LET m_tip_proces = 'A'
   LET m_ies_criticado = 'S'
   LET m_qtd_erro = 0
   LET m_cod_cent_trab =  ''
   LET p_status = FALSE
   
   IF pol1306_proc_manual() THEN
      CALL pol1306_processa() RETURNING p_status
   END IF
   
   IF m_qtd_erro > 0 THEN
      LET m_dat_proces = CURRENT
      CALL pol1306_envia_email()
   END IF
   
   CLOSE WINDOW w_pol1306
   
   RETURN p_status
   
END FUNCTION   

#----------------------------#
FUNCTION pol1306_exibe_tela()#
#----------------------------#

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 60

   LET p_versao = "pol1306-12.00.41  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1306") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1306 AT 5,07 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET g_tipo_sgbd = LOG_getCurrentDBType()

END FUNCTION

#--------------------------#
FUNCTION pol1306_controle()#
#--------------------------#

   LET INT_FLAG = FALSE
   LET m_qtd_erro = 0
   LET m_ies_criticado = 'N'
   
   INPUT m_cod_cent_trab, m_ies_criticado
      WITHOUT DEFAULTS FROM cod_cent_trab, ies_criticado
      
      AFTER FIELD cod_cent_trab    
         IF m_cod_cent_trab IS NOT NULL THEN
            SELECT den_cent_trab
              INTO m_den_cent_trab
              FROM cent_trabalho
             WHERE cod_empresa = p_cod_empresa
               AND cod_cent_trab = m_cod_cent_trab
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','cent_trabalho')
               NEXT FIELD cod_cent_trab
            END IF
            DISPLAY m_den_cent_trab to den_cent_trab
         END IF 

      AFTER INPUT     
         IF m_ies_criticado IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio.'
            NEXT FIELD ies_criticado
         END IF
         

      ON KEY (control-z)
         CALL pol1306_popup()
   
   END INPUT
   
   IF INT_FLAG THEN
      RETURN 
   END IF
      
   IF NOT log004_confirm(18,35) THEN
      RETURN
   END IF

   CALL pol1306_processa() RETURNING p_status
   
END FUNCTION

#-----------------------#
 FUNCTION pol1306_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cent_trab)
         CALL log009_popup(8,10,"CENTRO DE TRABALHO","cent_trabalho",
              "cod_cent_trab","den_cent_trab","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET m_cod_cent_trab = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cent_trab
         END IF
   END CASE 

END FUNCTION 
   
#---------------------------------#
FUNCTION pol1306_proc_automatico()#
#---------------------------------#

   DEFINE l_proces_apont    CHAR(01),
          l_proces_import   CHAR(01),
          l_dat_atu         CHAR(20)
   
   LET l_dat_atu = CURRENT
      
   SELECT proces_apont,
          dat_proces,
          proces_import
     INTO l_proces_apont,
          m_dat_proces,
          l_proces_import
     FROM proces_export_factory
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS = 100 THEN
      INSERT INTO proces_export_factory(
        cod_empresa, proces_export, proces_import,
        proces_apont, dat_proces)
       VALUES(p_cod_empresa,'N','N','S',l_dat_atu)
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS USING '<<<<<<<<', ' LENDO TABELA proces_export_factory'
         INSERT INTO porc_pol1306_304
          VALUES(0,CURRENT,m_msg,p_cod_empresa,p_user)
         RETURN FALSE
      ELSE         
         IF l_proces_apont = 'S' AND pol1306_retornar() THEN
            LET m_msg = 'O POL1306 EST� EM EXECU��O NO MOMENTO'
            LET g_msg = m_msg
            INSERT INTO porc_pol1306_304
             VALUES(0,CURRENT,m_msg,p_cod_empresa,p_user)
             
            UPDATE proces_export_factory
              SET proces_apont = 'N'
             WHERE cod_empresa = p_cod_empresa
            RETURN FALSE
            
         ELSE
            UPDATE proces_export_factory
               SET proces_apont = 'S',
                   dat_proces = l_dat_atu
             WHERE cod_empresa = p_cod_empresa
         END IF            
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1306_proc_manual()#
#-----------------------------#

   DEFINE l_proces_apont    CHAR(01),
          l_proces_import   CHAR(01)
          
   
   LET m_dat_atu = CURRENT
      
   SELECT proces_apont,
          dat_proces,
          proces_import
     INTO l_proces_apont,
          m_dat_proces,
          l_proces_import
     FROM proces_export_factory
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO ',STATUS USING '<<<<<<<<', ' LENDO TABELA proces_export_factory'
      INSERT INTO porc_pol1306_304
       VALUES(0,m_dat_atu,m_msg,p_cod_empresa,p_user)
      RETURN FALSE
   END IF
   
   IF l_proces_import = 'S'  THEN
      LET m_msg = 'O PGI1310 EST� EM EXECU��O NO MOMENTO'
      LET g_msg = m_msg
      CALL pol1306_grava_msg() RETURNING p_status
      RETURN FALSE
   END IF
         
   IF l_proces_apont = 'S' THEN
      LET m_msg = 'O POL1306 EST� EM EXECU��O NO MOMENTO'
      LET g_msg = m_msg
      CALL pol1306_grava_msg() RETURNING p_status
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1306_grava_msg()#
#---------------------------#

   INSERT INTO porc_pol1306_304
    VALUES(0,m_dat_atu,m_msg,p_cod_empresa,p_user)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   UPDATE proces_export_factory
      SET proces_apont = 'N',
          proces_import = 'N',
          dat_proces = m_dat_atu
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1306_retornar()#
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
   
   IF l_temp_dif > 1800 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1306_processa()#
#--------------------------#   
   
   DEFINE l_ret    SMALLINT

   UPDATE proces_export_factory
      SET proces_apont = 'S'
    WHERE cod_empresa = p_cod_empresa
      
   LET m_msg = NULL

   IF m_cod_cent_trab IS NULL THEN
      LET m_cod_cent_trab =  ''
   END IF
      
   LET g_id_man_apont = 0
   CALL pol1306_aponta()
   
   IF m_msg IS NULL THEN
      LET g_id_man_apont = 0
      CALL pol1306_estorna()
   END IF
   
   IF m_msg IS NULL THEN
      LET l_ret = TRUE
      LET m_msg = 'SUCESSO'
   ELSE
      LET l_ret = FALSE
   END IF

   CALL pol1306_grava_msg() RETURNING p_status
   
   {IF m_tip_proces <> 'B' THEN
      IF NOT pol1306_chama_delphi() THEN
         INSERT INTO porc_pol1306_304
          VALUES(0,m_dat_atu,m_msg,p_cod_empresa,p_user)
      END IF
   END IF  }    
   
   RETURN l_ret
   
END FUNCTION   
   
#------------------------------#
FUNCTION pol1306_chama_delphi()#
#------------------------------#

   DEFINE l_param         CHAR(01),
          p_comando       CHAR(200),
          l_proces        CHAR(01),
          l_carac         CHAR(01)
  
   LET p_caminho = NULL
  
   DECLARE cq_caminho CURSOR FOR
    SELECT nom_caminho
      FROM path_logix_v2
     WHERE cod_empresa = p_cod_empresa
       AND cod_sistema = 'DPH'

   FOREACH cq_caminho INTO p_caminho
     
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',m_erro CLIPPED,
            ' LENDO CAMINHO DE DIRETORIO DO SISTEMA DPH.'
         LET g_msg = m_msg
         RETURN FALSE
      END IF
     
      EXIT FOREACH
   END FOREACH
  
   IF p_caminho IS NULL THEN
      LET m_msg = 'Caminho do sistema DPH n�o en-\n',
                  'contrado. Consulte a log1100.'
      LET g_msg = m_msg
      RETURN FALSE
   END IF

   {UPDATE proces_export_factory
      SET proces_import = 'S'
    WHERE cod_empresa = p_cod_empresa}
                  
   LET p_comando = p_caminho CLIPPED, 'pgi1310.exe' #, m_cod_cent_trab #colocar nome do pgi aqui

   INSERT INTO porc_pol1306_304
    VALUES(0,m_dat_atu,p_comando,p_cod_empresa,p_user)

   CALL conout(p_comando)                            #tirar o comentario

   INSERT INTO porc_pol1306_304
    VALUES(0,m_dat_atu,p_comando,p_cod_empresa,p_user)
   
   
   IF m_tip_proces = 'M' THEN
      CALL runOnClient(p_comando)
   ELSE
      LET p_comando = p_comando CLIPPED
      RUN p_comando RETURNING p_status
   END IF

   #------------------#

   RETURN TRUE
   
   #------------------#


   DISPLAY 'Carregando apontamentos ' AT 12,14
       #lds CALL LOG_refresh_display()

   LET l_carac = '/'
   LET l_proces = 'S'
   
   WHILE l_proces = 'S'
   
      SELECT proces_import
        INTO l_proces
        FROM proces_export_factory
       WHERE cod_empresa = p_cod_empresa
   
       IF STATUS <> 0 THEN
          LET l_proces = 'N'
       END IF
   
       IF l_carac = '/' THEN
          LET l_carac = '-'
       ELSE
          LET l_carac = '/'
       END IF
       
       DISPLAY l_carac AT 12,45
       #lds CALL LOG_refresh_display()
       
       SLEEP 1
       
   END WHILE    

   DISPLAY 'conclu�do.' AT 12,45
   #lds CALL LOG_refresh_display()
  
   RETURN TRUE      

END FUNCTION   

#--------------------------------------#
FUNCTION pol1306_prende_registros(l_op)#
#--------------------------------------#
   
   DEFINE l_op      CHAR(01)
   
   SET LOCK MODE TO WAIT 300 
   
   LOCK TABLE man_apont_304 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' BLOQUEANDO A TABELA MAN_APONT_304'
      RETURN FALSE
   END IF 
   
   LET m_chave_acesso = EXTEND(CURRENT, YEAR TO SECOND)
   
   IF l_op = 'A' THEN
      UPDATE man_apont_304
         SET chave_acesso = m_chave_acesso
		    WHERE cod_empresa = p_cod_empresa
		      AND tip_integra <> 'E'
		      AND (integrado = 1 OR (integrado = 3 AND m_ies_criticado = 'S'))
		      AND (chave_acesso IS NULL OR chave_acesso = ' ')
   ELSE
      UPDATE man_apont_304
         SET chave_acesso = m_chave_acesso
		    WHERE cod_empresa = p_cod_empresa
		      AND tip_integra = 'E'
		      AND (integrado = 1 OR (integrado = 3 AND m_ies_criticado = 'S'))
		      AND (chave_acesso IS NULL OR chave_acesso = ' ')
   END IF
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' GRAVANDO CHAVE DE ACESSO NA TABELA MAN_APONT_304'
      RETURN FALSE
   END IF 
   
   SET LOCK MODE TO WAIT 60 
   
   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol1306_le_ordens()#
#----------------------------#       

      SELECT cod_local_prod,
             cod_local_estoq,
             num_lote,
             ies_situa,
             num_docum,
             cod_roteiro,
             num_altern_roteiro,
             cod_item
        INTO p_w_apont_prod.cod_local,
             p_w_apont_prod.cod_local_est,	
             p_w_apont_prod.num_lote,
             m_ies_situa,
             p_w_apont_prod.num_docum,
             p_w_apont_prod.cod_roteiro,
             p_w_apont_prod.num_altern,
             p_w_apont_prod.cod_item
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem

      IF STATUS = 100 THEN            
         LET m_msg = ' - A ordem enviada pelo PPI n�o existe no logix '
         IF NOT pol1306_grava_erro() THEN
            RETURN FALSE
         END IF
	 	     RETURN TRUE
      ELSE         
         IF STATUS <> 0 THEN            
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO DADOS DA TAB ORDENS'
            RETURN FALSE
         END IF
      END IF 

      SELECT cod_cent_trab,
          cod_arranjo,
          num_seq_operac,
          cod_cent_cust,
          ies_apontamento
        INTO p_w_apont_prod.cod_cent_trab,
          p_w_apont_prod.cod_arranjo,
          p_w_apont_prod.num_seq_operac,
          m_cod_cent_cust,
          m_ies_apontamento          
        FROM ord_oper
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem
         AND cod_operac = p_w_apont_prod.cod_operacao

      IF STATUS = 100 THEN            
         LET m_msg = ' - A opera��o enviada pelo PPI n�o existe p/ a OP ', m_num_ordem
         IF NOT pol1306_grava_erro() THEN
            RETURN FALSE
         END IF
	 	     RETURN TRUE
      ELSE         
         IF STATUS <> 0 THEN            
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO DADOS DA TAB ORD_OPER'
            RETURN FALSE
         END IF
      END IF 
      
      UPDATE man_apont_304
         SET cod_item = p_w_apont_prod.cod_item,
             cod_roteiro = p_w_apont_prod.cod_roteiro,
             num_rot_alt = p_w_apont_prod.num_altern,
             num_docum = p_w_apont_prod.num_docum,
      		   num_lote = p_w_apont_prod.num_lote,
      		   num_seq_operac = p_w_apont_prod.num_seq_operac,
      		   cod_cent_trab = p_w_apont_prod.cod_cent_trab,
      		   cod_cent_cust = m_cod_cent_cust,
      		   cod_arranjo = p_w_apont_prod.cod_arranjo,
      		   cod_local_prod = p_w_apont_prod.cod_local,
      		   cod_local_est = p_w_apont_prod.cod_local_est
       WHERE cod_empresa = p_cod_empresa
         AND id_registro = g_id_man_apont

      IF STATUS <> 0 THEN            
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO DADOS NA TAB MAN_APONT_304'
         RETURN FALSE
      END IF
      		         		   
      RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1306_grava_erro()#
#-----------------------------#       
   
	  IF NOT pol1306_ins_erro() THEN
	     RETURN FALSE
	  END IF

    LET m_cod_status = 'C'      
    LET m_integrado = 3
         
  	IF NOT pol1306_atu_man() THEN
	 	   RETURN FALSE
	 	END IF
	 	
	 	RETURN TRUE

END FUNCTION	 	
   
#-------------------------#
 FUNCTION pol1306_aponta()
#-------------------------#       
   
   DEFINE l_count     INTEGER,
          l_data      CHAR(19)
   
   IF NOT pol1306_cria_w_parada() THEN
      RETURN
   END IF
      				
   DISPLAY 'Apontando Ordem: ' AT 14,14
    #lds CALL LOG_refresh_display()

   {
   CALL log085_transacao("BEGIN")

   IF NOT pol1306_prende_registros("A") THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF   
   
   CALL log085_transacao("COMMIT")
   }
   
   DECLARE cq_apont CURSOR WITH HOLD FOR 	
    SELECT cod_empresa,
           cod_item,
           num_ordem,
           num_docum,
           cod_operac,
           num_seq_operac,
           cod_cent_trab,
           cod_turno,
           cod_arranjo,
           cod_eqpto,
           cod_ferramenta,
           hor_inicial,
           hor_final,
           qtd_refugo,
           qtd_movto,
           qtd_hor,
           cod_local_prod,
           cod_local_est, 
           dat_inicial,
           dat_final,
           matricula,
		       ies_terminado, 
		       id_registro,
		       num_lote, 
		       cod_roteiro, 
		       num_rot_alt,
		       unid_funcional,
		       cod_status,
		       tip_integra,
		       tip_movto,
		       qtd_tempo,
		       motivo_retrab,
		       motivo_refugo,
		       cod_parada,
		       dat_criacao
      FROM man_apont_304
		 WHERE cod_empresa = p_cod_empresa
		   AND tip_integra <> 'E'
		   AND (integrado = 1 OR integrado = 3)
	   ORDER BY id_registro
			         	 
	 FOREACH cq_apont INTO 	
	    p_w_apont_prod.cod_empresa,
			p_w_apont_prod.cod_item,
			p_w_apont_prod.num_ordem,
			p_w_apont_prod.num_docum,
			p_w_apont_prod.cod_operacao ,
			p_w_apont_prod.num_seq_operac,
			p_w_apont_prod.cod_cent_trab ,
			p_w_apont_prod.cod_turno ,
			p_w_apont_prod.cod_arranjo ,
			p_w_apont_prod.cod_equip ,
			p_w_apont_prod.cod_ferram ,
			p_w_apont_prod.hor_ini_periodo,
			p_w_apont_prod.hor_fim_periodo,
			p_w_apont_prod.qtd_refug ,
			m_qtd_movto,
			p_w_apont_prod.qtd_total_horas ,
			p_w_apont_prod.cod_local ,
			p_w_apont_prod.cod_local_est ,
			p_w_apont_prod.dat_ini_prod ,
			p_w_apont_prod.dat_fim_prod ,
			p_w_apont_prod.num_operador ,
			p_w_apont_prod.finaliza_operacao,
			g_id_man_apont,
			p_w_apont_prod.num_lote,
			p_w_apont_prod.cod_roteiro,
			p_w_apont_prod.num_altern,
			p_w_apont_prod.num_secao_requis,
			m_cod_status,
			m_tip_integra,
			m_tip_movto,
			m_qtd_tempo,
			m_mot_retrab,
			m_mot_refugo,
			m_cod_parada,
			m_dat_criacao

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA MAN_APONT_304'
         RETURN
      END IF 

      IF NOT pol1306_ins_proces() THEN
         RETURN
      END IF
      
      LET m_hor_producao = EXTEND(m_dat_criacao, HOUR TO MINUTE)
      LET m_dat_producao = DATE(m_dat_criacao)
      
      DELETE FROM apont_erro_912
       WHERE cod_empresa = p_cod_empresa
         AND id_man_apont = g_id_man_apont

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' DELETANDO DADOS DA TAB APONT_ERRO_912'
         RETURN 
      END IF 

	    LET m_msg = NULL
	    LET m_cod_status = 'N'
      LET m_num_ordem  = p_w_apont_prod.num_ordem
      LET m_cod_operac = p_w_apont_prod.cod_operacao
	    
      IF NOT pol1306_le_ordens() THEN
         RETURN        
      END IF  
      
      IF m_cod_status = 'C' THEN
         CONTINUE FOREACH
      END IF      
	    
	    LET g_tem_critica = FALSE
      LET m_cod_item = p_w_apont_prod.cod_item
            
      DISPLAY m_num_ordem AT 14,33
      DISPLAY m_qtd_movto AT 14,50
       #lds CALL LOG_refresh_display()
                                 			
			IF p_w_apont_prod.cod_arranjo = ' '   OR
			   p_w_apont_prod.cod_arranjo IS NULL THEN 
				 LET p_w_apont_prod.cod_arranjo = 0
			END IF 
			
			IF p_w_apont_prod.cod_ferram = ' '   OR  
			   p_w_apont_prod.cod_ferram IS NULL THEN 
				 INITIALIZE p_w_apont_prod.cod_ferram  TO NULL
				 LET p_w_apont_prod.ies_ferram_min =  "N"
			ELSE 
					LET p_w_apont_prod.ies_ferram_min =  "S"
			END IF 				
			
			IF p_w_apont_prod.cod_equip = ' '   OR 
			   p_w_apont_prod.cod_equip IS NULL THEN
				 LET p_w_apont_prod.ies_equip_min = "N"
         INITIALIZE p_w_apont_prod.cod_equip  TO NULL		 
			ELSE
				 LET p_w_apont_prod.ies_equip_min = "S"	
			END IF 
			
 	    DELETE FROM w_parada

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LIMPANDO DADOS DA TAB W_PARADA'
         RETURN 
      END IF
    
 			LET p_w_apont_prod.dat_producao	        =	p_w_apont_prod.dat_fim_prod

		  IF m_tip_integra MATCHES  "[PT]" THEN				
         IF p_w_apont_prod.hor_ini_periodo = p_w_apont_prod.hor_fim_periodo THEN
	 			    LET m_integrado = 9	 
	 			    LET m_cod_status = 'D'
      	 	  IF NOT pol1306_atu_man() THEN
	 	          RETURN
	 	        END IF
            CONTINUE FOREACH
         END IF
   	     
   	     IF NOT pol1306_acerta_turno(p_w_apont_prod.cod_turno) THEN
   	        RETURN
   	     END IF
   	      
   	     CALL pol1306_calc_hora(p_w_apont_prod.hor_ini_periodo,
   	            p_w_apont_prod.hor_fim_periodo)
   	               	      
         LET p_w_apont_prod.qtd_total_horas = m_qtd_hor
         
         UPDATE man_apont_304
            SET qtd_hor = m_qtd_hor,
                cod_turno = p_w_apont_prod.cod_turno
          WHERE cod_empresa = p_cod_empresa
            AND id_registro = g_id_man_apont

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZADNDO DADOS DA TAB MAN_APONT_304'
            RETURN 
         END IF
                   
         IF m_tip_integra =  "P" THEN		
            IF NOT pol1306_ins_paradas() THEN
               RETURN
            END IF
         END IF 
            
   	  ELSE
   	     IF NOT pol1306_le_hora(p_w_apont_prod.cod_turno) THEN
   	        RETURN
   	     END IF
   			 LET p_w_apont_prod.qtd_total_horas = 0
      END IF

 		  LET p_w_apont_prod.ies_defeito = 0
 		  LET p_w_apont_prod.ies_sucata = 0
	    LET p_w_apont_prod.qtd_boas = 0
	    LET p_w_apont_prod.qtd_refug = 0

			IF m_tip_movto = '2' THEN
         
         SELECT cod_item
           INTO m_cod_sucata
           FROM item_sucata_304
          WHERE cod_empresa = p_cod_empresa
            AND cod_operac = m_cod_operac

	       IF STATUS <> 0 AND STATUS <> 100 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LIMPANDO DADOS DA TAB ITEM_SUCATA_304'
            RETURN 
         END IF
         
         IF STATUS = 100 THEN
            LET m_cod_sucata = NULL
            LET p_w_apont_prod.ies_defeito = 1
            LET p_w_apont_prod.qtd_refug = m_qtd_movto
         ELSE
            LET p_w_apont_prod.ies_sucata = 1
         END IF   
      ELSE
   			 LET p_w_apont_prod.qtd_boas = m_qtd_movto
			END IF
			
			IF p_w_apont_prod.ies_sucata = 1 THEN
         IF NOT pol1306_gra_sucata() THEN
            RETURN                   
	    	 END IF
	    END IF 

      IF p_w_apont_prod.ies_defeito = 1  THEN             
         IF NOT pol1306_gra_defeito() THEN
            RETURN                   
	    	 END IF
		 	END IF 

      IF g_tem_critica THEN
      ELSE
         IF m_tip_integra = 'A' THEN	
            LET l_parametro.cod_empresa = p_cod_empresa
            LET l_parametro.num_ordem = m_num_ordem
            LET l_parametro.qtd_apont = m_qtd_movto
            LET m_msg = func006_checa_saldo(l_parametro)
            IF m_msg IS NOT NULL THEN
               CALL pol1306_ins_erro() RETURNING p_status
               RETURN
            END IF
         END IF
      END IF
      
      LET m_cod_status = 'N'
      
      IF g_tem_critica THEN 
         LET m_integrado = 3
  	 	   IF NOT pol1306_atu_man() THEN
	 	        RETURN
	 	     END IF
	 	     CONTINUE FOREACH
	 	  END IF
         
      LET m_integrado = 1

			LET p_w_apont_prod.estorno_total        = "N"
			LET p_w_apont_prod.cod_tip_movto        = 'N'
			LET p_w_apont_prod.ies_sit_qtd 					=	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL
			LET p_w_apont_prod.num_programa 				= 'POL1306'
			LET p_w_apont_prod.nom_usuario 					= p_user
			LET p_w_apont_prod.cod_item_grade1 			= NULL
			LET p_w_apont_prod.cod_item_grade2 			= NULL
			LET p_w_apont_prod.cod_item_grade3 			= NULL
			LET p_w_apont_prod.cod_item_grade4 			= NULL
			LET p_w_apont_prod.cod_item_grade5 			= NULL
			LET p_w_apont_prod.qtd_refug_ant 				= NULL
			LET p_w_apont_prod.qtd_boas_ant 				= NULL
			LET p_w_apont_prod.abre_transacao 			= 1
			LET p_w_apont_prod.modo_exibicao_msg 		= 1
			LET p_w_apont_prod.seq_reg_integra 			= NULL
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
			
			SELECT COUNT(*) INTO l_count  FROM w_parada
			
			IF l_count > 0 THEN
			   LET p_w_apont_prod.ies_parada = 1
			ELSE
			   LET p_w_apont_prod.ies_parada = 0
			END IF      

      IF NOT pol1306_le_ord_oper() THEN
         RETURN 
      END IF

      LET m_integrado = 3	
      LET m_cod_status = 'C'
      
      IF manr24_cria_w_comp_baixa (0) THEN
      END IF
      
	 	  IF manr24_cria_w_apont_prod(0)  THEN 

	 		   CALL man8246_cria_temp_fifo()
	 		   CALL man8237_cria_tables_man8237()
         
         LET m_ies_fecha_op = FALSE
         
         IF m_ies_situa = '5' THEN
            CALL pol1306_libera_op()
         END IF
        								
	 		   IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incluindo apontamento
	 			    IF manr27_processa_apontamento()  THEN #processando apontamento
	 			       LET m_integrado = 2	 
	 			       LET m_cod_status = 'A'
	 			    END IF 
	 	     ELSE
	 	        LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'
	 	        INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo,texto_detalhado)
	 	         VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo, m_txt_resumo) 
	 	     END IF 
	 	     IF m_ies_fecha_op THEN
	 	        BEGIN WORK
	 	        IF NOT pol1306_fecha_op() THEN
	 	           ROLLBACK WORK
	 	        ELSE
	 	           COMMIT WORK
	 	        END IF
	 	     END IF
	 	  ELSE
	 	     LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'
	 	     INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo,texto_detalhado)
	 	       VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo, m_txt_resumo) 
	 	  END IF

      IF m_integrado = 3 THEN
         IF NOT pol1306_le_erros() THEN
	 			    RETURN
	 			 END IF			     
	 	  END IF
	 	  
	 	  DELETE FROM w_apont_prod 
	 	  
	 	  IF NOT pol1306_atu_man() THEN
	 	     RETURN
	 	  END IF
	 	             	
   END FOREACH
    
END FUNCTION
   
#-----------------------------#
FUNCTION pol1306_libera_op()#
#-----------------------------#
   
   UPDATE ordens SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      RETURN
   END IF
               
   UPDATE necessidades SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      RETURN
   END IF
     
   LET m_ies_fecha_op = TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1306_fecha_op()#
#--------------------------#
   
   UPDATE ordens SET ies_situa = '5'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      RETURN FALSE
   END IF
               
   UPDATE necessidades SET ies_situa = '5'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN  
      RETURN FALSE
   END IF
     
END FUNCTION


#--------------------------#
FUNCTION pol1306_le_itens()#
#--------------------------#

   SELECT pes_unit,
          cod_unid_med
     INTO m_pes_unit, m_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB ITEM:PESO'
	    RETURN FALSE
	 END IF

   SELECT cod_unid_med
     INTO m_unid_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_sucata
	        
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB ITEM:SUCATA'
	    RETURN FALSE
	 END IF
	 
   RETURN TRUE

END FUNCTION
   
#----------------------------#
 FUNCTION pol1306_w_defeito()#
#----------------------------#
	
	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(10,3)
		)

	IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET m_msg = 'ERRO ',m_erro CLIPPED, ' CRIANDO TABELA W_DEFEITO '
     RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION 

#---------------------------#
 FUNCTION pol1306_w_sucata()
#---------------------------#
	
	DROP TABLE w_sucata

  CREATE TEMP TABLE w_sucata	(	
     cod_sucata      	CHAR(15),
     qtd_apont	        DECIMAL(15,3),
     fat_conversao	    DECIMAL(12,5),
     qtd_convertida  	DECIMAL(15,3),
     motivo_sucata 	  DECIMAL(3,0)
   );	

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' CRIANDO TABELA W_SUCATA '
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 
			
#-------------------------#
FUNCTION pol1306_atu_man()#
#-------------------------#

   UPDATE man_apont_304
      SET integrado = m_integrado,
          den_erro = m_msg,
          cod_status = m_cod_status
    WHERE id_registro = g_id_man_apont
      AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO TAB MAN_APONT_304 '
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1306_ins_proces()#
#----------------------------#
   
   DEFINE l_data      CHAR(19)
   
   LET l_data = EXTEND(CURRENT, YEAR TO SECOND)
   
   INSERT INTO apont_proces_304
    VALUES(g_id_man_apont, p_cod_empresa, l_data)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO DADOS NA TABELA APONT_PROCES_304'
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1306_le_erros()#
#--------------------------#
   
   DEFINE l_erro  CHAR(500)
   
   LET m_msg = ''
   
   DECLARE cq_erro CURSOR FOR 	
		SELECT texto_detalhado  	
		 	FROM man_log_apo_prod	
     WHERE empresa = p_cod_empresa
       AND ordem_producao = m_num_ordem
		  
   FOREACH cq_erro INTO l_erro	
  				
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO ERROS DA TAB MAN_LOG_APO_PROD '
         RETURN FALSE
      END IF 
      
      LET m_msg = l_erro 

 	    IF NOT pol1306_ins_erro() THEN
 	       RETURN FALSE
 	    END IF
   
   END FOREACH
   
   LET m_msg = ''
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1306_ins_erro()#
#--------------------------#
   
   LET g_tem_critica = TRUE
   LET m_qtd_erro = m_qtd_erro + 1
   
   INSERT INTO apont_erro_912
    VALUES(p_cod_empresa, g_id_man_apont, m_msg, m_num_ordem)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO DADOS NA TAB APONT_ERRO_912'
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION   
    
#----------------------------#
 FUNCTION pol1306_w_estorna()#
#----------------------------#
	
	DROP TABLE w_estorna_304

	CREATE TEMP TABLE w_estorna_304(
				seq_reg_mestre		INTEGER,
				qtd_apont     		DECIMAL(10,3),
		    qtd_produzida     DECIMAL(10,3),
        qtd_convertida    DECIMAL(10,3)
   )

	IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET m_msg = 'ERRO ',m_erro CLIPPED, ' CIRANDO TABELA W_ESTORNA_304'
		 RETURN FALSE
	ELSE 
     RETURN TRUE
	END IF 

END FUNCTION 

#-------------------------------#
FUNCTION pol1306_ins_w_estorno()#
#-------------------------------#

   INSERT INTO w_estorna_304
    VALUES(m_seq_reg_mestre, m_qtd_apont, m_qtd_produzida, m_qtd_convertida)

	IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO NA TABELA W_ESTORNA_304'
		 RETURN FALSE
	ELSE 
     RETURN TRUE
	END IF 

END FUNCTION
    
#-------------------------#
 FUNCTION pol1306_estorna()
#-------------------------#       
   
   DEFINE l_cod_turno       DECIMAL(3,0),
          l_seq_mestre      INTEGER,
          l_qtd_movto       CHAR(10),
          l_hor_inicial     CHAR(05),
          l_hor_final       CHAR(05)
   
   DEFINE lr_tip_sucata     RECORD
          cod_empresa       CHAR(02),
			    seq_reg_mestre    INTEGER,
			    estorno_total     CHAR(01),
			    tip_apont_sucata  CHAR(01), 
			    item_trata_qea    SMALLINT
   END RECORD
         				
   DISPLAY 'Verificando estornos: ' AT 14,14
    #lds CALL LOG_refresh_display()

   {
   CALL log085_transacao("BEGIN")

   IF NOT pol1306_prende_registros("E") THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF   
   
   CALL log085_transacao("COMMIT")
   }
   
   SELECT log_defn_parametro.val_padrao
     INTO lr_tip_sucata.tip_apont_sucata
     FROM log_defn_parametro 
    WHERE log_defn_parametro.parametro='tipo_apont_sucata'

   DECLARE cq_estorna CURSOR WITH HOLD FOR 	
    SELECT cod_item,
           num_ordem,
           num_docum,
           cod_operac,
           num_seq_operac,
           cod_local_prod,
           cod_local_est, 
           qtd_movto,
		       id_registro,
		       tip_integra,
		       tip_movto,
		       dat_inicial,
		       cod_turno,
		       hor_inicial,
		       hor_final
      FROM man_apont_304
 		 WHERE cod_empresa = p_cod_empresa
		   AND tip_integra = 'E'
		   AND (integrado = 1 OR integrado = 3)
	   ORDER BY id_registro
			         	 
	 FOREACH cq_estorna INTO 	
	    m_cod_item,
	    m_num_ordem,
	    m_num_docum,
	    m_cod_operac,
	    m_num_seq_operac,
	    m_cod_local_prod,
	    m_cod_local_estoq,
			m_qtd_movto,
			g_id_man_apont,
			m_tip_integra,
			m_tip_movto,
			m_dat_producao,
			l_cod_turno,
			l_hor_inicial,
			l_hor_final

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA MAN_APONT_304'
         RETURN
      END IF 
      
      IF NOT pol1306_ins_proces() THEN
         RETURN
      END IF
      
      DELETE FROM apont_erro_912
       WHERE cod_empresa = p_cod_empresa
         AND id_man_apont = g_id_man_apont

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' DELETANDO DADOS DA TAB APONT_ERRO_912'
         RETURN 
      END IF 

	    LET m_msg = NULL
	    LET m_cod_status = 'N'
	    
      IF NOT pol1306_le_ordens() THEN
         RETURN        
      END IF  
      
      IF m_cod_status = 'C' THEN
         CONTINUE FOREACH
      END IF      

	    LET m_cod_item = p_w_apont_prod.cod_item
	    LET m_num_docum = p_w_apont_prod.num_docum
	    LET m_num_seq_operac = p_w_apont_prod.num_seq_operac
	    LET m_cod_local_prod = p_w_apont_prod.cod_local
	    LET m_cod_local_estoq = p_w_apont_prod.cod_local_est

      IF NOT pol1306_w_estorna() THEN
         RETURN
      END IF    

	    LET m_msg = NULL
      LET g_tem_critica = FALSE
      
      DISPLAY m_num_ordem AT 14,33
      DISPLAY m_qtd_movto AT 14,50
       #lds CALL LOG_refresh_display()
      								      
			
			IF m_tip_movto = '1' THEN
         LET p_w_apont_prod.hor_ini_periodo = l_hor_inicial 
         LET p_w_apont_prod.hor_fim_periodo = l_hor_final
         LET m_tip_prod = 'B'
			ELSE
         SELECT cod_item
           INTO m_cod_sucata
           FROM item_sucata_304
          WHERE cod_empresa = p_cod_empresa
            AND cod_operac = m_cod_operac
         
         IF STATUS <> 0 AND STATUS <> 100 THEN
 	          LET m_erro = STATUS
	    	    LET m_msg = 'ERRO: ',m_erro CLIPPED, ' LENDO TAB ITEM_SUCATA_304'
	    	    RETURN
         END IF
         
	       IF STATUS = 100 THEN
            IF NOT pol1306_gra_defeito() THEN
               RETURN
    	    	END IF
            LET m_tip_prod = 'R'
  	     ELSE
  	        IF NOT pol1306_gra_sucata() THEN
  	           RETURN
  	        END IF
            LET m_tip_prod = 'S'
            LET m_cod_item = m_cod_sucata
         END IF
         
	    END IF 
      
      LET m_cod_status = 'N'
      
      IF g_tem_critica THEN 
         LET m_integrado = 3
  	 	   IF NOT pol1306_atu_man() THEN
	 	        RETURN
	 	     END IF
	 	     CONTINUE FOREACH
	 	  END IF
      
      LET m_saldo_apont = 0
            
      LET m_seq_reg_mestre = 0
      
      DECLARE cq_mestre CURSOR FOR                                               
       SELECT man_apo_mestre.seq_reg_mestre,
              man_item_produzido.qtd_produzida,                      
              man_item_produzido.qtd_convertida                                             
         FROM man_apo_mestre,                                                       
              man_item_produzido,                                                   
              man_apo_detalhe                                                       
        WHERE man_apo_mestre.empresa = p_cod_empresa                                
          AND man_apo_mestre.tip_moviment = 'N'                                     
          AND man_apo_mestre.ordem_producao = m_num_ordem                           
          AND man_apo_mestre.data_producao = m_dat_producao                         
          AND man_item_produzido.empresa = man_apo_mestre.empresa                   
          AND man_item_produzido.seq_reg_mestre = man_apo_mestre.seq_reg_mestre     
          AND man_item_produzido.tip_movto = 'N'                                    
          AND man_item_produzido.tip_producao = m_tip_prod                          
          AND man_item_produzido.item_produzido = m_cod_item                        
          AND man_apo_detalhe.empresa = man_apo_mestre.empresa                      
          AND man_apo_detalhe.seq_reg_mestre = man_apo_mestre.seq_reg_mestre        
          AND man_apo_detalhe.operacao = m_cod_operac                               
          AND man_apo_detalhe.sequencia_operacao = m_num_seq_operac    
          AND ((1 = 1 AND m_tip_prod <> 'S') OR
               (man_item_produzido.qtd_convertida = m_qtd_movto AND m_tip_prod = 'S'))          
        ORDER BY man_apo_mestre.seq_reg_mestre
        
      FOREACH cq_mestre INTO m_seq_reg_mestre, m_qtd_produzida, m_qtd_convertida  
      
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELAS DE APONTAMENTO'
            RETURN
         END IF 

         IF m_tip_prod = 'S' THEN
            LET m_qtd_apont = m_qtd_convertida
         ELSE
            LET m_qtd_apont = m_qtd_produzida
         END IF
                  
         SELECT SUM(qtd_produzida)
                INTO m_qtd_estorno
           FROM man_item_produzido
          WHERE empresa = p_cod_empresa
            AND seq_reg_mestre = m_seq_reg_mestre
            AND tip_movto = 'E'

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELAS DE MAN_ITEM_PRODUZIDO'
            RETURN
         END IF 
         
         IF m_qtd_estorno IS NULL THEN
            LET m_qtd_estorno = 0
         END IF

         LET m_qtd_apont = m_qtd_apont - m_qtd_estorno
         
         IF m_qtd_apont <= 0 THEN 
            CONTINUE FOREACH
         END IF
                     
         IF NOT pol1306_ins_w_estorno() THEN
            RETURN
         END IF
         
         LET m_saldo_apont = m_saldo_apont + m_qtd_apont
         
         IF m_saldo_apont >= m_qtd_movto THEN
            EXIT FOREACH
         END IF
                             
      END FOREACH
      
      FREE cq_mestre

      SELECT SUM(qtd_apont)
        INTO m_saldo_apont
        FROM w_estorna_304

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' SUMARIZANDO TABELA DE W_ESTORNA_304'
         RETURN
      END IF 
      
      IF m_saldo_apont IS NULL THEN
         LET m_saldo_apont = 0
      END IF
      
      IF m_saldo_apont < m_qtd_movto THEN
      
         IF m_tip_prod <> 'S' THEN
            LET m_msg = 'A quantidade a estornar � maior que a quantidade apontada.'      
         ELSE
            LET m_msg = 'N�o existe um apontamento ce produ��o correspondente ao estorno solicitado.'
         END IF

  	     IF NOT pol1306_ins_erro() THEN
	    	    RETURN
	    	 END IF

         LET m_integrado = 3
  	 	   IF NOT pol1306_atu_man() THEN
	 	        RETURN
	 	     END IF
	 	     
	 	     CONTINUE FOREACH
	 	  END IF

      DECLARE cq_w_estorna CURSOR WITH HOLD FOR 
       SELECT seq_reg_mestre, 
              qtd_apont,
              qtd_produzida,
              qtd_convertida
         FROM w_estorna_304
        ORDER BY seq_reg_mestre
      
      FOREACH cq_w_estorna INTO 
             m_seq_reg_mestre, m_qtd_apont, m_qtd_produzida, m_qtd_convertida
      
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA W_ESTORNA_304'
            RETURN
         END IF 
                             
         IF NOT pol1306_le_dados() THEN
            RETURN
         END IF

         LET m_integrado = 3	                                                       
	 			 LET m_cod_status = 'C'
                  
         IF manr24_cria_w_apont_prod(0)  THEN                                         
 		        CALL man8246_cria_temp_fifo()
	          CALL man8237_cria_tables_man8237()  
            DELETE FROM w_parada
   
            LET m_ies_fecha_op = FALSE
         
            IF m_ies_situa = '5' THEN
               CALL pol1306_libera_op()
            END IF
            
	          IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incluindo 
	             LET lr_tip_sucata.cod_empresa = p_w_apont_prod.cod_empresa
			         LET lr_tip_sucata.seq_reg_mestre = p_w_apont_prod.num_seq_registro 
			         LET lr_tip_sucata.estorno_total = 'S'			            
			         LET lr_tip_sucata.item_trata_qea = 1
               CALL man8232_carrega_sucata(lr_tip_sucata.*,1) RETURNING p_status
 	             IF manr27_processa_apontamento()  THEN #processando ESTORNO
	 			          LET m_integrado = 2	 
	 			          LET m_cod_status = 'A'
	 			       END IF 
	 	        ELSE
	 	           LET m_txt_resumo = 'ERRO:',STATUS,'INCLUINDO TAB W_APONT_PROD'
	 	           INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)
	 	            VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo) 
	 	        END IF
	 	     
	 	        IF m_ies_fecha_op THEN
	 	           BEGIN WORK
	 	           IF NOT pol1306_fecha_op() THEN
	 	              ROLLBACK WORK
	 	           ELSE
	 	              COMMIT WORK
	 	           END IF
	 	        END IF
	 	        
	 	     ELSE
            LET m_txt_resumo = 'ERRO:',STATUS,'CRIANDO TAB W_APONT_PROD'
            INSERT INTO man_log_apo_prod(empresa,ordem_producao,texto_resumo)
	 	         VALUES(p_cod_empresa, m_num_ordem, m_txt_resumo) 	 	     
	 	     END IF

	 	     IF NOT pol1306_atu_man() THEN
	 	        RETURN
	 	     END IF

         IF m_integrado = 3 THEN
            IF NOT pol1306_le_erros() THEN
              RETURN
           END IF			     
         END IF
	 	     
	 	     DELETE FROM w_apont_prod 

      END FOREACH
	 	                          	 	             	
   END FOREACH
    
END FUNCTION

#--------------------------#
FUNCTION pol1306_le_dados()#
#--------------------------#
   
   INITIALIZE p_w_apont_prod TO NULL
   
   SELECT
    man_apo_mestre.empresa,                   
    man_apo_mestre.seq_reg_mestre,
    man_apo_mestre.item_produzido,  
    man_apo_mestre.ordem_producao,
    man_apo_mestre.data_producao,
    man_apo_mestre.usu_apontamento,
    man_apo_mestre.secao_requisn,   
    man_tempo_producao.data_ini_producao,  
    man_tempo_producao.hor_ini_producao,  
    man_tempo_producao.dat_final_producao,  
    man_tempo_producao.hor_final_producao,  
    man_tempo_producao.turno_producao,
    man_apo_detalhe.roteiro_fabr,
    man_apo_detalhe.altern_roteiro,
    man_apo_detalhe.operacao,  
    man_apo_detalhe.sequencia_operacao,
    man_apo_detalhe.centro_trabalho,
    man_apo_detalhe.arranjo_fisico,
    man_apo_detalhe.ferramental,  
    man_apo_detalhe.atlz_ferr_min,      
    man_apo_detalhe.eqpto,  
    man_apo_detalhe.atualiza_eqpto_min,  
    man_apo_detalhe.operador,
    man_apo_detalhe.nome_programa,  
    man_item_produzido.lote_produzido,
    man_item_produzido.grade_1,
    man_item_produzido.grade_2,
    man_item_produzido.grade_3,
    man_item_produzido.grade_4,
    man_item_produzido.grade_5,
    man_item_produzido.local,
    man_item_produzido.sit_est_producao,
    man_item_produzido.qtd_produzida
    
   INTO p_w_apont_prod.cod_empresa,            
        p_w_apont_prod.num_seq_registro,  	 
        p_w_apont_prod.cod_item,        		 
        p_w_apont_prod.num_ordem,           
        p_w_apont_prod.dat_producao,     
        p_w_apont_prod.nom_usuario,   
        p_w_apont_prod.num_secao_requis,    
        p_w_apont_prod.dat_ini_prod,        
        p_w_apont_prod.hor_ini_periodo,     
        p_w_apont_prod.dat_fim_prod,        
        p_w_apont_prod.hor_fim_periodo,     
        p_w_apont_prod.cod_turno,           
 	      p_w_apont_prod.cod_roteiro,     
        p_w_apont_prod.num_altern,      
        p_w_apont_prod.cod_operacao,        
        p_w_apont_prod.num_seq_operac,      
        p_w_apont_prod.cod_cent_trab,       
        p_w_apont_prod.cod_arranjo,         
        p_w_apont_prod.cod_ferram,          
        p_w_apont_prod.ies_ferram_min,      
        p_w_apont_prod.cod_equip,           
        p_w_apont_prod.ies_equip_min,       
        p_w_apont_prod.num_operador,        
        p_w_apont_prod.num_programa,        
        p_w_apont_prod.num_lote,            
        p_w_apont_prod.cod_item_grade1,     
        p_w_apont_prod.cod_item_grade2,     
        p_w_apont_prod.cod_item_grade3,     
        p_w_apont_prod.cod_item_grade4,     
        p_w_apont_prod.cod_item_grade5,     
        p_w_apont_prod.cod_local,
        p_w_apont_prod.ies_sit_qtd,        
        p_w_apont_prod.qtd_boas_ant

    FROM man_apo_mestre, 
        man_tempo_producao,
        man_apo_detalhe,
        man_item_produzido 
   
   WHERE man_apo_mestre.empresa = p_cod_empresa
     AND man_apo_mestre.seq_reg_mestre = m_seq_reg_mestre
     AND man_tempo_producao.empresa = man_apo_mestre.empresa
     AND man_tempo_producao.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_apo_detalhe.empresa = man_apo_mestre.empresa  
     AND man_apo_detalhe.seq_reg_mestre = man_apo_mestre.seq_reg_mestre  
     AND man_item_produzido.empresa = man_apo_mestre.empresa
     AND man_item_produzido.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_item_produzido.tip_movto = 'N'
     AND man_item_produzido.tip_producao = m_tip_prod
     
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO APONTAMENTO A ESTORNAR'
      RETURN FALSE
   END IF 
   
   SELECT cod_local_prod,
          cod_local_estoq,
          num_lote,
          ies_situa
     INTO p_w_apont_prod.cod_local,
          p_w_apont_prod.cod_local_est,	
          p_w_apont_prod.num_lote,
          m_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO DADOS DA TAB ORDENS'
      RETURN FALSE
   END IF 
      
   IF NOT pol1306_le_ord_oper() THEN
      RETURN FALSE
   END IF
         
   LET p_w_apont_prod.cod_tip_movto = 'E'
            
   LET p_w_apont_prod.ies_parada = 0
   LET p_w_apont_prod.ies_apontamento	= '1'	
   LET p_w_apont_prod.abre_transacao = 1
   LET p_w_apont_prod.modo_exibicao_msg	= 1
   LET p_w_apont_prod.endereco = ' '
   LET p_w_apont_prod.identif_estoque	= NULL
   LET p_w_apont_prod.sku	= NULL 
   LET p_w_apont_prod.num_docum = m_num_docum
   LET p_w_apont_prod.observacao = '  '
   LET p_w_apont_prod.finaliza_operacao = 'N'
   LET p_w_apont_prod.tip_servico = ' '

   LET p_w_apont_prod.qtd_refug = 0			
   LET p_w_apont_prod.qtd_refug_ant = 0			
   LET p_w_apont_prod.ies_defeito = 0
   LET p_w_apont_prod.ies_sucata = 0

   IF m_tip_prod = 'B' THEN
      IF m_qtd_apont <= m_qtd_movto THEN
         LET p_w_apont_prod.estorno_total = 'S' 
         LET p_w_apont_prod.qtd_boas = m_qtd_apont
         LET m_qtd_movto = m_qtd_movto - m_qtd_apont
      ELSE
         LET p_w_apont_prod.estorno_total = 'N' 
         LET p_w_apont_prod.qtd_boas = m_qtd_movto
         LET m_qtd_movto = 0
      END IF
   END IF

   IF m_tip_prod = 'R' THEN
      LET p_w_apont_prod.ies_defeito = 1
      LET p_w_apont_prod.qtd_boas = 0
      LET p_w_apont_prod.qtd_boas_ant = 0 
      LET p_w_apont_prod.qtd_refug_ant = m_qtd_produzida		

      IF m_qtd_apont <= m_qtd_movto THEN
         LET p_w_apont_prod.estorno_total = 'S' 
         LET p_w_apont_prod.qtd_refug = m_qtd_apont
         LET m_qtd_movto = m_qtd_movto - m_qtd_apont
      ELSE
         LET p_w_apont_prod.estorno_total = 'N' 
         LET p_w_apont_prod.qtd_refug = m_qtd_movto
         LET m_qtd_movto = 0
      END IF
   END IF
   
   IF m_tip_prod = 'S' THEN
      LET p_w_apont_prod.ies_sucata = 1
      LET p_w_apont_prod.estorno_total = 'S' 
		  LET p_w_apont_prod.qtd_boas = 0     
		  LET p_w_apont_prod.qtd_boas_ant = 0 
		  LET p_w_apont_prod.ies_sit_qtd =  ' '
		  LET p_w_apont_prod.cod_roteiro = '               '      
		  LET p_w_apont_prod.num_altern = 0
		  LET p_w_apont_prod.observacao =  ' '
		  LET p_w_apont_prod.num_lote = NULL
		  LET p_w_apont_prod.cod_local_est = NULL
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1306_le_ord_oper()#
#-----------------------------#

   SELECT seq_processo
     INTO m_seq_processo
     FROM ord_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND num_seq_operac = p_w_apont_prod.num_seq_operac

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO DADOS DA TAB ORD_OPER'
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
 FUNCTION pol1306_cria_w_parada()#
#--------------------------------#
	
	DROP TABLE w_parada

	CREATE TEMP TABLE w_parada (
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' CRIANDO TABELA W_PARADA '
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#----------------------------#
FUNCTION pol1306_ins_paradas()#
#----------------------------#

   DEFINE  l_w_parada RECORD
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
   END RECORD 
      
   DELETE FROM w_parada   

   LET l_w_parada.cod_parada       = m_cod_parada[2,4]
   LET l_w_parada.dat_ini_parada   = p_w_apont_prod.dat_ini_prod
   LET l_w_parada.dat_fim_parada   = p_w_apont_prod.dat_fim_prod
   LET l_w_parada.hor_ini_periodo  = p_w_apont_prod.hor_ini_periodo
   LET l_w_parada.hor_fim_periodo  = p_w_apont_prod.hor_fim_periodo
   LET l_w_parada.hor_tot_periodo  = m_qtd_hor

   INSERT INTO w_parada
     VALUES(l_w_parada.*)
       
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO DADOS NA TABELA W_PARADA '
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------------#
FUNCTION pol1306_calc_hora(l_hor_ini, l_hor_fim)#
#-----------------------------------------------#

   DEFINE l_hor_ini     datetime hour to minute, 
          l_hor_fim     datetime hour to minute

   DEFINE l_hor_prod           CHAR(06),
          l_qtd_segundo        INTEGER,
          l_min, l_hor         INTEGER
          
     
	   IF l_hor_ini > l_hor_fim THEN
	      LET l_hor_prod = ('24:00' - (l_hor_ini - l_hor_fim))
	   ELSE
	      LET l_hor_prod = (l_hor_fim - l_hor_ini) 
	   END IF
	   	   
	   LET l_hor = l_hor_prod[2,3]
	   LET l_min = l_hor_prod[5,6]
	   
	   LET l_qtd_segundo = (l_hor * 3600) + (l_min * 60) 
	
	   LET m_qtd_hor = l_qtd_segundo / 3600

END FUNCTION

#-----------------------------------------#
FUNCTION pol1306_acerta_turno(l_cod_turno)#
#-----------------------------------------#

   DEFINE l_hor_ini           CHAR(05),
          l_hor_fim           CHAR(05),
          l_ini_s_ponto       CHAR(04),
          l_fim_s_ponto       CHAR(04),
          l_cod_turno         DECIMAL(3,0),
          l_hor_ini_normal    CHAR(04),
          l_hor_fim_normal    CHAR(04),
          l_dif_periodo       INTEGER,
          l_periodo           DECIMAL(2,0),
          l_hor_int           INTEGER,
          l_fim_ant           CHAR(04)

   SELECT parametro_numerico
     INTO m_corte_periodo
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'TOL_CORTE_FIM_PERIOD'

   IF STATUS = 100 THEN
      LET m_msg = 'Par�ametro TOL_CORTE_FIM_PERIOD n�o cadatrado.'
      CALL pol1306_ins_erro() RETURNING p_status
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE
      END IF
   END IF 

   LET l_hor_ini = p_w_apont_prod.hor_ini_periodo
   LET l_hor_fim = p_w_apont_prod.hor_fim_periodo
   LET l_ini_s_ponto = l_hor_ini[1,2],l_hor_ini[4,5]
   LET l_fim_s_ponto = l_hor_fim[1,2],l_hor_fim[4,5]
   
   SELECT hor_ini_normal,
          hor_fim_normal
    INTO l_hor_ini_normal,
         l_hor_fim_normal
    FROM turno
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno = l_cod_turno

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO PERIODO DA TABELA TURNO '
      RETURN FALSE
   END IF
   
   LET l_fim_ant = l_hor_fim_normal

   IF l_hor_fim_normal < l_hor_ini_normal THEN
      LET l_hor_int = l_hor_fim_normal
      LET l_hor_int = l_hor_int + 2400
      LET l_hor_fim_normal = func002_strzero(l_hor_int,4) 
      IF l_fim_s_ponto < l_ini_s_ponto THEN
         LET l_hor_int = l_fim_s_ponto
         LET l_hor_int = l_hor_int + 2400
         LET l_fim_s_ponto = func002_strzero(l_hor_int,4) 
      ELSE
         IF l_ini_s_ponto < l_fim_ant THEN
            LET l_hor_int = l_ini_s_ponto
            LET l_hor_int = l_hor_int + 2400
            LET l_ini_s_ponto = func002_strzero(l_hor_int,4)          
            LET l_hor_int = l_fim_s_ponto
            LET l_hor_int = l_hor_int + 2400
            LET l_fim_s_ponto = func002_strzero(l_hor_int,4) 
         END IF
      END IF
   END IF
   
   IF l_ini_s_ponto < l_hor_ini_normal THEN
      LET l_dif_periodo = l_hor_ini_normal - l_ini_s_ponto
      IF l_dif_periodo > m_corte_periodo THEN
         LET m_msg = ' - Periodo produtivo fora do intervalo do turno ', l_cod_turno
	    	 IF NOT pol1306_ins_erro() THEN
	    	    RETURN FALSE
	    	 END IF
         RETURN TRUE
      END IF
      LET l_hor_ini = l_hor_ini_normal[1,2],':',l_hor_ini_normal[3,4]
      LET p_w_apont_prod.hor_ini_periodo = l_hor_ini
   END IF

   IF l_fim_s_ponto > l_hor_fim_normal THEN
      LET l_dif_periodo = l_fim_s_ponto - l_hor_fim_normal
      IF l_dif_periodo > m_corte_periodo THEN
         LET m_msg = ' - Periodo produtivo fora do intervalo do turno ', l_cod_turno
	    	 IF NOT pol1306_ins_erro() THEN
	    	    RETURN FALSE
	    	 END IF
         RETURN TRUE
      END IF
      LET l_hor_fim = l_fim_ant[1,2],':',l_fim_ant[3,4]
      LET p_w_apont_prod.hor_fim_periodo = l_hor_fim
   END IF   
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1306_le_hora(l_cod_turno)#
#------------------------------------#

   DEFINE l_hor_ini           CHAR(05),
          l_cod_turno         DECIMAL(3,0),
          l_hor_ini_normal    CHAR(04),
          l_hor_fim_normal    CHAR(04),
          l_hor_tur_ini       INTEGER,
          l_hor_tur_fim       INTEGER,
          l_hor_criacao       INTEGER,
          l_hor_certa         INTEGER

   #LET l_hor_ini_normal = m_hor_producao[1,2],m_hor_producao[4,5]
   #LET l_hor_criacao = l_hor_ini_normal

   LET l_hor_ini = p_w_apont_prod.hor_ini_periodo
   LET l_hor_ini_normal = l_hor_ini[1,2],l_hor_ini[4,5]
   LET l_hor_criacao = l_hor_ini_normal
   
   SELECT hor_ini_normal,
          hor_fim_normal
    INTO l_hor_ini_normal,
         l_hor_fim_normal
    FROM turno
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno = l_cod_turno

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' LENDO PERIODO DA TABELA TURNO '
      RETURN FALSE
   END IF
   
   LET l_hor_tur_ini = l_hor_ini_normal
   LET l_hor_tur_fim = l_hor_fim_normal   
 
   IF l_cod_turno = 3 THEN
   
      IF l_hor_criacao <= l_hor_tur_fim  THEN
         LET l_hor_certa = l_hor_criacao
      ELSE
         IF l_hor_criacao >= l_hor_tur_ini THEN 
            LET l_hor_certa = l_hor_criacao
         ELSE
            LET l_hor_certa = l_hor_tur_ini
         END IF
      END IF
      
      IF l_hor_certa = 2230 THEN
         LET l_hor_certa = l_hor_certa + 1
      END IF
         
      #LET p_w_apont_prod.dat_producao	 = m_dat_producao
			#LET p_w_apont_prod.dat_ini_prod  = m_dat_producao
			#LET p_w_apont_prod.dat_fim_prod  = m_dat_producao

   ELSE

      IF l_hor_criacao >= l_hor_tur_ini  THEN
         IF l_hor_criacao <= l_hor_tur_fim  THEN
            LET l_hor_certa = l_hor_criacao
         ELSE
            LET l_hor_certa = l_hor_tur_fim
         END IF
      ELSE
         LET l_hor_certa = l_hor_tur_ini
      END IF
   END IF
      
   LET l_hor_ini_normal = func002_strzero(l_hor_certa,4)
   LET l_hor_ini = l_hor_ini_normal[1,2],':',l_hor_ini_normal[3,4]
   LET p_w_apont_prod.hor_ini_periodo = l_hor_ini
   LET p_w_apont_prod.hor_fim_periodo = l_hor_ini

   UPDATE man_apont_304
      SET qtd_hor = 0,
          hor_inicial = l_hor_ini,
          hor_final = l_hor_ini            
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = g_id_man_apont

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZADNDO DADOS DA TAB MAN_APONT_304'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1306_gra_sucata()#
#----------------------------#

   IF NOT pol1306_le_motivo() THEN
      RETURN
   END IF

   IF NOT pol1306_le_itens() THEN                                           
      RETURN                                                                      
   END IF                                                                         
                                                                                  
   IF m_unid_item = m_unid_sucata THEN                                            
      LET m_fat_conver = 1                                                        
      LET m_qtd_conver = m_qtd_movto                                              
   ELSE                                                                           
      LET m_fat_conver = m_pes_unit                                               
      LET m_qtd_conver = m_qtd_movto * m_fat_conver                               
   END IF                                                                         
                                                                                  
	 IF NOT pol1306_w_sucata() THEN                                                		 
		  RETURN FALSE
	 END IF
		
	 INSERT INTO w_sucata                                                   		 
		  VALUES(m_cod_sucata, m_qtd_conver, m_fat_conver, m_qtd_movto, m_cod_motivo  )    		 
    
   IF STATUS <> 0 THEN                                                    	   
      LET m_erro = STATUS
      LET m_msg = 'ERRO: ',m_erro CLIPPED, ' INSERINDO NA TAB W_SUCATA'   	   
      RETURN FALSE
	 END IF                                                                    		 
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1306_gra_defeito()#
#-----------------------------#

   IF NOT pol1306_le_motivo() THEN
      RETURN
   END IF

   IF NOT pol1306_w_defeito() THEN 
		 	RETURN FALSE
	 END IF   
	 
	 INSERT INTO w_defeito 
		  VALUES(m_cod_motivo, m_qtd_movto)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO: ',m_erro CLIPPED, ' INSERINDO NA TAB W_DEFEITO'
	    RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1306_le_motivo()#
#---------------------------#
   
   INITIALIZE m_cod_motivo to NULL
    
   IF m_mot_retrab IS NOT NULL OR m_mot_retrab = ' ' THEN
      LET m_cod_motivo = m_mot_retrab
   ELSE
      LET m_cod_motivo = m_mot_refugo
   END IF
   
   SELECT 1
     FROM defeito
    WHERE cod_empresa = p_cod_empresa
      AND cod_defeito = m_cod_motivo
   
   IF STATUS = 0 THEN 
   ELSE
     IF STATUS = 100 THEN
        #LET m_msg = 'O c�digo do defeito enviado pelo PPI n�o � v�lido.'
        #IF NOT pol1306_ins_erro() THEN
        #   RETURN FALSE
        #END IF
        LET m_cod_motivo = 13
     ELSE
        LET m_erro = STATUS
        LET m_msg = 'ERRO: ',m_erro CLIPPED, ' INSERINDO NA TAB W_DEFEITO'
	      RETURN FALSE
	   END IF
   END IF 

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1306_envia_email()#
#-----------------------------#
   
   CALL log150_procura_caminho("LST") RETURNING p_caminho
   
   LET p_assunto = 'Apontamentos criticados'

   SELECT parametro_texto
     INTO p_email_remetente
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'EMAIL_REMETENTE_ERRO'

   IF STATUS = 100 THEN
      RETURN
   END IF
   
   LET p_nom_remetente = 'Marcio'
   
   SELECT parametro_texto
     INTO p_email_destinatario
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'EMAIL_RECEPTOR_ERRO'

   IF STATUS = 100 THEN
      RETURN
   END IF
   
   LET p_nom_destinatario = 'Marco Antonio'   

   LET p_titulo1 = 'Prezado Sr.(a): ', p_nom_destinatario
      
   LET m_erro = m_qtd_erro
      
   LET p_titulo2 = 
         'Processamento do pol1306 executado em ', m_dat_proces
        
   LET p_arquivo = EXTEND(CURRENT, YEAR TO SECOND),'.lst'
   LET p_arquivo = 'pol1306.lst'
   LET p_den_comando = p_caminho CLIPPED, p_arquivo CLIPPED
         
   START REPORT pol1306_relat TO p_den_comando

   LET p_imp_linha = 
         ' Gerou ', m_erro CLIPPED, ' registros criticados na empresa ', p_cod_empresa
     
   OUTPUT TO REPORT pol1306_relat() 
      
   FINISH REPORT pol1306_relat  
      
   CALL log5600_envia_email(p_email_remetente, p_email_destinatario, p_assunto, p_den_comando, 2)

END FUNCTION

#---------------------#
 REPORT pol1306_relat()
#---------------------#

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
        PRINT
        PRINT COLUMN 001, 'Favor verificar no POL1308.'
        PRINT

        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 005, p_nom_remetente
        
END REPORT
   

 
       