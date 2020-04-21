#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                     #
# PROGRAMA: pol0654                                                     #
# OBJETIVO: EXPORTAÇÃO DE ORDENS P/ O TRIM PAPEL                        #
# DATA....: 23/10/2007                                                  #
# FUNÇÕES: FUNC002                                                      #
#-----------------------------------------------------------------------#

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
          p_caminho            CHAR(080)

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

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0654-10.02.00  "
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
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   ELSE
      LET p_cod_empresa = l_param1_empresa
   END IF
 
   IF l_param2_user IS NULL THEN
      LET p_user = 'pol0654'  
   ELSE
      LET p_user = l_param2_user
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

   IF NOT pol0654_exporta_ordens() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0654_exporta_pedidos() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   RETURN TRUE
      
END FUNCTION

#--------------------------------#
FUNCTION pol0654_exporta_ordens()
#--------------------------------#

   INITIALIZE p_ordens TO NULL

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

### O Pedro da Simula pediu p/ não mandar o endereço de entrega

{   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo  loc_entrega_885'
      RETURN FALSE
   END IF
     
   IF p_num_seq_loc IS NULL THEN
      LET p_num_seq_loc = 0
   END IF
}
   
	   DECLARE cq_ordens CURSOR WITH HOLD FOR
	    SELECT num_ordem,
	           num_docum,
	           cod_item,
	           dat_entrega,
	           qtd_planej
	      FROM ordens
	     WHERE cod_empresa = p_cod_empresa
	       AND ies_situa   = '3'
	     ORDER BY num_ordem

	   FOREACH cq_ordens INTO 
	           p_ordens.NumOrdem,
             p_num_docum,
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
	     WHERE CodEmpresa = p_cod_empresa
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

      CALL pol0654_pega_pedido()

      SELECT tipo_processo
        INTO p_tipo_processo
        FROM tipo_pedido_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordens.NumPedido         
      
      IF STATUS <> 0 THEN
          LET p_erro = STATUS
          LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo tipo_pedido_885'
	       RETURN FALSE
	    END IF

      IF p_tipo_processo = 2 THEN
         CONTINUE FOREACH
      END IF

      IF p_tipo_processo = 3 THEN
         LET p_ordens.iesretrabalho = 'S'
      ELSE
         LET p_ordens.iesretrabalho = 'N'
      END IF

      LET p_ordens.tipopedido = p_tipo_processo

      SELECT cod_cliente
        INTO p_ordens.CodCliente
        FROM pedidos
       WHERE cod_empresa    = p_cod_empresa
  	     AND num_pedido     = p_ordens.NumPedido
  	     AND ies_sit_pedido <> '9'

      IF STATUS <> 0 THEN
         CONTINUE FOREACH
	    END IF

      SELECT prz_entrega
        INTO p_ordens.datentrega
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_ordens.NumPedido
         AND num_sequencia = p_ordens.NumSeqItem
	       AND cod_item      = p_ordens.CodItem
	       
      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_itens'
        RETURN FALSE
      END IF

      IF NOT pol0654_le_clientes() THEN
         RETURN FALSE
      END IF
        
	      DISPLAY p_ordens.NumOrdem TO num_ordem
 		    #lds CALL LOG_refresh_display()	
	      
        LET p_ordens.cancelada    = 0

	      CALL log085_transacao("BEGIN")
        
	      IF NOT pol0654_insere_ordens_885() THEN
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF

	      IF NOT pol0654_libera_ordem() THEN
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF

	      IF NOT pol0654_exporta_operacao() THEN
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF
	
	      CALL log085_transacao("COMMIT")
	   
	      INITIALIZE p_ordens TO NULL   
   
      END FOREACH
         
      RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0654_libera_ordem()
#-----------------------------#

   UPDATE ordens
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_docum   = p_num_docum

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando ordens'
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_docum   = p_num_docum

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ', p_erro CLIPPED, ' atualizando necessidades'
      RETURN FALSE
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

#-----------------------------#
FUNCTION pol0654_pega_pedido()
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

#-----------------------------------#
FUNCTION pol0654_insere_ordens_885()
#-----------------------------------#

   
   LET p_num_seq = p_num_seq + 1   
   LET p_ordens.NumSequencia = p_num_seq
   LET p_ordens.CodEmpresa   = p_cod_empresa
  
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
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_info_compl'
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
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo ped_info_compl'
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

{  Se precisar exportar endereço de entrga, habilitar esse bloco

   DECLARE cq_ped_end CURSOR FOR
    SELECT *
      FROM ped_end_ent
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_ordens.NumPedido
       AND num_sequencia = p_ordens.NumSeqItem

   FOREACH cq_ped_end INTO p_ped_end_ent.*

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cursor cq_ped'
         RETURN FALSE
      END IF
	   
      IF NOT pol0654_insere_loc_entrega_885() THEN
         RETURN FALSE
      END IF
      
      EXIT FOREACH 
      
   END FOREACH
}
   RETURN TRUE

END FUNCTION


#---------------------------------#
FUNCTION pol0654_exporta_pedidos()
#---------------------------------#

   INITIALIZE p_ordens TO NULL   
   
   DECLARE cq_pedidos CURSOR FOR
    SELECT a.num_pedido,
           a.cod_cliente
      FROM pedidos a,
           tipo_pedido_885 b
     WHERE a.cod_empresa    = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND b.cod_empresa    = a.cod_empresa
       AND b.num_pedido     = a.num_pedido
       AND b.tipo_processo  = 2
       AND a.num_pedido NOT IN (
           SELECT c.numpedido
             FROM ordens_bob_885 c
            WHERE c.CodEmpresa = a.cod_empresa
              AND c.NumPedido  = a.num_pedido)

   FOREACH cq_pedidos INTO
           p_ordens.NumPedido,
           p_ordens.CodCliente

      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'Erro ',p_erro CLIPPED, ' lendo cursor cq_pedidos'
         RETURN FALSE
      END IF
      
      LET p_ordens.iesretrabalho = 'N'
      
      IF NOT pol0654_le_clientes() THEN
         RETURN FALSE
      END IF

      LET p_ordens.cancelada  = 0
      LET p_tipo_processo     = 2 
      LET p_ordens.tipopedido = p_tipo_processo

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

         DISPLAY p_ordens.NumPedido TO num_ordem
		      #lds CALL LOG_refresh_display()	
		                      
	       IF NOT pol0654_insere_ordens_885() THEN
	          RETURN FALSE
	       END IF
	
      END FOREACH

   END FOREACH
   
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
     WHERE cod_empresa = p_cod_empresa
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
 

	       
   