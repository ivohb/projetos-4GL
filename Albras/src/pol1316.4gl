#-------------------------------------------------------------------#
# OBJETIVO: IMPORTAÇÃO DO FERRAMENTAL DO PPI                        #
# DATA....: 08/08/2019                                              #
#-------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario
          
END GLOBALS

DEFINE p_comando            CHAR(80),  
       p_versao             CHAR(18),     
       p_caminho            CHAR(080),    
       m_msg                CHAR(150),
       p_status             SMALLINT    
                                       
DEFINE m_cod_arranjo        CHAR(10),
       m_num_ordem          CHAR(10),
       m_num_seq            CHAR(03),
       m_dat_ini            CHAR(10),
       m_dat_fim            CHAR(10),
       m_operacao           CHAR(05),
       m_linha              CHAR(60),
       m_dat_proces         CHAR(20),
       m_caminho            CHAR(120),
       m_ies_ambiente       CHAR(01),
       m_nom_arquivo        CHAR(120),
       m_processo           CHAR(80),
       m_dat_fec_man        DATE,
       m_count              INTEGER,
       m_seq_reg_mestre     INTEGER, 
       m_cod_operac         CHAR(10),
       m_cod_ferram         CHAR(15)

MAIN
   
   LET m_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   LET m_msg = NULL
   
   IF NUM_ARGS() > 0  THEN
      CALL LOG_connectDatabase("DEFAULT")
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_processo = 'Via bat ou outra aplicação'
      CALL pol1316_processar() 
   ELSE
      CALL log0180_conecta_usuario()
      CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
      
      IF p_status = 0  THEN
         LET m_processo = 'Manualmente pelo menu logix'
         CALL pol1316_processar()
         IF m_msg IS NOT NULL THEN
            CALL log0030_mensagem(m_msg,'INFO')
         END IF
      END IF
     
   END IF
      
END MAIN       

#------------------------------#
FUNCTION pol1316_job(l_rotina) #
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
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '01'
   END IF

   IF l_param2_user IS NULL THEN
      LET l_param2_user = 'job0003'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   LET m_processo = 'Executando via JOB0003'

   CALL pol1316_processar()
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#          
FUNCTION pol1316_processar()#
#---------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "POL1316-12.00.00  "
   CALL func002_versao_prg(p_versao)
   
   LET m_msg = NULL
   
   CALL pol1316_exec_processo()
   
   IF m_msg IS NULL THEN
      LET m_msg = 'Operação efetuada com sucesso'
   END IF

   INSERT INTO proces_pol1316 VALUES(p_cod_empresa,m_dat_proces,m_msg, m_processo)
             
END FUNCTION


#-------------------------------#
FUNCTION pol1316_exec_processo()#
#-------------------------------#
   
   DEFINE l_posi_arq, l_qtd_arq INTEGER
          

   IF NOT log0150_verifica_se_tabela_existe("proces_pol1316") THEN 
      IF NOT pol1316_cria_proces() THEN
         RETURN 
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe("apont_pol1316") THEN 
      IF NOT pol1316_cria_apont() THEN
         RETURN 
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe("ferra_ppi_pol1316") THEN 
      IF NOT pol1316_cria_f_ppi() THEN
         RETURN 
      END IF
   END IF

   IF NOT pol1316_cria_ferra() THEN
      RETURN 
   END IF
   
   SELECT nom_caminho,
          ies_ambiente
     INTO m_caminho,
          m_ies_ambiente
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "TXT"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema TXT não cadastrado na LOG1100.'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS, ' lendo tabela path_logix_v2 '
      ELSE
         IF m_caminho IS NULL THEN
            LET m_msg = 'Caminho do sistema TXT está nulo na LOG1100.'
         END IF
      END IF
   END IF
   
   IF m_msg IS NOT NULL THEN
      RETURN
   END IF

   LET m_caminho = m_caminho CLIPPED
   LET l_posi_arq = LENGTH(m_caminho) + 1
   LET l_qtd_arq = LOG_file_getListCount(m_caminho,"tabela_logix_ferramental.txt",FALSE,FALSE,TRUE)
   
   IF l_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', m_caminho
      RETURN 
   END IF
   
   LET m_nom_arquivo = LOG_file_getFromList(1)
   
   LOAD FROM m_nom_arquivo INSERT INTO ferra_pol1316
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') LOAD para tab ferra_pol1316'
      RETURN 
   END IF
   
   SELECT COUNT(*) INTO m_count
     FROM ferra_pol1316

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') COUNT na tab ferra_pol1316'
      RETURN 
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Não há dados no arquivo tabela_logix_ferramental.txt'
      RETURN 
   END IF
   
   IF NOT pol1316_move_arquivo() THEN
      RETURN
   END IF
   
   SELECT dat_fecha_ult_man
     INTO m_dat_fec_man
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') LENDO PAR_ESTOQUE'
      RETURN 
   END IF
   
   LET m_dat_fec_man = m_dat_fec_man + 1
   
   CALL pol1316_importa_ferramenta()
   
END FUNCTION

#-----------------------------#
FUNCTION pol1316_cria_proces()#
#-----------------------------#
      
   CREATE  TABLE proces_pol1316 (
    cod_empresa        char(02),
    dat_proces         char(20),
    mensagem           char(150),
    processado         char(80)
   );
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO TAB proces_pol1316'
      RETURN FALSE
   END IF

   CREATE INDEX ix_proces_pol1316
    ON proces_pol1316(cod_empresa,dat_proces);

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO ind ix_proces_pol1316'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1316_cria_apont()#
#----------------------------#
      
   CREATE  TABLE apont_pol1316 (
    cod_empresa        char(02),
    seq_reg_mestre     INTEGER
   );
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO TAB apont_pol1316'
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_apont_pol1316
    ON apont_pol1316(cod_empresa,seq_reg_mestre);

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO IND ix_apont_pol1316'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1316_cria_f_ppi()#
#----------------------------#
   
   DROP TABLE ferra_ppi_pol1316;
   
   CREATE  TABLE ferra_ppi_pol1316 (
    cod_empresa        char(02),
    num_ordem          INTEGER,
    cod_operac         char(05),
    num_sequencia      INTEGER,
    cod_ferram         char(15),
    cod_status         char(01)
   );
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO TAB ferra_ppi_pol1316'
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_ferra_ppi_pol1316
    ON ferra_ppi_pol1316(cod_empresa,num_ordem,cod_operac,num_sequencia);

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO IND ix_ferra_ppi_pol1316'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1316_cria_ferra()#
#----------------------------#
   
   DROP TABLE ferra_pol1316;
   
   CREATE  TABLE ferra_pol1316 (
    num_ordem          char(10),
    cod_operac         char(10),
    cod_ferram         char(15),
    num_sequencia      char(80)
   );
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO TAB ferra_pol1316'
      RETURN FALSE
   END IF

   CREATE INDEX ix_ferra_pol1316
    ON ferra_pol1316(num_ordem,cod_operac);

   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO:(',STATUS, ') CRIANDO IND ix_ferra_pol1316'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1316_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_data           CHAR(19),
          l_hora           CHAR(08)
   
   LET l_data = EXTEND(CURRENT,YEAR TO DAY)
   LET l_hora = TIME
   LET l_data = l_data CLIPPED,l_hora[1,2],l_hora[4,5],l_hora[7,8]
   
   LET l_arq_dest = m_caminho CLIPPED,l_data CLIPPED,'.log'

   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_nom_arquivo CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_nom_arquivo CLIPPED, ' ', l_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'Não foi possivel renomear o arquivo do PPI'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   
   
#-----------------------------------#
#Ler o código da ferramenta do      #
# arquivo txt e gravar esse código  #
# nos apontamentos efetuados        #
#Mover o arquivo texto de pasta     #
# para evitar seu reprocessamento   #
#                                   #
#ORDEM  OPER.SEQ FERRAM             #
#12840913|400.1|FE5120A|            #
#                                   #
#-----------------------------------#
FUNCTION pol1316_importa_ferramenta()
#-----------------------------------#

   DEFINE lr_ferra     RECORD
    num_ordem          char(10),
    cod_operac         char(10),
    cod_ferram         char(15),
    num_sequencia      char(80)
   END RECORD
   
   DEFINE l_operacao   CHAR(10),
          l_ind,l_posi INTEGER,
          l_tamanho    INTEGER,
          l_num_ordem  INTEGER,
          l_num_seq    INTEGER,
          l_cod_operac CHAR(05),
          l_funcao     CHAR(01)
   
   DECLARE cq_separa CURSOR WITH HOLD FOR
    SELECT * FROM ferra_pol1316
   
   FOREACH cq_separa INTO lr_ferra.*

      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') LENDO FERRA_POL1316'
         RETURN 
      END IF 
      
      LET l_operacao = lr_ferra.cod_operac CLIPPED
      LET l_tamanho = LENGTH(l_operacao CLIPPED)
      
      FOR l_ind = 1 TO l_tamanho
          IF l_operacao[l_ind] = '.' THEN
             LET l_posi = l_ind - 1
             LET l_cod_operac = l_operacao[1,l_posi]
             LET l_posi = l_ind + 1
             LET l_num_seq = l_operacao[l_posi, l_tamanho]
             EXIT FOR
          END IF
      END FOR
      
      LET l_num_ordem = lr_ferra.num_ordem
      
      SELECT 1 FROM ferra_ppi_pol1316
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = l_num_ordem
         AND cod_operac = l_cod_operac
         AND num_sequencia = l_num_seq

      IF STATUS = 0 THEN
         LET l_funcao = 'A'
      ELSE
         IF STATUS = 100 THEN
            LET l_funcao = 'I'
         ELSE
            LET m_msg = 'ERRO:(',STATUS, ') LENDO FERRA_PPI_POL1316'
            RETURN 
         END IF
      END IF 

      CALL log085_transacao("BEGIN")
      
      IF l_funcao = 'I' THEN
         INSERT INTO ferra_ppi_pol1316
          VALUES(p_cod_empresa,l_num_ordem, l_cod_operac, 
                 l_num_seq, lr_ferra.cod_ferram, 'N')
      ELSE
         UPDATE ferra_ppi_pol1316 
            SET cod_ferram = lr_ferra.cod_ferram,
                cod_status = 'N'
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem = l_num_ordem
            AND cod_operac = l_cod_operac
            AND num_sequencia = l_num_seq                
      END IF
      
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') GRAVANADO REG. NA TAB FERRA_PPI_POL1316'
         CALL log085_transacao("ROLLBACK")
         RETURN 
      END IF 
      
      CALL log085_transacao("COMMIT")
      
   END FOREACH
            
   DECLARE cq_import CURSOR WITH HOLD FOR
    SELECT m.seq_reg_mestre, f.cod_operac, f.cod_ferram,
           f.num_ordem, f.num_sequencia
      FROM man_apo_mestre m, man_apo_detalhe d, ferra_ppi_pol1316 f
     WHERE m.empresa = p_cod_empresa
       AND m.sit_apontamento = 'A'
       AND m.data_producao >= m_dat_fec_man
       AND m.empresa = d.empresa
       AND m.seq_reg_mestre = d.seq_reg_mestre
       AND m.ordem_producao = f.num_ordem
       AND d.operacao = f.cod_operac
       AND d.sequencia_operacao = f.num_sequencia
       AND f.cod_status = 'N'
       AND m.seq_reg_mestre NOT IN (
         SELECT a.seq_reg_mestre FROM apont_pol1316 a
          WHERE a.cod_empresa = m.empresa)

   FOREACH cq_import INTO m_seq_reg_mestre, m_cod_operac, 
      m_cod_ferram, l_num_ordem, l_num_seq
     
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') LENDO APONTAMENTOS'
         RETURN 
      END IF 
      
      CALL log085_transacao("BEGIN")
      
      UPDATE man_apo_detalhe SET ferramental = m_cod_ferram
       WHERE empresa = p_cod_empresa
         AND seq_reg_mestre = m_seq_reg_mestre

      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') UPDATE MAN_APO_DETALHE'
         CALL log085_transacao("ROLLBACK")
         RETURN 
      END IF 
      
      UPDATE ferra_ppi_pol1316
         SET cod_status = 'P'
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = l_num_ordem
         AND cod_operac = m_cod_operac
         AND num_sequencia = l_num_seq

      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') UPDATE FERRA_PPI_POL1316'
         CALL log085_transacao("ROLLBACK")
         RETURN 
      END IF 
      
      INSERT INTO apont_pol1316
       VALUES(p_cod_empresa, m_seq_reg_mestre)
       
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO:(',STATUS, ') INSERT APONT_POL1316'
         CALL log085_transacao("ROLLBACK")
         RETURN 
      END IF 
      
      CALL log085_transacao("COMMIT")
     
  END FOREACH

END FUNCTION
