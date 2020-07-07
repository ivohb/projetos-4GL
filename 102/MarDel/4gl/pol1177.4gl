#-----------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                                 #
# PROGRAMA: POL1177                                                     #
# MODULOS.: POL1177-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060             #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500             #
# OBJETIVO: INSPE플O DE ENTRADA                                         #
# AUTOR...: POLO INFORMATICA - IVO SQL                                  #
# DATA....: 17/07/2006                                                  #
#-----------------------------------------------------------------------#

DATABASE LOGIX

GLOBALS
   DEFINE P_COD_EMPRESA        LIKE EMPRESA.COD_EMPRESA,
          P_DEN_EMPRESA        LIKE EMPRESA.DEN_EMPRESA,
          P_USER               LIKE USUARIO.NOM_USUARIO,
          P_COD_ITEM           LIKE ITEM.COD_ITEM,
          P_COD_LOCAL_ESTOQ    LIKE ITEM.COD_LOCAL_ESTOQ,
          P_COD_LOCAL_INSP     LIKE ITEM.COD_LOCAL_INSP,
          P_COD_LOCAL_AR       LIKE ITEM.COD_LOCAL_INSP,
          P_NUM_TRANSAC        LIKE ESTOQUE_LOTE.NUM_TRANSAC,
          P_NUM_TRANSAC_ORIG   LIKE AVISO_REC_ESTOQUE.NUM_TRANSAC,
          P_COD_OPERACAO       LIKE PAR_SUP.COD_OPERAC_ESTOQ_L,
          P_QTD_SALDO          LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_INSP_NORMAL    LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_INSP_EXCEPC    LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_IES_LIBERACAO_INSP LIKE AVISO_REC.IES_LIBERACAO_INSP,
          P_COD_FORNECEDOR     LIKE NF_SUP.COD_FORNECEDOR,
          P_NUM_AVISO_REC      LIKE NF_SUP.NUM_AVISO_REC,
          P_FATOR              LIKE ORDEM_SUP.FAT_CONVER_UNID,
          P_NUM_OC             LIKE AVISO_REC.NUM_OC,
          P_ZZ2_FLAG           CHAR(01),
          P_ZZ2_OBS            CHAR(100),
          P_QTD_INSPECIONADA   LIKE AVISO_REC.QTD_LIBER,
          P_QTD_PC_A_INSP      LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_PC_EXCEP       LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_PC_INSP        LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_TOTAL          LIKE AVISO_REC.QTD_LIBER,
          P_DIFER              LIKE ESTOQUE_LOTE.QTD_SALDO,
          P_QTD_RECEBIDA       LIKE AVISO_REC.QTD_RECEBIDA,
          P_COUNT              SMALLINT,
          P_STATUS             SMALLINT,
          COMANDO              CHAR(80),
          P_IES_IMPRESSAO      CHAR(01),
          G_IES_AMBIENTE       CHAR(01),
          P_VERSAO             CHAR(18),
          P_NOM_ARQUIVO        CHAR(100),
          P_NOM_TELA           CHAR(200),
          P_NOM_HELP           CHAR(200),
          P_HOUVE_ERRO         SMALLINT,
          P_CAMINHO            CHAR(080),
          P_ENDERECO           LIKE ESTOQUE_TRANS_END.ENDERECO,
          p_instancia          CHAR(30),
          p_cod_erro           CHAR(07),
          p_msg                CHAR(80),
          p_dat_proces         DATETIME YEAR TO SECOND,
          p_num_ar             INTEGER

          
   DEFINE P_ESTOQUE_LOTE       RECORD LIKE ESTOQUE_LOTE.*,
          P_ESTOQUE_LOTE_ENDER RECORD LIKE ESTOQUE_LOTE_ENDER.*,
          P_ESTOQUE_TRANS      RECORD LIKE ESTOQUE_TRANS.*,
          P_ESTOQUE_TRANS_END  RECORD LIKE ESTOQUE_TRANS_END.*,
          P_ESTOQUE_AUDITORIA  RECORD LIKE ESTOQUE_AUDITORIA.*

   DEFINE 	P_ZZ2          RECORD 
			ZZ2_FILIAL   CHAR(06),               
			ZZ2_PRODUT   CHAR(15),               
    	ZZ2_AR       CHAR(15),               
	    ZZ2_SEQAR    DECIMAL(3,0),           
	    ZZ2_LOTE     CHAR(16),               
	    ZZ2_QTDLIB    DECIMAL(12,2),          
	    ZZ2_QTREJ    DECIMAL(12,2),          
	    ZZ2_QTEXCE   DECIMAL(12,2),          
	    ZZ2_FLAG     CHAR(1),                
	    ZZ2_OBS      CHAR(100),              
	    ZZ2_SALDO    DECIMAL(12,2),          
	    ZZ2_NUMSEQ   CHAR(06),               
	    ZZ2_DATA     CHAR(08),  
      ZZ2_TPREG    CHAR(02),
      ZZ2_NUMOP    CHAR(09),
      ZZ2_SEQLOT   CHAR(02),		
      D_E_L_E_T_   CHAR(01),               
      R_E_C_N_O_   INTEGER

   END RECORD

   DEFINE P_AEN              RECORD 
          COD_LIN_PROD       LIKE ITEM.COD_LIN_PROD,
          COD_LIN_RECEI      LIKE ITEM.COD_LIN_RECEI,
          COD_SEG_MERC       LIKE ITEM.COD_SEG_MERC,
          COD_CLA_USO        LIKE ITEM.COD_CLA_USO
  END RECORD

END GLOBALS

DEFINE SQL_STMT CHAR(2000)

MAIN
   CALL LOG0180_CONECTA_USUARIO()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60 
   DEFER INTERRUPT
   LET P_VERSAO = "POL1177-10.02.27"
   INITIALIZE P_NOM_HELP TO NULL  
   
   CALL LOG140_PROCURA_CAMINHO("POL1177.IEM") RETURNING P_NOM_HELP
   LET P_NOM_HELP = P_NOM_HELP CLIPPED

   {CALL LOG001_ACESSA_USUARIO("ESPEC999","")
      RETURNING P_STATUS, P_COD_EMPRESA, P_USER
   IF P_STATUS = 0  THEN
      CALL POL1177_CONTROLE()
   END IF}

   LET P_USER = 'SIGA'
   CALL POL1177_CONTROLE()
   
END MAIN

#------------------------------#
FUNCTION pol1177_job(l_rotina) #
#------------------------------#

   DEFINE L_ROTINA          CHAR(06),
          L_DEN_EMPRESA     CHAR(50),
          L_PARAM1_EMPRESA  CHAR(02),
          L_PARAM2_USER     CHAR(08),
          L_PARAM3_USER     CHAR(08),
          L_STATUS          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '01'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_user IS NULL THEN
      LET p_user = 'pol1177'
   END IF
   }
   
   LET p_houve_erro = FALSE

   LET P_USER = 'SIGA'
   CALL POL1177_CONTROLE()
   
   IF P_HOUVE_ERRO THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   


#--------------------------#
 FUNCTION POL1177_CONTROLE()
#--------------------------#

   LET p_num_ar = 0
   
   IF NOT pol1177_checa_proces() THEN
      LET p_houve_erro = TRUE
      CALL pol1177_erro_critico()
      RETURN
   END IF
   
   CALL LOG085_TRANSACAO("BEGIN")

   IF POL1177_PROCESSA() THEN
      CALL LOG085_TRANSACAO("COMMIT")
      LET P_HOUVE_ERRO = FALSE
   ELSE
      CALL LOG085_TRANSACAO("ROLLBACK")
      LET P_HOUVE_ERRO = TRUE
      CALL pol1177_erro_critico()
   END IF

   UPDATE proces_pol1177_5054 
      SET processando = 'N'

   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'AUTALIZANDO TABELA PROCES_POL1177_5054'
      CALL pol1177_erro_critico()
      LET p_houve_erro = TRUE
   END IF
  
END FUNCTION

#------------------------------#
FUNCTION pol1177_checa_proces()#
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
          p_hoje                 DATE,
          p_processando          CHAR(01)

   LET p_processa = FALSE
   LET p_encontrou = FALSE
   LET p_hor_atu = CURRENT HOUR TO SECOND

   DECLARE cq_proces CURSOR FOR
    SELECT dat_proces,
           hor_proces,
           processando
      FROM proces_pol1177_5054

   FOREACH cq_proces INTO p_data, p_hora, p_processando
     
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'LENDO TABELA PROCES_POL1177_5054'
         RETURN FALSE
      END IF
      
      LET p_encontrou = TRUE

      IF p_processando = 'N' THEN    
         LET p_processa = TRUE      
         EXIT FOREACH
      END IF
         
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
         
      IF p_qtd_segundo > 3600 THEN
         LET p_processa = TRUE
      END IF
      
      EXIT FOREACH
   
   END FOREACH

   LET p_hoje = TODAY
   LET p_hor_proces = p_hor_atu
   
   IF p_encontrou THEN
      IF NOT p_processa THEN
         RETURN FALSE
      ELSE           
         UPDATE proces_pol1177_5054 
            SET dat_proces = p_hoje, hor_proces = p_hor_proces, processando = 'S'
         IF STATUS <> 0 THEN
            LET p_cod_erro = STATUS
            LET p_msg = 'AUTALIZANDO TABELA PROCES_POL1177_5054'
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF
   END IF 

   INSERT INTO proces_pol1177_5054
    VALUES(p_hoje, p_hor_proces, 'S')
   
   IF STATUS <> 0 THEN
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO NA TABELA PROCES_POL1177_5054'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1177_erro_critico()
#-------------------------------#

   LET P_DAT_PROCES = CURRENT

   INSERT INTO ERRO_CRITICO_5054
      VALUES (P_COD_EMPRESA,
              P_USER,
              P_NUM_AR,
              P_DAT_PROCES,
              P_COD_ERRO,
              P_MSG)
      
END FUNCTION
    
#--------------------------#
FUNCTION POL1177_PROCESSA()
#--------------------------#

   DEFINE P_POSI SMALLINT

   SELECT parametro_texto
     INTO p_instancia
     FROM min_par_modulo
    WHERE empresa = '01'
      AND parametro = 'INSTANCIA_PROTHEUS'
   
   IF STATUS = 100 THEN
      LET p_instancia = ''
   ELSE 
      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE
      END IF
   END IF

   LET p_instancia = log9900_conversao_minusculo(p_instancia)
   
   LET SQL_STMT =
   "SELECT ZZ2_FILIAL, ",
          "ZZ2_PRODUT, ",
          "ZZ2_AR,     ",
          "ZZ2_SEQAR,  ",
          "ZZ2_LOTE,   ",
          "ZZ2_QTDLIB, ",
          "ZZ2_QTREJ,  ",
          "ZZ2_QTEXCE, ",
          "ZZ2_FLAG,   ",
          "ZZ2_OBS,    ",
          "ZZ2_SALDO,  ",
          "ZZ2_NUMSEQ, ",
          "ZZ2_DATA,   ",
		      "ZZ2_TPREG,  ",
          "ZZ2_NUMOP,  ",
		      "ZZ2_SEQLOT, ",
          "D_E_L_E_T_, ",
          "R_E_C_N_O_  ",
     " FROM ", p_instancia CLIPPED, "ZZ2010 WHERE ZZ2_FLAG IN ('N','E') "

   PREPARE VAR_QUERY FROM SQL_STMT
   DECLARE CQ_ZZ2 CURSOR FOR VAR_QUERY
   
   FOREACH CQ_ZZ2 INTO 
           P_ZZ2.ZZ2_FILIAL,  
           P_ZZ2.ZZ2_PRODUT,  
           P_ZZ2.ZZ2_AR,      
           P_ZZ2.ZZ2_SEQAR,   
           P_ZZ2.ZZ2_LOTE,    
           P_ZZ2.ZZ2_QTDLIB,   
           P_ZZ2.ZZ2_QTREJ,   
           P_ZZ2.ZZ2_QTEXCE,  
           P_ZZ2.ZZ2_FLAG,    
           P_ZZ2.ZZ2_OBS,     
           P_ZZ2.ZZ2_SALDO,   
           P_ZZ2.ZZ2_NUMSEQ,  
           P_ZZ2.ZZ2_DATA,  
           P_ZZ2.ZZ2_TPREG,    
           P_ZZ2.ZZ2_NUMOP, 
		       P_ZZ2.ZZ2_SEQLOT,
           P_ZZ2.D_E_L_E_T_,  
           P_ZZ2.R_E_C_N_O_ 

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'LENDO A TABELA ZZ2010 - CURSOR CQ_ZZ2'
         RETURN FALSE
      END IF
            
      LET P_COD_EMPRESA = P_ZZ2.ZZ2_FILIAL[5,6]
      LET p_num_ar = P_ZZ2.ZZ2_AR
      IF  P_COD_EMPRESA = ' ' 
      OR  P_COD_EMPRESA = '0' 
      OR  P_COD_EMPRESA = '0 'THEN 
         CONTINUE FOREACH
      END IF   
      
      SELECT COD_OPERAC_ESTOQ_L
        INTO P_COD_OPERACAO
        FROM PAR_SUP
       WHERE COD_EMPRESA = P_COD_EMPRESA

      IF STATUS <> 0 THEN
         LET p_cod_erro = STATUS
         LET p_msg = 'LENDO A TABELA PAR_SUP'
         RETURN FALSE
      END IF

      LET P_ZZ2_FLAG  = "E"

      SELECT COD_LOCAL_INSP,
             COD_LOCAL_ESTOQ,
             COD_LIN_PROD, 
             COD_LIN_RECEI,
             COD_SEG_MERC, 
             COD_CLA_USO             
        INTO P_COD_LOCAL_INSP, P_COD_LOCAL_ESTOQ, P_AEN.*
        FROM ITEM
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND COD_ITEM    = P_ZZ2.ZZ2_PRODUT
      
      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET P_ZZ2_OBS = 'PRODUTO INEXISTENTE'
         IF NOT POL1177_ATUALIZA_ZZ2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF

      IF P_ZZ2.ZZ2_TPREG <> 'OP' THEN
      
         SELECT (QTD_REJEIT + QTD_LIBER + QTD_LIBER_EXCEP),                                               
                QTD_RECEBIDA,                                                                             
                IES_LIBERACAO_INSP,                                                                       
                NUM_AVISO_REC,                                                                            
                NUM_OC,                                                                                   
                COD_LOCAL_ESTOQ
           INTO P_QTD_INSPECIONADA,                                                                       
                P_QTD_RECEBIDA,                                                                           
                P_IES_LIBERACAO_INSP,                                                                     
                P_NUM_AVISO_REC,                                                                          
                P_NUM_OC,                                                                                 
                P_COD_LOCAL_AR                                                                          
           FROM AVISO_REC                                                                       
          WHERE COD_EMPRESA   = P_COD_EMPRESA                                                             
            AND NUM_AVISO_REC = P_ZZ2.ZZ2_AR                                                              
            AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT                                                          
            AND NUM_SEQ       = P_ZZ2.ZZ2_SEQAR                                                           
                                                                                                          
         IF SQLCA.SQLCODE = NOTFOUND THEN                                                                 
            LET P_ZZ2_OBS = 'AR/PRODUTO/SEQUENCIA INEXISTENTE'                                            
            IF NOT POL1177_ATUALIZA_ZZ2() THEN                                                            
               RETURN FALSE                                                                               
            ELSE                                                                                          
               CONTINUE FOREACH                                                                           
            END IF                                                                                        
         END IF                                                                                           

         IF (P_COD_LOCAL_INSP IS NULL)  
         OR (P_COD_LOCAL_INSP = ' ')  		 THEN                                                                                                                              
             LET P_COD_LOCAL_INSP = P_COD_LOCAL_ESTOQ                                                                                                                                        
         END IF                                                                                           
                                                                                                          
         IF P_IES_LIBERACAO_INSP = "S" THEN                                                               
            LET P_ZZ2_OBS = 'ITEM: ', P_ZZ2.ZZ2_PRODUT, ' JA INSPECIONADO'                                
            IF NOT POL1177_ATUALIZA_ZZ2() THEN                                                            
               RETURN FALSE                                                                               
            ELSE                                                                                          
               CONTINUE FOREACH                                                                           
            END IF                                                                                        
         END IF                                                                                           
                                                                                                          
         SELECT COD_FORNECEDOR                                                                            
           INTO P_COD_FORNECEDOR                                                                          
           FROM NF_SUP                                                                          
          WHERE COD_EMPRESA   = P_COD_EMPRESA                                                             
            AND NUM_AVISO_REC = P_NUM_AVISO_REC      

         SELECT FAT_CONVER_UNID                    
           INTO P_FATOR                            
           FROM ORDEM_SUP                
          WHERE COD_EMPRESA = P_COD_EMPRESA        
            AND NUM_OC      = P_NUM_OC             
            AND IES_VERSAO_ATUAL = 'S'             
                                                   
         IF SQLCA.SQLCODE = NOTFOUND THEN          
            LET P_FATOR = 1                        
         END IF                                    
                                                   
         IF P_FATOR = 0 OR P_FATOR IS NULL THEN    
            LET P_FATOR = 1                        
         END IF      
      ELSE                              
         LET P_FATOR = 1       
         LET P_ZZ2.ZZ2_AR    = P_ZZ2.ZZ2_NUMOP
         LET P_ZZ2.ZZ2_SEQAR = 0                                             
      END IF
      
      LET P_QTD_PC_INSP = (P_ZZ2.ZZ2_QTDLIB + P_ZZ2.ZZ2_QTREJ + P_ZZ2.ZZ2_QTEXCE)
      
      IF P_QTD_PC_INSP = 0 THEN
         LET P_ZZ2_OBS = 'SOMATORIA DAS QUANTIDADES INSPECIONADAS = 0'
         IF NOT POL1177_ATUALIZA_ZZ2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
            
      SELECT *
        INTO P_ESTOQUE_LOTE.*
        FROM ESTOQUE_LOTE
       WHERE COD_EMPRESA   = P_COD_EMPRESA
         AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
         AND COD_LOCAL     = P_COD_LOCAL_INSP
         AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
         AND IES_SITUA_QTD = 'I'

      IF STATUS <> 0 THEN 
         LET P_COD_LOCAL_INSP = P_COD_LOCAL_ESTOQ
         SELECT *
           INTO P_ESTOQUE_LOTE.*
           FROM ESTOQUE_LOTE
          WHERE COD_EMPRESA   = P_COD_EMPRESA
            AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
            AND COD_LOCAL     = P_COD_LOCAL_INSP
            AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
            AND IES_SITUA_QTD = 'I'

         IF STATUS <> 0 THEN 
            LET P_COD_LOCAL_INSP = P_COD_LOCAL_AR
            SELECT *
              INTO P_ESTOQUE_LOTE.*
              FROM ESTOQUE_LOTE
             WHERE COD_EMPRESA   = P_COD_EMPRESA
               AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
               AND COD_LOCAL     = P_COD_LOCAL_INSP
               AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
               AND IES_SITUA_QTD = 'I'

            IF STATUS <> 0 THEN
               LET P_COD_LOCAL_INSP = 'DEVOLUCAO'
               SELECT *
                 INTO P_ESTOQUE_LOTE.*
                 FROM ESTOQUE_LOTE
                WHERE COD_EMPRESA   = P_COD_EMPRESA
                  AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
                  AND COD_LOCAL     = P_COD_LOCAL_INSP
                  AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
                  AND IES_SITUA_QTD = 'I'
            
               IF STATUS <> 0 THEN
                  LET P_COD_LOCAL_INSP = 'RETRABALHO'
                  SELECT *
                    INTO P_ESTOQUE_LOTE.*
                    FROM ESTOQUE_LOTE
                   WHERE COD_EMPRESA   = P_COD_EMPRESA
                     AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
                     AND COD_LOCAL     = P_COD_LOCAL_INSP
                     AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
                     AND IES_SITUA_QTD = 'I'
            
                  IF STATUS <> 0 THEN
                     LET P_ZZ2_OBS = 'LOTE INEXISTENTE - ESTOQUE_LOTE'
                     IF NOT POL1177_ATUALIZA_ZZ2() THEN
                        RETURN FALSE
                     ELSE
                        CONTINUE FOREACH
                     END IF
                  END IF
               END IF
            END IF
         END IF
      END IF

      SELECT *
        INTO P_ESTOQUE_LOTE_ENDER.*
        FROM ESTOQUE_LOTE_ENDER
       WHERE COD_EMPRESA   = P_COD_EMPRESA
         AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
         AND COD_LOCAL     = P_COD_LOCAL_INSP
         AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
         AND IES_SITUA_QTD = 'I'
     
      IF SQLCA.SQLCODE <> 0 THEN 
         LET P_ZZ2_OBS = 'LOTE INEXISTENTE - ESTOQUE_LOTE_ENDER'
         IF NOT POL1177_ATUALIZA_ZZ2() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      LET P_QTD_PC_A_INSP = P_ESTOQUE_LOTE.QTD_SALDO
      
      IF P_QTD_PC_INSP > P_QTD_PC_A_INSP THEN
         LET P_DIFER = P_QTD_PC_INSP - P_QTD_PC_A_INSP
         IF P_DIFER >= 1 THEN
            LET P_ZZ2_OBS = 'QUANTIDADE A INSPECIONAR > SALDO DO LOTE'
            IF NOT POL1177_ATUALIZA_ZZ2() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
      END IF

      UPDATE ESTOQUE
         SET QTD_LIBERADA  = QTD_LIBERADA  + P_ZZ2.ZZ2_QTDLIB,
             QTD_REJEITADA = QTD_REJEITADA + P_ZZ2.ZZ2_QTREJ,
             QTD_LIB_EXCEP = QTD_LIB_EXCEP + P_ZZ2.ZZ2_QTEXCE,
             QTD_IMPEDIDA  = QTD_IMPEDIDA  - P_QTD_PC_INSP
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND COD_ITEM = P_ZZ2.ZZ2_PRODUT
      
      IF STATUS <> 0 THEN 
         LET p_cod_erro = STATUS
         LET p_msg = 'ATUALIZANDO A TABELA ESTOQUE'
         RETURN FALSE
      END IF

      IF P_ZZ2.ZZ2_TPREG <> 'OP' THEN      
         UPDATE AVISO_REC                                                      
            SET QTD_LIBER          = QTD_LIBER       + (P_ZZ2.ZZ2_QTDLIB / P_FATOR),      
                QTD_REJEIT         = QTD_REJEIT      + (P_ZZ2.ZZ2_QTREJ / P_FATOR),      
                QTD_LIBER_EXCEP    = QTD_LIBER_EXCEP + (P_ZZ2.ZZ2_QTEXCE / P_FATOR),     
                IES_LIBERACAO_INSP = 'S',                                                
                IES_LIBERACAO_CONT = 'S',                                                
                IES_LIBERACAO_AR   = '1',                                                
                IES_SITUA_AR       = 'E',                                                
                VAL_COMPL_ESTOQUE  = 0,                                                  
                COD_LOCAL_ESTOQ    = P_COD_LOCAL_ESTOQ                                   
          WHERE COD_EMPRESA   = P_COD_EMPRESA                                                             
            AND NUM_AVISO_REC = P_ZZ2.ZZ2_AR                                                              
            AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT                                                          
            AND NUM_SEQ       = P_ZZ2.ZZ2_SEQAR                                                           
                                                                                         
         IF STATUS <> 0 THEN 
            LET p_cod_erro = STATUS
            LET p_msg = 'ATUALIZANDO A TABELA AVISO_REC'
            RETURN FALSE
         END IF
      END IF
      
      IF NOT POL1177_MOV_ESTOQUE() THEN
         RETURN FALSE
      END IF

      LET P_ZZ2_FLAG  = "S"
      LET P_ZZ2_OBS = 'PROCESSO EFETUADO COM SUCESSO'

      IF NOT POL1177_ATUALIZA_ZZ2() THEN
         RETURN FALSE
      END IF
         
   END FOREACH
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION POL1177_MOV_ESTOQUE()
#-----------------------------#

   LET P_ESTOQUE_LOTE.QTD_SALDO = P_ESTOQUE_LOTE.QTD_SALDO -
       (P_ZZ2.ZZ2_QTDLIB + P_ZZ2.ZZ2_QTREJ + P_ZZ2.ZZ2_QTEXCE)
   
   IF P_ESTOQUE_LOTE.QTD_SALDO >= 1 THEN
      UPDATE ESTOQUE_LOTE
         SET QTD_SALDO = P_ESTOQUE_LOTE.QTD_SALDO
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND NUM_TRANSAC = P_ESTOQUE_LOTE.NUM_TRANSAC

      IF STATUS <> 0 THEN 
         LET p_cod_erro = STATUS
         LET p_msg = 'ATUALIZANDO A TABELA ESTOQUE_LOTE'
         RETURN FALSE
      END IF
         
      UPDATE ESTOQUE_LOTE_ENDER
         SET QTD_SALDO = P_ESTOQUE_LOTE.QTD_SALDO
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND NUM_TRANSAC = P_ESTOQUE_LOTE_ENDER.NUM_TRANSAC

      IF STATUS <> 0 THEN 
         LET p_cod_erro = STATUS
         LET p_msg = 'ATUALIZANDO A TABELA ESTOQUE_LOTE_ENDER'
         RETURN FALSE
      END IF
   ELSE
      DELETE FROM ESTOQUE_LOTE
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND NUM_TRANSAC = P_ESTOQUE_LOTE.NUM_TRANSAC

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL LOG003_ERR_SQL("DELE플O","ESTOQUE_LOTE")
         RETURN FALSE
      END IF
         
      DELETE FROM ESTOQUE_LOTE_ENDER
       WHERE COD_EMPRESA = P_COD_EMPRESA
         AND NUM_TRANSAC = P_ESTOQUE_LOTE_ENDER.NUM_TRANSAC

      IF STATUS <> 0 THEN 
         LET p_cod_erro = STATUS
         LET p_msg = 'DELETANDO REGISTRO TAB ESTOQUE_LOTE_ENDER'
         RETURN FALSE
      END IF
   END IF

   LET P_COUNT = 0
   
   IF P_ZZ2.ZZ2_QTDLIB > 0 THEN
      LET P_ESTOQUE_LOTE.IES_SITUA_QTD = 'L'
      LET P_ESTOQUE_LOTE.QTD_SALDO = P_ZZ2.ZZ2_QTDLIB
      SELECT NUM_TRANSAC
        INTO P_NUM_TRANSAC
        FROM ESTOQUE_LOTE
       WHERE COD_EMPRESA   = P_COD_EMPRESA
         AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
         AND COD_LOCAL     = P_COD_LOCAL_ESTOQ
         AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
         AND IES_SITUA_QTD = 'L'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET P_ESTOQUE_LOTE.NUM_TRANSAC = 0
         IF NOT POL1177_INSERE_LOTE() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT POL1177_ATUALIZA_LOTE() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF P_ZZ2.ZZ2_QTREJ > 0 THEN
      LET P_ESTOQUE_LOTE.IES_SITUA_QTD = 'R'
      LET P_ESTOQUE_LOTE.QTD_SALDO = P_ZZ2.ZZ2_QTREJ
      SELECT NUM_TRANSAC
        INTO P_NUM_TRANSAC
        FROM ESTOQUE_LOTE
       WHERE COD_EMPRESA   = P_COD_EMPRESA
         AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
         AND COD_LOCAL     = P_COD_LOCAL_ESTOQ
         AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
         AND IES_SITUA_QTD = 'R'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET P_ESTOQUE_LOTE.NUM_TRANSAC = 0
         IF NOT POL1177_INSERE_LOTE() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT POL1177_ATUALIZA_LOTE() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF P_ZZ2.ZZ2_QTEXCE > 0 THEN
      LET P_ESTOQUE_LOTE.IES_SITUA_QTD = 'E'
      LET P_ESTOQUE_LOTE.QTD_SALDO = P_ZZ2.ZZ2_QTEXCE
      SELECT NUM_TRANSAC
        INTO P_NUM_TRANSAC
        FROM ESTOQUE_LOTE
       WHERE COD_EMPRESA   = P_COD_EMPRESA
         AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
         AND COD_LOCAL     = P_COD_LOCAL_ESTOQ
         AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
         AND IES_SITUA_QTD = 'E'

      IF SQLCA.SQLCODE = NOTFOUND THEN 
         LET P_ESTOQUE_LOTE.NUM_TRANSAC = 0
         IF NOT POL1177_INSERE_LOTE() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT POL1177_ATUALIZA_LOTE() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION POL1177_INSERE_LOTE()
#-----------------------------#

   LET P_ESTOQUE_LOTE.COD_LOCAL = P_COD_LOCAL_ESTOQ

   INSERT INTO ESTOQUE_LOTE(
          COD_EMPRESA, 
          COD_ITEM, 
          COD_LOCAL, 
          NUM_LOTE, 
          IES_SITUA_QTD, 
          QTD_SALDO)  
          VALUES(P_ESTOQUE_LOTE.COD_EMPRESA,
                 P_ESTOQUE_LOTE.COD_ITEM,
                 P_ESTOQUE_LOTE.COD_LOCAL,
                 P_ESTOQUE_LOTE.NUM_LOTE,
                 P_ESTOQUE_LOTE.IES_SITUA_QTD,
                 P_ESTOQUE_LOTE.QTD_SALDO)
            
   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO NA TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF
      
   LET P_ESTOQUE_LOTE_ENDER.COD_LOCAL     = P_COD_LOCAL_ESTOQ
   LET P_ESTOQUE_LOTE_ENDER.NUM_TRANSAC   = 0
   LET P_ESTOQUE_LOTE_ENDER.QTD_SALDO     = P_ESTOQUE_LOTE.QTD_SALDO
   LET P_ESTOQUE_LOTE_ENDER.IES_SITUA_QTD = P_ESTOQUE_LOTE.IES_SITUA_QTD
   
   INSERT INTO ESTOQUE_LOTE_ENDER(
          COD_EMPRESA,
          COD_ITEM,
          COD_LOCAL,
          NUM_LOTE,
          ENDERECO,
          NUM_VOLUME,
          COD_GRADE_1,
          COD_GRADE_2,
          COD_GRADE_3,
          COD_GRADE_4,
          COD_GRADE_5,
          DAT_HOR_PRODUCAO,
          NUM_PED_VEN,
          NUM_SEQ_PED_VEN,
          IES_SITUA_QTD,
          QTD_SALDO,
          IES_ORIGEM_ENTRADA,
          DAT_HOR_VALIDADE,
          NUM_PECA,
          NUM_SERIE,
          COMPRIMENTO,
          LARGURA,
          ALTURA,
          DIAMETRO,
          DAT_HOR_RESERV_1,
          DAT_HOR_RESERV_2,
          DAT_HOR_RESERV_3,
          QTD_RESERV_1,
          QTD_RESERV_2,
          QTD_RESERV_3,
          NUM_RESERV_1,
          NUM_RESERV_2,
          NUM_RESERV_3,
          TEX_RESERVADO) 
          VALUES(P_ESTOQUE_LOTE_ENDER.COD_EMPRESA,
                 P_ESTOQUE_LOTE_ENDER.COD_ITEM,
                 P_ESTOQUE_LOTE_ENDER.COD_LOCAL,
                 P_ESTOQUE_LOTE_ENDER.NUM_LOTE,
                 P_ESTOQUE_LOTE_ENDER.ENDERECO,
                 P_ESTOQUE_LOTE_ENDER.NUM_VOLUME,
                 P_ESTOQUE_LOTE_ENDER.COD_GRADE_1,
                 P_ESTOQUE_LOTE_ENDER.COD_GRADE_2,
                 P_ESTOQUE_LOTE_ENDER.COD_GRADE_3,
                 P_ESTOQUE_LOTE_ENDER.COD_GRADE_4,
                 P_ESTOQUE_LOTE_ENDER.COD_GRADE_5,
                 P_ESTOQUE_LOTE_ENDER.DAT_HOR_PRODUCAO,
                 P_ESTOQUE_LOTE_ENDER.NUM_PED_VEN,
                 P_ESTOQUE_LOTE_ENDER.NUM_SEQ_PED_VEN,
                 P_ESTOQUE_LOTE_ENDER.IES_SITUA_QTD,
                 P_ESTOQUE_LOTE_ENDER.QTD_SALDO,
                 P_ESTOQUE_LOTE_ENDER.IES_ORIGEM_ENTRADA,
                 P_ESTOQUE_LOTE_ENDER.DAT_HOR_VALIDADE,
                 P_ESTOQUE_LOTE_ENDER.NUM_PECA,
                 P_ESTOQUE_LOTE_ENDER.NUM_SERIE,
                 P_ESTOQUE_LOTE_ENDER.COMPRIMENTO,
                 P_ESTOQUE_LOTE_ENDER.LARGURA,
                 P_ESTOQUE_LOTE_ENDER.ALTURA,
                 P_ESTOQUE_LOTE_ENDER.DIAMETRO,
                 P_ESTOQUE_LOTE_ENDER.DAT_HOR_RESERV_1,
                 P_ESTOQUE_LOTE_ENDER.DAT_HOR_RESERV_2,
                 P_ESTOQUE_LOTE_ENDER.DAT_HOR_RESERV_3,
                 P_ESTOQUE_LOTE_ENDER.QTD_RESERV_1,
                 P_ESTOQUE_LOTE_ENDER.QTD_RESERV_2,
                 P_ESTOQUE_LOTE_ENDER.QTD_RESERV_3,
                 P_ESTOQUE_LOTE_ENDER.NUM_RESERV_1,
                 P_ESTOQUE_LOTE_ENDER.NUM_RESERV_2,
                 P_ESTOQUE_LOTE_ENDER.NUM_RESERV_3,
                 P_ESTOQUE_LOTE_ENDER.TEX_RESERVADO)
   
   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO A TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF
      
   LET P_ENDERECO =   P_ESTOQUE_LOTE_ENDER.ENDERECO 
      
   IF NOT POL1177_INSERE_TRANS() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION POL1177_ATUALIZA_LOTE()
#-------------------------------#
   INITIALIZE P_ENDERECO   TO  NULL 
   
   UPDATE ESTOQUE_LOTE
      SET QTD_SALDO = QTD_SALDO + P_ESTOQUE_LOTE.QTD_SALDO
    WHERE COD_EMPRESA = P_COD_EMPRESA
      AND NUM_TRANSAC = P_NUM_TRANSAC

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'ATUALIZANDO A TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF

   SELECT NUM_TRANSAC, ENDERECO
     INTO P_NUM_TRANSAC, P_ENDERECO
     FROM ESTOQUE_LOTE_ENDER
    WHERE COD_EMPRESA   = P_COD_EMPRESA
      AND COD_ITEM      = P_ZZ2.ZZ2_PRODUT
      AND COD_LOCAL     = P_COD_LOCAL_ESTOQ
      AND NUM_LOTE      = P_ZZ2.ZZ2_LOTE
      AND IES_SITUA_QTD = P_ESTOQUE_LOTE.IES_SITUA_QTD

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'LENDO A TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF
         
   UPDATE ESTOQUE_LOTE_ENDER
      SET QTD_SALDO = QTD_SALDO + P_ESTOQUE_LOTE.QTD_SALDO
    WHERE COD_EMPRESA = P_COD_EMPRESA
      AND NUM_TRANSAC = P_NUM_TRANSAC

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'ATUALIZANDO A TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF
   
   IF NOT POL1177_INSERE_TRANS() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#-----------------------------#
FUNCTION POL1177_INSERE_TRANS()
#-----------------------------#

#    LET  P_COUNT = P_COUNT + 1
    LET  P_ESTOQUE_TRANS.COD_EMPRESA        = P_COD_EMPRESA
    LET  P_ESTOQUE_TRANS.DAT_MOVTO          = TODAY
    LET  P_ESTOQUE_TRANS.DAT_PROCES         = TODAY
    LET  P_ESTOQUE_TRANS.HOR_OPERAC         = TIME
    LET  P_ESTOQUE_TRANS.IES_TIP_MOVTO      = "N"
    LET  P_ESTOQUE_TRANS.COD_OPERACAO       = P_COD_OPERACAO
    LET  P_ESTOQUE_TRANS.COD_ITEM           = P_ZZ2.ZZ2_PRODUT
    LET  P_ESTOQUE_TRANS.NUM_TRANSAC        = 0
    LET  P_ESTOQUE_TRANS.NUM_PROG           = "POL1177"
    LET  P_ESTOQUE_TRANS.NUM_DOCUM          = P_ZZ2.ZZ2_AR
    LET  P_ESTOQUE_TRANS.NUM_SEQ            = P_ZZ2.ZZ2_SEQAR # P_COUNT
    LET  P_ESTOQUE_TRANS.CUS_UNIT_MOVTO_P   =  0
    LET  P_ESTOQUE_TRANS.CUS_TOT_MOVTO_P    =  0
    LET  P_ESTOQUE_TRANS.CUS_UNIT_MOVTO_F   =  0
    LET  P_ESTOQUE_TRANS.CUS_TOT_MOVTO_F    =  0
    LET  P_ESTOQUE_TRANS.NUM_CONTA          =  NULL
    LET  P_ESTOQUE_TRANS.NUM_SECAO_REQUIS   =  NULL
    LET  P_ESTOQUE_TRANS.COD_LOCAL_EST_ORIG =  P_COD_LOCAL_INSP
    LET  P_ESTOQUE_TRANS.COD_LOCAL_EST_DEST =  P_COD_LOCAL_ESTOQ
    LET  P_ESTOQUE_TRANS.NUM_LOTE_ORIG      =  P_ZZ2.ZZ2_LOTE
    LET  P_ESTOQUE_TRANS.NUM_LOTE_DEST      =  P_ZZ2.ZZ2_LOTE
    LET  P_ESTOQUE_TRANS.IES_SIT_EST_ORIG   =  "I"
    LET  P_ESTOQUE_TRANS.IES_SIT_EST_DEST   =  P_ESTOQUE_LOTE.IES_SITUA_QTD
    LET  P_ESTOQUE_TRANS.COD_TURNO          =  NULL
    LET  P_ESTOQUE_TRANS.NOM_USUARIO        =  P_USER
    LET  P_ESTOQUE_TRANS.QTD_MOVTO          =  P_ESTOQUE_LOTE.QTD_SALDO
    LET  P_ESTOQUE_TRANS.DAT_REF_MOEDA_FORT =  TODAY     

    INSERT INTO ESTOQUE_TRANS(
          COD_EMPRESA,
          COD_ITEM,
          DAT_MOVTO,
          DAT_REF_MOEDA_FORT,
          COD_OPERACAO,
          NUM_DOCUM,
          NUM_SEQ,
          IES_TIP_MOVTO,
          QTD_MOVTO,
          CUS_UNIT_MOVTO_P,
          CUS_TOT_MOVTO_P,
          CUS_UNIT_MOVTO_F,
          CUS_TOT_MOVTO_F,
          NUM_CONTA,
          NUM_SECAO_REQUIS,
          COD_LOCAL_EST_ORIG,
          COD_LOCAL_EST_DEST,
          NUM_LOTE_ORIG,
          NUM_LOTE_DEST,
          IES_SIT_EST_ORIG,
          IES_SIT_EST_DEST,
          COD_TURNO,
          NOM_USUARIO,
          DAT_PROCES,
          HOR_OPERAC,
          NUM_PROG)   
          VALUES (P_ESTOQUE_TRANS.COD_EMPRESA,
                  P_ESTOQUE_TRANS.COD_ITEM,
                  P_ESTOQUE_TRANS.DAT_MOVTO,
                  P_ESTOQUE_TRANS.DAT_REF_MOEDA_FORT,
                  P_ESTOQUE_TRANS.COD_OPERACAO,
                  P_ESTOQUE_TRANS.NUM_DOCUM,
                  P_ESTOQUE_TRANS.NUM_SEQ,
                  P_ESTOQUE_TRANS.IES_TIP_MOVTO,
                  P_ESTOQUE_TRANS.QTD_MOVTO,
                  P_ESTOQUE_TRANS.CUS_UNIT_MOVTO_P,
                  P_ESTOQUE_TRANS.CUS_TOT_MOVTO_P,
                  P_ESTOQUE_TRANS.CUS_UNIT_MOVTO_F,
                  P_ESTOQUE_TRANS.CUS_TOT_MOVTO_F,
                  P_ESTOQUE_TRANS.NUM_CONTA,
                  P_ESTOQUE_TRANS.NUM_SECAO_REQUIS,
                  P_ESTOQUE_TRANS.COD_LOCAL_EST_ORIG,
                  P_ESTOQUE_TRANS.COD_LOCAL_EST_DEST,
                  P_ESTOQUE_TRANS.NUM_LOTE_ORIG,
                  P_ESTOQUE_TRANS.NUM_LOTE_DEST,
                  P_ESTOQUE_TRANS.IES_SIT_EST_ORIG,
                  P_ESTOQUE_TRANS.IES_SIT_EST_DEST,
                  P_ESTOQUE_TRANS.COD_TURNO,
                  P_ESTOQUE_TRANS.NOM_USUARIO,
                  P_ESTOQUE_TRANS.DAT_PROCES,
                  P_ESTOQUE_TRANS.HOR_OPERAC,
                  P_ESTOQUE_TRANS.NUM_PROG)   

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO NA TABELA ESTOQUE_TRANS'
      RETURN FALSE
   END IF

     LET P_NUM_TRANSAC = SQLCA.SQLERRD[2]

     LET P_ESTOQUE_TRANS_END.COD_EMPRESA = P_COD_EMPRESA
     LET P_ESTOQUE_TRANS_END.NUM_TRANSAC = P_NUM_TRANSAC
     LET P_ESTOQUE_TRANS_END.ENDERECO    = P_ENDERECO
     LET P_ESTOQUE_TRANS_END.NUM_VOLUME  = 0
     LET P_ESTOQUE_TRANS_END.QTD_MOVTO = P_ESTOQUE_TRANS.QTD_MOVTO
     LET P_ESTOQUE_TRANS_END.COD_GRADE_1 = " "
     LET P_ESTOQUE_TRANS_END.COD_GRADE_2 = " "
     LET P_ESTOQUE_TRANS_END.COD_GRADE_3 = " "
     LET P_ESTOQUE_TRANS_END.COD_GRADE_4 = " "
     LET P_ESTOQUE_TRANS_END.COD_GRADE_5 = " "
     LET P_ESTOQUE_TRANS_END.DAT_HOR_PROD_INI = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.DAT_HOR_PROD_FIM = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.VLR_TEMPERATURA = 0
     LET P_ESTOQUE_TRANS_END.ENDERECO_ORIGEM = " "
     LET P_ESTOQUE_TRANS_END.NUM_PED_VEN = 0
     LET P_ESTOQUE_TRANS_END.NUM_SEQ_PED_VEN = 0
     LET P_ESTOQUE_TRANS_END.DAT_HOR_PRODUCAO = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.DAT_HOR_VALIDADE = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.NUM_PECA = " "
     LET P_ESTOQUE_TRANS_END.NUM_SERIE = " "
     LET P_ESTOQUE_TRANS_END.COMPRIMENTO = 0
     LET P_ESTOQUE_TRANS_END.LARGURA = 0
     LET P_ESTOQUE_TRANS_END.ALTURA = 0
     LET P_ESTOQUE_TRANS_END.DIAMETRO = 0
     LET P_ESTOQUE_TRANS_END.DAT_HOR_RESERV_1 = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.DAT_HOR_RESERV_2 = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.DAT_HOR_RESERV_3 = "1900-01-01 00:00:00"
     LET P_ESTOQUE_TRANS_END.QTD_RESERV_1 = 0
     LET P_ESTOQUE_TRANS_END.QTD_RESERV_2 = 0
     LET P_ESTOQUE_TRANS_END.QTD_RESERV_3 = 0
     LET P_ESTOQUE_TRANS_END.NUM_RESERV_1 = 0
     LET P_ESTOQUE_TRANS_END.NUM_RESERV_2 = 0
     LET P_ESTOQUE_TRANS_END.NUM_RESERV_3 = 0
     LET P_ESTOQUE_TRANS_END.TEX_RESERVADO = " "
     LET P_ESTOQUE_TRANS_END.CUS_UNIT_MOVTO_P = 0
     LET P_ESTOQUE_TRANS_END.CUS_UNIT_MOVTO_F = 0
     LET P_ESTOQUE_TRANS_END.CUS_TOT_MOVTO_P = 0
     LET P_ESTOQUE_TRANS_END.CUS_TOT_MOVTO_F = 0
     LET P_ESTOQUE_TRANS_END.COD_ITEM      = P_ESTOQUE_TRANS.COD_ITEM
     LET P_ESTOQUE_TRANS_END.DAT_MOVTO     = P_ESTOQUE_TRANS.DAT_MOVTO
     LET P_ESTOQUE_TRANS_END.COD_OPERACAO  = P_ESTOQUE_TRANS.COD_OPERACAO
     LET P_ESTOQUE_TRANS_END.DAT_MOVTO     = P_ESTOQUE_TRANS.DAT_MOVTO
     LET P_ESTOQUE_TRANS_END.IES_TIP_MOVTO = P_ESTOQUE_TRANS.IES_TIP_MOVTO
     LET P_ESTOQUE_TRANS_END.NUM_PROG = "POL1177"

     INSERT INTO ESTOQUE_TRANS_END
        VALUES (P_ESTOQUE_TRANS_END.*)

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO NA TABELA ESTOQUE_TRANS_END'
      RETURN FALSE
   END IF
     
   INSERT INTO EST_TRANS_AREA_LIN
       VALUES (P_COD_EMPRESA, P_NUM_TRANSAC, P_AEN.*)

   IF STATUS <> 0 THEN 
      LET p_cod_erro = STATUS
      LET p_msg = 'INSERINDO A TABELA EST_TRANS_AREA_LIN'
      RETURN FALSE
   END IF
     
    LET P_ESTOQUE_AUDITORIA.COD_EMPRESA = P_COD_EMPRESA
    LET P_ESTOQUE_AUDITORIA.NUM_TRANSAC = P_NUM_TRANSAC
    LET P_ESTOQUE_AUDITORIA.NOM_USUARIO = P_USER
    LET P_ESTOQUE_AUDITORIA.DAT_HOR_PROCES = CURRENT
    LET P_ESTOQUE_AUDITORIA.NUM_PROGRAMA = 'POL1177'
    
    INSERT INTO ESTOQUE_AUDITORIA 
       VALUES(P_ESTOQUE_AUDITORIA.*)

    IF STATUS <> 0 THEN 
       LET p_cod_erro = STATUS
       LET p_msg = 'INSERINDO A TABELA ESTOQUE_AUDITORIA'
       RETURN FALSE
    END IF
   
   IF P_ZZ2.ZZ2_TPREG = 'AR' THEN
   
      SELECT NUM_TRANSAC                                              
        INTO P_NUM_TRANSAC_ORIG                                       
        FROM AVISO_REC_ESTOQUE                                        
       WHERE COD_EMPRESA   = P_COD_EMPRESA                            
         AND NUM_AVISO_REC = P_ZZ2.ZZ2_AR                             
         AND NUM_SEQ       = P_ZZ2.ZZ2_SEQAR                          
                                                                      
        IF SQLCA.SQLCODE = 0 THEN                                     
           INSERT INTO SUP_MOV_ORIG_DEST                              
            VALUES(P_COD_EMPRESA,                                     
                   P_NUM_TRANSAC_ORIG,                                
                   P_NUM_TRANSAC,                                     
                   "3")                                               
                                                                      
           IF STATUS <> 0 THEN 
              LET p_cod_erro = STATUS
              LET p_msg = 'INSERINDO NA TABELA SUP_MOV_ORIG_DEST'
              RETURN FALSE
           END IF
        END IF                                                        
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION POL1177_ATUALIZA_ZZ2()
#-----------------------------#

  # COLOCA O COMANDO NO SQL_STMT
  # PREPARE VAR_QUERY FROM SQL_STMT
  # EXECUTE VAR_QUERY

   LET P_ZZ2_OBS = P_ZZ2_OBS CLIPPED, ' ', TODAY, ' ', TIME

   LET SQL_STMT =
   "UPDATE ", p_instancia CLIPPED,"ZZ2010 ",
   "   SET ZZ2_FLAG = '",P_ZZ2_FLAG,"' ", 
   "      , ZZ2_OBS = '",P_ZZ2_OBS,"' ",
   " WHERE R_E_C_N_O_ = '",P_ZZ2.R_E_C_N_O_,"' "
   
   PREPARE VAR_UPD FROM SQL_STMT
   EXECUTE VAR_UPD
     
    IF STATUS <> 0 THEN 
       LET p_cod_erro = STATUS
       LET p_msg = 'ATUALIZANDO A TABELA ZZ2010'
       RETURN FALSE
    END IF
   
   RETURN TRUE
   
END FUNCTION


#-------------------------------- FIM DO PROGRAMA BI-----------------------------#
{ALTERA합ES
29/08/2012 - CONSIDERAR O LOTE NO LOCAL DO AR, CASO N홒 ESTEJA NO LOCAL DE INSPE플O OU ESTOQUE
04/09/2012 - CONSIDERAR NA PESQUISA DO LOTE OS LOCAIS DEVOLUCAO E  RETRABALHO
27/03/2012 - ROTINA PARA QUE O PROGRAMA POSSA SER CADASTRADO NO AGENDADOR DA TOTVS
           - INSER플O DE ERRO CRITICO NA TABELA ERRO_CRITICO_912
           