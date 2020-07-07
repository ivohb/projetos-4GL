#-------------------------------------------------------------------#
# PROGRAMA: pol0923                                                 #
# OBJETIVO: MRP POR PEDIOS                                          #
# CLIENTE.: ALBRAS                                                  #
# DATA....: 30/03/2009                                              #
# POR.....: IVO H BARBOSA                                           #
# ALTERADO:                                                         #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(70),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT,
         p_neces              SMALLINT,
         p_hoje               DATE 

   DEFINE p_num_seq           INTEGER,
          p_num_seq_item      DECIMAL(3,0),
          p_sequencia         INTEGER,
          p_gerar             CHAR(02),
          p_fantasma          CHAR(01),
          p_explodiu          CHAR(01)
   
   DEFINE p_cod_item          LIKE item.cod_item,
          p_cod_item_pai      LIKE item.cod_item,
          p_item_ordem        LIKE item.cod_item,
          p_cod_fantasma      LIKE item.cod_item,
          p_num_lote          LIKE ordens.num_lote,
          p_qtd_fantasma      LIKE estrutura.qtd_necessaria,
          p_ies_tip_item      LIKE item.ies_tip_item,
          p_cod_item_compon   LIKE estrutura.cod_item_compon,
          p_qtd_necessaria    LIKE estrutura.qtd_necessaria,
          p_qtd_prodcomp      LIKE estrutura.qtd_necessaria,
          p_qtd_compon        LIKE estrutura.qtd_necessaria,
          p_qtd_ordem         LIKE estrutura.qtd_necessaria,
          p_num_pedido        LIKE pedidos.num_pedido,
          p_prz_entrega       LIKE ped_itens.prz_entrega,
          p_qtd_sdo_ped       LIKE ped_itens.qtd_pecas_solic,
          p_qtd_sdo_est       LIKE estoque_lote.qtd_saldo,
          p_cod_horizon       LIKE item_man.cod_horizon,
          p_qtd_dias          LIKE horizonte.qtd_dias_horizon,
          p_qtd_sdo_ord       LIKE ordens.qtd_planej,
          p_qtd_sdo_oc        LIKE ordem_sup.qtd_solic,
          p_cod_local         LIKE estoque_lote.cod_local,
          p_qtd_reservada     LIKE estoque_loc_reser.qtd_reservada,
          p_prx_num_oc        LIKE par_sup.prx_num_oc,
          p_prx_num_op        LIKE par_mrp.prx_num_ordem,
          p_prx_num_neces     LIKE par_mrp.prx_num_neces,
          p_num_oc            LIKE ordem_sup.num_oc,
          m_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
          m_num_conta          LIKE item_sup.num_conta,
          m_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
          m_ies_tip_item       LIKE item.ies_tip_item,
          m_cod_progr          LIKE item_sup.cod_progr,
          m_cod_comprador      LIKE item_sup.cod_comprador,
          m_ies_tip_incid_ipi  LIKE item_sup.ies_tip_incid_ipi,
          m_cod_fiscal         LIKE item_sup.cod_fiscal,
          m_prx_num_oc         LIKE par_sup.prx_num_oc,
          m_pct_ipi            LIKE item.pct_ipi,
          m_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
          m_cod_unid_med       LIKE item.cod_unid_med,
          m_qtd_lote_minimo    LIKE item_sup.qtd_lote_minimo,
          m_qtd_estoq_seg      LIKE item_sup.qtd_estoq_seg,
          p_pct_refug          LIKE estrutura.pct_refug,
          p_texto              LIKE ordem_sup_txt.tex_observ_oc,
          p_num_docum          LIKE ordem_sup.num_docum,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_data_in						 LIKE ped_itens.prz_entrega,
          p_data_fi						 LIKE ped_itens.prz_entrega
          
   DEFINE p_ordens            RECORD LIKE ordens.*,
          p_op_compl          RECORD LIKE ordens_complement.*,
          p_necessidades      RECORD LIKE necessidades.*,
          p_item_man          RECORD LIKE item_man.*,
          p_ordem_sup         RECORD LIKE ordem_sup.*,
          p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*,
          p_dest_ordem_sup    RECORD LIKE dest_ordem_sup.*,
          p_estr_ordem_sup    RECORD LIKE estrut_ordem_sup.*
  
   DEFINE pr_pedido            ARRAY[500] OF RECORD
          num_pedido          LIKE ped_itens.num_pedido,
          dat_pedido          LIKE pedidos.dat_pedido,
          nom_cliente         LIKE pedidos.cod_cliente,
          num_pedido_cli      LIKE pedidos.num_pedido_cli          
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0923-10.02.00"
   INITIALIZE p_data_fi TO NULL 
   INITIALIZE p_data_in TO NULL
   
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0923_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0923_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0923") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0923 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
   	COMMAND "Informar" "Informar parâmetros para o processamento"
       IF pol0923_informar() THEN 
       	  ERROR 'Parâmetros informados com sucesso!'
       	  LET p_ies_cons = TRUE
       	  NEXT OPTION "Processar"
       ELSE 
        	ERROR 'Operação cancelada!'
        	LET p_ies_cons = FALSE
       END IF 
   COMMAND "Processar" "Gera ordens para os pedidos com saldo"
       IF log004_confirm(18,35) THEN
          IF pol0923_processa() THEN
             LET p_msg = 'Processamento efetuado com sucesso !!!'
          ELSE 
             LET p_msg = 'Operação cancelada !!!'
          END IF
          MESSAGE ''
          CALL log0030_mensagem(p_msg,'info')
          NEXT OPTION 'Fim'
       END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0923_sobre()
    COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR comando
       RUN comando
       PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
       DATABASE logix
       LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
       EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0923

END FUNCTION

#--------------------------#
 FUNCTION pol0923_informar()		
#--------------------------#
    
   LET INT_FLAG = FALSE
   
   CALL pol0923_limpa_tela()
   
   INITIALIZE p_data_in,p_data_fi TO NULL
   
   INPUT p_data_in,p_data_fi WITHOUT DEFAULTS
    FROM data_in,
         data_fi
      			
			AFTER FIELD data_in
					
				IF p_data_in IS NULL THEN
           EXIT INPUT
    	 	END IF	
    	 	
    	 	AFTER FIELD data_fi
					
				IF p_data_fi IS NULL THEN
							ERROR "Campo com Preenchimento Obrigatório !!!"
            	NEXT FIELD data_fi
        END IF

        IF p_data_in > p_data_fi THEN
         	 ERROR "Data final tem que ser maior que a data inicial !!!"
         	 NEXT FIELD data_fi
        END IF 
  
   END INPUT 

   IF INT_FLAG THEN
      CALL pol0923_limpa_tela()
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION 

#----------------------------#
FUNCTION pol0923_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION

#--------------------------#
FUNCTION pol0923_processa()
#--------------------------#

   IF NOT p_ies_cons THEN 
		  LET p_data_in = '01/01/2009'
		  LET p_data_fi = '01/01/3000'
	 END IF 

   IF NOT pol0923_del_tabs_tmp() THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN") 

   IF NOT pol0923_ve_necessidade() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF

   IF NOT pol0923_proces_mrp() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0923_ve_necessidade()
#-------------------------------#

   IF NOT pol0923_bloqueia_tab() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol0923_varre_pedidos() THEN
      RETURN FALSE
   END IF

   LET p_neces = FALSE
   
   IF NOT pol0923_carrega_itens_ped() THEN
      RETURN FALSE
   END IF

    IF NOT p_neces THEN
       LET p_msg = 'Não há pedido com necessidade de ordens'
       CALL log0030_mensagem(p_msg, 'excla')
       RETURN FALSE
    END IF
  
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0923_bloqueia_tab()
#------------------------------#

   MESSAGE 'Bloqueando tabelas...'

   LOCK TABLE pedido_tmp_304 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Bloqueando','pedido_tmp_304')
      RETURN FALSE
   END IF

   LOCK TABLE ped_itens_tmp_304 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Bloqueando','ped_itens_tmp_304')
      RETURN FALSE
   END IF

   LOCK TABLE estrut_tmp_304 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Bloqueando','estrut_tmp_304')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION



#------------------------------#
FUNCTION pol0923_del_tabs_tmp()
#------------------------------#

   MESSAGE 'Inicializando tabelas...'

   DELETE FROM pedido_tmp_304
   IF STATUS = 0 THEN
      DELETE FROM ped_itens_tmp_304
      IF STATUS = 0 THEN
         DELETE FROM estrut_tmp_304
         IF STATUS = 0 THEN
            DELETE FROM pedido_oc_304
            IF STATUS = 0 THEN
               RETURN TRUE
            END IF
         END IF
      END IF
   END IF

   RETURN FALSE

END FUNCTION
    
#-------------------------------#
FUNCTION pol0923_varre_pedidos()
#-------------------------------#

   MESSAGE 'Varrendo carteira de pedidos...'

   DECLARE cq_varre CURSOR FOR
   SELECT DISTINCT a.num_pedido
     FROM pedidos a,
          ped_itens b
    WHERE a.cod_empresa     = p_cod_empresa
      AND a.ies_sit_pedido <> '9'
      AND b.cod_empresa     = a.cod_empresa
      AND b.num_pedido      = a.num_pedido
      AND b.prz_entrega BETWEEN p_data_in  AND	p_data_fi					
      AND (b.qtd_pecas_solic - 
           b.qtd_pecas_atend - 
           b.qtd_pecas_cancel -
           b.qtd_pecas_romaneio) > 0

   FOREACH cq_varre INTO p_num_pedido
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_varre')
         RETURN FALSE
      END IF
      
      IF NOT pol0923_ins_pedido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0923_ins_pedido()
#----------------------------#

   INSERT INTO pedido_tmp_304
     VALUES(p_num_pedido)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','pedido_tmp_304')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0923_carrega_itens_ped()
#-----------------------------------#

   DEFINE p_cod_familia LIKE item.cod_familia

   MESSAGE 'Carregando itens do pedido...'
         
   DECLARE cq_ped CURSOR FOR 
    SELECT num_pedido
      FROM pedido_tmp_304
   
   FOREACH cq_ped INTO p_num_pedido

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ped')
         RETURN FALSE
      END IF
    
      DECLARE cq_pi CURSOR FOR 
       SELECT num_sequencia,
              cod_item,
              prz_entrega,
             (qtd_pecas_solic - 
              qtd_pecas_atend  - 
              qtd_pecas_cancel -
              qtd_pecas_romaneio)
         FROM ped_itens 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido  = p_num_pedido
          AND prz_entrega BETWEEN p_data_in AND p_data_fi					
          AND (qtd_pecas_solic - 
              qtd_pecas_atend  - 
              qtd_pecas_cancel -
              qtd_pecas_romaneio) > 0
       
      FOREACH cq_pi INTO
              p_num_seq,
              p_cod_item,
              p_prz_entrega,
              p_qtd_sdo_ped
   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_pi')
            RETURN FALSE
         END IF

         SELECT cod_familia
           INTO p_cod_familia
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item
         
         IF STATUS <> 0 THEN
            ERROR 'Item:',p_cod_item
            CALL log003_err_sql('Lendo','item')
            RETURN FALSE
         END IF
         
         SELECT cod_empresa
           FROM familia_mrp_304
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_cod_familia

         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','familia_mrp_304')
               RETURN FALSE
            END IF
         END IF
              
         LET p_num_docum = p_num_pedido
         LET p_num_docum = p_num_docum CLIPPED, '/', p_num_seq USING '<<<'

         IF NOT pol0923_le_sdo_op() THEN
            RETURN FALSE
         END IF
      
         LET p_qtd_sdo_ped = p_qtd_sdo_ped - p_qtd_sdo_ord
      
         IF p_qtd_sdo_ped <= 0 THEN
            CONTINUE FOREACH
         END IF

         INSERT INTO ped_itens_tmp_304
             VALUES(p_num_pedido,
                    p_num_seq,
                    p_cod_item, 
                    p_qtd_sdo_ped,
                    p_prz_entrega)
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','ped_itens_tmp_304')
            RETURN FALSE
         END IF
         
         LET p_neces = TRUE
                    
       END FOREACH
       
    END FOREACH
      
    RETURN TRUE
    
END FUNCTION         

#---------------------------#
FUNCTION pol0923_le_sdo_op()
#---------------------------#

   SELECT SUM(qtd_planej)
		 INTO p_qtd_sdo_ord
		 FROM ordens
		WHERE cod_empresa = p_cod_empresa
		  AND cod_item    = p_cod_item
		  AND ies_situa   = '4'
		  AND ies_origem  = 'H'
		  AND num_docum   = p_num_docum
         
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','ordens:sdo')
       RETURN FALSE
    END IF  
      
    IF p_qtd_sdo_ord IS NULL THEN
       LET p_qtd_sdo_ord = 0
    END IF

    RETURN TRUE

END FUNCTION 

#----------------------------#
FUNCTION pol0923_proces_mrp()
#----------------------------#
  
   DECLARE cq_proces CURSOR FOR
    SELECT num_pedido,
           num_seq,
           cod_item,
           qtd_saldo,
           dat_entrega
      FROM ped_itens_tmp_304
     ORDER BY num_pedido, num_seq 
   
   FOREACH cq_proces INTO 
           p_num_pedido,
           p_num_seq_item,
           p_cod_item, 
           p_qtd_sdo_ped,
           p_prz_entrega

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_proces')
         RETURN FALSE
      END IF
                 
      IF NOT pol0923_le_tip_item(p_cod_item) THEN
         RETURN FALSE
      END IF   

      LET p_num_seq = 0
 
      IF p_ies_tip_item = 'T' THEN
         LET p_gerar = NULL
      ELSE
         IF p_ies_tip_item MATCHES '[FP]' THEN
            LET p_gerar = 'OP'
         ELSE
            LET p_gerar = 'OC'
         END IF
      END IF
   
      LET p_cod_item_pai = '0'
      LET p_cod_item_compon = p_cod_item
      LET p_qtd_compon = 1
      LET p_explodiu = 'N'
      
      IF NOT pol0923_ins_estrut() THEN
         RETURN FALSE
      END IF

      IF NOT pol0923_explode_estrutura() THEN
         RETURN FALSE
      END IF

      IF NOT pol0923_ins_ped_oc() THEN
         RETURN FALSE
      END IF
      
      LET p_num_docum = p_num_pedido
      LET p_num_docum = p_num_docum CLIPPED, '/', p_num_seq_item USING '<<<'
       
      IF NOT pol0923_gera_ops() THEN
         RETURN FALSE
      END IF
       
      IF NOT pol0923_deleta_estrut() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   IF NOT pol0923_gera_ocs() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
  
END FUNCTION

#---------------------------------------#
FUNCTION pol0923_le_tip_item(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT ies_tip_item
     INTO p_ies_tip_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      ERROR 'Item:',p_cod_item
      CALL log003_err_sql('Lendo','item:local')
      RETURN FALSE
   END IF

  RETURN TRUE
  
END FUNCTION


#------------------------------#
FUNCTION pol0923_deleta_estrut()
#------------------------------#

   DELETE FROM estrut_tmp_304
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estrut_tmp_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0923_deleta_ops()
#----------------------------#

   DEFINE p_num_ordem LIKE ordens.num_ordem
          
   DECLARE cq_del_neces CURSOR FOR
    SELECT num_ordem
      FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND ies_situa   IN ('1','2','3')
      AND ies_origem  = 'H'
      AND num_docum   = p_num_docum  

   FOREACH cq_del_neces INTO p_num_ordem
   
      DELETE FROM necessidades
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem

      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","necessidades")
         RETURN FALSE
      END IF

      DELETE FROM ord_compon
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem

      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","ord_compon")
         RETURN FALSE
      END IF
      
      DELETE FROM ordens_complement
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem

      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","ordens_complement")
         RETURN FALSE
      END IF
      
      DELETE FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_num_ordem
      
      IF STATUS <> 0 then
         CALL log003_err_sql("Deletando","ordens")
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0923_explode_estrutura()
#-----------------------------------#

   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM estrut_tmp_304
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','estrut_tmp_304:while')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT num_seq,
            cod_item,
            qtd_prodcomp
       FROM estrut_tmp_304
      WHERE explodiu = 'N'
    
    FOREACH cq_exp INTO p_sequencia, p_cod_item_pai, p_qtd_prodcomp
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','estrut_tmp_304:cq_exp')
          RETURN FALSE
       END IF
       
       UPDATE estrut_tmp_304
          SET explodiu = 'S'
        WHERE num_seq = p_sequencia

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','estrut_tmp_304:cq_exp')
          RETURN FALSE
       END IF
       
       LET p_hoje = TODAY 
       
       DECLARE cq_est CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria,
               pct_refug
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_item_pai
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
               (dat_validade_ini IS NULL AND dat_validade_fim >= p_hoje) OR
               (dat_validade_fim IS NULL AND dat_validade_ini <= p_hoje )OR
               (p_hoje BETWEEN dat_validade_ini AND dat_validade_fim))
       
       FOREACH cq_est INTO p_cod_item_compon, p_qtd_necessaria, p_pct_refug

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura:cq_est')
             RETURN FALSE
          END IF
       
          IF NOT pol0923_le_tip_item(p_cod_item_compon) THEN
             RETURN FALSE
          END IF
          
          LET p_qtd_necessaria = p_qtd_necessaria + (p_qtd_necessaria * p_pct_refug / 100)
          LET p_qtd_compon = p_qtd_prodcomp * p_qtd_necessaria

          IF p_ies_tip_item = 'T' THEN
             LET p_gerar = NULL
          ELSE
             IF p_ies_tip_item MATCHES '[FP]' THEN
                LET p_gerar = 'OP'
             ELSE
                LET p_gerar = 'OC'
             END IF
          END IF
          
          IF p_ies_tip_item = 'C' THEN
             LET p_explodiu = 'S'
          ELSE
             LET p_explodiu = 'N'
          END IF
          
          IF p_gerar = 'OC' THEN
             SELECT num_seq
               INTO p_num_seq
               FROM estrut_tmp_304
              WHERE cod_item = p_cod_item_compon
                AND gerar    = p_gerar
             
             IF STATUS = 0 THEN
                IF NOT pol0923_atu_estrut() THEN
                   RETURN FALSE
                END IF
             ELSE
                IF NOT pol0923_ins_estrut() THEN
                   RETURN FALSE
                END IF
             END IF
          ELSE
             IF NOT pol0923_ins_estrut() THEN
                RETURN FALSE
             END IF
          END IF
          
          DISPLAY p_cod_item_compon AT 21,30
          
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION 

#----------------------------#
FUNCTION pol0923_ins_estrut()
#----------------------------#

   LET p_num_seq = p_num_seq + 1

   INSERT INTO estrut_tmp_304
      VALUES(p_num_seq,
             p_cod_item_pai,
             p_cod_item_compon,
             p_ies_tip_item,
             p_qtd_compon,
             p_gerar,
             p_explodiu)
                   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estrut_tmp_304:insert')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0923_ins_ped_oc()
#----------------------------#

   DECLARE cq_ipo CURSOR FOR        
    SELECT cod_item, 
           SUM(qtd_prodcomp) 
      FROM estrut_tmp_304 
     WHERE gerar = 'OC' 
     GROUP BY cod_item

   FOREACH cq_ipo INTO
           p_cod_item_compon,
           p_qtd_compon
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ipo')
         RETURN FALSE
      END IF
      
      SELECT cod_compon
        FROM pedido_oc_304
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_qtd_sdo_ped
         AND cod_compon    = p_cod_item_compon
      
      IF STATUS = 0 THEN
         UPDATE pedido_oc_304
            SET qtd_necessaria = p_qtd_compon
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_num_pedido
            AND num_sequencia = p_qtd_sdo_ped
            AND cod_compon    = p_qtd_compon
      ELSE
         IF STATUS = 100 THEN
            INSERT INTO pedido_oc_304
             VALUES(p_cod_empresa,
              p_num_pedido,
              p_num_seq_item,
              p_cod_item, 
              p_qtd_sdo_ped,
              p_cod_item_compon,
              p_qtd_compon,0)
         ELSE
            CALL log003_err_sql('Lendo','pedido_oc_304')
            RETURN FALSE
         END IF
      END IF
              
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Gravando','pedido_oc_304')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

      
#----------------------------#
FUNCTION pol0923_atu_estrut()
#----------------------------#

   UPDATE estrut_tmp_304
      SET qtd_prodcomp = qtd_prodcomp + p_qtd_compon
    WHERE num_seq    = p_num_seq
                   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizado','estrut_tmp_304:update')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0923_le_estoque()
#----------------------------#

   SELECT qtd_liberada  +
          qtd_lib_excep -
          qtd_reservada
     INTO p_qtd_sdo_est
     FROM estoque
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_item_ordem
   
   IF STATUS = 100  THEN
      LET p_qtd_sdo_est = 0
   ELSE
      IF STATUS <> 0  THEN
         ERROR 'Item:',p_item_ordem
         CALL log003_err_sql('Lendo','estoque')
         RETURN FALSE
      END IF
   END IF
       
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol0923_del_ocs()
#------------------------#

   DELETE FROM ordem_sup
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = p_item_ordem
      AND ies_situa_oc = 'P'

   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Deletando', 'ordens planejadas')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol0923_le_ocs()
#------------------------#

   SELECT SUM(qtd_solic - qtd_recebida)
     INTO p_qtd_sdo_oc
     FROM ordem_sup
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item       = p_item_ordem
      AND cod_fornecedor <> ' '
      AND qtd_solic      > qtd_recebida
      AND ies_situa_oc   NOT IN ('C','L','S')
      AND ies_versao_atual = 'S'
      
      {AND num_pedido   > 0
      AND num_pedido IN
          (SELECT num_pedido FROM pedido_sup
            WHERE cod_empresa = p_cod_empresa
              AND ies_situa_ped <> 'C')}
     
   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Lendo', 'ordem_sup')
      RETURN FALSE
   END IF
   
   IF p_qtd_sdo_oc IS NULL THEN
      LET p_qtd_sdo_oc = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0923_gera_ops()
#--------------------------#

   IF NOT pol0923_deleta_ops() THEN
      RETURN FALSE
   END IF
         
   DECLARE cq_op CURSOR FOR
    SELECT cod_item_pai,
           cod_item,
           tip_item,
           qtd_prodcomp,
           gerar
      FROM estrut_tmp_304
     WHERE tip_item    <> 'T'
       AND qtd_prodcomp > 0
       AND gerar = 'OP'
   
   FOREACH cq_op INTO 
           p_cod_item_pai,
           p_item_ordem, 
           p_ies_tip_item,
           p_qtd_prodcomp, 
           p_gerar

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_tmp_304:cq_op')
         RETURN FALSE
      END IF

      LET p_qtd_ordem = p_qtd_prodcomp * p_qtd_sdo_ped

      LET p_cod_item = p_item_ordem

      IF NOT pol0923_le_sdo_op() THEN
         RETURN FALSE
      END IF
      
      LET p_qtd_ordem = p_qtd_ordem - p_qtd_sdo_ord
      
      IF p_qtd_ordem  <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0923_le_item_man() THEN
         RETURN FALSE
      END IF 
      
      CALL pol0923_grava_op() RETURNING p_status
      
      IF NOT p_status THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0923_grava_op()
#-------------------------#

   IF NOT pol0923_insere_ordens() THEN
      RETURN FALSE
   END IF      

   IF NOT pol0923_insere_op_compl() THEN
      RETURN FALSE
   END IF

   IF NOT pol0923_le_compon() THEN
      RETURN FALSE
   END IF      
   
   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol0923_insere_ordens()
#-------------------------------#

   IF NOT pol0923_prx_num_op() THEN
      RETURN FALSE
   END IF

   INITIALIZE p_ordens TO NULL

   LET p_ordens.cod_empresa        = p_cod_empresa
   LET p_ordens.num_ordem          = p_prx_num_op
   LET p_ordens.num_neces          = 0
   LET p_ordens.num_versao         = 0
   LET p_ordens.cod_item           = p_item_ordem
   LET p_ordens.cod_item_pai       = p_cod_item_pai
   LET p_ordens.dat_entrega        = p_prz_entrega
   LET p_ordens.dat_abert          = TODAY
   LET p_ordens.dat_liberac        = TODAY
   LET p_ordens.qtd_planej         = p_qtd_ordem
   LET p_ordens.pct_refug          = 0
   LET p_ordens.qtd_boas           = 0
   LET p_ordens.qtd_refug          = 0
   LET p_ordens.qtd_sucata         = 0
   LET p_ordens.cod_local_prod     = p_item_man.cod_local_prod
   LET p_ordens.cod_local_estoq    = p_cod_local
   LET p_ordens.num_docum          = p_num_docum
   LET p_ordens.ies_lista_ordem    = '2'
   LET p_ordens.ies_lista_roteiro  = p_item_man.ies_lista_roteiro
   LET p_ordens.ies_origem         = 'H'
   LET p_ordens.ies_situa          = '1'
   LET p_ordens.ies_abert_liber    = p_item_man.ies_abert_liber
   LET p_ordens.ies_baixa_comp     = p_item_man.ies_baixa_comp
   LET p_ordens.ies_apontamento    = p_item_man.ies_apontamento
   LET p_ordens.dat_atualiz        = TODAY
   LET p_ordens.num_lote           = p_num_docum
   LET p_ordens.cod_roteiro        = p_item_man.cod_roteiro
   LET p_ordens.num_altern_roteiro = p_item_man.num_altern_roteiro

   INSERT INTO ordens VALUES (p_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','Ordens')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0923_le_item_man()
#-----------------------------#

   SELECT *
     INTO p_item_man.*
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF
   
   SELECT cod_local_estoq
     INTO p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem
     
   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Lendo','item:2')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol0923_prx_num_op()
#----------------------------#

   SELECT prx_num_ordem
     INTO p_prx_num_op
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_op')
      RETURN FALSE
   END IF

   IF p_prx_num_op IS NULL THEN
      LET p_prx_num_op = 1
   ELSE
      LET p_prx_num_op = p_prx_num_op + 1
   END IF

   UPDATE par_mrp
      SET prx_num_ordem = p_prx_num_op
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_op')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0923_prx_num_neces()
#-------------------------------#

   SELECT prx_num_neces
     INTO p_prx_num_neces
     FROM par_mrp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','par_mrp:num_neces')
      RETURN FALSE
   END IF

   IF p_prx_num_neces IS NULL THEN
      LET p_prx_num_neces = 0
   ELSE
      LET p_prx_num_neces = p_prx_num_neces + 1
   END IF
   
   UPDATE par_mrp
      SET prx_num_neces = p_prx_num_neces
    WHERE cod_empresa   = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Update','par_mrp:num_neces')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol0923_insere_op_compl()
#---------------------------------#

   INITIALIZE p_op_compl  TO NULL

   LET p_op_compl.cod_empresa    = p_ordens.cod_empresa
   LET p_op_compl.num_ordem      = p_ordens.num_ordem
   LET p_op_compl.cod_grade_1    = " "
   LET p_op_compl.cod_grade_2    = " "
   LET p_op_compl.cod_grade_3    = " "
   LET p_op_compl.cod_grade_4    = " "
   LET p_op_compl.cod_grade_5    = " "
   LET p_op_compl.num_lote       = p_ordens.num_lote
   LET p_op_compl.ies_tipo       = "N"
   LET p_op_compl.num_prioridade = 9999

   INSERT INTO ordens_complement VALUES (p_op_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','ordens_complement')
      RETURN  FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0923_le_compon()
#-----------------------------#
   
   LET p_hoje = TODAY 
   
   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_ordens.cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= p_hoje) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= p_hoje )OR
            (p_hoje BETWEEN dat_validade_ini AND dat_validade_fim))
       
   FOREACH cq_compon INTO p_cod_item_compon, p_qtd_necessaria

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrutura:cq_compon')
         RETURN FALSE
      END IF
      
      IF NOT pol0923_le_tip_item(p_cod_item_compon) THEN
         RETURN FALSE
      END IF

      IF p_ies_tip_item  = "T"  THEN
         LET p_cod_fantasma = p_cod_item_compon
         IF NOT pol0923_trata_fantasma() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0923_insere_necessidades() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------------#          
FUNCTION pol0923_trata_fantasma()
#--------------------------------#
   
   LET p_hoje = TODAY
   
   DECLARE cq_fantasma   CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_cod_fantasma
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= p_hoje) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= p_hoje )OR
            (p_hoje BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_fantasma INTO p_cod_item_compon, p_qtd_necessaria

      IF NOT pol0923_insere_necessidades() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0923_insere_necessidades()
#-------------------------------------#

   IF NOT pol0923_prx_num_neces() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE p_necessidades TO NULL

   LET p_necessidades.cod_empresa      = p_ordens.cod_empresa
   LET p_necessidades.num_neces        = p_prx_num_neces
   LET p_necessidades.num_versao       = p_ordens.num_versao
   LET p_necessidades.cod_item_pai     = p_ordens.cod_item
   LET p_necessidades.cod_item         = p_cod_item_compon
   LET p_necessidades.qtd_necessaria   = p_ordens.qtd_planej * p_qtd_necessaria
   LET p_necessidades.num_ordem        = p_ordens.num_ordem
   LET p_necessidades.qtd_saida        = 0
   LET p_necessidades.num_docum        = p_ordens.num_docum
   LET p_necessidades.dat_neces        = p_ordens.dat_entrega
   LET p_necessidades.ies_origem       = p_ordens.ies_origem
   LET p_necessidades.ies_situa        = p_ordens.ies_situa
   LET p_necessidades.num_neces_consol = 0

   INSERT INTO necessidades  VALUES (p_necessidades.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','Necessidades')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0923_gera_ocs()
#--------------------------#

   DEFINE p_qtd_solic LIKE ordem_sup.qtd_solic

   DECLARE cq_gera CURSOR FOR
    SELECT cod_compon, 
           sum(qtd_saldo * qtd_necessaria)
      FROM pedido_oc_304
     WHERE cod_empresa = p_cod_empresa
     GROUP BY cod_compon
 
   FOREACH cq_gera INTO 
           p_item_ordem, 
           p_qtd_ordem

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor cq_ocs')
         RETURN FALSE
      END IF
      
      IF NOT pol0923_le_estoque() THEN
         RETURN FALSE
      END IF

      IF NOT pol0923_le_item_sup() THEN
         RETURN FALSE
      END IF

      IF NOT pol0923_del_ocs() THEN
         RETURN FALSE
      END IF

      IF NOT pol0923_le_ocs() THEN
         RETURN FALSE
      END IF

      LET p_qtd_ordem = p_qtd_ordem + m_qtd_estoq_seg - p_qtd_sdo_est - p_qtd_sdo_oc
      
      IF p_qtd_ordem <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_ordem < m_qtd_lote_minimo THEN
         LET p_qtd_ordem = m_qtd_lote_minimo
      END IF
      
      INITIALIZE m_prx_num_oc, p_num_oc TO NULL
      
      DECLARE cq_first CURSOR FOR
      SELECT num_oc
        FROM ordem_sup
       WHERE cod_empresa    = p_cod_empresa
         AND cod_item       = p_item_ordem
         AND ies_situa_oc   = 'A'
         AND cod_fornecedor = ' ' 
         AND ies_versao_atual = 'S'
       ORDER BY num_oc

      FOREACH cq_first INTO m_prx_num_oc
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'ordem_sup')
            RETURN FALSE
         END IF
         
         IF p_num_oc IS NULL THEN
            LET p_num_oc = m_prx_num_oc
         ELSE
            DELETE FROM ordem_sup
             WHERE cod_empresa = p_cod_empresa
               AND num_oc      = m_prx_num_oc
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Deletando', 'ordem_sup')
               RETURN FALSE
            END IF
         END IF
                 
      END FOREACH
      
      LET m_prx_num_oc = p_num_oc 
      
      IF m_prx_num_oc IS NULL THEN
         CALL pol0923_grava_oc() RETURNING p_status
      ELSE
         CALL pol0923_atualiza_oc() RETURNING p_status
      END IF
      
      IF NOT p_status THEN
         RETURN TRUE
      END IF

      IF NOT pol0923_atu_pedido_oc_304() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0923_atualiza_oc()
#----------------------------#

   UPDATE ordem_sup
      SET qtd_solic = p_qtd_ordem
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = m_prx_num_oc
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando', 'ordem_sup')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0923_atu_pedido_oc_304()
#-----------------------------------#

   DEFINE p_num_pedido, p_num_seq INTEGER

   UPDATE pedido_oc_304
      SET num_oc = m_prx_num_oc
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon  = p_item_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando', 'pedido_oc_304')
      RETURN FALSE
   END IF

   DECLARE cq_304 CURSOR FOR
    SELECT num_pedido,
           num_sequencia
      FROM pedido_oc_304
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon  = p_item_ordem

   FOREACH cq_304 INTO p_num_pedido, p_num_seq
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cq_304')
         RETURN FALSE
      END IF
   
      SELECT cod_empresa
        FROM pedido_mrp_304
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
         AND num_seq     = p_num_seq
         #AND num_oc      = m_prx_num_oc
      
      IF STATUS = 100 THEN
         INSERT INTO pedido_mrp_304
          VALUES(p_cod_empresa, p_num_pedido, p_num_seq, m_prx_num_oc)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo', 'pedido_mrp_304')
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'pedido_mrp_304')
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0923_grava_oc()
#--------------------------#

   INITIALIZE p_ordem_sup, 
              p_prog_ordem_sup, 
              p_dest_ordem_sup,
              p_estr_ordem_sup TO NULL

   IF NOT pol0923_le_par_compl() THEN
      RETURN FALSE
   END IF 
     
   IF pol0923_prx_num_oc() = FALSE THEN
      RETURN FALSE
   END IF
   
   IF pol0923_insere_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF pol0923_insere_prog_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF pol0923_insere_dest_oc() = FALSE THEN
      RETURN FALSE
   END IF

   IF p_ies_tip_item = 'B' THEN
      IF pol0923_insere_estrut() = FALSE THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
 FUNCTION pol0923_prx_num_oc()
#----------------------------#
   LET m_prx_num_oc = 0

   SELECT prx_num_oc
     INTO m_prx_num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','par_sup')
      RETURN FALSE
   END IF

   IF m_prx_num_oc IS NULL THEN
      LET m_prx_num_oc = 0
   END IF

   UPDATE par_sup
      SET prx_num_oc = m_prx_num_oc + 1
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','par_sup')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol0923_insere_oc()
#---------------------------#

   SELECT cod_progr INTO m_cod_progr
     FROM programador
    WHERE cod_empresa = p_cod_empresa
      AND login       = p_user
   
   IF STATUS <> 0 THEN
      LET m_cod_progr = 0
   END IF

   LET p_ordem_sup.cod_empresa        = p_cod_empresa
   LET p_ordem_sup.num_oc             = m_prx_num_oc
   LET p_ordem_sup.num_versao         = 0
   LET p_ordem_sup.num_versao_pedido  = 0
   LET p_ordem_sup.ies_versao_atual   = 'S'
   LET p_ordem_sup.cod_item           = p_item_ordem
   LET p_ordem_sup.num_pedido         = 0
   LET p_ordem_sup.ies_situa_oc       = 'P'
   LET p_ordem_sup.ies_origem_oc      = 'H'
   LET p_ordem_sup.ies_item_estoq     = 'S' 
   LET p_ordem_sup.ies_imobilizado    = 'N'
   LET p_ordem_sup.cod_unid_med       = m_cod_unid_med
   LET p_ordem_sup.dat_emis           = TODAY
   LET p_ordem_sup.qtd_solic          = p_qtd_ordem
   LET p_ordem_sup.dat_entrega_prev   = p_prz_entrega - p_qtd_dias
   LET p_ordem_sup.fat_conver_unid    = 1
   LET p_ordem_sup.qtd_recebida       = 0
   LET p_ordem_sup.pre_unit_oc        = 0
   LET p_ordem_sup.pct_ipi            = m_pct_ipi
   LET p_ordem_sup.cod_moeda          = 1
   LET p_ordem_sup.cod_fornecedor     = ' '
   LET p_ordem_sup.cnd_pgto           = 0
   LET p_ordem_sup.cod_mod_embar      = 0
   LET p_ordem_sup.num_docum          = p_num_docum
   LET p_ordem_sup.gru_ctr_desp       = m_gru_ctr_desp
   LET p_ordem_sup.cod_secao_receb    = " "
   LET p_ordem_sup.cod_progr          = m_cod_progr
   LET p_ordem_sup.cod_comprador      = m_cod_comprador
   LET p_ordem_sup.pct_aceite_dif     = 0
   LET p_ordem_sup.ies_tip_entrega    = 'D'
   LET p_ordem_sup.ies_liquida_oc     = '2'
   LET p_ordem_sup.dat_abertura_oc    = TODAY
   LET p_ordem_sup.num_oc_origem      = m_prx_num_oc
   LET p_ordem_sup.qtd_origem         = p_qtd_ordem
   LET p_ordem_sup.ies_tip_incid_ipi  = m_ies_tip_incid_ipi
   LET p_ordem_sup.ies_tip_incid_icms = m_ies_tip_incid_icms
   LET p_ordem_sup.cod_fiscal         = m_cod_fiscal
   LET p_ordem_sup.cod_tip_despesa    = m_cod_tip_despesa
   LET p_ordem_sup.ies_insp_recebto   = '4'

   INSERT INTO ordem_sup VALUES (p_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inderindo','ordem_sup')
      RETURN  FALSE
   END IF

   {LET p_texto = ?

   INSERT INTO ordem_sup_txt
     VALUES(p_ordem_sup.cod_empresa,
            p_ordem_sup.num_oc,
            "O",
            1,
            p_texto)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Inclusão","ordem_sup_txt")       
      RETURN FALSE
   END IF}

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0923_insere_prog_oc()
#--------------------------------#
   LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
   LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
   LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao
   LET p_prog_ordem_sup.num_prog_entrega = 1
   LET p_prog_ordem_sup.ies_situa_prog   = p_ordem_sup.ies_situa_oc
   LET p_prog_ordem_sup.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.qtd_solic        = p_ordem_sup.qtd_solic
   LET p_prog_ordem_sup.qtd_recebida     = p_ordem_sup.qtd_recebida
   LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_abertura_oc

   INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','prog_ordem_sup')
      RETURN FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0923_insere_dest_oc()
#--------------------------------#
   LET p_dest_ordem_sup.cod_empresa        = p_ordem_sup.cod_empresa
   LET p_dest_ordem_sup.num_oc             = p_ordem_sup.num_oc
   LET p_dest_ordem_sup.cod_area_negocio   = 0
   LET p_dest_ordem_sup.cod_lin_negocio    = 0
   LET p_dest_ordem_sup.pct_particip_comp  = 100
   LET p_dest_ordem_sup.cod_secao_receb    = p_ordem_sup.cod_secao_receb
   LET p_dest_ordem_sup.num_conta_deb_desp = m_num_conta
   LET p_dest_ordem_sup.qtd_particip_comp  = p_ordem_sup.qtd_solic
   LET p_dest_ordem_sup.num_transac        = 0

   INSERT INTO dest_ordem_sup VALUES (p_dest_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','dest_ordem_sup')
      RETURN  FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol0923_insere_estrut()
#-------------------------------#
   
   LET p_hoje = TODAY 
   
   DECLARE cq_estr CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_ordem_sup.cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= p_hoje) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= p_hoje )OR
            (p_hoje BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_estr INTO 
           p_estr_ordem_sup.cod_item_comp,
           p_estr_ordem_sup.qtd_necessaria,
           p_pct_refug

      LET p_estr_ordem_sup.cod_empresa    = p_ordem_sup.cod_empresa
      LET p_estr_ordem_sup.num_oc         = p_ordem_sup.num_oc
      LET p_estr_ordem_sup.qtd_necessaria = p_estr_ordem_sup.qtd_necessaria +
          (p_estr_ordem_sup.qtd_necessaria * p_pct_refug / 100)
      
      INSERT INTO estrut_ordem_sup VALUES (p_estr_ordem_sup.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','estrut_ordem_sup')
         RETURN  FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0923_le_item_sup()
#-----------------------------#
   
   SELECT cod_comprador,
          cod_progr,
          gru_ctr_desp,
          num_conta,
          cod_tip_despesa,
          ies_tip_incid_icms,
          ies_tip_incid_ipi,
          cod_fiscal,
          qtd_lote_minimo,
          qtd_estoq_seg
     INTO m_cod_comprador,
          m_cod_progr,
          m_gru_ctr_desp,
          m_num_conta,
          m_cod_tip_despesa,
          m_ies_tip_incid_icms,
          m_ies_tip_incid_ipi,
          m_cod_fiscal,
          m_qtd_lote_minimo,
          m_qtd_estoq_seg
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR 'Item:',p_item_ordem
      CALL log0030_mensagem("Item Não Localizado na Tab. item_sup","exclamation")
      RETURN FALSE
   END IF

   IF m_num_conta IS NULL THEN
      LET m_num_conta = 0
   END IF

   IF m_gru_ctr_desp IS NULL THEN 
      LET m_gru_ctr_desp = 0
   END IF

{   IF m_cod_progr = 0 THEN 
      LET p_msg = "item_sup.cod_progr = 0 - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF
  
   IF m_cod_tip_despesa = 0 THEN
      LET p_msg = "item_sup.cod_tip_despesa = 0 - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_ies_tip_incid_icms IS NULL THEN
      LET p_msg = "item_sup.ies_tip_incid_icms = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_ies_tip_incid_ipi IS NULL THEN
      LET p_msg = "item_sup.ies_tip_incid_ipi = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF

   IF m_cod_fiscal IS NULL THEN
      LET p_msg = "item_sup.cod_fiscal = nulo - item:",p_item_ordem
      CALL log0030_mensagem(p_msg,"exclamation")
      RETURN FALSE
   END IF
}

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0923_le_par_compl()
#------------------------------#

   SELECT pct_ipi, 
          cod_unid_med
     INTO m_pct_ipi, 
          m_cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Lendo','item:und')
      RETURN FALSE
   END IF

   SELECT cod_horizon
     INTO p_cod_horizon
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ordem

   IF STATUS <> 0 THEN
      ERROR 'Item:',p_item_ordem
      CALL log003_err_sql('Lendo','item_man:oc')
      RETURN FALSE
   END IF
   
   SELECT qtd_dias_horizon
     INTO p_qtd_dias
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0923_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----FIM DO PROGRAMA------#
