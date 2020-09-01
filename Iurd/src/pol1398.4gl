#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc ou na JOB0003 do Logix         #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1398                                                            #
# OBJETIVO: GERAÇÃO DE ARQUIVO TEXTO COM APs A PAGAR                           #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 27/07/2020                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
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
          g_tipo_sgbd            CHAR(003)
END GLOBALS

DEFINE m_msg                      CHAR(150),   
       m_erro                     CHAR(10),    
       m_dat_proces               VARCHAR(19), 
       m_tem_erro                 SMALLINT,    
       m_file_w                   VARCHAR(80),
       m_handle_w                 SMALLINT,
       m_cod_empresa              CHAR(02),  
       m_num_ap                   CHAR(06),       
       m_num_nf                   CHAR(07),       
       m_data                     CHAR(10),  
       m_val_liq                  CHAR(16),      
       m_cod_tip                  CHAR(04),
       m_linha                    VARCHAR(50)                            

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_user = ARG_VAL(2)
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1398_exibe_tela()
         LET m_msg = NULL
         IF NOT pol1398_processa() THEN
            IF m_msg IS NOT NULL THEN
               CALL pol1398_grava_erro() RETURNING p_status
            END IF
         END IF
         CLOSE WINDOW w_pol1398
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
            
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      CALL pol1398_controle()
   END IF
         
END MAIN

#----------------------------#
FUNCTION pol1398_exibe_tela()#
#----------------------------#
   
   DEFINE l_nom_tela  CHAR(200)
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 60

   LET p_versao = "pol1398-12.00.03  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1398") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1398 AT 3,05 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   LET m_tem_erro = FALSE
   
END FUNCTION

#------------------------------#
FUNCTION pol1398_job(l_rotina) #
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

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
      
   CALL pol1398_exibe_tela()

   LET m_msg = NULL
   LET p_status = pol1398_processa() 

   IF NOT p_status THEN
      IF m_msg IS NOT NULL THEN
         CALL pol1398_grava_erro() RETURNING p_status
      END IF
   END IF

   CLOSE WINDOW w_pol1398   
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1398_controle()#
#--------------------------#

   CALL pol1398_exibe_tela()
   
   MENU "OPCAO"
      COMMAND "Processar" "Processa a geração do arquivo"
         LET m_msg = NULL
         IF NOT pol1398_processa() THEN
            CALL log0030_mensagem(m_msg,'info')
            ERROR 'Operação cancelada.'
         ELSE
            ERROR 'Operação efetuada com sucesso.'
         END IF         
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1398   
   
END FUNCTION

#----------------------------#
FUNCTION pol1398_grava_erro()#
#----------------------------#

   IF NOT log0150_verifica_se_tabela_existe("erro_exporta_ap") THEN 
      IF NOT pol1398_cria_tab_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   INSERT INTO erro_exporta_ap VALUES(m_dat_proces, m_msg)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED,
         ' gavando tabela de erros'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1398_cria_tab_erro()#
#-------------------------------#

   CREATE TABLE erro_exporta_ap (
      dat_proces           VARCHAR(19),
      erro                 VARCHAR(120)
   );

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED,
         ' criando tabela de erros'
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_erro_exporta_ap
    ON erro_exporta_ap(dat_proces);

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED,
         ' criando tabela de erros'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1398_processa()#
#--------------------------#
   
   LET m_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   
   IF NOT pol1398_le_caminho() THEN
      RETURN FALSE
   END IF

   {IF NOT pol1398_gera_arq() THEN
      RETURN FALSE
   END IF}

   IF NOT pol1398_le_ap() THEN
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1398_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
     FROM log_usu_dir_relat
    WHERE empresa = p_cod_empresa 
      AND usuario = p_user 
      AND sistema_fonte = 'TXT'
 
   {SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2 #log_usu_dir_relat
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "TXT"}

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema TXT não cadastrado na log00098.'      
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED,
            ' lendo caminho do sistema TXT'
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1398_dirExist(m_caminho) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol1398_dirExist(l_dir)#
#-------------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = l_dir CLIPPED
 
  IF NOT LOG_dir_exist(l_dir,0) THEN
     IF NOT LOG_dir_exist(l_dir,1) THEN
        LET m_msg = "Diretório não existe: ",l_dir
        RETURN FALSE
     END IF     
  END IF
  
  RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1398_gera_arq()#
#--------------------------#
        
  LET m_file_w = m_caminho CLIPPED, 'APS_A_PAGAR.txt'  
  LET m_handle_w = LOG_file_create(m_file_w,0,0)
      
  IF m_handle_w < 0 THEN
     LET m_msg = ' Erro gerando arquivo ', m_file_w CLIPPED
     RETURN FALSE
  END IF     
  
  LET m_handle_w = LOG_file_close(m_handle_w)
  
  RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1398_le_ap()#
#-----------------------#
   
   DEFINE l_num_ap        DECIMAL(6,0),
          l_cod_tip_desp  DECIMAL(4,0),
          l_val_liquido   DECIMAL(15,2),
          l_cod_tip_val   LIKE ap_valores.cod_tip_val,
          l_valor         LIKE ap_valores.valor,
          l_ies_tipo      CHAR(01)
   
   {LET m_handle_w = LOG_file_openMode(m_file_w,0,1)
  
   IF m_handle_w < 0 THEN
      LET m_msg = 'Erro na abertura do arquivo ', m_file_w
      RETURN FALSE
   END IF    }
   
   LET m_file_w = m_caminho CLIPPED, 'APS_A_PAGAR.txt'     
   START REPORT pol1398_relat TO m_file_w

   DECLARE cq_ap CURSOR FOR
    SELECT a.cod_empresa, 
           c.num_ap, 
           '9910',
           d.dt_vencimento, 
           a.cod_tip_despesa,
           c.val_nom_ap
      FROM gi_ad_912 a, 
           gi_imovel b, 
           ap c, 
           gi_ap_912 d, 
           gi_obrigacao e
     WHERE a.ies_gera_nota = 'S'
       AND a.cod_contrato = b.cod_imovel 
       AND a.cod_obrigacao = e.cod_obrigacao
       AND e.ies_situacao <> 'E'
       AND a.cod_empresa=c.cod_empresa
       AND d.num_ap = c.num_ap
       AND c.ies_versao_atual = 'S' 
       AND c.dat_pgto IS NULL
       AND a.id_ad = d.id_ad
       AND b.cod_status <> 'E'
  ORDER BY a.cod_empresa,  c.num_ap

   FOREACH cq_ap INTO 
      m_cod_empresa, 
      l_num_ap, 
      m_num_nf, 
      m_data,
      l_cod_tip_desp,
      l_val_liquido
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED, ' lendo APs - cq_ap'
         RETURN FALSE
      END IF

      DISPLAY m_cod_empresa TO cod_empresa
      DISPLAY l_num_ap TO num_ap
      #lds CALL LOG_refresh_display()
             
      DECLARE cq_valor CURSOR FOR
       SELECT cod_tip_val, valor 
         FROM ap_valores 
        WHERE cod_empresa = m_cod_empresa
          AND num_ap = l_num_ap
          AND ies_versao_atual = 'S'

      FOREACH cq_valor INTO l_cod_tip_val, l_valor

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'Erro ', m_erro CLIPPED, ' lendo tabela ap_valores - cq_valor'
            RETURN FALSE
         END IF
      
         SELECT ies_alt_val_pag
           INTO l_ies_tipo
           FROM tipo_valor 
          WHERE cod_empresa = m_cod_empresa
            AND cod_tip_val = l_cod_tip_val
            AND ies_ad_ap = '2'

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'Erro ', m_erro CLIPPED, ' lendo tipo_valor: ', l_cod_tip_val
            RETURN FALSE
         END IF
         
         IF l_ies_tipo = '+' THEN
            LET l_val_liquido = l_val_liquido + l_valor
         ELSE
            IF l_ies_tipo = '-' THEN
               LET l_val_liquido = l_val_liquido - l_valor
            END IF
         END IF
         
      END FOREACH
			
			FREE cq_valor
			 
      LET m_num_ap = func002_strzero(l_num_ap, 6)
      LET m_cod_tip = func002_strzero(l_cod_tip_desp, 4)
      LET m_val_liq = func002_dec_strzero(l_val_liquido, 16)
      
      LET m_linha = m_cod_empresa,'|',m_num_ap,'|',m_num_nf,'|',m_data,'|',m_val_liq,'|',m_cod_tip

      {IF NOT LOG_file_write(m_handle_w, m_linha) THEN
         LET m_msg = 'Erro ao gravar no arquivo ',m_file_w
         RETURN FALSE
      END IF}
      
      OUTPUT TO REPORT pol1398_relat() 
            
   END FOREACH
   
   #LET m_handle_w = LOG_file_close(m_handle_w)
   
   FINISH REPORT pol1398_relat  
   FREE cq_ap
   
   RETURN TRUE

END FUNCTION

#---------------------#
 REPORT pol1398_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
          
     ON EVERY ROW 
        PRINT COLUMN 001, m_linha
        
END REPORT
   
#LOG1700
#-------------------------------#
 FUNCTION pol1398_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/pol1398.4gl $|$Revision: 03 $|$Date: 25/08/2020 16:12 $|$Modtime: 14/08/2020 13:12 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION


