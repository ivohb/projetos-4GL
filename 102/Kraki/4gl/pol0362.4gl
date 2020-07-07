#---------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                           #
# PROGRAMA: POL0362                                                   #
# OBJETIVO: PROGRAMA PARA GERAR ORDEM DE MONTAGEM - KRAKI             #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR              # 
# DATA....: 01/09/2005                                                #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa, 
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_msg               CHAR(300),
         p_cod_cliente       LIKE clientes.cod_cliente,
         p_cod_nat_oper      LIKE nat_operacao.cod_nat_oper,
         p_cod_nat_oper_it   LIKE nat_operacao.cod_nat_oper,
         p_num_pedido        LIKE pedidos.num_pedido,
         p_texto             LIKE audit_vdp.texto,   
         p_count             SMALLINT,
         p_status            SMALLINT,
         p_ies_impressao     CHAR(01),
         p_grava             CHAR(01),
         comando             CHAR(80),
         p_comando           CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_versao            CHAR(18),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         g_ies_ambiente      CHAR(001),
         p_caminho           CHAR(080)
          
END GLOBALS

   DEFINE mr_tela              RECORD
         cod_empresa         LIKE empresa.cod_empresa,
         num_pedido          LIKE pedidos.num_pedido,
         entrega_ate         LIKE ped_itens.prz_entrega,
         cod_cliente         LIKE clientes.cod_cliente,
         nom_cliente         LIKE clientes.nom_cliente 
                              END RECORD

   DEFINE ma_tela    ARRAY[100] OF RECORD
         num_sequencia          LIKE ped_itens.num_sequencia,
         den_item_reduz         LIKE item.den_item_reduz, 
         qtd_saldo              LIKE ped_itens.qtd_pecas_solic,
         qtd_reservada          LIKE ped_itens.qtd_pecas_solic,
         qtd_estoque            LIKE ped_itens.qtd_pecas_solic
                     END RECORD

   DEFINE ma_tela1   ARRAY[100] OF RECORD
      cod_item                  LIKE item.cod_item
                     END RECORD
      
   DEFINE mr_ordem_montag_mest  RECORD LIKE ordem_montag_mest.*,
          mr_ordem_montag_item  RECORD LIKE ordem_montag_item.*,
          mr_ordem_montag_grade RECORD LIKE ordem_montag_grade.*,
          mr_estoque_operac     RECORD LIKE estoque_operac.*,
          mr_nat_operacao       RECORD LIKE nat_operacao.*,
          mr_pedidos            RECORD LIKE pedidos.*

   DEFINE m_informou            SMALLINT,
          m_ind                 SMALLINT,
          m_houve_erro          SMALLINT,
          m_cond_carteira       CHAR(70),
          m_cond_repres         CHAR(100) 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   LET p_versao = "POL0362-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0362.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      INITIALIZE mr_tela.* TO NULL
      INITIALIZE ma_tela TO NULL
      CALL pol0362_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0362_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0362") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0362 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa data parametros para processamento."           
         HELP 002
         MESSAGE ""
         LET int_flag = 0
         IF log005_seguranca(p_user,"VDP","POL0362","CO") THEN
            IF pol0362_informa_dados() THEN
               IF pol0362_informa_quantidades() THEN
                  NEXT OPTION "Processar"
               ELSE
                  ERROR "Função Cancelada"
               END IF
            ELSE
               ERROR "Função Cancelada"
            END IF
         END IF
      
      COMMAND "Processar" "Processa a Criação da OM."         
         HELP 002
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","POL0362","CO") THEN
            IF m_informou THEN
               IF log004_confirm(21,45) THEN
                  IF pol0362_processa() THEN
                     NEXT OPTION "Informar"
                  ELSE
                     CALL log0030_mensagem("Ocorreu erros no processamento, Não foi Gerada OM.","stop")   
                  END IF
               END IF
            ELSE
               ERROR "Informe dados para processamento"
               NEXT OPTION "Informar"
            END IF
         END IF

      COMMAND "Cliente X Pedido"  "Abre tela de geração por Cliente/Pedido."
         HELP 0000
         MESSAGE ""
         LET int_flag = 0
         CALL log120_procura_caminho("VDP1906") RETURNING p_comando
         LET p_comando = p_comando CLIPPED, " ",mr_pedidos.cod_cliente
         RUN p_comando
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0362_sobre()       
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
         
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0362
   
END FUNCTION

#-----------------------#
FUNCTION pol0362_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND
   
   LET p_dat = CURRENT
   
   LET p_msg = p_versao CLIPPED,"\n\n",
               " Alteração: ",p_dat,"\n\n",
               " LOGIX 05.10 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
 FUNCTION pol0362_informa_dados()
#-------------------------------#
   CLEAR FORM
   INITIALIZE mr_tela.*,       
              ma_tela TO NULL
   
   CALL log006_exibe_teclas("01 02",p_versao)
   CURRENT WINDOW IS w_pol0362
   LET mr_tela.cod_empresa = p_cod_empresa
 ##LET mr_tela.entrega_ate = TODAY
   
   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS
   
      AFTER FIELD num_pedido     
         IF mr_tela.num_pedido IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatório"
            NEXT FIELD num_pedido  
         ELSE 
            IF pol0362_verifica_pedido() = FALSE THEN
               NEXT FIELD num_pedido
            ELSE
               IF pol0362_verifica_saldo_pedido() = FALSE THEN
                  ERROR "Pedido sem saldo para Processar OM."
                  NEXT FIELD num_pedido  
               END IF
            END IF
         END IF
   
      AFTER FIELD entrega_ate    
         IF mr_tela.entrega_ate IS NOT NULL THEN
            IF mr_tela.entrega_ate < mr_pedidos.dat_pedido THEN
               ERROR "Data de Entrega Menor que a Data do Pedido."
               NEXT FIELD entrega_ate 
            END IF
         END IF
   
   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0362
   
   IF INT_FLAG <> 0 THEN
      RETURN FALSE 
   ELSE
      IF pol0362_busca_itens_pedido() = FALSE THEN
         LET m_informou = FALSE 
         RETURN FALSE
      ELSE
         LET m_informou = TRUE
         RETURN TRUE
      END IF
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0362_verifica_pedido() 
#---------------------------------#
   DEFINE l_nom_cliente             LIKE clientes.nom_cliente

   SELECT *
     INTO mr_pedidos.*
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = mr_tela.num_pedido

   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Pedido não Cadastrado.'
      RETURN FALSE
   END IF
  
   IF mr_pedidos.ies_sit_pedido = '9' THEN
      ERROR 'Pedido Cancelado.'
      RETURN FALSE
   END IF
      
   IF mr_pedidos.ies_sit_pedido = 'B' THEN
      ERROR 'Pedido Bloqueado.'
      RETURN FALSE
   END IF

   IF mr_pedidos.ies_sit_pedido = 'S' THEN
      ERROR 'Pedido Suspenso.'
      RETURN FALSE
   END IF
 
   IF mr_pedidos.ies_sit_pedido <> 'F' AND 
      mr_pedidos.ies_sit_pedido <> 'A' THEN
      IF pol0362_verifica_credito() = FALSE THEN
         RETURN FALSE
      END IF
   END IF
      
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_pedidos.cod_cliente

   DISPLAY mr_pedidos.cod_cliente TO cod_cliente
   DISPLAY l_nom_cliente TO nom_cliente
 
   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol0362_verifica_credito()
#----------------------------------#
   DEFINE lr_par_vdp           RECORD LIKE par_vdp.*,
          lr_cli_credito       RECORD LIKE cli_credito.*,
          l_valor_cli          DECIMAL(15,2),
          l_parametro          CHAR(1)
          
   SELECT *
     INTO lr_cli_credito.*
     FROM cli_credito
    WHERE cod_cliente = mr_pedidos.cod_cliente
      
   IF sqlca.sqlcode <> 0 THEN
      ERROR 'Cliente sem dados de crédito.'
      RETURN FALSE
   END IF

   SELECT *
     INTO lr_par_vdp.*
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF lr_par_vdp.par_vdp_txt[367] = 'S' THEN
      IF lr_cli_credito.qtd_dias_atr_dupl > lr_par_vdp.qtd_dias_atr_dupl THEN
         ERROR 'Cliente com duplicatas em atraso excedido.'
         RETURN FALSE
      END IF
      IF lr_cli_credito.qtd_dias_atr_med > lr_par_vdp.qtd_dias_atr_med THEN
         ERROR 'Cliente com atraso médio excedido.'
         RETURN FALSE
      END IF
   END IF

   SELECT par_ies
     INTO l_parametro
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'ies_limite_credito'
    
   IF l_parametro = 'S' THEN         
      LET l_valor_cli = lr_cli_credito.val_ped_carteira + lr_cli_credito.val_dup_aberto
       
      IF l_valor_cli > lr_cli_credito.val_limite_cred THEN
         ERROR 'Limite de crédito excedido.'
         RETURN FALSE
      END IF
   END IF

   IF lr_cli_credito.dat_val_lmt_cr IS NOT NULL THEN
      IF lr_cli_credito.dat_val_lmt_cr < TODAY THEN
         ERROR 'Data crédito expirada.'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0362_verifica_saldo_pedido() 
#---------------------------------------#
   DEFINE l_cod_empresa          LIKE empresa.cod_empresa

   DECLARE cq_saldo CURSOR FOR 
    SELECT a.cod_empresa
      FROM ped_itens a
     WHERE a.cod_empresa = p_cod_empresa 
       AND a.num_pedido  = mr_tela.num_pedido
       AND (a.qtd_pecas_solic - (a.qtd_pecas_atend  +
                                 a.qtd_pecas_cancel +
                                 a.qtd_pecas_reserv +
                                 a.qtd_pecas_romaneio)) > 0 
      OPEN cq_saldo
     FETCH cq_saldo INTO l_cod_empresa
  
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF  

END FUNCTION

#------------------------------------#
 FUNCTION pol0362_busca_itens_pedido()
#------------------------------------#
   DEFINE l_ind               SMALLINT,
          l_prioridade        LIKE man_prior_consumo.prioridade, 
          l_qtd_reservada     LIKE man_prior_consumo.qtd_reservada,
          sql_stmt            CHAR(1000)

   LET l_ind = 1

   LET sql_stmt = 
      " SELECT a.num_sequencia, b.den_item_reduz, ",
      "        (qtd_pecas_solic - (qtd_pecas_atend + ",
      "                            qtd_pecas_cancel + ",
      "                            qtd_pecas_reserv + ",
      "                            qtd_pecas_romaneio)), ",
      "        a.cod_item ",
      "   FROM ped_itens a, item b ",
      "  WHERE a.cod_empresa = '",p_cod_empresa,"'",
      "    AND a.num_pedido  = ",mr_tela.num_pedido,
      "    AND a.cod_empresa = b.cod_empresa ",
      "    AND a.cod_item    = b.cod_item ",
      "    AND (qtd_pecas_solic - (qtd_pecas_atend  + ",
      "                            qtd_pecas_cancel + ",
      "                            qtd_pecas_reserv + ",
      "                            qtd_pecas_romaneio)) > 0 "
      
   IF mr_tela.entrega_ate IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, "  AND a.prz_entrega <= '",mr_tela.entrega_ate,"'"
   END IF

   LET sql_stmt = sql_stmt CLIPPED, "  ORDER BY a.num_sequencia "
   
   PREPARE var_query FROM sql_stmt
   DECLARE cq_itens CURSOR FOR var_query
 
   FOREACH cq_itens INTO ma_tela[l_ind].num_sequencia,
                         ma_tela[l_ind].den_item_reduz,
                         ma_tela[l_ind].qtd_saldo,
                         ma_tela1[l_ind].cod_item
 
       SELECT (qtd_liberada - 
              (qtd_rejeitada +
               qtd_lib_excep + 
               qtd_disp_venda + 
               qtd_reservada))
         INTO ma_tela[l_ind].qtd_estoque                               
         FROM estoque
        WHERE cod_empresa   = p_cod_empresa
          AND cod_item      = ma_tela1[l_ind].cod_item
 
      IF ma_tela[l_ind].qtd_estoque IS NULL THEN
         LET ma_tela[l_ind].qtd_estoque = 0 
      END IF

      LET ma_tela[l_ind].qtd_reservada = ma_tela[l_ind].qtd_saldo
 
      LET l_ind = l_ind + 1

   END FOREACH    
   
   IF l_ind = 1 THEN
      RETURN FALSE
   ELSE 
      LET m_ind = l_ind - 1 
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol0362_informa_quantidades() 
#-------------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0362

   LET INT_FLAG =  FALSE
   CALL SET_COUNT(m_ind)

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_om.*

      BEFORE FIELD qtd_reservada 
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD qtd_reservada 
         IF ma_tela[pa_curr].qtd_reservada IS NOT NULL AND
            ma_tela[pa_curr].qtd_reservada > 0 THEN
            IF ma_tela[pa_curr].qtd_reservada > ma_tela[pa_curr].qtd_saldo THEN
               CALL log0030_mensagem("Quantidade reservada maior que saldo do item","info")
                NEXT FIELD qtd_reservada
            END IF
             IF pol0362_verifica_qtd_embal() = FALSE THEN
               CALL log0030_mensagem("Pedido padrao embal. qtd. pecas nao padrao embal.","info")
                NEXT FIELD qtd_reservada
             END IF
         END IF

      ON KEY (control-p)
         CALL pol0362_mostra_item()

   END INPUT        

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0362

   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0362_verifica_qtd_embal()
#------------------------------------#

   DEFINE l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_qtd_embal         LIKE item_embalagem.qtd_padr_embal

   WHENEVER ERROR CONTINUE
     SELECT a.qtd_padr_embal
       INTO l_qtd_padr_embal
       FROM item_embalagem a
      WHERE a.cod_empresa   = p_cod_empresa
        AND a.cod_item      = ma_tela1[pa_curr].cod_item
        AND a.ies_tip_embal IN ('I','N')
   WHENEVER ERROR STOP   
   
   LET l_qtd_embal = ma_tela[pa_curr].qtd_reservada MOD l_qtd_padr_embal
   
   IF (l_qtd_embal > 0 )
   AND (mr_pedidos.ies_embal_padrao <> '3' )  THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION
 
#--------------------------#
 FUNCTION pol0362_processa()
#--------------------------#
   DEFINE l_ind               SMALLINT,
          l_num_om            LIKE ordem_montag_mest.num_om,
          l_num_lote          LIKE ordem_montag_mest.num_lote_om,
          p_pes_unit_it       LIKE item.pes_unit,
          p_pes_unit_embal    LIKE embalagem.pes_unit,
          l_qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
          l_qtd_reservada     LIKE man_prior_consumo.qtd_reservada, 
          l_qtd_reserv        LIKE man_prior_consumo.qtd_reservada,
          l_situacao_prior    LIKE man_prior_consumo.prior_atendida,
          l_cod_local_estoq   LIKE item.cod_local_estoq,
          l_num_reserva       INTEGER,
          l_cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
          l_cod_transpor      LIKE pedidos.cod_transpor,
          l_cont              SMALLINT,
          l_qtd_volume        LIKE ordem_montag_mest.qtd_volume_om,
          l_cod_embal_matriz  LIKE embalagem.cod_embal_matriz,
          l_cod_embal_int     LIKE item_embalagem.cod_embal,
          p_den_embal         LIKE embalagem.den_embal,
          p_txt_volume        CHAR(16),
          p_qtd_volume        INTEGER,
          p_tot_volume        INTEGER

   MESSAGE "Processando a Criação da OM..." ATTRIBUTE(REVERSE)
   LET l_num_lote = 0
   LET l_cont     = 0
   
   
   WHENEVER ERROR CONTINUE
   
   DROP TABLE embal_tmp

   IF STATUS = 0 OR STATUS -206 THEN 
 
      CREATE  TABLE embal_tmp(
         cod_embal CHAR(03)
         
       );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","embal_tmp")
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   # SELECT MAX(num_lote_om)
   #   INTO l_num_lote
   #   FROM ordem_montag_lote
   #  WHERE cod_empresa = p_cod_empresa
   #       
   # IF l_num_lote IS NULL THEN 
   #    LET l_num_lote = 1
   # ELSE    
   #    LET l_num_lote = l_num_lote + 1
   # END IF    
   
   SELECT MAX(num_om)
     INTO l_num_om
     FROM usuario_num_om
    WHERE cod_empresa = p_cod_empresa

   IF l_num_om IS NULL THEN
      LET l_num_om = 1
   ELSE
      LET l_num_om = l_num_om + 1
   END IF

   LET p_tot_volume = 0
   
   FOR l_ind = 1 TO 100
      IF ma_tela[l_ind].qtd_reservada IS NULL OR
         ma_tela[l_ind].qtd_reservada <= 0 THEN
         CONTINUE FOR
      END IF
      
      INITIALIZE l_cod_embal_matriz to NULL

      WHENEVER ERROR CONTINUE

      SELECT qtd_padr_embal, 
             cod_embal
        INTO l_qtd_padr_embal, 
             l_cod_embal_int
        FROM item_embalagem
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = ma_tela1[l_ind].cod_item
         AND ies_tip_embal IN ('I','N')

      IF sqlca.sqlcode <> 0 THEN   
         LET l_qtd_padr_embal = 0
         LET l_cod_embal_int  = 0
      ELSE
        SELECT cod_embal_matriz
          INTO l_cod_embal_matriz
          FROM embalagem 
         WHERE cod_embal = l_cod_embal_int
         IF sqlca.sqlcode <> 0 THEN   
            INITIALIZE l_cod_embal_matriz TO NULL
         END IF
      END IF

      IF l_qtd_padr_embal > 0 THEN
         LET l_qtd_volume = ma_tela[l_ind].qtd_reservada / l_qtd_padr_embal
      ELSE
         LET l_qtd_volume = 0
      END IF

      LET p_qtd_volume = l_qtd_volume
      LET p_txt_volume = l_qtd_volume USING '&&&&&&&&&&&&.&&&'

      IF p_txt_volume[14,16] > 0 THEN
         LET p_qtd_volume = p_qtd_volume + 1
      END IF

      SELECT pes_unit
        INTO p_pes_unit_embal
        FROM embalagem
       WHERE cod_embal = l_cod_embal_int
       
      IF STATUS <> 0 THEN
         LET p_pes_unit_embal = 0
      END IF
      
      SELECT pes_unit
        INTO p_pes_unit_it 
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela1[l_ind].cod_item

      IF l_cod_embal_matriz IS NOT NULL THEN
         LET l_cod_embal_int = l_cod_embal_matriz
      END IF 	     

      IF l_cod_embal_int <> '0' THEN
         SELECT cod_embal
           FROM embal_tmp
          WHERE cod_embal = l_cod_embal_int
         
         IF sqlca.sqlcode = NOTFOUND THEN
            INSERT INTO embal_tmp VALUES(l_cod_embal_int)
         END IF
      END IF
      
      SELECT COUNT(cod_embal)
        INTO p_count
        FROM embal_tmp
      
      IF p_count > 5 THEN
         CALL log0030_mensagem('Limite de 5 embalagens ultrapasado.','exclamation')      
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
         
      SELECT den_embal
        INTO p_den_embal
        FROM embalagem
       WHERE cod_embal = l_cod_embal_int
       
      IF STATUS <> 0 THEN
         LET p_den_embal = NULL
      END IF

      LET mr_ordem_montag_item.qtd_volume_item = p_qtd_volume
      LET mr_ordem_montag_item.cod_empresa     = p_cod_empresa
      LET mr_ordem_montag_item.num_om          = l_num_om
      LET mr_ordem_montag_item.num_pedido      = mr_tela.num_pedido
      LET mr_ordem_montag_item.num_sequencia   = ma_tela[l_ind].num_sequencia 
      LET mr_ordem_montag_item.cod_item        = ma_tela1[l_ind].cod_item
      LET mr_ordem_montag_item.qtd_reservada   = ma_tela[l_ind].qtd_reservada
      LET mr_ordem_montag_item.ies_bonificacao = 'N'
      LET mr_ordem_montag_item.pes_total_item  = 0
#          (ma_tela[l_ind].qtd_reservada * p_pes_unit_it) +
#          (ma_tela[l_ind].qtd_reservada * p_pes_unit_embal)

      WHENEVER ERROR CONTINUE
        INSERT INTO ordem_montag_item VALUES (mr_ordem_montag_item.*)
      WHENEVER ERROR STOP 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_ITEM") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF
      
      LET p_tot_volume = p_tot_volume + p_qtd_volume
      
      WHENEVER ERROR CONTINUE
        INSERT INTO ordem_montag_embal VALUES(p_cod_empresa,
                mr_ordem_montag_item.num_om,
					      1,#mr_ordem_montag_item.num_sequencia,	
                mr_ordem_montag_item.cod_item,
                l_cod_embal_int,
                mr_ordem_montag_item.qtd_volume_item,
                0,
                0,
                'T',
                1,
                1,
                mr_ordem_montag_item.qtd_reservada)
                
      WHENEVER ERROR STOP 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_EMBAL") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
   #  IF pol0362_bx_estoque() THEN
         UPDATE ped_itens 
            SET qtd_pecas_romaneio = qtd_pecas_romaneio + 
                                     mr_ordem_montag_item.qtd_reservada
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = mr_ordem_montag_item.num_pedido
           AND num_sequencia = mr_ordem_montag_item.num_sequencia
           AND cod_item      = mr_ordem_montag_item.cod_item
         WHENEVER ERROR STOP 
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("ALTERACAO","PED_ITENS") 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            RETURN FALSE
         END IF

         IF pol0362_item_estoque() THEN

            { Consistencia Para Fazer a Reserva do Produto }

            SELECT cod_movto_estoq
               INTO mr_nat_operacao.cod_movto_estoq
            FROM nat_operacao
            WHERE cod_nat_oper = mr_pedidos.cod_nat_oper
            
            IF mr_nat_operacao.cod_movto_estoq IS NOT NULL THEN
               SELECT ies_tipo,
                      ies_com_quantidade
                  INTO mr_estoque_operac.ies_tipo,
                       mr_estoque_operac.ies_com_quantidade
               FROM estoque_operac
               WHERE cod_empresa = p_cod_empresa
			 AND cod_operacao = mr_nat_operacao.cod_movto_estoq

               IF mr_estoque_operac.ies_tipo = "S" AND
                  mr_estoque_operac.ies_com_quantidade = "S" THEN

                  WHENEVER ERROR CONTINUE
                  UPDATE estoque
                     SET qtd_reservada = qtd_reservada + 
                                         mr_ordem_montag_item.qtd_reservada
                  WHERE cod_empresa = p_cod_empresa
                    AND cod_item = mr_ordem_montag_item.cod_item
                  WHENEVER ERROR STOP 
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql("ALTERACAO","ESTOQUE") 
                     CALL log085_transacao("ROLLBACK")
                  #  ROLLBACK WORK
                     RETURN FALSE
                  END IF
               END IF
            END IF
         END IF
   #  END IF
            
      INITIALIZE p_texto TO NULL
      LET p_texto = "INCLUSAO DA OM Nr.",
                    mr_ordem_montag_item.num_om CLIPPED,
                    " QTDE RESERVADA", 
                    mr_ordem_montag_item.qtd_reservada
     
      WHENEVER ERROR CONTINUE
      INSERT INTO audit_vdp VALUES(p_cod_empresa,
                                   mr_ordem_montag_item.num_pedido,
                                   "I", 
                                   "I", 
                                   p_texto,
                                   "POL0362",
                                   TODAY,
                                   CURRENT HOUR TO SECOND,
                                   p_user,
                                   0)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN
         CALL log003_err_sql("INCLUSAO","AUDIT_VDP") 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         RETURN FALSE
      END IF

      LET l_cont = l_cont + 1       
   END FOR

   IF l_cont > 0 THEN
      SELECT cod_transpor, cod_tip_carteira
         INTO l_cod_transpor, l_cod_tip_carteira
      FROM pedidos
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = mr_ordem_montag_item.num_pedido
      
      IF l_cod_transpor IS NULL THEN
         LET l_cod_transpor = '0'
      END IF
      
      LET mr_ordem_montag_mest.cod_empresa   = p_cod_empresa
      LET mr_ordem_montag_mest.num_om        = l_num_om
      LET mr_ordem_montag_mest.num_lote_om   = 0
      LET mr_ordem_montag_mest.ies_sit_om    = 'N'
      LET mr_ordem_montag_mest.cod_transpor  = NULL 
      LET mr_ordem_montag_mest.qtd_volume_om = l_qtd_volume
      LET mr_ordem_montag_mest.dat_emis      = TODAY 

      WHENEVER ERROR CONTINUE
        INSERT INTO ordem_montag_mest VALUES (mr_ordem_montag_mest.*)
      WHENEVER ERROR STOP 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","ORDEM_MONTAG_MEST") 
         CALL log085_transacao("ROLLBACK")
     #   ROLLBACK WORK
         RETURN FALSE
      END IF
      
      WHENEVER ERROR CONTINUE
        INSERT INTO om_list VALUES (p_cod_empresa,
                                    mr_ordem_montag_mest.num_om,
                                    mr_ordem_montag_item.num_pedido,
                                    TODAY,
                                    p_user)
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO","OM_LIST") 
         CALL log085_transacao("ROLLBACK")
     #   ROLLBACK WORK
         RETURN FALSE
      END IF
            
      WHENEVER ERROR CONTINUE
      SELECT cod_empresa
        FROM usuario_num_om
       WHERE cod_empresa = p_cod_empresa 
         AND nom_usuario = p_user

      IF STATUS = 0 THEN
        UPDATE usuario_num_om
           SET num_om  = l_num_om
         WHERE cod_empresa = p_cod_empresa 
           AND nom_usuario = p_user
      ELSE
         INSERT INTO usuario_num_om
          VALUES(p_cod_empresa, p_user, l_num_om, mr_ordem_montag_mest.num_lote_om)
      END IF
           
      WHENEVER ERROR STOP 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("ALTERACAO","usuario_num_om") 
         CALL log085_transacao("ROLLBACK")
     #   ROLLBACK WORK
         RETURN FALSE
      END IF
   END IF

   CALL log085_transacao("COMMIT")
#  COMMIT WORK
   
   CLEAR FORM 

   IF l_cont = 0 THEN
      CALL log0030_mensagem("Não foi Gerada OM.","stop") 
      RETURN TRUE 
   ELSE
      CALL log0030_mensagem("OM Gerada com Sucesso !!!","info")
      RETURN TRUE
   END IF    

END FUNCTION

#-----------------------------#
 FUNCTION pol0362_bx_estoque()  
#-----------------------------#
   DEFINE l_cod_nat_oper        LIKE pedidos.cod_nat_oper         
   
   LET l_cod_nat_oper =  0 

   SELECT cod_nat_oper
     INTO l_cod_nat_oper
     FROM pedidos 
   WHERE  cod_empresa  = p_cod_empresa
     AND  num_pedido   =   mr_tela.num_pedido  

    IF sqlca.sqlcode <> 0 THEN
       RETURN FALSE
    END IF

   SELECT nat_operacao.cod_movto_estoq
     FROM nat_operacao, estoque_operac
    WHERE estoque_operac.cod_empresa   = p_cod_empresa
      AND estoque_operac.cod_operacao  = nat_operacao.cod_movto_estoq
      AND nat_operacao.cod_movto_estoq is not null
      AND nat_operacao.cod_nat_oper = l_cod_nat_oper

    IF sqlca.sqlcode <> 0 THEN
       RETURN FALSE
    END IF
        
    RETURN TRUE 

END FUNCTION
#-----------------------------#
 FUNCTION pol0362_item_estoque()  
#-----------------------------#
   DEFINE l_ies_ctr_est CHAR(01)

   LET l_ies_ctr_est    =  'N'

   SELECT ies_ctr_estoque
     INTO l_ies_ctr_est 
     FROM item
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = mr_ordem_montag_item.cod_item

    IF sqlca.sqlcode <> 0 THEN
       RETURN FALSE
    END IF
        
    IF  l_ies_ctr_est  <>  'S'   THEN 
        RETURN FALSE
    END IF

    RETURN TRUE 

END FUNCTION
#-----------------------------#
 FUNCTION pol0362_mostra_item()
#-----------------------------#
   DEFINE l_r           CHAR(01)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol03621") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol03621 AT 8,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY ma_tela1[pa_curr].* TO s_item[sc_curr].*

   PROMPT "Digite Enter p/ Retornar." FOR l_r

   CLOSE WINDOW w_pol03621
   CURRENT WINDOW IS w_pol0362

END FUNCTION 
