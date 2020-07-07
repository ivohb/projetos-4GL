#-----------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O LOGIX X TRIM                                     #
# PROGRAMA: pol0654                                                     #
# OBJETIVO: EXPORTA��O DE ORDENS P/ O TRIM PAPEL                        #
# DATA....: 23/10/2007                                                  #
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
          
   DEFINE p_NumSequencia       LIKE ordens_885.NumSequencia,
          p_QtdPedida          LIKE ordens_885.QtdPedida,
          p_num_docum          LIKE ordens.num_docum,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
          p_cod_cliente_matriz LIKE clientes.cod_cliente_matriz,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_num_seq_loc        INTEGER,
          p_tipo_processo      INTEGER,
          p_num_seq            INTEGER

   DEFINE p_ordens             RECORD LIKE ordens_bob_885.*,
          p_item_chapa_885     RECORD LIKE item_chapa_885.*,
          p_loc_entrega_885    RECORD LIKE loc_entrega_885.*,
          p_ped_end_ent        RECORD LIKE ped_end_ent.*
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0654-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0654.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0654_controle()
   END IF
END MAIN

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

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         LET p_cod_emp_ger = p_cod_empresa
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF NOT pol0654_exporta_ordens() THEN
      RETURN
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0654_exporta_pedidos() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   CLOSE WINDOW w_pol0654
   
END FUNCTION

#--------------------------------#
FUNCTION pol0654_exporta_ordens()
#--------------------------------#

   INITIALIZE p_ordens TO NULL

   SELECT MAX(numsequencia)
     INTO p_num_seq
     FROM ordens_bob_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ordens_885")
      RETURN FALSE
   END IF
     
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF

### O Pedro da Simula pediu p/ n�o mandar o endere�o de entrega

{   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","LOC_ENTREGA_885")
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

	    IF STATUS <> 0 THEN
	       CALL log003_err_sql("LEITURA","ordens:cq_ordens")
	       RETURN FALSE
	    END IF

	   FOREACH cq_ordens INTO 
	           p_ordens.NumOrdem,
             p_num_docum,
	           p_ordens.CodItem,
	           p_ordens.DatEntrega,
	           p_ordens.QtdPedida

	      SELECT NumSequencia
	        FROM ordens_bob_885
	       WHERE CodEmpresa = p_cod_empresa
	         AND NumOrdem   = p_ordens.NumOrdem
	      
	      IF STATUS = 0 THEN
	         CONTINUE FOREACH
	      ELSE
	         IF STATUS <> 100 THEN
	            CALL log003_err_sql("LEITURA","ordens_885")
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
    	     CALL log003_err_sql("LEITURA","tipo_pedido_885")
	         RETURN FALSE
	      END IF

        IF p_tipo_processo = 2 THEN
           CONTINUE FOREACH
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
           CALL log003_err_sql("LEITURA","pedidos")
           RETURN FALSE
        END IF

        IF NOT pol0654_le_clientes() THEN
           RETURN FALSE
        END IF
        
	      DISPLAY p_ordens.NumOrdem TO num_ordem
	      
        LET p_ordens.cancelada    = 0

	      CALL log085_transacao("BEGIN")
        
	      IF NOT pol0654_insere_ordens_885() THEN
	         CALL log085_transacao("ROLLBACK")
	         EXIT FOREACH
	      END IF

	      IF NOT pol0654_libera_ordem() THEN
	         CALL log085_transacao("ROLLBACK")
	         EXIT FOREACH
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
    WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
      AND num_ordem   = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDENS")
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
      AND num_ordem   = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","NECESSIDADES")
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
      CALL log003_err_sql("LEITURA","clientes")
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
         CALL log003_err_sql("LEITURA","item_bobina_885")
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
         CALL log003_err_sql("LEITURA","PED_INFO_COMPL")
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
         CALL log003_err_sql("LEITURA","PED_INFO_COMPL")
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
         CALL log003_err_sql("LEITURA","ped_itens_texto")
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
         CALL log003_err_sql("LEITURA","ped_info_compl")
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
         CALL log003_err_sql("LEITURA","ped_info_compl")
         RETURN FALSE
      END IF
   END IF
      
   LET p_ordens.StatusRegistro = '0'
      
   INSERT INTO ordens_bob_885
    VALUES(p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUS�O","ordens_bob_885")
      RETURN FALSE
   END IF

{  Se precisar exportar endere�o de entrga, habilitar esse bloco

   DECLARE cq_ped_end CURSOR FOR
    SELECT *
      FROM ped_end_ent
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_ordens.NumPedido
       AND num_sequencia = p_ordens.NumSeqItem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","ped_end_ent")
      RETURN FALSE
   END IF

   FOREACH cq_ped_end INTO p_ped_end_ent.*
   
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

       IF STATUS <> 0 THEN
	        CALL log003_err_sql("LEITURA","PED_ITENS")
	        RETURN FALSE
	     END IF

      FOREACH cq_itens INTO
              p_ordens.NumSeqItem,
              p_ordens.CodItem,
              p_ordens.QtdPedida,
              p_ordens.DatEntrega
              
	      DISPLAY p_ordens.NumPedido TO num_ordem
        
	      IF NOT pol0654_insere_ordens_885() THEN
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF
	
      END FOREACH

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION


