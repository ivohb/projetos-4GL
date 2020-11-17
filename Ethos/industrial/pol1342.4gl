#-------------------------------------------------------------------#
# PROGRAMA: pol1342                                                 #
# CLIENTE.: ETHOS IND                                               #
# OBJETIVO: GERAÇÃO DE CSV COM DADOS DA CARTEIRA DE PEDIDOS         #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           comando         CHAR(80),
           p_ies_impressao CHAR(01),
           g_ies_ambiente  CHAR(01),
           p_caminho       CHAR(080),
           p_nom_arquivo   CHAR(100),
           g_tipo_sgbd     CHAR(003)
END GLOBALS

DEFINE m_processo          CHAR(20),
       m_msg               VARCHAR(120),
       m_caminho           VARCHAR(80),
       m_erro              VARCHAR(10)

DEFINE mr_fat              RECORD
   cliente                 VARCHAR(40),
   prz_entrega             DATE,
   pedido                  DECIMAL(6,0),
   num_seq                 DECIMAL(4,0),
   cod_Item                VARCHAR(15),
   descricao               VARCHAR(50),
   qtd_faturar             DECIMAL(10,3),
   posicao                 VARCHAR(10),
   observacao              VARCHAR(10),
   responsavel             VARCHAR(15),
   produto                 VARCHAR(15),
   num_pedido_cli          VARCHAR(30)
END RECORD

MAIN

    CALL log0180_conecta_usuario()

    IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_processo = 'Via bat'
      CALL pol1342_processar() RETURNING p_status
   ELSE
      CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
     IF p_status = 0  THEN
        LET m_processo = 'Manual'
        CALL pol1342_processar()
     END IF
   END IF
   
END MAIN       

#------------------------------#
FUNCTION pol1342_job(l_rotina) #
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
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '06'
   END IF

   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF      
   
   LET m_processo = 'Agendador'
      
   CALL pol1342_processar() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#------------------------------#
FUNCTION pol1342_ins_processo()#
#------------------------------#
   
   DEFINE l_dat_proces  CHAR(19)
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)

   INSERT INTO proces_csv_547
    VALUES(0,l_dat_proces,m_processo,p_cod_empresa,p_user, m_msg)

END FUNCTION   

#-----------------------------#
FUNCTION pol1342_cria_proces()#
#-----------------------------#

   CREATE TABLE proces_csv_547 (
      id         serial,
      data       CHAR(19),
      processo   CHAR(20),
      empresa    CHAR(02),
      usuario    CHAR(08),
      mesagem    VARCHAR(120)
   )
   
   CREATE UNIQUE INDEX ix_proces_csv_547
    ON proces_csv_547(id)
    
END FUNCTION
   
#---------------------------#
 FUNCTION pol1342_processar()
#---------------------------#

   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   DEFER INTERRUPT

   IF NOT log0150_verifica_se_tabela_existe("proces_csv_547") THEN 
      IF NOT pol1342_cria_proces() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET m_msg = 'INICIO do processamento'
   CALL pol1342_ins_processo()
   CALL pol1342_exec_proces() RETURNING p_status
   LET m_msg = 'FIM do processamento'
   CALL pol1342_ins_processo()   
   
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1342_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = 'VDP'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema VDPEDI não cadastrado na LOG1100/LOG00098'
      CALL pol1342_ins_processo()   
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela path_logix_v2'
         CALL pol1342_ins_processo()   
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1342_exec_proces()#
#-----------------------------#

   DEFINE l_prz_entrega    DATE,
          l_mes            INTEGER,
          l_dia            INTEGER,
          l_dia_proces     INTEGER,
          l_dia_acres      INTEGER,
          l_nom_arq        VARCHAR(30),
          l_local_arq      VARCHAR(120)
   
   IF NOT pol1342_le_caminho() THEN
      RETURN FALSE
   END IF
   
   LET l_nom_arq = 'vi-faturar-cli.csv'
   LET l_local_arq = m_caminho CLIPPED, l_nom_arq
               
   START REPORT pol1342_relat TO l_local_arq     

   LET l_prz_entrega = TODAY + 60
   LET l_mes = MONTH(l_prz_entrega)
   
   IF l_mes = 2 THEN 
      LET l_dia = 28
   ELSE
      IF l_mes = 4 OR l_mes = 6 OR l_mes = 9 OR l_mes = 11 THEN
         LET l_dia = 30
      ELSE
         LET l_dia = 31
      END IF
   END IF
   
   LET l_dia_proces = DAY(l_prz_entrega)
   
   IF l_dia_proces < l_dia THEN
      LET l_dia_acres = l_dia - l_dia_proces
      LET l_prz_entrega = l_prz_entrega + l_dia_acres
   END IF
   
   DECLARE cq_exec CURSOR FOR
    SELECT * FROM vi_afaturar_cli_excel 
     WHERE prazo_entrega <= l_prz_entrega
   FOREACH cq_exec INTO mr_fat.*
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela vi_afaturar_cli'
         CALL pol1342_ins_processo()   
         RETURN
      END IF
      
      OUTPUT TO REPORT pol1342_relat()          
   
   END FOREACH
   
   FINISH REPORT pol1342_relat  
   
END FUNCTION


#---------------------#
 REPORT pol1342_relat()
#---------------------#
   
   DEFINE l_total CHAR(100),
          l_data  CHAR(100)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
      
      FIRST PAGE HEADER
      
      PRINT COLUMN 001, 
             'Cliente;',
             'Prz_entrega;',
             'Pedido;',
             'Sequencia;',          
             'Item;',         
             'Descricao;',        
             'Qtd faturar;',     
             'Posicao;',          
             'Observacao;',       
             'Responsavel;',
             'Produto;',          
             'Texto;'   
                            
      ON EVERY ROW

      PRINT COLUMN 001, 
            mr_fat.cliente,';',       
            mr_fat.prz_entrega,';',
            mr_fat.pedido,';',   
            mr_fat.num_seq,';',   
            mr_fat.cod_Item,';',  
            mr_fat.descricao,';', 
            mr_fat.qtd_faturar,';',
            mr_fat.posicao,';',
            mr_fat.observacao,';',  
            mr_fat.responsavel,';',
            mr_fat.produto,';',
            mr_fat.num_pedido_cli 
            
END REPORT
   
#LOG1700             
#-------------------------------#
 FUNCTION pol1342_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1342.4gl $|$Revision: 00 $|$Date: 05/11/2020 09:51 $|$Modtime: 05/11/2020 09:51 $" 

 END FUNCTION
