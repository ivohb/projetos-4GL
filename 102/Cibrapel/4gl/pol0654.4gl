#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                     #
# PROGRAMA: pol0654                                                     #
# OBJETIVO: EXPORTAÇÃO DE ORDENS P/ O TRIM PAPEL                        #
# DATA....: 23/10/2007                                                  #
# FUNÇÕES: FUNC002                                                      #
#-----------------------------------------------------------------------#

{
lISTA DE PREÇO 10002/10003

UPDATE item SET ies_tip_item='B' WHERE  cod_empresa = '12' AND cod_item = 'C100 '
UPDATE man_item_compl SET dat_ultima_alteracao='16/07/2019' WHERE  empresa = '12' AND item = 'C100           '

  UPDATE item_man SET cod_local_prod='0',
   cod_roteiro=NULL,num_altern_roteiro=NULL,
   dat_atualiz_cad='16/07/2019' 
  WHERE  cod_empresa = '12' AND cod_item = 'CD100          '

http://10.10.0.4/homologacao/

}

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          p_sobe               DECIMAL(1,0),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          g_msg                CHAR(150)
END GLOBALS
          
   DEFINE p_NumSequencia       LIKE ordens_885.NumSequencia,
          p_QtdPedida          LIKE ordens_885.QtdPedida,
          p_num_docum          LIKE ordens.num_docum,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
          p_cod_cliente_matriz LIKE clientes.cod_cliente_matriz,
          p_num_seq_loc        INTEGER,
          p_tipo_processo      INTEGER,
          p_num_seq            INTEGER

   DEFINE p_ordens             RECORD LIKE ordens_bob_885.*,
          p_item_chapa_885     RECORD LIKE item_chapa_885.*,
          p_loc_entrega_885    RECORD LIKE loc_entrega_885.*,
          p_ped_end_ent        RECORD LIKE ped_end_ent.*
   
   DEFINE p_msg                CHAR(100),
          p_erro               CHAR(10)

DEFINE m_num_ver_pc            INTEGER,
       m_num_pc                INTEGER,
       m_cod_emp_op            CHAR(02)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0654-10.02.03  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0654.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0  THEN
      CALL pol0654_controle()
      CALL log0030_mensagem(p_msg,'info')
   END IF
END MAIN

#------------------------------#
FUNCTION pol0654_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_user IS NULL THEN
      LET p_user = 'pol0654'
   END IF      
      
   LET p_houve_erro = FALSE
   
   CALL pol0654_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
 FUNCTION pol0654_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0654") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0654 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   WHENEVER ERROR CONTINUE
   
   IF pol0654_exportar() THEN
      LET p_msg = 'Exportacao efetuada com sucesso'
   END IF
   
   CALL pol0654_grava_msg()
   
   CLOSE WINDOW w_pol0654
   
END FUNCTION

#---------------------------#
FUNCTION pol0654_grava_msg()#
#---------------------------#
   
   DEFINE p_dat_hor DATETIME YEAR TO SECOND
   
   LET p_dat_hor = CURRENT
   
   INSERT INTO pol0654_msg_885
    VALUES(p_dat_hor, p_msg)

END FUNCTION       

#--------------------------#
FUNCTION pol0654_exportar()#
#--------------------------#

   SELECT cod_emp_ordem 
     INTO m_cod_emp_op
     FROM de_para_empresa_885
    WHERE cod_emp_pedido = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo tab de_para_empresa_885'
      RETURN FALSE
   END IF
   
   IF m_cod_emp_op <> p_cod_empresa THEN
      #IF NOT pol0654_le_parametros() THEN
      #   RETURN FALSE
      #END IF      
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_seq
     FROM ordens_bob_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo  ordens_bob_885'
      RETURN FALSE
   END IF
     
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF

   IF NOT pol0654_exporta_pedidos() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#-------------------------------#
FUNCTION pol0654_le_parametros()#
#-------------------------------#

   DEFINE l_min_par     CHAR(06)
   
   SELECT parametro_numerico
     INTO l_min_par 
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'PEDIDO_COMPRAS_INDUS'

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo tab min_par_modulo'
      RETURN FALSE
   END IF

   IF l_min_par IS NULL THEN
      LET p_msg = 'Parâmetro PEDIDO_COMPRAS_INDUS está nulo '
      RETURN FALSE
   END IF
   
   LET m_num_pc = l_min_par
   
   SELECT num_versao
     INTO m_num_ver_pc
     FROM pedido_sup     
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pc
      AND ies_versao_atual = 'S'

   IF STATUS = 100 THEN
      LET p_msg = 'Pedido de compra ',l_min_par, ' não existe.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo tab pedido_sup'
         RETURN FALSE
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION
   

#-----------------------------#
FUNCTION pol0654_le_clientes()
#-----------------------------#

   SELECT nom_cliente,
          nom_reduzido
     INTO p_ordens.nomcliente,
          p_ordens.nomreduzido
     FROM clientes
    WHERE cod_cliente = p_ordens.CodCliente
	       
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo clientes'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0654_insere_ordens_885()
#-----------------------------------#

   
   LET p_num_seq = p_num_seq + 1   
   LET p_ordens.NumSequencia = p_num_seq
   LET p_ordens.CodEmpresa   = m_cod_emp_op
  
   SELECT largura,
          diametro,
          tubete,
          num_pedido_cli
     INTO p_ordens.largura,
          p_ordens.diametro,
          p_ordens.tubete,
          p_ordens.numpedcli
     FROM item_bobina_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem
     
   IF STATUS = 100 THEN
      INITIALIZE p_ordens.largura,
                 p_ordens.diametro,
                 p_ordens.tubete TO NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo item_bobina_885'
         RETURN FALSE
      END IF
   END IF
      
   SELECT parametro_val
     INTO p_ordens.tolentmenos
     FROM ped_info_compl
    WHERE empresa = p_cod_empresa
      AND pedido  = p_ordens.numpedido
      AND campo   = 'pct_tolerancia_minimo'

    IF STATUS = 100 THEN
      INITIALIZE p_ordens.tolentmenos TO NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_info_compl'
         RETURN FALSE
      END IF
   END IF

   SELECT parametro_val
     INTO p_ordens.tolentmais
     FROM ped_info_compl
    WHERE empresa = p_cod_empresa
      AND pedido  = p_ordens.numpedido
      AND campo   = 'pct_tolerancia_maximo'

    IF STATUS = 100 THEN
      INITIALIZE p_ordens.tolentmais TO NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_info_compl'
         RETURN FALSE
      END IF
   END IF
      
   SELECT den_texto_1
     INTO p_ordens.ObsPedItem
     FROM ped_item_texto_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem
  
   IF STATUS = 100 THEN
      INITIALIZE p_ordens.ObsPedItem TO NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_item_texto_885'
         RETURN FALSE
      END IF
   END IF
      
   LET p_ordens.StatusRegistro = '0'
      
   INSERT INTO ordens_bob_885
    VALUES(p_ordens.*)

   IF STATUS <> 0 THEN
       LET p_erro = STATUS
       LET p_msg = 'Erro ',p_erro CLIPPED, ' inserindo ordens_bob_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0654_libera_ordem()
#-----------------------------#

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa = m_cod_emp_op
      AND num_ordem   = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando necessidades'
      RETURN FALSE
   END IF

   IF p_cod_empresa = m_cod_emp_op THEN

      UPDATE ordens
         SET ies_situa = '4'
       WHERE cod_empresa = m_cod_emp_op
         AND num_ordem   = p_ordens.NumOrdem

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando ordens.1'
         RETURN FALSE
      END IF

   ELSE

      UPDATE ordens
         SET ies_situa = '4',
             cod_local_estoq = 'PROD_CIB'
       WHERE cod_empresa = m_cod_emp_op
         AND num_ordem   = p_ordens.NumOrdem

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando ordens.2'
         RETURN FALSE
      END IF
   
      UPDATE ord_compon
         SET cod_local_baixa = 'BENEF_CIB'
       WHERE cod_empresa = m_cod_emp_op
         AND num_ordem   = p_ordens.NumOrdem

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando ord_compon.1'
         RETURN FALSE
      END IF
    
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0654_exporta_operacao()#
#----------------------------------#
   
   DEFINE p_oper_bob_885 RECORD
      codempresa    char(02),
      numordem      INTEGER,
      codoperac     char(10),
      numseqoperac  INTEGER,
      qtdhoras      decimal(12,5)
   END RECORD
   
   DECLARE cq_oper CURSOR FOR
    SELECT cod_empresa,
           num_ordem,
           cod_operac,
           num_seq_operac,
           qtd_horas
      FROM ord_oper
     WHERE cod_empresa = m_cod_emp_op
       AND num_ordem = p_ordens.numordem
       AND ies_apontamento = 'S'
   
   FOREACH cq_oper INTO 
           p_oper_bob_885.codempresa,  
           p_oper_bob_885.numordem,  
           p_oper_bob_885.codoperac,   
           p_oper_bob_885.numseqoperac,
           p_oper_bob_885.qtdhoras    
   
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cursor cq_oper'
	       RETURN FALSE
	    END IF
	    
	    INSERT INTO oper_bob_885
	     VALUES(p_oper_bob_885.*)

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' inserindo tabela oper_bob_885'
	       RETURN FALSE
	    END IF
	 
	 END FOREACH
	 
	 RETURN TRUE

END FUNCTION


#-------------------------------# 
FUNCTION pol0654_gera_ord_comp()#
#-------------------------------#
   
   DEFINE l_param          RECORD
          cod_empresa       CHAR(02),
          cod_user          CHAR(08),
          cod_item          CHAR(15),
          dat_entrega       DATE,                   
          dat_abertura      DATE,                   
          qtd_planej        DECIMAL(10,3),          
          dat_emissao       DATE,                    
          gru_ctr_desp      LIKE item_sup.gru_ctr_desp,
          cod_tip_despesa   LIKE item_sup.cod_tip_despesa            
   END RECORD

   LET l_param.cod_empresa  = p_cod_empresa
   LET l_param.cod_user     = p_user
   LET l_param.cod_item     = p_ordens.CodItem
   LET l_param.dat_entrega  = p_ordens.DatEntrega
   LET l_param.dat_abertura = NULL
   LET l_param.qtd_planej   = p_ordens.QtdPedida
   LET l_param.dat_emissao  = TODAY
   LET l_param.gru_ctr_desp = NULL
   LET l_param.cod_tip_despesa = NULL
   
   LET p_msg = func017_gera_oc(l_param)
   
   IF NOT func002_isNumero(p_msg) THEN
      RETURN FALSE
   END IF

   {LET l_param.cod_empresa  = m_cod_emp_op
   LET l_param.gru_ctr_desp = 2
   LET l_param.cod_tip_despesa = 7777

   LET p_msg = func017_gera_oc(l_param)

   IF NOT func002_isNumero(p_msg) THEN
      RETURN FALSE
   END IF}
   
   DELETE FROM ord_benef_885
    WHERE cod_empresa = m_cod_emp_op 
      AND num_ordem = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' deletando registro da tab ord_benef_885'
     RETURN FALSE
   END IF
   
   INSERT INTO ord_benef_885 VALUES(m_cod_emp_op, p_ordens.NumOrdem)
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' inserindo registro na tab ord_benef_885'
     RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#--------------------------------# 
FUNCTION pol0654_gera_ped_indus()#
#--------------------------------#
   
   DEFINE l_count         INTEGER,
          l_num_pedido    DECIMAL(6,0)

   DEFINE lr_pedido       RECORD
          empresa         LIKE pedidos.cod_empresa,
          pedido          LIKE pedidos.num_pedido,
          item            LIKE item.cod_item,
          quantidade      LIKE ped_itens.qtd_pecas_solic,
          entrega         LIKE ped_itens.prz_entrega          
   END RECORD

   LET p_msg = func018_le_ped_indus(p_cod_empresa, m_cod_emp_op )
   
   IF NOT func002_isNumero(p_msg) THEN
      RETURN FALSE
   END IF
   
   LET l_num_pedido = p_msg
   
   SELECT COUNT(*) 
     INTO l_count
     FROM ped_itens
    WHERE cod_empresa = m_cod_emp_op
      AND num_pedido = l_num_pedido
      AND cod_item = p_ordens.CodItem
      
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO ITEM DO PEDIDO ',l_num_pedido
      RETURN p_msg 
   END IF
   
   IF l_count > 0 THEN
      RETURN TRUE
   END IF
   
   LET lr_pedido.empresa    = m_cod_emp_op
   LET lr_pedido.pedido     = l_num_pedido
   LET lr_pedido.item       = p_ordens.CodItem
   LET lr_pedido.quantidade = p_ordens.QtdPedida
   LET lr_pedido.entrega    = p_ordens.DatEntrega
   
   LET p_msg = func018_ins_ped_itens(lr_pedido)
         
   IF p_msg = 'OK' THEN
      RETURN TRUE
   END IF      
   
   RETURN FALSE

END FUNCTION
    
#---------------------------------#
FUNCTION pol0654_exporta_pedidos()
#---------------------------------#
   
   DEFINE l_cod_nat_oper      LIKE pedidos.cod_nat_oper,
          l_ies_tip_controle  LIKE nat_operacao.ies_tip_controle
   
   INITIALIZE p_ordens TO NULL      
   
   DECLARE cq_pedidos CURSOR WITH HOLD FOR  
    SELECT a.num_pedido,
           a.cod_cliente,
           a.cod_nat_oper,
           b.tipo_processo
      FROM pedidos a,
           tipo_pedido_885 b
     WHERE a.cod_empresa    = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND b.cod_empresa    = a.cod_empresa
       AND b.num_pedido     = a.num_pedido
       AND a.num_pedido NOT IN (
           SELECT c.numpedido
             FROM ordens_bob_885 c
            WHERE c.CodEmpresa = a.cod_empresa
              AND c.NumPedido  = a.num_pedido)

   FOREACH cq_pedidos INTO
           p_ordens.NumPedido,
           p_ordens.CodCliente,
           l_cod_nat_oper,
           p_tipo_processo

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cursor cq_pedidos'
         RETURN FALSE
      END IF

      SELECT ies_tip_controle
        INTO l_ies_tip_controle
        FROM nat_operacao
       WHERE cod_nat_oper = l_cod_nat_oper
       
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo tab nat_operacao'
         RETURN FALSE
      END IF
      
      IF l_ies_tip_controle MATCHES '[23]' THEN
         CONTINUE FOREACH
      END IF

      IF p_tipo_processo = 3 THEN                                                                                             
         LET p_ordens.iesretrabalho = 'S'                                                                                     
      ELSE                                                                                                                    
         LET p_ordens.iesretrabalho = 'N'                                                                                     
      END IF                                                                                                                  
                                                                                                                          
      LET p_ordens.tipopedido = p_tipo_processo                                                                               
      LET p_ordens.cancelada  = 0
      
      IF NOT pol0654_le_clientes() THEN
         RETURN FALSE
      END IF

	    CALL log085_transacao("BEGIN")                                                                                        

      IF NOT pol0654_exp_item() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")
   
   END FOREACH
   
   FREE cq_pedidos
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0654_exp_item()
#--------------------------#
   
   DECLARE cq_itens CURSOR FOR                                                 
    SELECT num_sequencia,                                                         
           cod_item,                                                              
           qtd_pecas_solic,                                                       
           prz_entrega                                                            
      FROM ped_itens                                                              
     WHERE cod_empresa        = p_cod_empresa                                     
       AND num_pedido         = p_ordens.NumPedido                                
       AND qtd_pecas_atend    = 0                                                 
       AND qtd_pecas_cancel   = 0                                                 
       AND qtd_pecas_romaneio = 0                                                 
                                                                               
   FOREACH cq_itens INTO                                                          
           p_ordens.NumSeqItem,                                                   
           p_ordens.CodItem,                                                      
           p_ordens.QtdPedida,                                                    
           p_ordens.DatEntrega                                                    
                                                                               
      IF STATUS <> 0 THEN                                                         
         LET p_erro = STATUS                                                      
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cursor cq_itens'             
	       RETURN FALSE                                                             
	    END IF                                                                      
                                                                               
      DISPLAY p_ordens.NumPedido TO num_pedido                                     
		    #lds CALL LOG_refresh_display()	                                         
      
      LET p_num_docum = p_ordens.NumPedido USING '<<<<<<'
      LET p_num_docum = p_num_docum CLIPPED,'/', p_ordens.NumSeqItem USING '<<<'
                                                                
      IF p_tipo_processo <> 2 THEN                                                
         IF NOT pol0654_exp_ordens() THEN                                          
            RETURN FALSE                                                          
         END IF                                                                   
      ELSE                                                                        
         IF NOT pol0654_insere_ordens_885() THEN                                	
	          RETURN FALSE                                                          
	       END IF                                                                   
      END IF                                                                      
      		                                                                        
   END FOREACH                                                                    
   
   FREE cq_itens
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0654_exp_ordens()
#----------------------------#
   
   DECLARE cq_ordens CURSOR WITH HOLD FOR                                                                                 
	  SELECT num_ordem,                                                                                                       
	         cod_item,                                                                                                        
	         dat_entrega,                                                                                                     
	         qtd_planej                                                                                                       
	    FROM ordens                                                                                                           
	   WHERE cod_empresa = m_cod_emp_op                                                                                      
	     AND ies_situa   = '3'    
	     AND num_docum = p_num_docum                                                                                           
	   ORDER BY num_ordem                                                                                                     
                                                                                                                          
	 FOREACH cq_ordens INTO                                                                                                   
	         p_ordens.NumOrdem,                                                                                               
	         p_ordens.CodItem,                                                                                                
	         p_ordens.DatEntrega,                                                                                             
	         p_ordens.QtdPedida                                                                                               
                                                                                                                          
      IF STATUS <> 0 THEN                                                                                                     
         LET p_erro = STATUS                                                                                                  
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo  cursor cq_ordens'                                                       
	       RETURN FALSE                                                                                                         
	    END IF                                                                                                                  
		                                                                                                                       
	    SELECT NumSequencia                                                                                                     
	      FROM ordens_bob_885                                                                                                   
	     WHERE CodEmpresa = m_cod_emp_op                                                                                       
	       AND NumOrdem   = p_ordens.NumOrdem                                                                                   
	                                                                                                                          
	    IF STATUS = 0 THEN                                                                                                      
	       CONTINUE FOREACH                                                                                                     
	    ELSE                                                                                                                    
	       IF STATUS <> 100 THEN                                                                                                
            LET p_erro = STATUS                                                                                               
            LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ordens_bob_885'                                                       
	          RETURN FALSE                                                                                                      
	       END IF                                                                                                               
	    END IF                                                                                                                  
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	    IF NOT pol0654_insere_ordens_885() THEN                                                                               
	       RETURN FALSE                                                                                                       
	    END IF                                                                                                                
                                                                                                                          
	    IF NOT pol0654_libera_ordem() THEN                                                                                    
	       RETURN FALSE                                                                                                       
	    END IF                                                                                                                
                                                                                                                          
	    IF NOT pol0654_exporta_operacao() THEN                                                                                
	       RETURN FALSE                                                                                                       
	    END IF                                                                                                                

      IF p_cod_empresa <> m_cod_emp_op THEN
   	     IF NOT pol0654_gera_ord_comp() THEN                                                                                
	          RETURN FALSE                                                                                                       
	       END IF                                                                                                                
   	     IF NOT pol0654_gera_ped_indus() THEN                                                                                
	          RETURN FALSE                                                                                                       
	       END IF                                                                                                                
      END IF
      	                                                                                                                        	                                                                                                                          
	    INITIALIZE p_ordens TO NULL                                                                                           
                                                                                                                          
    END FOREACH                                                                                                             
    
    FREE cq_ordens
                                                                                                                 
    RETURN TRUE                                                                                                             
   
END FUNCTION


	       
   