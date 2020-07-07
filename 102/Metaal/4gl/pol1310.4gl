# PROGRAMA: pol1310                                                            #
# OBJETIVO: LEITURA E SEPARAÇÃO DE ARQUIVO TEXTO                               #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/10/2016                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

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
          g_tipo_sgbd            CHAR(003)
          
END GLOBALS

DEFINE m_erro                   CHAR(010),
       m_msg                    CHAR(150),
       m_ies_proces             CHAR(01),
       m_dat_atu                CHAR(10),
       m_id_arquivo             INTEGER,
       m_nom_arquivo            CHAR(150),
       m_caminho                CHAR(100),
       m_comando                CHAR(200),
       m_count                  INTEGER,
       m_ies_ambiente           CHAR(001),
       m_ies_cons               CHAR(01),
       m_registro               CHAR(129),
       m_itp                    CHAR(129),
       m_ftp                    CHAR(129),
       m_tem_erro               SMALLINT,
       m_num_pedido             INTEGER,
       m_ped_txt                CHAR(10),
       m_par_vdp                CHAR(100),
       m_relat                  CHAR(120)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30
   LET p_versao = "pol1310-12.00.03  "
   CALL func002_versao_prg(p_versao)

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user

   #LET p_status = 0 ; LET p_cod_empresa = '01' ;   LET p_user = 'admlog'
   
   CALL pol1310_menu() 

END MAIN

#------------------------------#
FUNCTION pol1310_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   #CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   #CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   #CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '01'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
  
   IF NOT pol1310_exec_edi() THEN
      CALL pol1310_ins_erro()
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1310_exec_edi()#
#--------------------------#

   IF NOT pol1310_checa_tabelas() THEN
      RETURN FALSE
   END IF   

   IF NOT pol1310_ck_proces() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1310_chama_delphi() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1310_processa() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#----------------------#
FUNCTION pol1310_menu()#
#----------------------#

   DEFINE l_nom_tela        CHAR(200)
   
   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1310") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1310 AT 02,02 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol1310_checa_tabelas() THEN
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF   

   MENU "OPCAO"
      COMMAND "Informar" "Informar arquivo para divisão"
         CALL pol1310_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Arquivo informado com sucesso !'
            LET m_ies_cons = TRUE
            NEXT OPTION 'Processar'
         ELSE
            IF m_msg IS NOT NULL THEN
               CALL log0030_mensagem(m_msg,'info')
            END IF
            ERROR 'Operação cancelada !!!'
            LET m_ies_cons = FALSE
         END IF 
      COMMAND "Processar" "Processa a divisão do arquivo"
         IF m_ies_cons THEN
            CALL pol1310_processa() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso.'
               IF m_tem_erro THEN
                  CALL log0030_mensagem(m_msg,'info')
               END IF
            ELSE
               CALL log0030_mensagem(m_msg,'info')
               ERROR 'Operação cancelada.'
            END IF 
         ELSE
            ERROR 'Informe o arquivo previamente!'
            NEXT OPTION 'Informar'
         END IF
         LET m_ies_cons = FALSE
         MESSAGE ''
         #lds CALL LOG_refresh_display()
      COMMAND "Consultar" "Consulta erros do processamento"
         CALL pol1310_consulta() RETURNING p_status
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR m_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1310

END FUNCTION


#--------------------------#
FUNCTION pol1310_ins_erro()#
#--------------------------#

   INSERT INTO edi_erro_912(
      cod_empresa,
      nom_arquivo,
      dat_carga,  
      den_erro)
   VALUES(p_cod_empresa,
          m_nom_arquivo,
          m_dat_atu,
          m_msg)  

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','info')
   END IF

   LET m_tem_erro = TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1310_le_caminho(l_system)#
#------------------------------------#

   DEFINE l_system          CHAR(003)

   SELECT nom_caminho,
          ies_ambiente           
     INTO m_caminho, 
          m_ies_ambiente
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = l_system
     
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' lendo caminho de diretorio do sistema ', l_system
      LET m_caminho = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1310_informar()#
#--------------------------#   
   
   DEFINE l_qtd_dig_caminho  INTEGER,
          l_qtd_dig_arquvio  INTEGER
   
   DISPLAY '' TO nom_arquivo
   
   INITIALIZE m_nom_arquivo, m_msg TO NULL
   
   IF NOT pol1310_le_caminho('EDI') THEN
      RETURN FALSE
   END IF
   
   LET l_qtd_dig_caminho = LENGTH(m_caminho CLIPPED)

   IF NOT pol1310_del_tab_arq() THEN
      RETURN FALSE
   END IF
   
   LET m_nom_arquivo = log0820_abrir_arquivo(5, 2, m_caminho, ' ','A')

   IF m_nom_arquivo IS NULL THEN
      RETURN FALSE
   END IF
   
   DISPLAY m_nom_arquivo TO nom_arquivo
   
   LET l_qtd_dig_arquvio = LENGTH(m_nom_arquivo CLIPPED)
   
   IF (l_qtd_dig_arquvio - l_qtd_dig_caminho) < 3 THEN
      LET m_msg = 'O arquivo selecionado não é valido.'
      RETURN FALSE
   END IF
   
   INSERT INTO arquivos_912(
    cod_empresa,
    nom_arquivo)
   VALUES(p_cod_empresa,
          m_nom_arquivo)
          
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'inserindo na tabela arquivos_912'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1310_le_vdp()#
#------------------------#

   SELECT val_par_texto
     INTO m_par_vdp
     FROM vdp_parametro_edi
    WHERE empresa = p_cod_empresa
      AND van = 1
      AND parametro = 'camh_arq_entrada'

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' lendo tabela vdp_parametro_edi'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1310_processa()#
#--------------------------#   

   IF NOT pol1310_le_vdp() THEN
      RETURN FALSE
   END IF
          
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_dat_atu = TODAY
   LET m_msg = NULL
   LET m_tem_erro = FALSE

   DECLARE cq_ars CURSOR FOR
    SELECT nom_arquivo
      FROM arquivos_912
     WHERE cod_empresa = p_cod_empresa
   
   FOREACH cq_ars INTO m_nom_arquivo

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro: ', m_erro CLIPPED, 'lendo tabela arquivos_912:cq_ars'
         RETURN FALSE
      END IF            
       
      IF NOT pol1310_cria_tab_edi() THEN
         RETURN FALSE
      END IF

      SELECT COUNT(*)
        INTO m_count
        FROM edi_912

      IF m_count > 0 THEN
         LET m_msg = 'Não foi possivel limpara a tabela edi_912:cq_ars'
         RETURN FALSE
      END IF            

      LOAD FROM m_nom_arquivo INSERT INTO edi_912 (registro)

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro: ',m_erro CLIPPED,
            ' carregando ',m_nom_arquivo
         RETURN FALSE
      END IF

      IF NOT pol1310_divid_edi() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
      
   RETURN TRUE         
   
END FUNCTION   

#-------------------------------#
FUNCTION pol1310_checa_tabelas()#
#-------------------------------#

   IF NOT log0150_verifica_se_tabela_existe('arquivos_912') THEN
      IF NOT pol1310_cria_tab_arq() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe('edi_erro_912') THEN
      IF NOT pol1310_cria_tab_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe('proces_912') THEN
      IF NOT pol1310_cria_tab_proces() THEN
         RETURN FALSE
      END IF
   END IF   

   IF NOT log0150_verifica_se_tabela_existe('pedido_912') THEN
      IF NOT pol1310_cria_tab_ped() THEN
         RETURN FALSE
      END IF
   END IF   
       
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1310_cria_tab_arq()#
#------------------------------#

   CREATE TABLE arquivos_912 (
      cod_empresa    CHAR(02),
      nom_arquivo    CHAR(150)
   )
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando tabela arquivos_912'
      RETURN FALSE
   END IF            
   
   CREATE INDEX arquivos_912 ON arquivos_912(cod_empresa)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando index arquivos_912'
      RETURN FALSE
   END IF           
   
   RETURN TRUE

END FUNCTION 

#-------------------------------#
FUNCTION pol1310_cria_tab_erro()#
#-------------------------------#

   CREATE TABLE edi_erro_912 (
      cod_empresa    CHAR(02),
      nom_arquivo    CHAR(150),
      dat_carga      CHAR(10),
      den_erro       CHAR(150)
   )
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando tabela edi_erro_912'
      RETURN FALSE
   END IF            
   
   CREATE INDEX edi_erro_912 ON edi_erro_912(cod_empresa)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando index edi_erro_912'
      RETURN FALSE
   END IF           
   
   RETURN TRUE

END FUNCTION 

#---------------------------------#
FUNCTION pol1310_cria_tab_proces()#
#---------------------------------#

   CREATE TABLE proces_912 (
      cod_empresa    CHAR(02),
      ies_proces     CHAR(01)
   )
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando tabela proces_912'
      RETURN FALSE
   END IF            

   CREATE UNIQUE INDEX proces_912 ON proces_912(cod_empresa)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando INDEX proces_912'
      RETURN FALSE
   END IF            
      
   RETURN TRUE

END FUNCTION 

#------------------------------#
FUNCTION pol1310_cria_tab_ped()#
#------------------------------#

   CREATE TABLE pedido_912 (
      cod_empresa    CHAR(02),
      num_pedido     INTEGER
   )
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando tabela pedido_912'
      RETURN FALSE
   END IF            

   CREATE UNIQUE INDEX pedido_912 ON pedido_912(cod_empresa)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando INDEX pedido_912'
      RETURN FALSE
   END IF            
   
   INSERT INTO pedido_912(
    cod_empresa,
    num_pedido)
   VALUES(p_cod_empresa, 299)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'inserindo tabela pedido_912'
      RETURN FALSE
   END IF            
   
   RETURN TRUE

END FUNCTION 

#------------------------------#
FUNCTION pol1310_cria_tab_edi()#
#------------------------------#
   
   DROP TABLE edi_912
   
   CREATE  TABLE edi_912 (
      registro   CHAR(129)
   )
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'criando tabela edi_912'
      RETURN FALSE
   END IF            
      
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol1310_del_tab_arq()#
#-----------------------------#

   DELETE FROM arquivos_912 
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ', m_erro CLIPPED, 'deletado tabela arquivos_912'
      RETURN FALSE
   END IF            
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1310_ck_proces()#
#---------------------------#

   SELECT ies_proces
     INTO m_ies_proces
     FROM proces_912
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS = 100 THEN
      INSERT INTO proces_912(
        cod_empresa, ies_proces)
       VALUES(p_cod_empresa,'N')
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',m_erro CLIPPED,
            ' lendo tabela proces_912'
         RETURN FALSE
      END IF
      
      IF m_ies_proces = 'S' THEN
         LET m_msg = 'Esse procesimento já está sendo executado. Tente mais tarde.'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1310_chama_delphi()#
#------------------------------#

   DEFINE l_param         CHAR(150),
          p_comando       CHAR(200),
          l_proces        CHAR(01),
          l_carac         CHAR(01)
  
   IF NOT pol1310_le_caminho('EDI') THEN
      RETURN FALSE
   END IF
   
   LET l_param = m_caminho
   
   IF NOT pol1310_le_caminho('DPH') THEN
      RETURN FALSE
   END IF
          
   IF m_caminho IS NULL THEN
      LET m_msg = 'Caminho do sistema DPH não encontrado. Consulte a log1100.'
      RETURN FALSE
   END IF
   
   LET m_ies_proces = 'S'
   
   UPDATE proces_912
      SET ies_proces = m_ies_proces
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' gravando tabela proces_912'
      RETURN FALSE
   END IF

   IF NOT pol1310_del_tab_arq() THEN
      RETURN FALSE
   END IF
   
   LET p_comando = m_caminho CLIPPED, 'pgi1314.exe ', l_param 

   CALL conout(p_comando)                            

   CALL runOnClient(p_comando)                       

   DISPLAY 'Lendo arquivos ' AT 10,14
       #lds CALL LOG_refresh_display()

   LET l_carac = '/'
   
   WHILE m_ies_proces = 'S'
   
      SELECT ies_proces
        INTO m_ies_proces
        FROM proces_912
       WHERE cod_empresa = p_cod_empresa
   
      IF STATUS <> 0 THEN
         LET m_ies_proces = 'S'
      END IF
   
      IF l_carac = '/' THEN
         LET l_carac = '-'
      ELSE
         LET l_carac = '/'
      END IF
       
      DISPLAY l_carac AT 10,45
      #lds CALL LOG_refresh_display()
       
      SLEEP 1
       
   END WHILE    
  
   RETURN TRUE      

END FUNCTION   

#---------------------------------#
FUNCTION pol1310_mov_arq(l_system)#
#---------------------------------#
   
   DEFINE l_system     CHAR(03)
   
   IF NOT pol1310_le_caminho(l_system) THEN
      RETURN FALSE
   END IF

   IF m_ies_ambiente = 'W' THEN
      LET m_comando = 'move ', m_nom_arquivo CLIPPED, ' ', m_caminho
   ELSE
      LET m_comando = 'mv ', m_nom_arquivo CLIPPED, ' ', m_caminho
   END IF
      
   RUN m_comando RETURNING p_status

   IF p_status THEN
      LET M_msg = "Nao foi possivel mover o arquivo ", m_nom_arquivo,
                  " para a pasta ", m_caminho
      RETURN FALSE
   END IF
   
   RETURN TRUE
        
END FUNCTION

#---------------------------#
FUNCTION pol1310_divid_edi()#
#---------------------------#

   DEFINE l_prefixo  CHAR(03),
          l_finish   SMALLINT
   
   DECLARE cq_pri_reg CURSOR FOR
    SELECT registro
      FROM edi_912
   FOREACH cq_pri_reg INTO m_registro

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro: ',m_erro CLIPPED,
            ' lendo tabela edi_912:cq_pri_reg'
         RETURN FALSE
      END IF
      
      LET m_registro = m_registro CLIPPED
      
      IF m_registro = ''    OR 
         m_registro IS NULL OR 
         LENGTH(m_registro) = 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET l_prefixo = m_registro[1,3]
      
      EXIT FOREACH
      
   END FOREACH
      
   IF l_prefixo IS NULL OR l_prefixo <> 'ITP' THEN
      IF NOT pol1310_mov_arq('DES') THEN
         RETURN FALSE
      END IF
      LET m_msg = 'Arquivo ', m_nom_arquivo CLIPPED, ' invalido.'
      CALL pol1310_ins_erro()
      RETURN TRUE         
   END IF   
   
   LET m_itp = m_registro
   
   SELECT registro
     INTO m_ftp
     FROM edi_912 
    WHERE registro LIKE 'FTP%'

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' lendo registro FTP da tabela edi_912'
      RETURN FALSE
   END IF
   
   LET m_ped_txt = NULL
   LET l_finish = FALSE
   
   SELECT num_pedido
     INTO m_num_pedido
     FROM pedido_912
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' lendo numeracao da tabela pedido_912'
      RETURN FALSE
   END IF
      
   DECLARE cq_edi CURSOR FOR
    SELECT registro
      FROM edi_912
   FOREACH cq_edi INTO m_registro
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro: ',m_erro CLIPPED,
            ' lendo tabela edi_912:cq_edi'
         RETURN FALSE
      END IF

      LET m_registro = m_registro CLIPPED
      
      IF m_registro = ''    OR 
         m_registro IS NULL OR 
         LENGTH(m_registro) = 0 THEN
         CONTINUE FOREACH
      END IF
      
      LET l_prefixo = m_registro[1,3]
      
      IF l_prefixo = 'ITP' THEN
         CONTINUE FOREACH
      END IF

      IF l_prefixo = 'FTP' THEN
         EXIT FOREACH
      END IF

      IF l_prefixo = 'PM1' THEN
         IF l_finish THEN
            FINISH REPORT pol1310_relat
         END IF 
         LET m_num_pedido = m_num_pedido + 1
         LET m_ped_txt = m_num_pedido USING '<<<<<<<<<<'
         LET m_relat = 'pedido', m_ped_txt CLIPPED
         LET m_relat = m_par_vdp CLIPPED, m_relat CLIPPED
         MESSAGE 'Arquivo: ', m_relat
                #lds CALL LOG_refresh_display()
         START REPORT pol1310_relat TO m_relat 
         LET l_finish = TRUE
      END IF

      OUTPUT TO REPORT pol1310_relat() 
   
   END FOREACH

   IF l_finish THEN
      FINISH REPORT pol1310_relat
   END IF 

   UPDATE pedido_912 
      SET num_pedido = m_num_pedido
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro: ',m_erro CLIPPED,
         ' atualizando tabela pedido_912'
      RETURN FALSE
   END IF

   IF NOT pol1310_mov_arq('PRC') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE  

END FUNCTION

#---------------------#
REPORT pol1310_relat()#
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT

      FIRST PAGE HEADER  
         PRINT COLUMN 001, m_itp
                                     
      ON EVERY ROW
         PRINT COLUMN 001, m_registro
                              
      ON LAST ROW
         PRINT COLUMN 001, m_ftp

        
END REPORT
