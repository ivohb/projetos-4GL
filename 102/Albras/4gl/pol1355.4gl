#-------------------------------------------------------------------#
# OBJETIVO: GERAR ARQUIVO TEXTO COM INDRMÇÕES DA ORD PRODUÇÃO       #
# DATA....: 08/08/2019                                              #
#-------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario
          
END GLOBALS

DEFINE p_comando            CHAR(80),  
       p_versao             CHAR(18),     
       p_nom_arquivo        CHAR(100),    
       p_caminho            CHAR(080),    
       m_msg                CHAR(150),
       p_status             SMALLINT    
                                       
DEFINE m_cod_arranjo        CHAR(10),
       m_num_ordem          CHAR(10),
       m_num_seq            CHAR(03),
       m_dat_ini            CHAR(10),
       m_dat_fim            CHAR(10),
       m_operacao           CHAR(05),
       m_linha              CHAR(60)

MAIN

   IF NUM_ARGS() > 0  THEN
      CALL LOG_connectDatabase("DEFAULT")
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      CALL pol1355_processar() 
   ELSE
      CALL log0180_conecta_usuario()
      CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
      
      LET m_msg = NULL
      
      IF p_status = 0  THEN
         CALL pol1355_processar()
         IF m_msg IS NOT NULL THEN
            CALL log0030_mensagem(m_msg,'INFO')
         END IF
      END IF
     
   END IF
   
END MAIN       

#---------------------------#          
FUNCTION pol1355_processar()#
#---------------------------#
   
   DEFINE l_dat_ini    CHAR(08),
          l_dat_fim    CHAR(08)
          
   LET m_msg = NULL
   
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = "TXT"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema TXT não cadastrado na LOG1100.'
   ELSE
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS, ' lendo tabela path_logix_v2 '
      ELSE
         IF p_caminho IS NULL THEN
            LET m_msg = 'Caminho do sistema TXT está nulo na LOG1100.'
         END IF
      END IF
   END IF
   
   IF m_msg IS NOT NULL THEN
      RETURN
   END IF
   
   LET p_nom_arquivo = p_caminho CLIPPED,'\insert_fila_ppi.txt'
   
   START REPORT pol1355_relat TO p_nom_arquivo
       
   DECLARE cq_le_info CURSOR FOR
    SELECT ord_oper.cod_arranjo,                                     
           ordens.num_ordem,                                               
           ord_oper.num_seq_operac,                                        
           man_oper_compl.dat_ini_planejada,                               
           man_oper_compl.dat_trmn_planejada,                              
           man_oper_compl.operacao                                         
      FROM ordens, ord_oper,  man_oper_compl                               
     WHERE ordens.cod_empresa = p_cod_empresa                                       
       AND ordens.ies_situa = '4'                                          
       AND ord_oper.cod_empresa = ordens.cod_empresa                       
       AND ord_oper.num_ordem = ordens.num_ordem                           
        AND man_oper_compl.empresa =  ord_oper.cod_empresa                 
        AND man_oper_compl.ordem_producao =  ord_oper.num_ordem
        AND man_oper_compl.operacao =  ord_oper.cod_operac                 
        AND man_oper_compl.sequencia_operacao =  ord_oper.num_seq_operac   
        AND man_oper_compl.dat_ini_planejada >= '2019-07-01 00:00:00'      
      ORDER BY man_oper_compl.dat_ini_planejada
   
   FOREACH cq_le_info INTO    
      m_cod_arranjo,
      m_num_ordem,  
      m_num_seq,    
      m_dat_ini,    
      m_dat_fim,    
      m_operacao

      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS, ' lendo dados da operacao:cq_le_info'
         EXIT FOREACH
      END IF
      
      LET l_dat_ini = m_dat_ini[1,4],m_dat_ini[6,7],m_dat_ini[9,10]
      LET l_dat_fim = m_dat_fim[1,4],m_dat_fim[6,7],m_dat_fim[9,10]
      LET m_linha = m_cod_arranjo CLIPPED,'|',m_num_ordem CLIPPED,'|',
          m_operacao CLIPPED,'.',m_num_seq CLIPPED,'|',
          l_dat_ini CLIPPED,'|',l_dat_fim CLIPPED,'|',m_num_seq CLIPPED,'|@|'
                
      OUTPUT TO REPORT pol1355_relat() 
      
   END FOREACH
   
   FINISH REPORT pol1355_relat

END FUNCTION

#--------------------------------#
 REPORT pol1355_relat()#
#--------------------------------#
      
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
       
   FORMAT

      ON EVERY ROW
         
         PRINT COLUMN 001, m_linha
         
END REPORT    
