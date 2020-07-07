#---------------------------------------------------------------#
#--Objetivo: Efetuar transferência de estoque do item original  #
# p/ o item sucata ou refugo, nos casos de devolução de cliente #
#--------------------------parâmetros---------------------------#
#                           nenhum                              #
#--------------------------retorno lógico-----------------------#
#             TRUE, processo completado;                        #
#            FALSE, pocesso interrompido por um erro critico    #
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
          p_statusRegistro     CHAR(01), 
          p_tipoRegistro       CHAR(01),
          p_msg                CHAR(150),
          p_num_seq_orig       INTEGER,   
          p_criticou           SMALLINT,
          p_qtd_dev            DECIMAL(10,3),
          p_qtd_estoque        DECIMAL(10,3),
          p_ies_ctr_lote       CHAR(01),
          p_ies_tip_movto      CHAR(01),
          p_ies_situa          CHAR(01),
          p_tip_operacao       CHAR(01),
          p_num_trans_atual    INTEGER,
          p_transac_apont      INTEGER,
          p_cod_tip_apon       CHAR(01),
          p_ies_implant        CHAR(01),
          p_dat_movto          DATE,
          p_dat_proces         DATE,
          p_hor_operac         CHAR(08),
          p_cod_operacao       CHAR(05),
          p_qtd_movto          DECIMAL(10,3),
          p_dat_fim            DATETIME YEAR TO SECOND,
          p_datageracao        DATETIME YEAR TO SECOND

   DEFINE p_dat_fecha_ult_man   LIKE par_estoque.dat_fecha_ult_man,    
          p_dat_fecha_ult_sup   LIKE par_estoque.dat_fecha_ult_sup     

   DEFINE p_man                RECORD LIKE man_apont_885.*,
          p_parametros_885     RECORD LIKE parametros_885.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*

   
END GLOBALS

DEFINE p_cod_local_estoq LIKE item.cod_local_estoq    


#-----------------------------------#
FUNCTION pol1269d_transf_devolucao()#
#-----------------------------------#

   LET p_msg = NULL
   LET p_ies_implant = 'N'
   
   DECLARE cq_td CURSOR WITH HOLD FOR
    SELECT numsequencia,
					 codempresa,
					 numordem,
					 coditem,
					 num_lote,
					 qtdprod,
					 tipmovto,
					 fim,
					 pesoteorico,
					 datageracao
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')
       AND iesdevolucao = 'S'

   FOREACH cq_td INTO 
           p_man.num_seq_apont,
           p_man.empresa,
           p_man.ordem_producao,
           p_man.item,
           p_man.lote,
           p_man.qtd_movto,
           p_man.tip_movto,
           p_dat_fim,
           p_man.peso_teorico,
           p_datageracao
           
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_TD'
         RETURN FALSE
      END IF                                           
            
      LET p_dat_movto  = DATE(p_dat_fim)
      LET p_dat_proces = DATE(p_datageracao)
      LET p_hor_operac = EXTEND(p_datageracao, HOUR TO SECOND)
      LET p_statusRegistro = '2'
      LET p_tipoRegistro = 'I'      
      LET p_man.largura = 0
      LET p_man.comprimento = 0
      LET p_man.altura = 0 
      LET p_man.diametro = 0
      LET p_man.nom_usuario = p_user
      LET p_man.turno = NULL
      LET p_man.nom_prog = 'POL1269'

      IF NOT pol1269d_consiste() THEN
         RETURN FALSE
      END IF
      
      IF p_criticou THEN
         IF NOT pol1269_grava_apont_trim() THEN
           RETURN FALSE
         END IF
      ELSE
         CALL log085_transacao("BEGIN")
         IF NOT pol1269d_proces_transf() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF         
         CALL log085_transacao("COMMIT")
      END IF

   END FOREACH

END FUNCTION      

#--------------------------------#
FUNCTION pol1269d_proces_transf()#
#--------------------------------#
        
     #faz a saída do item origem                                         
   LET p_ies_situa = 'L'                                                       
   LET p_ies_tip_movto = 'N'                                                   
   LET p_cod_tip_apon = 'B'                                                    
   LET p_tip_operacao = 'S'                                                    
   LET p_qtd_movto = p_man.qtd_movto                                           
                                                                               
   IF p_man.tip_movto = 'S' THEN                                               
      LET p_cod_operacao = p_parametros_885.oper_sucateamento                  
      IF NOT pol1269_movto_estoque() THEN                                     
         RETURN FALSE                                                          
      END IF                                                                   
   ELSE                                                                           
      LET p_cod_operacao = p_parametros_885.oper_sai_tp_refugo                 
      IF NOT pol1269_movto_estoque() THEN                                     
         RETURN FALSE                                                          
      END IF                    

      LET p_est_trans_relac.num_transac_orig = p_num_trans_atual
      LET p_est_trans_relac.cod_item_orig = p_man.item
                                                     
        #faz a entrada no item de retrabalho                                   
      LET p_cod_operacao = p_parametros_885.oper_ent_tp_refugo                 
      LET p_man.item = p_parametros_885.cod_item_retrab                        
      LET p_man.lote = p_parametros_885.num_lote_retrab                        
      LET p_cod_tip_apon = 'A'                                                 
      LET p_tip_operacao = 'E'                                                 
      LET p_qtd_movto = p_man.peso_teorico                                     
                                                                         
      IF NOT pol1269_movto_estoque() THEN                                     
         RETURN FALSE                                                          
      END IF                                                                   

      LET p_est_trans_relac.num_transac_orig = p_num_trans_atual
      LET p_est_trans_relac.cod_item_orig = p_parametros_885.num_lote_retrab

      IF NOT pol1269_insere_relac() THEN                                     
         RETURN FALSE                                                          
      END IF                                                                   

   END IF                                                                      

   LET p_statusRegistro = '1'
   LET p_tipoRegistro = '1'      
      
   IF NOT pol1269_grava_apont_trim() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      
#---------------------------#
FUNCTION pol1269d_consiste()#
#---------------------------#

   IF NOT pol1269_ck_sequencia() THEN                                                                      
      RETURN FALSE                                                                                      
   END IF                                                                                               

   IF p_criticou THEN
      RETURN TRUE
   END IF

   SELECT cod_item
     INTO p_man.item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_man.ordem_producao

   IF STATUS = 100 THEN
      LET p_msg = 'A OF ENVIADA NAO EXISTE NO LOGIX'                                                  
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS'
         RETURN FALSE
      END IF                                           
   END IF
                                                                                                    
   SELECT ies_ctr_lote,
          cod_local_estoq                                                                                  
     INTO p_ies_ctr_lote ,
          p_cod_local_estoq                                                                               
     FROM item                                                                                          
    WHERE cod_empresa = p_cod_empresa                                                                   
      AND cod_item = p_man.item                                                                         
                                                                                                        
   IF STATUS = 100 THEN                                                                                 
      LET p_msg = 'O ITEM ENVIADO NAO EXISTE NO LOGIX'                                                  
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
   ELSE                                                                                                 
      IF STATUS <> 0 THEN                                                                               
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM DEVOLVIDO NA TABELA ITEM'                           
         RETURN FALSE                                                                                   
      END IF                                                                                            
   END IF                                                                                               
                                                                                                        
   IF p_ies_ctr_lote = 'S' AND p_man.lote IS NULL THEN                                                  
      LET p_msg = 'O LOTE NAO FOI ENVIADO NA INTEGRACAO'                                                
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
   END IF                                                                                               
                                                                                                        
   IF p_man.qtd_movto IS NULL OR p_man.qtd_movto = 0 THEN                                               
      LET p_msg = 'A QUANTIDADE ENVIADA NAO EH VALIDA'                                                  
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
   END IF                                                                                               
                                                                                                     
   IF p_man.tip_movto MATCHES "[RS]" THEN                                                               
   ELSE                                                                                                 
      LET p_msg = 'O TIPO DE MOVIMENTO ENVIADO NAO E VALIDO'                                            
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
   END IF                                                                                               
                                                                                                     
   IF p_dat_fim IS NULL THEN                                                                            
      LET p_msg = 'DATA FINAL DA PRODUCAO NULA'                                                         
      IF NOT pol1269_insere_erro() THEN                                                                 
         RETURN FALSE                                                                                   
      END IF                                                                                            
   ELSE                                                                                                 
      LET p_man.dat_fim_producao = EXTEND(p_dat_fim, YEAR TO DAY)                                       
                                                                                                     
      IF p_dat_fecha_ult_man IS NOT NULL THEN                                                           
         IF p_man.dat_fim_producao <= p_dat_fecha_ult_man THEN                                          
            LET p_msg = 'MOVIMENTO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL'                 
            IF NOT pol1269_insere_erro() THEN                                                           
               RETURN FALSE                                                                             
            END IF                                                                                      
         END IF                                                                                         
      END IF                                                                                            
                                                                                                     
      IF p_dat_fecha_ult_sup IS NOT NULL THEN                                                           
         IF p_man.dat_fim_producao < p_dat_fecha_ult_sup THEN                                           
            LET p_msg = 'MOVIMENTO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL'                    
            IF NOT pol1269_insere_erro() THEN                                                           
               RETURN FALSE                                                                             
            END IF                                                                                      
         END IF                                                                                         
      END IF                                                                                            
                                                                                                        
   END IF                                                                                               

   IF p_man.peso_teorico IS NULL OR p_man.peso_teorico = 0 THEN
      LET p_msg = 'ENVIO DE DEVOLUCAO DE PECAS SEM PESO TEORICO'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT p_criticou THEN
      IF p_man.qtd_movto < 0 THEN
         IF NOT pol1269d_ck_estorno() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1269_le_saldo(p_man.item, p_cod_local_estoq,  p_man.lote) THEN
            RETURN FALSE
         END IF
         IF p_man.qtd_movto > p_qtd_estoque THEN
            LET p_msg = 'A QUANTIDADE ENVIADA PELO TRIM EH MAIOR QUE O SALDO DO LOGIX'
            IF NOT pol1269_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF      
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1269d_ck_estorno()#
#-----------------------------#
     
   INITIALIZE p_num_seq_orig TO NULL
   
   LET p_qtd_dev = p_man.qtd_movto * (-1)
   
   DECLARE cq_ck_est CURSOR FOR
    SELECT numsequencia
      FROM apont_trim_885
     WHERE codempresa = p_cod_empresa
       AND coditem    = p_man.item
       AND numordem   = p_man.ordem_producao
       AND fim        = p_dat_fim
       AND qtdprod    = p_qtd_dev
       AND tipmovto   = p_man.tip_movto
       AND statusregistro = '1'
       AND numsequencia IN 
           (SELECT DISTINCT num_seq_apont
              FROM apont_trans_885
             WHERE cod_empresa   = p_cod_empresa
               AND cod_tip_apon  = 'A'           #A=Apontamento B=Baixa do material
               AND cod_tip_movto = 'N')          #N=Movimento normal R=Reversão

   FOREACH cq_ck_est INTO p_num_seq_orig
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTORNO - CURSOR CQ_CK_EST'
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
            
   IF p_num_seq_orig IS NULL THEN
      LET p_msg = 'ESTORNO DE DEVOLUCAO NAO ENVIADO OU JA ESTORNADO'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

   