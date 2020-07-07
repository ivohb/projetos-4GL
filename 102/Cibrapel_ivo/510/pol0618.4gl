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
          p_cod_cliente_ent    LIKE clientes.cod_cliente,
          p_ies_tip_controle   LIKE nat_operacao.ies_tip_controle,
          p_cod_nat_oper       LIKE pedidos.cod_nat_oper,
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_tipo_processo      INTEGER,
          p_num_seq_loc        INTEGER,
          p_num_seq            INTEGER

   DEFINE p_ordens             RECORD LIKE ordens_885.*,
          p_item_chapa_885     RECORD LIKE item_chapa_885.*,
          p_loc_entrega_885    RECORD LIKE loc_entrega_885.*,
          p_ped_end_ent        RECORD LIKE ped_end_ent.*
   
END GLOBALS

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
   LET p_versao = "POL0618-10.02.02  "
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
   IF p_status = 0  THEN
      CALL pol0618_controle()
   END IF
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

   DISPLAY p_cod_empresa TO cod_empresa
   
   WHENEVER ERROR CONTINUE

   IF NOT pol0618_exporta_ordens() THEN
      RETURN
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0618_exporta_pedidos() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   CLOSE WINDOW w_pol0618
   
END FUNCTION

#--------------------------------#
FUNCTION pol0618_exporta_ordens()
#--------------------------------#

   INITIALIZE p_ordens TO NULL

   SELECT MAX(numsequencia)
     INTO p_num_seq
     FROM ordens_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ordens_885")
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
	      LET p_houve_erro = TRUE
	      EXIT FOREACH
	   END IF
	   
	   LET p_houve_erro = FALSE
     CALL log085_transacao("BEGIN")
   
	   DECLARE cq_ordens CURSOR FOR
	    SELECT num_ordem,
	           ies_situa,
	           cod_item,
	           dat_entrega,
	           qtd_planej
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
	           p_ordens.QtdPedida

 	      IF STATUS <> 0 THEN
	         LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF

        LET pr_men[1].mensagem = p_ordens.NumOrdem
        CALL pol0618_exib_mensagem()
        
	      SELECT NumSequencia
	        FROM ordens_885
	       WHERE CodEmpresa = p_cod_empresa
	         AND NumOrdem   = p_ordens.NumOrdem
	      
	      IF STATUS = 100 THEN
	      ELSE
           LET p_houve_erro = TRUE
           EXIT FOREACH
	      END IF

        CALL pol0618_pega_pedido()

        SELECT tipo_processo
          INTO p_tipo_processo
          FROM tipo_pedido_885
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_ordens.NumPedido         
      
        IF STATUS <> 0 THEN
           LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF

        IF p_tipo_processo = 2 THEN
           LET p_houve_erro = TRUE
           EXIT FOREACH
        END IF

        LET p_ordens.tipopedido = p_tipo_processo
        
        SELECT cod_cliente,
               cod_nat_oper
          INTO p_ordens.CodCliente,
               p_cod_nat_oper
          FROM pedidos
         WHERE cod_empresa    = p_cod_empresa
  	       AND num_pedido     = p_ordens.NumPedido
  	       AND ies_sit_pedido <> '9'

	      IF STATUS = 0 THEN
	      ELSE
           CONTINUE FOREACH
	      END IF

        SELECT cod_item
          FROM ped_itens
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_ordens.NumPedido
           AND num_sequencia = p_ordens.NumSeqItem
	         AND cod_item      = p_ordens.CodItem
	       
	      IF STATUS = 100 THEN
	         SELECT cod_grupo_item
	           INTO p_cod_grupo_item
	           FROM item_vdp
	          WHERE cod_empresa = p_cod_empresa
	            AND cod_item    = p_ordens.CodItem

	         IF STATUS <> 0 THEN
	            LET p_houve_erro = TRUE
	            EXIT FOREACH
	         ELSE
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
                    LET p_houve_erro = TRUE
                    EXIT FOREACH
                 END IF
              END IF
	         END IF
	      ELSE
	         IF STATUS <> 0 THEN
	            LET p_houve_erro = TRUE
	            EXIT FOREACH
	         END IF
	      END IF
	           
	      IF NOT pol0618_insere_ordens_885() THEN
	         LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF

	      IF NOT pol0618_libera_ordem() THEN
	         LET p_houve_erro = TRUE
	         EXIT FOREACH
	      END IF
	         	
	      INITIALIZE p_ordens TO NULL   
   
      END FOREACH

      IF p_houve_erro THEN
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0618_libera_ordem()
#-----------------------------#

   UPDATE ordens
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","ORDENS")
      RETURN FALSE
   END IF

   UPDATE necessidades
      SET ies_situa = '4'
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_ordens.NumOrdem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","NECESSIDADES")
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
           a.cod_nat_oper
      FROM pedidos a,
           tipo_pedido_885 b
     WHERE a.cod_empresa    = p_cod_empresa
       AND a.ies_sit_pedido <> '9'
       AND b.cod_empresa    = a.cod_empresa
       AND b.num_pedido     = a.num_pedido
       AND b.tipo_processo  = 2
       AND a.num_pedido NOT IN (
           SELECT c.numpedido
             FROM ordens_885 c
            WHERE c.CodEmpresa = a.cod_empresa
              AND c.NumPedido  = a.num_pedido)

   FOREACH cq_pedidos INTO
           p_ordens.NumPedido,
           p_cod_cliente,
           p_cod_nat_oper

      IF STATUS <> 0 THEN
	       CALL log003_err_sql("LEITURA","pedidos:cq_pedidos")
	       RETURN FALSE
	    END IF

      LET p_ordens.tipopedido = 2

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
	        CALL log003_err_sql("LEITURA","PED_ITENS:cq_pedidos")
	        RETURN FALSE
	     END IF

      FOREACH cq_itens INTO
              p_ordens.NumSeqItem,
              p_ordens.CodItem,
              p_ordens.QtdPedida,
              p_ordens.DatEntrega
              
        LET pr_men[1].mensagem = p_ordens.NumPedido
        CALL pol0618_exib_mensagem()

        LET p_ordens.CodCliente = p_cod_cliente
	         
	      IF NOT pol0618_insere_ordens_885() THEN
	         CALL log085_transacao("ROLLBACK")
	         RETURN FALSE
	      END IF
	
      END FOREACH

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
FUNCTION pol0618_insere_ordens_885()
#-----------------------------------#
   
   DEFINE p_cli_nat LIKE clientes.cod_cliente
   
   LET p_num_seq = p_num_seq + 1   
   LET p_ordens.NumSequencia = p_num_seq
   LET p_ordens.CodEmpresa   = p_cod_empresa
  
   SELECT *
     INTO p_item_chapa_885.*
     FROM item_chapa_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem
     
   IF STATUS = 0 THEN
      LET p_ordens.composicao  = p_ordens.CodItem
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
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LEITURA","item_chapa_885")
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
               CALL log003_err_sql("LEITURA","item_bobina_885")
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql("LEITURA","item_caixa_885")
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
         CALL log003_err_sql("LEITURA","gramatura_885")
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
         CALL log003_err_sql("LEITURA","ped_item_texto_885")
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
         CALL log003_err_sql("LEITURA","ped_item_texto_885")
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
     
   SELECT ies_tip_controle
     INTO p_ies_tip_controle
     FROM nat_operacao
    WHERE cod_nat_oper = p_cod_nat_oper

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","nat_operacao")
      RETURN FALSE
   END IF
   
   SELECT cod_cliente_matriz
     INTO p_cod_cliente_matriz
     FROM clientes
    WHERE cod_cliente = p_ordens.CodCliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","clientes:1")
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
      CALL log003_err_sql("LEITURA","clientes:3")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0618_end_do_pedido()
#-------------------------------#

   DEFINE p_num_seq SMALLINT
   
   SELECT MAX(num_sequencia)
     INTO p_num_seq
     FROM ped_end_ent
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_ordens.NumPedido
      AND num_sequencia = p_ordens.NumSeqItem

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","ped_end_ent:max_seq")
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
         CALL log003_err_sql("LENDO","ped_end_ent")
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
      CALL log003_err_sql("LEITURA","CIDADES")
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
      
   INSERT INTO ordens_885
    VALUES(p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSÃO","ordens_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0618_inere_end_ent()
#-------------------------------#

   SELECT nom_cliente,
          dat_atualiz
     INTO p_loc_entrega_885.razaosocial,
          p_loc_entrega_885.datatualizacao
     FROM clientes
    WHERE cod_cliente = p_cod_cliente_ent

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","clientes:2")
      RETURN FALSE
   END IF

   SELECT MAX(numsequencia)
     INTO p_num_seq_loc
     FROM loc_entrega_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","LOC_ENTREGA_885")
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
   LET p_loc_entrega_885.nomprograma     = 'POL0618'
   
   INSERT INTO loc_entrega_885
    VALUES(p_loc_entrega_885.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSÃO","LOC_ENTREGA_885")
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION
