#-----------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                            #
# PROGRAMA: POL1378                                               #
# OBJETIVO: CARGA DE ARQUIVOS COM APTO DE PRODUÇÃO                #
# AUTOR...: IVO HB                                                #
# DATA....: 02/01/2020                                            #
#-----------------------------------------------------------------#

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
          g_tem_critica          SMALLINT,
          p_nom_tela             CHAR(200)      
END GLOBALS

DEFINE m_execucao                CHAR(01),
       m_ies_ambiente            CHAR(01),
       m_nom_arquivo             VARCHAR(80),
       m_reg_proces              INTEGER,
       m_dat_proces              DATE,
       m_hor_proces              CHAR(08),
       m_posi_arq                INTEGER,
       m_qtd_arq                 INTEGER,
       m_msg                     VARCHAR(150),
       g_msg                     VARCHAR(150),
       m_arq_arigem              VARCHAR(150),
       m_arq_dest                VARCHAR(150)

DEFINE ma_files ARRAY[150] OF CHAR(80)

DEFINE m_tela                 RECORD
       nom_arquivo            VARCHAR(80),
       dat_de                 DATE,
       dat_ate                DATE,
       hor_de                 CHAR(08),
       hor_ate                CHAR(08)
END RECORD

DEFINE mr_itens              ARRAY[1000] OF RECORD
       arquivo               VARCHAR(80), 
       data                  DATE,
       hora                  CHAR(08),
       reg                   DECIMAL(5,0),
       mensagem              VARCHAR(80)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120
   DEFER INTERRUPT
   
   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET m_execucao = 'B'   
   ELSE
      CALL log001_acessa_usuario("ESPEC999","")     
          RETURNING p_status, p_cod_empresa, p_user
      LET m_execucao = 'M'   
   END IF

   CALL pol1378_exibe_tela()
   LET g_msg = NULL
         
   IF m_execucao = 'M' THEN
      CALL pol1378_menu()
   ELSE
      CALL pol1378_processa() RETURNING p_status
   END IF

   CLOSE WINDOW w_pol1378
    
END MAIN

#------------------------------#
FUNCTION pol1378_job(l_rotina) #
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
      
   LET m_execucao = 'A'
   CALL pol1378_exibe_tela()
   CALL pol1378_processa() RETURNING p_status
   CLOSE WINDOW w_pol1378
   RETURN p_status
   
END FUNCTION   

#----------------------------#
FUNCTION pol1378_exibe_tela()#
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1378") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1378 AT 2,2 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   CALL LOG_refresh_display()

END FUNCTION

#----------------------#
FUNCTION pol1378_menu()#
#----------------------#

   LET p_versao = "pol1378-12.00.03  "
   CALL func002_versao_prg(p_versao)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta erros de processamento"
         IF pol1378_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Processar" "Processa a importação de arquivos"
         CALL pol1378_processa() RETURNING p_status
         ERROR m_msg
      COMMAND "Sobre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior."
         EXIT MENU
   END MENU

END FUNCTION

#--------------------------#
FUNCTION pol1378_consulta()#
#--------------------------#

   INITIALIZE m_tela.* TO NULL
   INITIALIZE mr_itens TO NULL

   CLEAR FORM
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME m_tela.* WITHOUT DEFAULTS
      
      AFTER FIELD nom_arquivo
   
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1378_le_erros() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1378_le_erros()#
#--------------------------#
   
   DEFINE sql_stmt     VARCHAR(800),
          l_ind        INTEGER
   
   LET sql_stmt = 
       "SELECT nom_arquivo, dat_proces, hor_proces, reg_proces, mensagem ",
       "  FROM erros_carga_pol1378 ",
       " WHERE cod_empresa = '",p_cod_empresa,"' ",
       "   AND nom_arquivo LIKE '","%",m_tela.nom_arquivo CLIPPED,"%","' "
       
   IF m_tela.dat_de IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND dat_proces >= '",m_tela.dat_de,"' "
   END IF

   IF m_tela.dat_ate IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND dat_proces <= '",m_tela.dat_ate,"' "
   END IF

   IF m_tela.hor_de IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND hor_proces >= '",m_tela.hor_de,"' "
   END IF

   IF m_tela.hor_ate IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND hor_proces <= '",m_tela.hor_ate,"' "
   END IF
   
   LET l_ind = 1
   
   PREPARE var_query FROM sql_stmt   
   
   DECLARE cq_padrao CURSOR FOR var_query
   
   FOREACH cq_padrao INTO mr_itens[l_ind].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
         RETURN FALSE
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 1000 THEN
         CALL log0030_mensagem('Somente 1000 registros serão exibidos','info')
         EXIT FOREACH
      END IF      
      
   END FOREACH
   
   CALL SET_COUNT(l_ind - 1)
   
   DISPLAY ARRAY mr_itens TO sr_itens.*   

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1378_processa()#
#--------------------------#

   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF

   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF

   LET p_versao = "pol1378-12.00.00  "
   CALL func002_versao_prg(p_versao)

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_nom_arquivo = ' '
   LET m_reg_proces = 0
   LET m_dat_proces = TODAY
   LET m_hor_proces = TIME

   IF NOT log0150_verifica_se_tabela_existe("control_proces_pol1378") THEN 
      IF NOT pol1378_cria_controle() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1378_check_proces()THEN
      CALL pol1378_ins_erro() RETURNING p_status
      RETURN FALSE
   END IF

   CALL pol1378_exec_carga() RETURNING p_status

   UPDATE control_proces_pol1378
      SET ies_processando = 'N',
          qtd_tentativa = 0
    WHERE id_proces = 1    
      
   RETURN p_status
   
END FUNCTION

#-------------------------------#
FUNCTION pol1378_cria_controle()#
#-------------------------------#

   CREATE TABLE control_proces_pol1378 (
      id_proces            INTEGER,
      ies_processando      char(01),
      qtd_tentativa        INTEGER
   );

   IF STATUS <> 0 THEN
      DROP TABLE control_proces_pol1378
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_proces_pol1378
    ON control_proces_pol1378(id_proces);

   IF STATUS <> 0 THEN
      DROP TABLE control_proces_pol1378
      RETURN FALSE
   END IF
   
   INSERT INTO control_proces_pol1378 VALUES(1,'N',0)

   IF STATUS <> 0 THEN
      DROP TABLE control_proces_pol1378
      RETURN FALSE
   END IF

   RETURN TRUE      
   
END FUNCTION

#-------------------------------#
FUNCTION pol1378_cria_tab_erros()#
#-------------------------------#

   CREATE TABLE erros_carga_pol1378 (
      cod_empresa          char(02),
      dat_proces           DATE,
      hor_proces           CHAR(08),
      nom_arquivo          VARCHAR(80),
      reg_proces           INTEGER,
      mensagem             VARCHAR(150)
   );

   IF STATUS <> 0 THEN
      DROP TABLE erros_carga_pol1378
      RETURN FALSE
   END IF

   CREATE INDEX ix_erros_carga_pol1378
    ON erros_carga_pol1378(cod_empresa, dat_proces);

   IF STATUS <> 0 THEN
      DROP TABLE erros_carga_pol1378
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION

#------------------------------#
FUNCTION pol1378_check_proces()#
#------------------------------#
   
   DEFINE l_ies_processando  CHAR(01),
          l_qtd_tentativa    INTEGER
          
   SELECT ies_processando,
          qtd_tentativa
     INTO l_ies_processando,
          l_qtd_tentativa
     FROM control_proces_pol1378
    WHERE id_proces = 1

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<', ' lendo tab control_proces_pol1378'
      RETURN FALSE
   END IF

   IF l_ies_processando = 'N' THEN
      UPDATE control_proces_pol1378
         SET ies_processando = 'S',
             qtd_tentativa = 0
       WHERE id_proces = 1    

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<', ' atuali tab control_proces_pol1378:1'
         RETURN FALSE
      END IF
     
      RETURN TRUE
   END IF
   
   IF l_qtd_tentativa < 10 THEN
      UPDATE control_proces_pol1378
         SET qtd_tentativa = qtd_tentativa + 1
       WHERE id_proces = 1    

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<', ' atuali tab control_proces_pol1378:2'
      ELSE
         LET m_msg = 'Já existe processamento em andamento'
      END IF

      RETURN FALSE
   
   END IF
         
   RETURN TRUE   

END FUNCTION   

#----------------------------#         
FUNCTION pol1378_exec_carga()#
#----------------------------#
      
   IF NOT pol1378_le_caminho() THEN
      RETURN FALSE
   END IF

   IF NOT pol1378_dirExist() THEN
      RETURN FALSE
   END IF

   {IF NOT pol1378_fileExist() THEN
      RETURN FALSE
   END IF}

   IF NOT pol1378_carrega_lista() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1378_le_caminho()#
#----------------------------#
   
   DEFINE l_achou      SMALLINT
   
   LET l_achou = FALSE
   LET m_msg = NULL
   
   DECLARE cq_caminho CURSOR FOR
    SELECT nom_caminho, ies_ambiente
      FROM path_logix_v2
     WHERE cod_empresa = p_cod_empresa 
       AND cod_sistema = "TRG"
   
   FOREACH cq_caminho
      INTO m_caminho, m_ies_ambiente

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<', ' lendo tab path_logix_v2'
         CALL pol1378_ins_erro() RETURN p_status
         RETURN FALSE
      END IF      
      
      LET l_achou = TRUE
      EXIT FOREACH

   END FOREACH
         
   IF l_achou THEN
      CALL LOG_consoleMessage("Caminho dos arquivos: "||m_caminho)
      RETURN TRUE
   END IF
   
   LET m_msg = 'Caminho do sistema TRG não cadastrado'
      
   CALL pol1378_ins_erro() RETURN p_status

   RETURN FALSE
   
END FUNCTION

#--------------------------#
FUNCTION pol1378_ins_erro()#
#--------------------------#

   INSERT INTO erros_carga_pol1378
    VALUES(p_cod_empresa,
           m_dat_proces,
           m_hor_proces,
           m_nom_arquivo,
           m_reg_proces,
           m_msg)
   
   IF STATUS <> 0 THEN
      LET g_msg = 'Erro ', STATUS, ' inserindo dados na tabela erros_carga_pol1378'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1378_dirExist()#
#---------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = m_caminho CLIPPED
 
  IF LOG_dir_exist(l_dir,0) THEN
  ELSE          
     IF LOG_dir_exist(l_dir,1) THEN
     ELSE
        CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
        LET l_msg = "Diretório : ",l_dir CLIPPED, ' não exite \n', log0030_mensagem_get_texto()
        CALL log0030_mensagem(l_msg,'info')
        RETURN FALSE
     END IF
     
  END IF
  
  RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION pol1378_fileExist()#
#----------------------------#

  DEFINE l_file  CHAR(250),
         l_msg   CHAR(100)
 
  
 
  LET l_file = "c:\\temp\\ivo.txt"
 
 {
  IF LOG_file_exist(l_file,0) THEN
     LET l_msg = "Arquivo existe no servidor"
  ELSE
     #CALL conout("Arquivo não existe no servidor")
     LET l_msg = "Arquivo existe não no servidor"
  END IF
 }
  CALL log0030_mensagem(l_msg, 'info')
 
  IF NOT LOG_file_exist(l_file,1) THEN
     #CALL conout("Arquivo não existe no client")
     LET l_msg = 'Arquivo não existe no client'
  ELSE
     #CALL conout("Arquivo existe no client")
     LET l_msg = 'Arquivo existe no client'
  END IF
  
END FUNCTION
  
#-------------------------------#
FUNCTION pol1378_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03),
          l_caminho CHAR(150)
               
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.unl",FALSE,FALSE,FALSE)
   
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado '
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   ELSE
      IF m_qtd_arq > 150 THEN
         LET m_msg = 'Qtd arquivos enconrada > qtd prevista'
         CALL pol1378_ins_erro() RETURN p_status
         RETURN FALSE
      END IF
   END IF
   
   INITIALIZE ma_files TO NULL
   
   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       LET m_arq_arigem =  ma_files[l_ind]
       LET m_nom_arquivo = m_arq_arigem[m_posi_arq, LENGTH(m_arq_arigem)]
       
       IF NOT pol1378_load_arq() THEN
          RETURN FALSE
       END IF
       
   END FOR
   
   LET m_msg = 'Processamento efetuado com sucesso'
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1378_load_arq()#
#--------------------------#
   
   LET m_reg_proces = 0

   DELETE FROM man_tmp_arq_targa

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' delet reg da tab man_tmp_arq_targa '
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_arigem INSERT INTO man_tmp_arq_targa
   
   IF STATUS <> 0 THEN 
      LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' na carga do ', m_nom_arquivo
      CALL LOG_transaction_rollback()
      CALL pol1378_ins_erro() RETURNING  p_status    
      LET m_arq_dest = pol1378_renomeia('.err')  
      CALL pol1378_move_arquivo() RETURNING p_status
      RETURN TRUE
   END IF

   DELETE FROM man_imp_arq_targa
    WHERE cod_empresa = p_cod_empresa
      AND nome_arquivo_import = m_nom_arquivo

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' delet reg da tab man_imp_arq_targa '
      CALL LOG_transaction_rollback()
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   END IF

   DELETE FROM erros_carga_pol1378
    WHERE cod_empresa = p_cod_empresa
      AND nom_arquivo = m_nom_arquivo

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' delet reg da tab erros_carga_pol1378 '
      CALL LOG_transaction_rollback()
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   END IF
   
   IF NOT pol1378_ins_tab_imp() THEN
      CALL LOG_transaction_rollback()
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   END IF
   
   CALL LOG_transaction_commit()
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1378_ins_tab_imp()#
#-----------------------------#

   DEFINE  lr_man_tmp           RECORD
      check_plan                   char(02)       ,       
      posicao                      integer        ,       
      num_analise                  integer        ,       
      inspetor                     char(50)       ,       
      data_prod                    date           ,       
      hora_prod                    char(05)       ,       
      produto                      char (15)      ,       
      maquina                      char(05)       ,       
      lado                         char(02)       ,       
      tamanho                      char(05)       ,       
      turno                        char(03)       ,       
      num_lote                     char(15)       ,       
      cod_item                     char(15)       ,       
      den_item                     varchar(70)    ,       
      disposicao                   char(18)       ,       
      peso_grama                   decimal(15,3)  ,       
      qtd_sacos                    decimal(15,3)  ,       
      peso_tot_kg                  decimal(15,3)  ,       
      peso_medio                   decimal(15,3)  ,       
      qtd_lote_prod                decimal(15,3)  ,       
      marcacao                     decimal(15,3)  ,       
      fur_palm_pun_dedo            decimal(15,3)  ,       
      esbarrada                    decimal(15,3)  ,       
      rasgada                      decimal(15,3)  ,       
      mistura                      decimal(15,3)  ,       
      prega                        decimal(15,3)  ,       
      impureza                     decimal(15,3)  ,       
      cordao_defeito               decimal(15,3)  ,       
      acumulo                      decimal(15,3)  ,       
      ponto_fraco                  decimal(15,3)  ,       
      motivo_Reprova               varchar(50)    ,       
      obs_marcacao                 varchar(50)    ,       
      obs_palm_pun_dedo            varchar(50)    ,       
      obs_esbarrada                varchar(50)    ,       
      obs_rasgada                  varchar(50)    ,       
      obs_mistura                  varchar(50)    ,       
      obs_prega                    varchar(50)    ,       
      obs_impureza                 varchar(50)    ,       
      obs_cordao_defeito           varchar(50)    ,       
      obs_acumulo                  varchar(50)    ,       
      obs_ponto_fraco              varchar(50)    ,       
      obs_geral                    varchar(50)            
   END RECORD
   
   LET m_reg_proces = 0

   DECLARE cq_le_tmp CURSOR FOR
    SELECT * FROM man_tmp_arq_targa
   FOREACH cq_le_tmp INTO lr_man_tmp.*
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' lendo tab man_tmp_arq_targa:cq_le_tmp'
         RETURN FALSE
      END IF
      
      INSERT INTO man_imp_arq_targa 
       VALUES(p_cod_empresa, m_nom_arquivo, lr_man_tmp.*)
       
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro: ', STATUS USING '<<<<<', ' insert reg na tab man_imp_arq_targa'
         RETURN FALSE
      END IF

      LET m_reg_proces = m_reg_proces + 1
   
   END FOREACH
   
   IF m_reg_proces = 0 THEN
      LET m_msg = 'Arquivo esta vazio'
      LET m_arq_dest = pol1378_renomeia('.err')
   ELSE
      LET m_msg = 'Arquivo processado com sucesso'
      LET m_arq_dest = pol1378_renomeia('.pro') 
   END IF

   IF NOT pol1378_ins_erro() THEN
      RETURN FALSE
   END IF

   IF NOT pol1378_move_arquivo() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1378_renomeia(l_ext)#
#-------------------------------#
   
   DEFINE l_ext     CHAR(04),
          l_arq     VARCHAR(150),
          l_posi_f  INTEGER
   
   LET l_posi_f = (LENGTH(m_arq_arigem CLIPPED)) - 4
   LET l_arq = m_arq_arigem[1, l_posi_f]
   LET l_arq = l_arq CLIPPED, l_ext
   
   RETURN l_arq
   
END FUNCTION

#------------------------------#
FUNCTION pol1378_move_arquivo()#
#------------------------------#
   
   DEFINE l_comando        CHAR(150)
          
   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_arigem CLIPPED, ' ', m_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_arigem CLIPPED, ' ', m_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'Não foi possivel renomear arquivo'
      CALL pol1378_ins_erro() RETURN p_status
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
          