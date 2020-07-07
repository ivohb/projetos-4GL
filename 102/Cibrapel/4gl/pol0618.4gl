#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                     #
# PROGRAMA: pol0618                                                     #
# OBJETIVO: EXPORTAÇÃO DE ORDENS P/ O TRIM                              #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 24/07/2007                                                  #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                     #
# FUNÇÕES: FUNC002                                                      #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_msg                CHAR(100),
          p_erro               CHAR(10),
          p_num_ordem          INTEGER,
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
          p_ies_sit_ped        CHAR(01)

END GLOBALS
          
   DEFINE p_NumSequencia       LIKE ordens_885.NumSequencia,
          p_QtdPedida          LIKE ordens_885.QtdPedida,
          p_num_docum          LIKE ordens.num_docum,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
          p_cod_cliente_matriz LIKE clientes.cod_cliente_matriz,
          p_cod_cliente_ent    LIKE clientes.cod_cliente,
          p_ies_tip_controle   LIKE nat_operacao.ies_tip_controle,
          p_cod_nat_oper       LIKE pedidos.cod_nat_oper,
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_cod_item_pai       LIKE ordens.cod_item_pai,
          p_cod_conjunto       LIKE ordens.cod_item_pai,

          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_desc_oper      LIKE desc_nat_oper_885.pct_desc_oper,
          p_pct_acres_valor    LIKE desc_nat_oper_912.pct_acres_valor,

          p_tipo_processo      INTEGER,
          p_num_seq_loc        INTEGER,
          p_num_seq            INTEGER,
          p_cancel_chapa       SMALLINT,
          p_op_cancela         INTEGER,
          p_op_ja_export       INTEGER,
          p_troca_op           SMALLINT,
          m_ordem_antiga       INTEGER,
          p_ve_divisao         SMALLINT

   DEFINE p_ordens             RECORD LIKE ordens_885.*,
          p_item_chapa_885     RECORD LIKE item_chapa_885.*,
          p_loc_entrega_885    RECORD LIKE loc_entrega_885.*,
          p_ped_end_ent        RECORD LIKE ped_end_ent.*,
          p_dat_hor            DATETIME YEAR TO SECOND
   
   DEFINE pr_men               ARRAY[1] OF RECORD    
          mensagem             CHAR(60)
   END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0618-10.02.14  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0618.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   CALL pol0618_controle()

END MAIN

#------------------------------#
FUNCTION pol0618_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa = '01' #l_param1_empresa
   LET p_user = 'pol0618'  #l_param2_user
   
   LET p_houve_erro = FALSE
   
   CALL pol0618_controle()
   
   IF p_houve_erro THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#------------------------------#
FUNCTION pol0618_exib_mensagem()
#------------------------------#

   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

END FUNCTION

#--------------------------#
 FUNCTION pol0618_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0618") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0618 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_cod_empresa = '01' #Lu pediu para fixar a empresa
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   WHENEVER ERROR CONTINUE
   
   LET p_dat_hor = CURRENT

   IF NOT pol0618_exporta_ordens() THEN
      RETURN
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0618_exporta_pedidos() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
      LET p_msg = 'Processamewnto concluido'
      LET p_num_docum = ''
   END IF
   
   CALL pol0618_ins_erro() 
   
   CLOSE WINDOW w_pol0618
   
END FUNCTION

#--------------------------#
FUNCTION pol0618_ins_erro()#
#--------------------------#
      
   INSERT INTO ordem_erro_885
    VALUES(p_num_docum, p_msg, p_dat_hor)

END FUNCTION     
    
#--------------------------------#
FUNCTION pol0618_exporta_ordens()
#--------------------------------#
   
   DEFINE l_cod_unid_med LIKE item.cod_unid_med,
          l_ies_tip_item LIKE item.ies_tip_item,
          l_cod_item     LIKE item.cod_item

  SELECT parametro_numerico 
    INTO m_ordem_antiga
    FROM min_par_modulo 
   WHERE empresa = p_cod_empresa
     AND parametro = 'MAIOR_OP_ANTIGA'

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo min_par_modulo.MAIOR_OP_ANTIGA'
      CALL pol0618_ins_erro()
      RETURN FALSE
   END IF
                 
   IF m_ordem_antiga IS NULL THEN
      LET m_ordem_antiga = 0
   END IF
               
   INITIALIZE p_ordens TO NULL
   LET p_num_docum = ''
   
   DELETE FROM ordem_erro_885
   
   SELECT MAX(numsequencia)
     INTO p_num_seq
     FROM ordens_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ordens_885.numsequencia'
      CALL pol0618_ins_erro()
      RETURN FALSE
   END IF
     
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF

   DECLARE cq_docum CURSOR WITH HOLD FOR 
    SELECT DISTINCT num_docum
      FROM ordens
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa   = '3'
     ORDER BY num_docum

   FOREACH cq_docum INTO p_num_docum

  	 IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo cursor cq_docum'
        LET p_num_docum = ''
	      LET p_houve_erro = TRUE
	      EXIT FOREACH
	   END IF
	   
	   LET p_houve_erro = FALSE
	   LET p_op_ja_export = 0
	   
     CALL log085_transacao("BEGIN")
     
     LET p_cod_conjunto = NULL
     
	   DECLARE cq_ordens CURSOR FOR
	    SELECT num_ordem,
	           ies_situa,
	           cod_item,
	           dat_entrega,
	           qtd_planej,
	           cod_item_pai
	      FROM ordens
	     WHERE cod_empresa = p_cod_empresa
	       AND ies_situa   = '3'
	       AND num_docum   = p_num_docum
	     ORDER BY num_ordem

	   FOREACH cq_ordens INTO 
	           p_ordens.NumOrdem,
	           p_ordens.StatusOrdem,
	           p_ordens.CodItem,
	           p_ordens.DatEntrega,
	           p_ordens.QtdPedida,
	           p_cod_item_pai

 	      IF STATUS <> 0 THEN
           LET p_erro = STATUS
           LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo cursor cq_ordens'
           LET p_num_ordem = 0
	         LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF
        
        IF p_op_ja_export = p_ordens.NumOrdem THEN
           CONTINUE FOREACH
        END IF
                        
        LET p_cancel_chapa = FALSE

        LET pr_men[1].mensagem = p_ordens.NumOrdem
        CALL pol0618_exib_mensagem()
        LET p_num_ordem = p_ordens.NumOrdem
        
	      SELECT NumSequencia
	        FROM ordens_885
	       WHERE CodEmpresa = p_cod_empresa
	         AND NumOrdem   = p_ordens.NumOrdem
	      
	      IF STATUS = 100 THEN
	      ELSE
           IF STATUS = 0 THEN
              LET p_msg = 'Ordem ja existe no Trim ', p_num_ordem 
           ELSE
              LET p_erro = STATUS
              LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ordens_885:checando existencia'
           END IF
           LET p_houve_erro = TRUE
           EXIT FOREACH
	      END IF

        CALL pol0618_pega_pedido()

        SELECT COUNT(*)
          INTO p_count
          FROM item_chapa_885        
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_ordens.NumPedido
           AND num_sequencia = p_ordens.NumSeqItem

        IF STATUS <> 0 THEN
           LET p_erro = STATUS
           LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo item_chapa_885.COUNT'
           LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF
        
        IF p_count > 0 THEN
        ELSE
           
           #se o item possuir na estrutura um ou mais 
           #componentes contendo no final do código "CX", 
           #então o mesmo é um conjunto e
           #sua ordem não será enviada ao trim   

           SELECT COUNT(a.cod_item_compon) 
             INTO p_count
             FROM ord_compon a, item b 
            WHERE a.cod_empresa = p_cod_empresa                               
              AND a.num_ordem = p_ordens.NumOrdem  
              AND a.num_ordem > m_ordem_antiga                                            
              AND a.ies_tip_item <> 'C'                               
              AND b.cod_empresa = a.cod_empresa                       
              AND b.cod_item = a.cod_item_compon                      
              AND b.cod_familia  in ('200','201','202','205')         
              AND substring(a.cod_item_compon,1,1) < 'A'  

 	         IF STATUS <> 0 THEN
              LET p_erro = STATUS
              LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ord_compon:cq_ordens'
              LET p_num_ordem = 0
	            LET p_houve_erro = TRUE
    	        EXIT FOREACH
	         END IF

           IF p_count > 1 THEN
              LET p_cod_conjunto = p_ordens.CodItem
              CONTINUE FOREACH 
           END IF

        END IF        

        SELECT tipo_processo
          INTO p_tipo_processo
          FROM tipo_pedido_885
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_ordens.NumPedido         
      
        IF STATUS <> 0 THEN
           LET p_erro = STATUS
           LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo tipo_pedido_885.tipo_processo'
           LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF

        IF p_tipo_processo = 2 THEN
           LET p_msg = NULL
           #LET p_houve_erro = TRUE
           CONTINUE FOREACH
        END IF

        LET p_ordens.tipopedido = p_tipo_processo
        
        SELECT cod_cliente,
               cod_nat_oper,
               ies_sit_pedido,
               ies_frete
          INTO p_ordens.CodCliente,
               p_cod_nat_oper,
               p_ies_sit_ped,
               p_ordens.tipfrete
          FROM pedidos
         WHERE cod_empresa    = p_cod_empresa
  	       AND num_pedido     = p_ordens.NumPedido

        IF STATUS <> 0 THEN
           LET p_erro = STATUS
           LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo pedidos:cq_ordens'
           LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF

        IF p_ies_sit_ped = '9' THEN
           LET p_msg = 'pedido cancelado ',p_ordens.NumPedido
           LET p_houve_erro = TRUE
	         CONTINUE FOREACH
	      END IF

        SELECT cod_item
          INTO l_cod_item
          FROM ped_itens
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_ordens.NumPedido
           AND num_sequencia = p_ordens.NumSeqItem

        IF STATUS <> 0 THEN
           LET p_erro = STATUS
           LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo grupo_produto_885:cq_ordens'
           LET p_houve_erro = TRUE
           EXIT FOREACH
        END IF

        LET p_ordens.codconjunto = ''
        	       
	      IF l_cod_item <> p_ordens.CodItem THEN
           
           LET p_ve_divisao = FALSE
           
   	        SELECT cod_grupo_item
              INTO p_cod_grupo_item
              FROM item_vdp
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_ordens.CodItem

            IF STATUS <> 0 THEN
                LET p_erro = STATUS
                LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo item_vdp:cq_ordens'
               LET p_houve_erro = TRUE
               EXIT FOREACH
            END IF
	         
            SELECT cod_grupo
              FROM grupo_produto_885
             WHERE cod_empresa = p_cod_empresa
               AND cod_grupo   = p_cod_grupo_item
               AND cod_tipo    = '2'
           
            IF STATUS = 100 THEN
     	      ELSE
               IF STATUS = 0 THEN
	                CONTINUE FOREACH
	             ELSE
                  LET p_erro = STATUS
                  LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo grupo_produto_885:cq_ordens'
                  LET p_houve_erro = TRUE
                  EXIT FOREACH
               END IF
            END IF

            LET p_ordens.codconjunto = p_cod_conjunto

        ELSE
           LET p_ve_divisao = TRUE
	      END IF
	           
	      IF NOT pol0618_insere_ordens_885() THEN
	         LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF
	      
	      IF p_ve_divisao THEN
   	       IF NOT pol0618_ve_divisao() THEN
	            LET p_houve_erro = TRUE
	            EXIT FOREACH
	         END IF
	      END IF
	      
	      INITIALIZE p_ordens TO NULL   
   
      END FOREACH

      IF NOT p_houve_erro THEN
	      IF NOT pol0618_libera_ordem() THEN
	         LET p_houve_erro = TRUE
	      END IF
      END IF
      
      IF p_cancel_chapa THEN #cancela a OP da chapa peça
	      IF NOT pol0618_cancela_ordem() THEN
	         LET p_houve_erro = TRUE
	      END IF
      END IF
            
      IF p_houve_erro THEN
         CALL log085_transacao("ROLLBACK")
         IF p_msg IS NOT NULL THEN
            CALL pol0618_ins_erro()
         END IF
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0618_libera_ordem()
#-----------------------------#
  
  DEFINE l_num_neces     INTEGER
  
  DECLARE cq_elinina CURSOR FOR
   SELECT n.num_neces
     FROM necessidades n, ord_compon a, item b
     WHERE n.cod_empresa = p_cod_empresa
       AND n.num_docum   = p_num_docum
       AND a.cod_empresa = n.cod_empresa
       AND a.cod_item_pai = n.num_neces
       AND a.num_ordem = n.num_ordem
       AND a.ies_tip_item = 'C'
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item =  a.cod_item_compon
       AND b.ies_situacao = 'I'

   FOREACH cq_elinina INTO l_num_neces
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo necessidades'
         RETURN FALSE
      END IF
      
      DELETE FROM necessidades
       WHERE cod_empresa = p_cod_empresa
         AND num_neces = l_num_neces

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' deletando necessidades'
         RETURN FALSE
      END IF
   
      DELETE FROM ord_compon
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_pai = l_num_neces

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' deletando ord_compon'
         RETURN FALSE
      END IF
   
   END FOREACH

   UPDATE ordens
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_docum   = p_num_docum

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' liberando ordens'
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_docum   = p_num_docum

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' liberando necessidades'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0618_cancela_ordem()
#------------------------------#

   UPDATE ordens
      SET ies_situa = '9'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_op_cancela

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' cancelando ordens'
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '9'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_op_cancela

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' cancelando necessidades'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0618_pega_pedido()
#-----------------------------#

   DEFINE p_carac CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3)

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_ordens.numpedido  = p_numpedido
   LET p_ordens.numseqitem = p_numseq
   
END FUNCTION

#---------------------------------#
FUNCTION pol0618_exporta_pedidos()
#---------------------------------#

   INITIALIZE p_ordens TO NULL   
   
   DECLARE cq_pedidos CURSOR FOR
    SELECT a.num_pedido,
           a.cod_cliente,
           a.cod_nat_oper,
           a.ies_frete,
           d.num_sequencia,
           d.cod_item,
           d.qtd_pecas_solic,
           d.prz_entrega
      FROM pedidos a,
           tipo_pedido_885 b,
           ped_itens d
     WHERE a.cod_empresa    = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND b.cod_empresa    = a.cod_empresa
       AND b.num_pedido     = a.num_pedido
       AND b.tipo_processo  in (2,4)
       AND a.num_pedido NOT IN (
           SELECT c.numpedido
             FROM ordens_885 c
            WHERE c.CodEmpresa = a.cod_empresa
              AND c.NumPedido  = a.num_pedido)
       AND d.cod_empresa = a.cod_empresa
       AND d.num_pedido = a.num_pedido
       AND d.qtd_pecas_atend    = 0
       AND d.qtd_pecas_cancel   = 0
       AND d.qtd_pecas_romaneio = 0
       
   FOREACH cq_pedidos INTO
           p_ordens.NumPedido,
           p_cod_cliente,
           p_cod_nat_oper,
           p_ordens.tipfrete,
           p_ordens.NumSeqItem,
           p_ordens.CodItem,
           p_ordens.QtdPedida,
           p_ordens.DatEntrega

      IF STATUS <> 0 THEN
         LET p_num_docum = ''
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo necessidades'
	       RETURN FALSE
	    END IF

      LET p_ordens.tipopedido = 2
      LET p_num_docum = p_ordens.NumPedido
      LET p_num_docum = p_num_docum CLIPPED,'/',p_ordens.NumSeqItem USING '<<<'
      
      LET pr_men[1].mensagem = p_num_docum
      CALL pol0618_exib_mensagem()
              
      LET p_ordens.CodCliente = p_cod_cliente
      	      
	    IF NOT pol0618_insere_ordens_885() THEN
	       RETURN FALSE
	    END IF
	
      INITIALIZE p_ordens.* TO NULL

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
FUNCTION pol0618_insere_ordens_885()
#-----------------------------------#
   
   DEFINE p_itemcliente CHAR(30)

   DEFINE p_cli_nat LIKE clientes.cod_cliente

   LET p_troca_op = FALSE
   LET p_num_seq = p_num_seq + 1   
   LET p_ordens.NumSequencia = p_num_seq
   LET p_ordens.CodEmpresa   = p_cod_empresa
  
   SELECT cod_item_cliente
     INTO p_itemcliente
     FROM cliente_item
    WHERE cod_cliente_matriz = p_ordens.CodCliente
      AND cod_item = p_ordens.CodItem
   
   IF STATUS <> 0 THEN
      LET p_itemcliente = p_ordens.CodItem
   END IF    

   LET p_ordens.composicao  = NULL 
   LET p_ordens.Largura     = NULL  
   LET p_ordens.Comprimento = NULL     
   LET p_ordens.Vinco1      = NULL     
   LET p_ordens.Vinco2      = NULL     
   LET p_ordens.Vinco3      = NULL     
   LET p_ordens.Vinco4      = NULL     
   LET p_ordens.Vinco5      = NULL     
   LET p_ordens.Vinco6      = NULL     
   LET p_ordens.Vinco7      = NULL     
   LET p_ordens.Vinco8      = NULL     
   LET p_ordens.ExigeLaudo  = NULL     
   LET p_ordens.numpedidocli = NULL       
   
   UPDATE desc_nat_oper_885
     SET ies_apontado = 'S'   #MARCA O PEDIDO COMO JÁ EXPORTADO PARA O TRIM
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_ordens.NumPedido

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' UPDATE desc_nat_oper_885'
      RETURN FALSE
   END IF
     
   SELECT *
     INTO p_item_chapa_885.*
     FROM item_chapa_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem
     
   IF STATUS = 0 THEN
   
      IF p_tipo_processo = 1 THEN     #pedido de chapa só pra estoque deve ter a OP da chapa peça
         LET p_cancel_chapa = TRUE    #cancelada após a mesma ser exportada para o trim
         LET p_op_cancela = p_ordens.NumOrdem
      END IF
   
      LET p_ordens.composicao  = p_itemcliente
      LET p_ordens.Largura     = p_item_chapa_885.Largura
      LET p_ordens.Comprimento = p_item_chapa_885.Comprimento
      LET p_ordens.Vinco1      = p_item_chapa_885.Vinco1
      LET p_ordens.Vinco2      = p_item_chapa_885.Vinco2
      LET p_ordens.Vinco3      = p_item_chapa_885.Vinco3
      LET p_ordens.Vinco4      = p_item_chapa_885.Vinco4
      LET p_ordens.Vinco5      = p_item_chapa_885.Vinco5
      LET p_ordens.Vinco6      = p_item_chapa_885.Vinco6
      LET p_ordens.Vinco7      = p_item_chapa_885.Vinco7
      LET p_ordens.Vinco8      = p_item_chapa_885.Vinco8
      LET p_ordens.ExigeLaudo  = p_item_chapa_885.Laudo
      LET p_ordens.numpedidocli = p_item_chapa_885.num_pedido_cli
      
      IF p_ordens.NumOrdem IS NULL OR p_ordens.NumOrdem = ' ' THEN
      ELSE
           #pegar dados da chapa kilo
     
         SELECT num_ordem,
                qtd_planej
           INTO p_ordens.ordcompon,
                p_ordens.qtdcompon
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_docum = p_num_docum
            AND cod_item = p_ordens.composicao
            AND cod_item_pai = p_ordens.CodItem

         IF STATUS <> 0 THEN
            LET p_erro = STATUS
            LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ordem da chapa ',p_ordens.composicao
            RETURN FALSE
         END IF                                           
         
         LET p_troca_op = TRUE
      END IF
      
   ELSE
      IF STATUS <> 100 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo item_chapa_885'
         RETURN FALSE
      ELSE
         SELECT num_pedido_cli
           INTO p_ordens.numpedidocli
           FROM item_caixa_885        
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_ordens.NumPedido
            AND num_sequencia = p_ordens.NumSeqItem         
         IF STATUS = 100 THEN
            SELECT num_pedido_cli
              INTO p_ordens.numpedidocli
              FROM item_bobina_885        
             WHERE cod_empresa   = p_cod_empresa
               AND num_pedido    = p_ordens.NumPedido
               AND num_sequencia = p_ordens.NumSeqItem         
            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo item_bobina_885'
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               LET p_erro = STATUS
               LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo item_caixa_885'
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
      
   SELECT gramatura
     INTO p_ordens.Gramatura
     FROM gramatura_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ordens.CodItem

    IF STATUS = 100 THEN
      INITIALIZE p_ordens.Gramatura TO NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo gramatura_885'
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
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_item_texto_885'
         RETURN FALSE
      END IF
   END IF

   SELECT den_texto_1,
          den_texto_2,
          den_texto_3,
          den_texto_4,
          den_texto_5
     INTO p_ordens.ObsPedido1,
          p_ordens.ObsPedido2,
          p_ordens.ObsPedido3,
          p_ordens.ObsPedido4,
          p_ordens.ObsPedido5
     FROM ped_item_texto_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = 0
  
   IF STATUS = 100 THEN
      INITIALIZE p_ordens.ObsPedido1,
                 p_ordens.ObsPedido2,
                 p_ordens.ObsPedido3,
                 p_ordens.ObsPedido4,
                 p_ordens.ObsPedido5  TO NULL
   ELSE 
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_item_texto_885'
         RETURN FALSE
      END IF
   END IF
   
   SELECT parametro_val
     INTO p_ordens.tolentmais
     FROM ped_info_compl
    WHERE empresa = p_cod_empresa
      AND pedido  = p_ordens.NumPedido
      AND campo   = 'pct_tolerancia_maximo'
   
   IF STATUS = 100 THEN
      LET p_ordens.tolentmais = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_info_compl'
         RETURN FALSE
      END IF
   END IF
   
   SELECT parametro_val
     INTO p_ordens.tolentmenos
     FROM ped_info_compl
    WHERE empresa = p_cod_empresa
      AND pedido  = p_ordens.NumPedido
      AND campo   = 'pct_tolerancia_minimo'
   
   IF STATUS = 100 THEN
      LET p_ordens.tolentmenos = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_info_compl'
         RETURN FALSE
      END IF
   END IF
     
   SELECT ies_tip_controle
     INTO p_ies_tip_controle
     FROM nat_operacao
    WHERE cod_nat_oper = p_cod_nat_oper

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo nat_operacao'
      RETURN FALSE
   END IF
   
   SELECT cod_cliente_matriz
     INTO p_cod_cliente_matriz
     FROM clientes
    WHERE cod_cliente = p_ordens.CodCliente

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo clientes'
      RETURN FALSE
   END IF
   
   IF p_cod_cliente_matriz IS NULL OR p_cod_cliente_matriz =  ' ' OR
       LENGTH(p_cod_cliente_matriz) = 0 THEN
      LET p_cod_cliente_matriz = p_ordens.CodCliente
   END IF

   INITIALIZE p_ped_end_ent.*,
              p_cod_cliente_ent  TO NULL
              
   DECLARE cq_nat CURSOR FOR              
   SELECT cod_cliente
     FROM ped_item_nat
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = 0

   FOREACH cq_nat INTO p_cli_nat
      LET p_cod_cliente_ent = p_cli_nat
      EXIT FOREACH
   END FOREACH

    IF p_cod_cliente_ent IS NOT NULL THEN 
      IF NOT pol0618_end_do_cliente() THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_cod_cliente_ent = p_ordens.CodCliente
      IF NOT pol0618_end_do_pedido() THEN
         RETURN FALSE
      END IF
   END IF
      
   LET p_cod_cidade = p_ped_end_ent.cod_cidade
 
   IF p_cod_cidade IS NOT NULL THEN
      IF NOT pol0618_le_cidade() THEN
         RETURN FALSE
      END IF
      IF NOT pol0618_inere_end_ent() THEN
         RETURN FALSE
      END IF
      LET p_ordens.endentpadrao = 'N'
   ELSE
      LET p_ordens.endentpadrao = 'S'
   END IF


   IF p_troca_op  THEN
      #LET p_ordens.NumOrdem = p_ordens.ordcompon #descomentar
      #LET p_ordens.CodItem = p_ordens.composicao #descomentar
      LET p_op_ja_export = p_ordens.ordcompon
   END IF
   
   IF NOT pol0618_insere_ordens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0618_end_do_cliente()
#--------------------------------#

   SELECT num_cgc_cpf,
          ins_estadual,
          end_cliente,
          den_bairro,
          cod_cep,
          cod_cidade
     INTO p_ped_end_ent.num_cgc,
          p_ped_end_ent.ins_estadual,
          p_ped_end_ent.end_entrega,
          p_ped_end_ent.den_bairro,
          p_ped_end_ent.cod_cep,
          p_ped_end_ent.cod_cidade
     FROM clientes
    WHERE cod_cliente = p_cod_cliente_ent 
    
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo clientes'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0618_end_do_pedido()#
#-------------------------------#

   DEFINE p_num_seq SMALLINT
   
   SELECT MAX(num_sequencia)
     INTO p_num_seq
     FROM ped_end_ent
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_end_ent'
      RETURN FALSE
   END IF
    
   IF p_num_seq IS NOT NULL THEN
      SELECT end_entrega,
             den_bairro,
             cod_cidade,
             cod_cep,
             num_cgc,
             ins_estadual,
             num_sequencia
        INTO p_ped_end_ent.end_entrega,
             p_ped_end_ent.den_bairro,
             p_ped_end_ent.cod_cidade,
             p_ped_end_ent.cod_cep,
             p_ped_end_ent.num_cgc,
             p_ped_end_ent.ins_estadual,
             p_ped_end_ent.num_sequencia
        FROM ped_end_ent
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordens.NumPedido
         AND num_sequencia = p_num_seq

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo tabela ped_end_ent'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0618_le_cidade()
#---------------------------#
   
   INITIALIZE p_loc_entrega_885 TO NULL
   
   SELECT den_cidade,
          cod_uni_feder
     INTO p_loc_entrega_885.municipio,
          p_loc_entrega_885.uf
     FROM cidades
    WHERE cod_cidade = p_cod_cidade

   IF STATUS <> 0  AND STATUS <> 100 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo cidades'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0618_insere_ordens()
#------------------------------#

   LET p_ordens.numloja    = p_ordens.CodCliente
   LET p_ordens.codcliente = p_cod_cliente_matriz
   LET p_ordens.numlocent  = p_cod_cliente_ent

   LET p_ordens.TipoRegistro   = 'I'
   LET p_ordens.StatusRegistro = '0'

   IF p_ordens.tipfrete = '3' THEN
      LET p_ordens.tipfrete = 'F'
   ELSE
      LET p_ordens.tipfrete = 'C'
   END IF
      
   INSERT INTO ordens_885
    VALUES(p_ordens.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' inserindo ordens_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0618_inere_end_ent()
#-------------------------------#

   SELECT COUNT(*)
     INTO p_count
     FROM loc_entrega_885 
    WHERE numpedido = p_ordens.numpedido

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo loc_entrega_885'
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      RETURN TRUE
   END IF

   SELECT nom_cliente,
          dat_atualiz
     INTO p_loc_entrega_885.razaosocial,
          p_loc_entrega_885.datatualizacao
     FROM clientes
    WHERE cod_cliente = p_cod_cliente_ent

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo clientes'
      RETURN FALSE
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo loc_entrega_885'
      RETURN FALSE
   END IF
     
   IF p_num_seq_loc IS NULL THEN
      LET p_num_seq_loc = 0
   END IF

   LET p_num_seq_loc                    = p_num_seq_loc + 1   

   LET p_loc_entrega_885.codcliente     = p_cod_cliente_matriz
   LET p_loc_entrega_885.nrloja         = p_ordens.CodCliente
   LET p_loc_entrega_885.nrlocalentrega = p_cod_cliente_ent
   LET p_loc_entrega_885.numsequencia   = p_num_seq_loc
   LET p_loc_entrega_885.numcnpj        = p_ped_end_ent.num_cgc
   LET p_loc_entrega_885.inscestatual   = p_ped_end_ent.ins_estadual
   LET p_loc_entrega_885.endereco       = p_ped_end_ent.end_entrega
   LET p_loc_entrega_885.bairro         = p_ped_end_ent.den_bairro
   LET p_loc_entrega_885.cep            = p_ped_end_ent.cod_cep
   LET p_loc_entrega_885.tiporegistro   = 'I'
   LET p_loc_entrega_885.statusregistro = '0'
   LET p_loc_entrega_885.nomprograma    = 'POL0618'
   LET p_loc_entrega_885.numpedido      = p_ordens.numpedido
   LET p_loc_entrega_885.codcidade      = p_cod_cidade #27/04/15
   
   INSERT INTO loc_entrega_885
    VALUES(p_loc_entrega_885.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' inserindo loc_entrega_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION


#-----------------------------#
FUNCTION pol0618_ve_divisao() #
#-----------------------------#

   DEFINE p_qtd_pecas         LIKE ped_itens.qtd_pecas_solic, 
          p_pre_unit          LIKE ped_itens.pre_unit,
          p_qtd_cancel        LIKE ped_itens.qtd_pecas_solic,
          p_acres_valor       LIKE ped_itens.pre_unit
   
   IF NOT pol0618_le_desconto() THEN
      RETURN FALSE
   END IF
   
   IF p_pct_desc_qtd > 0 THEN
      
      SELECT qtd_pecas_solic, pre_unit
        INTO p_qtd_pecas, p_pre_unit
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordens.NumPedido
         AND num_sequencia = p_ordens.NumSeqItem

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo ped_itens:ve_div'
         RETURN FALSE
      END IF

      #LET p_qtd_cancel = p_qtd_pecas * p_pct_desc_qtd / 100
      LET p_qtd_cancel = 0
      
      IF p_pct_acres_valor > 0 THEN
         LET p_acres_valor = p_pre_unit * p_pct_acres_valor / 100
      ELSE
         LET p_acres_valor = 0
      END IF
      
      UPDATE ped_itens 
         SET qtd_pecas_cancel = qtd_pecas_cancel + p_qtd_cancel,
             pre_unit = pre_unit + p_acres_valor
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordens.NumPedido
         AND num_sequencia = p_ordens.NumSeqItem

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando ped_itens:upd_qtd'
         RETURN FALSE
      END IF
   
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0618_le_desconto()#
#-----------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd,
          pct_desc_oper,
          pct_acres_valor
     INTO p_pct_desc_valor,
          p_pct_desc_qtd,
          p_pct_desc_oper,
          p_pct_acres_valor
     FROM desc_nat_oper_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_ordens.NumPedido
	
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' lendo desc_nat_oper_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
      