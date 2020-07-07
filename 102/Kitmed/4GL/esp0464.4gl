#-------------------------------------------------------------#
# OBJETIVO: MANUTENCAO DE PEDIDOS (LOGIX E WEB SIMULTANEOS)   #
#-------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_cliente       LIKE clientes.nom_cliente,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_tela_nom          CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT,
         p_den_item_reduz    LIKE item.den_item_reduz

   DEFINE p_tela RECORD
         cod_empresa       LIKE  pedidos.cod_empresa,
         num_pedido        LIKE  pedidos.num_pedido,
         num_pedido_cli    LIKE  pedidos.num_pedido_cli,
         cod_cliente       LIKE  pedidos.cod_cliente,
         nom_cliente       LIKE  clientes.nom_cliente
   END RECORD
         
   DEFINE p_ped_itens  ARRAY[200] OF RECORD
                        ies_acao          CHAR(02),
                        num_sequencia     LIKE ped_itens.num_sequencia,
                        cod_item          LIKE ped_itens.cod_item,
                        den_item          CHAR(41), 
                        qtd_pecas_solic   LIKE ped_itens.qtd_pecas_solic 
   END RECORD

   DEFINE p_compl_it  ARRAY[200] OF RECORD
                        qtd_pecas_cancel   LIKE ped_itens.qtd_pecas_cancel,
                        qtd_somar          LIKE ped_itens.qtd_pecas_cancel,
                        cod_it_novo        LIKE ped_itens.cod_item,
                        ies_ped            CHAR(01),
                        den_obs            CHAR(70),
                        qtd_cancel_tot     LIKE ped_itens.qtd_pecas_cancel,
                        pre_unit           LIKE desc_preco_item.pre_unit                      
   END RECORD

   DEFINE p_ped_it_ant  ARRAY[200] OF RECORD
                        qtd_saldo          LIKE ped_itens.qtd_pecas_cancel,
                        cod_item           LIKE ped_itens.cod_item,
                        pre_unit           LIKE desc_preco_item.pre_unit      
   END RECORD


   DEFINE p_tela1 RECORD
         cod_item          LIKE ped_itens.cod_item,
         den_item          CHAR(41), 
         qtd_pecas_solic   LIKE ped_itens.qtd_pecas_solic,
         qtd_pecas_cancel  LIKE ped_itens.qtd_pecas_cancel,
         qtd_somar         LIKE ped_itens.qtd_pecas_cancel,
         den_obs           CHAR(70)  
   END RECORD

   DEFINE p_tela2 RECORD
         cod_item          LIKE ped_itens.cod_item,
         den_item          CHAR(41), 
         qtd_pecas_solic   LIKE ped_itens.qtd_pecas_solic,
         qtd_pecas_cancel  LIKE ped_itens.qtd_pecas_cancel,
         cod_it_novo       LIKE ped_itens.cod_item,
         ies_ped           CHAR(01),
         den_obs           CHAR(70)  
   END RECORD

   DEFINE p_pedido RECORD
          pedido_venda       INTEGER,
          planta             CHAR(5),
          num_ped_terceiro   CHAR(12),
          terceiro           CHAR(15), 
          programa_coleta    INTEGER,
          cliente_terceiro   CHAR(15), 
          restricao          INTEGER,
          rota               INTEGER,
          dat_entrega        DATE, 
          dat_emissao        DATE, 
          dat_inclusao       DATE, 
          sit_pedido_venda   CHAR(1), 
          dat_sit_ped_venda  DATE, 
          usuario            CHAR(12), 
          qtd_item           INTEGER,
          qtd_item_volume    INTEGER,
          qtd_item_atendido  INTEGER,
          qtd_item_cancelado INTEGER,
          cancel_exped       CHAR(1),
          cnpj_cliente       DECIMAL(15,0),
          cliente_interno    CHAR(15),
          lote_transf        DECIMAL(15,0),
          transportadora     CHAR(15),
          consignatario      CHAR(15),
          tip_entrega        CHAR(1),
          cliente_origem     CHAR(15),
          origem_pedido      CHAR(1), 
          sequencia_entrega  INTEGER,
          fatura_antecip     CHAR(1), 
          viagem             INTEGER,
          tip_proc_ped_venda CHAR(1),
          vago_1             CHAR(1),
          tip_cnfr_exped     CHAR(1),
          pedido_embalagem   CHAR(1)
      END RECORD

DEFINE p_ind                 INTEGER,
       pa_curr               SMALLINT,
       sc_curr               SMALLINT,
       p_count               SMALLINT,
       p_num_ped_wms         INTEGER,
       p_num_ped             INTEGER,
       p_num_ped_ter         CHAR(07),
       p_seq_ter             DECIMAL(3),
       p_desc                CHAR(12),
       p_num_ped_novo        INTEGER,
       p_des_erro            CHAR(50),
       p_num_seq             INTEGER,
       p_num_seqw            INTEGER,
       p_cod_item_num        INTEGER,
       p_item_novo_num       INTEGER,
       p_lote                INTEGER,                    
       p_dat_entrega         DATE,              
       p_dat_cur             DATETIME YEAR TO SECOND,
       p_qtd_cancel_tot      LIKE ped_itens.qtd_pecas_cancel, 
       p_pre_unit            LIKE desc_preco_item.pre_unit,
       p_cod_nat_oper_refer  LIKE nat_oper_refer.cod_nat_oper_refer,
       p_cod_uni_feder       CHAR(02),                     
       p_tip_cnfr_exped      CHAR(01),
       p_item_wms            INTEGER,
       sql_prep              CHAR(350),
       sql_prep1             CHAR(600),
       p_num_ped_par         INTEGER, 
       p_ind_pari            INTEGER,
       p_ind_parf            INTEGER,
       p_den_par             CHAR(06),
       p_msg_fim             CHAR(70),
       p_seq_terc            CHAR(30)

DEFINE p_audit_ped_ktm   RECORD
       cod_empresa        CHAR(05),
       num_ped_ant        DECIMAL(6,0),
       num_ped_atu        DECIMAL(6,0),
       cod_item_ant       CHAR(15),
       cod_item_atu       CHAR(15),
       qtd_pecas_ant      DECIMAL(10,3),
       qtd_pecas_atu      DECIMAL(10,3),
       pre_unit_ant       DECIMAL(17,6),  
       pre_unit_atu       DECIMAL(17,6),
       fat_conv_ant       DECIMAL(9,6),
       fat_conv_atu       DECIMAL(9,6),
       texto              CHAR(200),
       data               DATE,
       hora               CHAR(08),
       usuario            CHAR(12) 
     END RECORD           
         
  DEFINE p_pedidos           RECORD LIKE pedidos.*,    
         p_ped_its           RECORD LIKE ped_itens.*,
         p_ped_it_txt        RECORD LIKE ped_itens_texto.*,
         p_audit_vdp         RECORD LIKE audit_vdp.*,    
         p_item              RECORD LIKE item.*
END GLOBALS

MAIN
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "ESP0464-05.10.15"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("esp0464.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN

###aquioooooooo
##       LET p_user = 'admlog'
##       LET p_cod_empresa = '20'
###aquioooooooo
      
      CALL esp0464_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp0464_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_tela_nom TO NULL
  CALL log130_procura_caminho("esp0464") RETURNING p_tela_nom
  LET  p_tela_nom = p_tela_nom CLIPPED 
###  LET  p_tela_nom = 'esp0464'
  OPEN WINDOW w_esp0464 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF esp0464_entrada_dados() THEN
          CALL esp0464_monta_array()
          IF p_ies_cons = TRUE THEN
             NEXT OPTION "Modificar"
          END IF
       END IF    

     COMMAND "Modificar" "Altera pedido"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF p_pedidos.num_pedido IS NOT NULL THEN
          IF esp0464_modificacao() THEN
             IF esp0464_efetiva() THEN
                INITIALIZE p_tela.*,
                           p_tela1.*,
                           p_tela2.*,
                           p_ped_itens,
                           p_seq_ter,
                           p_compl_it TO NULL 
                CLEAR FORM           
                ERROR p_msg_fim
             ELSE
                ERROR 'PROBLEMA DURANTE ALTERACAO'
             END IF 
          ELSE
             ERROR 'PROCESSO CANCELADO'
          END IF    
       ELSE
         ERROR " Consulte previamente para fazer a modificacao. "
       END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_esp0464
END FUNCTION

#--------------------------------#
 FUNCTION esp0464_entrada_dados()
#--------------------------------#

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_esp0464

  CLEAR FORM
  INITIALIZE p_tela.*,
             p_tela1.*,
             p_tela2.*,
             p_ped_itens,
             p_seq_ter,
             p_compl_it TO NULL 

  LET p_tela.cod_empresa = p_cod_empresa

  INPUT p_tela.num_pedido,
        p_tela.num_pedido_cli
   FROM num_pedido,
        num_pedido_cli

    AFTER FIELD num_pedido 
      IF p_tela.num_pedido  IS NOT NULL THEN
         IF esp0464_verifica_pedido() THEN
            DISPLAY p_tela.cod_cliente    TO cod_cliente 
            DISPLAY p_tela.nom_cliente    TO nom_cliente
            DISPLAY p_tela.num_pedido_cli TO num_pedido_cli
         ELSE 
            ERROR p_des_erro
            NEXT FIELD num_pedido  
         END IF
      END IF

    BEFORE FIELD num_pedido_cli
      IF p_tela.num_pedido IS NOT NULL THEN
         EXIT INPUT
      END IF    

    AFTER FIELD num_pedido_cli
      IF p_tela.num_pedido_cli  IS NOT NULL THEN
         IF esp0464_verifica_pedido() THEN
            DISPLAY p_tela.cod_cliente    TO cod_cliente 
            DISPLAY p_tela.nom_cliente    TO nom_cliente
            DISPLAY p_tela.num_pedido     TO num_pedido
         ELSE 
            ERROR p_des_erro
            NEXT FIELD num_pedido_cli  
         END IF
      ELSE 
         ERROR "Informe o num. do pedido ou pedido terceiro"
         NEXT FIELD num_pedido
      END IF

 END INPUT 
 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_esp0464
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#----------------------------------#
 FUNCTION esp0464_verifica_pedido()
#----------------------------------#

IF p_tela.num_pedido IS NOT NULL THEN 
   SELECT *
     INTO p_pedidos.*
     FROM pedidos
    WHERE num_pedido  = p_tela.num_pedido
      AND cod_empresa = p_cod_empresa
ELSE
   SELECT *
     INTO p_pedidos.*
     FROM pedidos
    WHERE num_pedido_cli  = p_tela.num_pedido_cli
      AND cod_empresa = p_cod_empresa
END IF 

IF sqlca.sqlcode = 0 THEN
   LET p_tela.cod_cliente    = p_pedidos.cod_cliente
   LET p_tela.num_pedido_cli = p_pedidos.num_pedido_cli
   LET p_tela.num_pedido     = p_pedidos.num_pedido 

   LET sql_prep = "SELECT MAX(pedido_venda) ",
                  "  FROM logix.wms_pedido_venda@kitwms ",
                  " WHERE num_ped_terceiro = '", p_pedidos.num_pedido_cli,"'"

   LET sql_prep = sql_prep CLIPPED

   PREPARE var_pedw FROM sql_prep

   DECLARE cq_pedw CURSOR FOR var_pedw

   FOREACH cq_pedw INTO p_num_ped_wms 
      EXIT FOREACH 
   END FOREACH

   IF p_num_ped_wms  IS NULL THEN 
      LET p_des_erro = 'Pedido com problema na integracao, nao cadastrado no WMS'
      RETURN FALSE
   END IF 
   
   LET sql_prep = "SELECT COUNT(*) ",
                  "  FROM logix.wms_sku_ped_venda@kitwms ",
                  " WHERE pedido_venda = ", p_num_ped_wms

   LET sql_prep = sql_prep CLIPPED

   PREPARE var_cped FROM sql_prep
   DECLARE c_count CURSOR FOR  var_cped
   OPEN c_count
   FETCH c_count INTO p_count
   CLOSE c_count
   FREE c_count
  
   IF p_count > 0 THEN
      LET p_des_erro = 'Pedido nao pode ser alterado, existe processso em andamento no WMS'
      RETURN FALSE
   ELSE
      SELECT nom_cliente
        INTO p_tela.nom_cliente
        FROM clientes
       WHERE cod_cliente = p_pedidos.cod_cliente   
   END IF    
ELSE
   LET p_des_erro = 'PEDIDO NAO CADASTRADO'
   RETURN FALSE
END IF

RETURN TRUE

END FUNCTION 

#--------------------------------#
 FUNCTION esp0464_monta_array()
#--------------------------------#
 DEFINE p_ind      SMALLINT
 
 LET p_ind = 1
 DECLARE cq_it CURSOR WITH HOLD FOR
 SELECT *
   FROM ped_itens
  WHERE num_pedido  = p_pedidos.num_pedido
    AND cod_empresa = p_cod_empresa
 FOREACH cq_it INTO p_ped_its.*
    LET p_ped_itens[p_ind].qtd_pecas_solic = (p_ped_its.qtd_pecas_solic - p_ped_its.qtd_pecas_atend - p_ped_its.qtd_pecas_cancel)
    IF p_ped_itens[p_ind].qtd_pecas_solic <= 0 THEN 
       CONTINUE FOREACH
    END IF    
    LET p_ped_itens[p_ind].num_sequencia   = p_ped_its.num_sequencia
    LET p_ped_itens[p_ind].cod_item        = p_ped_its.cod_item
    
    SELECT den_item
      INTO p_ped_itens[p_ind].den_item
      FROM item 
     WHERE cod_empresa = p_cod_empresa 
       AND cod_item    = p_ped_its.cod_item

    LET p_ped_it_ant[p_ind].qtd_saldo   =  p_ped_itens[p_ind].qtd_pecas_solic
    LET p_ped_it_ant[p_ind].cod_item    =  p_ped_its.cod_item
    LET p_ped_it_ant[p_ind].pre_unit    =  p_ped_its.pre_unit
   
    LET p_ind = p_ind + 1 
 END FOREACH

 LET p_ind = p_ind - 1
 CALL SET_COUNT(p_ind)
 
 DISPLAY ARRAY p_ped_itens TO s_ped_itens.* 
 END DISPLAY 

END FUNCTION 

#------------------------------#
 FUNCTION esp0464_modificacao()
#------------------------------#

   INPUT ARRAY p_ped_itens
      WITHOUT DEFAULTS FROM s_ped_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
        LET pa_curr  = ARR_CURR()
        LET sc_curr  = SCR_LINE()
        LET p_dat_cur = CURRENT   

     AFTER FIELD ies_acao
       IF p_ped_itens[pa_curr].ies_acao IS NOT NULL THEN      
          IF p_ped_itens[pa_curr].ies_acao <> 'ER' AND        
             p_ped_itens[pa_curr].ies_acao <> 'ES' AND
             p_ped_itens[pa_curr].ies_acao <> 'TT' AND
             p_ped_itens[pa_curr].ies_acao <> 'TP' THEN   
             ERROR "INFORME : ER - Erro , ES - Problema est, TT - Troca it total, TP - Troca it parcial"
             NEXT FIELD ies_acao
          END IF
          IF esp0464_verifica_pedido() THEN
          ELSE 
             ERROR p_des_erro
             EXIT INPUT 
          END IF
          IF p_ped_itens[pa_curr].ies_acao = 'ER' THEN             
             CALL esp0464_processa_erro_est()
          ELSE
             IF p_ped_itens[pa_curr].ies_acao = 'ES' THEN             
                CALL esp0464_processa_erro_est()
             ELSE
                IF p_ped_itens[pa_curr].ies_acao = 'TT' THEN             
                   CALL esp0464_processa_troca()
                ELSE
                   CALL esp0464_processa_troca()
                END IF
             END IF
          END IF         
       END IF 
   END INPUT 

 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_esp0464
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF

END FUNCTION 

#-----------------------------------#
 FUNCTION esp0464_processa_erro_est()
#-----------------------------------#
  CALL log006_exibe_teclas("01 02 07",p_versao)
  CALL log130_procura_caminho("esp04641") RETURNING p_tela_nom
  LET  p_tela_nom = p_tela_nom CLIPPED 
#  LET  p_tela_nom = 'esp04641'
  OPEN WINDOW w_esp04641 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  INPUT p_tela1.qtd_pecas_cancel,
        p_tela1.qtd_somar,
        p_tela1.den_obs
   FROM qtd_pecas_cancel,
        qtd_somar,
        den_obs

    BEFORE FIELD qtd_pecas_cancel
      LET p_tela1.cod_item = p_ped_itens[pa_curr].cod_item
      LET p_tela1.den_item = p_ped_itens[pa_curr].den_item
      LET p_tela1.qtd_pecas_solic = p_ped_itens[pa_curr].qtd_pecas_solic
      LET p_tela1.qtd_pecas_cancel  = 0
      LET p_tela1.qtd_somar  = 0
      DISPLAY p_tela1.qtd_pecas_cancel TO qtd_pecas_cancel
      DISPLAY p_tela1.qtd_somar TO qtd_somar
      DISPLAY p_tela1.cod_item TO cod_item
      DISPLAY p_tela1.den_item TO den_item
      DISPLAY p_tela1.qtd_pecas_solic TO qtd_pecas_solic

    AFTER FIELD qtd_pecas_cancel
       IF p_tela1.qtd_pecas_solic < p_tela1.qtd_pecas_cancel THEN 
          ERROR "Quantidade a cancelar nao pode ser maior que saldo do pedido"
          NEXT FIELD qtd_pecas_cancel
       ELSE
          IF p_tela1.qtd_pecas_cancel > 0 THEN 
             NEXT FIELD den_obs
          END IF    
       END IF 

    AFTER FIELD den_obs
      IF (p_tela1.qtd_pecas_cancel > 0 OR 
          p_tela1.qtd_somar > 0) AND 
          p_tela1.den_obs IS NULL  THEN
         ERROR "Informe o motivo da alteracao de quantidade"
         NEXT FIELD den_obs
      ELSE
         IF p_tela1.qtd_pecas_cancel > 0 THEN
            LET p_compl_it[pa_curr].qtd_pecas_cancel = p_tela1.qtd_pecas_cancel
            LET p_compl_it[pa_curr].qtd_somar = 0
            LET p_compl_it[pa_curr].den_obs = p_tela1.den_obs
         ELSE
            IF p_tela1.qtd_somar > 0 THEN
               LET p_compl_it[pa_curr].qtd_pecas_cancel = 0
               LET p_compl_it[pa_curr].qtd_somar = p_tela1.qtd_somar
               LET p_compl_it[pa_curr].den_obs = p_tela1.den_obs
            ELSE
               LET p_ped_itens[pa_curr].ies_acao = '  '
            END IF    
         END IF 
      END IF

 END INPUT 
 CLOSE WINDOW w_esp04641
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_esp0464
 DISPLAY p_ped_itens[pa_curr].ies_acao TO ies_acao

END FUNCTION 

#--------------------------------#
 FUNCTION esp0464_processa_troca()
#--------------------------------#
  CALL log006_exibe_teclas("01 02 07",p_versao)
  CALL log130_procura_caminho("esp04642") RETURNING p_tela_nom
  LET  p_tela_nom = p_tela_nom CLIPPED 
#  LET  p_tela_nom = 'esp04642'
  OPEN WINDOW w_esp04642 AT 2,5 WITH FORM p_tela_nom 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  INPUT p_tela2.ies_ped,
        p_tela2.cod_it_novo,
        p_tela2.qtd_pecas_cancel,
        p_tela2.den_obs
   FROM ies_ped, 
        cod_it_novo,
        qtd_pecas_cancel,
        den_obs

    BEFORE FIELD ies_ped
      LET p_tela2.cod_item = p_ped_itens[pa_curr].cod_item
      LET p_tela2.den_item = p_ped_itens[pa_curr].den_item
      LET p_tela2.qtd_pecas_solic  = p_ped_itens[pa_curr].qtd_pecas_solic
      LET p_tela2.qtd_pecas_cancel = 0
      DISPLAY p_tela2.qtd_pecas_cancel TO qtd_pecas_cancel
      DISPLAY p_tela2.cod_item TO cod_item
      DISPLAY p_tela2.den_item TO den_item
      DISPLAY p_tela2.qtd_pecas_solic TO qtd_pecas_solic
      IF p_ped_itens[pa_curr].ies_acao = 'TT' THEN 
         LET p_tela2.qtd_pecas_cancel  = p_tela2.qtd_pecas_solic
         LET p_tela2.ies_ped = 'N'
         DISPLAY p_tela2.qtd_pecas_cancel TO qtd_pecas_cancel
         DISPLAY p_tela2.ies_ped TO ies_ped
         NEXT FIELD cod_it_novo
      END IF    

    AFTER FIELD ies_ped
      IF p_tela2.ies_ped IS NOT NULL THEN
         IF p_tela2.ies_ped <> 'S' AND 
            p_tela2.ies_ped <> 'N' THEN
            ERROR 'Informe (S) para alterar o novo item no mesmo pedido, ou (N) para incluir em novo pedido'
            NEXT FIELD ies_ped
         END IF
      ELSE
         ERROR 'Informe (S) para alterar o novo item no mesmo pedido, ou (N) para incluir em novo pedido'
         NEXT FIELD ies_ped
      END IF              

    AFTER FIELD cod_it_novo
      IF p_tela2.cod_it_novo IS NULL  THEN
         IF p_tela2.ies_ped IS NOT NULL THEN 
            ERROR "Informe o codigo do item substitutivo"
            NEXT FIELD cod_it_novo
         END IF    
      ELSE
         IF p_tela2.cod_it_novo = p_tela2.cod_item THEN 
            ERROR "Cod. do item substitutivo noa pode ser igual ao item atual"
            NEXT FIELD cod_it_novo
         END IF  
         LET p_count = 0 
         SELECT COUNT(*)
           INTO p_count
           FROM item 
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela2.cod_it_novo
         IF p_count = 0 THEN 
            ERROR 'ITEM NAO CADASTRADO'     
            NEXT FIELD cod_it_novo
         END IF

         IF esp0464_pega_preco_it_novo() THEN 
         ELSE
            ERROR p_des_erro
         END IF 
      END IF 

    BEFORE FIELD qtd_pecas_cancel
       IF p_ped_itens[pa_curr].ies_acao = 'TT' THEN 
          LET p_tela2.qtd_pecas_cancel = p_tela2.qtd_pecas_solic
          LET p_qtd_cancel_tot = p_tela2.qtd_pecas_solic
##          NEXT FIELD den_obs
       END IF 

    AFTER FIELD qtd_pecas_cancel
       IF p_tela2.qtd_pecas_cancel = 0 OR 
          p_tela2.qtd_pecas_cancel IS NULL THEN
          IF p_tela2.cod_it_novo IS NOT NULL  THEN
             ERROR "Informe a quantidade a ser transferida para o novo item"
             NEXT FIELD qtd_pecas_cancel
         END IF
       ELSE
#          IF p_tela2.qtd_pecas_cancel > p_tela2.qtd_pecas_solic THEN 
#             ERROR "qtde a cancelar maior que saldo do pedido"
#             NEXT FIELD qtd_pecas_cancel
#          ELSE
#             NEXT FIELD den_obs    
#          END IF 
       END IF    

    AFTER FIELD den_obs
         IF p_tela2.den_obs IS NULL AND 
            p_tela2.cod_it_novo IS NOT NULL THEN
            ERROR "Informe o motivo da troca do item"
            NEXT FIELD den_obs 
         ELSE   
            IF p_tela2.cod_it_novo IS NOT NULL THEN
               LET p_compl_it[pa_curr].qtd_pecas_cancel = p_tela2.qtd_pecas_cancel
               IF p_ped_itens[pa_curr].ies_acao = 'TT' THEN 
                  LET p_compl_it[pa_curr].qtd_cancel_tot   = p_qtd_cancel_tot
               ELSE
                  LET p_compl_it[pa_curr].qtd_cancel_tot   = 0
               END IF    
               LET p_compl_it[pa_curr].cod_it_novo = p_tela2.cod_it_novo
               LET p_compl_it[pa_curr].ies_ped = p_tela2.ies_ped
               LET p_compl_it[pa_curr].den_obs = p_tela2.den_obs
               LET p_compl_it[pa_curr].pre_unit = p_pre_unit
            ELSE
               LET p_ped_itens[pa_curr].ies_acao = '  '
            END IF 
         END IF

 END INPUT 
 
 CALL log006_exibe_teclas("01",p_versao)
 CLOSE WINDOW w_esp04642
 CURRENT WINDOW IS w_esp0464
 DISPLAY p_ped_itens[pa_curr].ies_acao TO ies_acao

END FUNCTION 

#------------------------------------#
 FUNCTION esp0464_pega_preco_it_novo()
#------------------------------------#

 INITIALIZE p_des_erro TO NULL

  IF esp0464_pega_lista_atual() THEN 
     RETURN TRUE 
  ELSE
     IF esp0464_pega_nova_lista_cliente() THEN
        RETURN TRUE
     ELSE
        IF p_des_erro IS NULL THEN  
           IF esp0464_pega_nova_lista_uf() THEN
              RETURN TRUE
           ELSE
              IF p_des_erro IS NULL THEN
                 IF esp0464_pega_nova_lista_item() THEN
                    RETURN TRUE
                 ELSE
                    RETURN FALSE
                 END IF
              ELSE
                 RETURN FALSE
              END IF     
           END IF
        ELSE
           RETURN FALSE
        END IF     
     END IF    
  END IF    
END FUNCTION 

#------------------------------------#
 FUNCTION esp0464_pega_lista_atual()
#------------------------------------#
   SELECT pre_unit
     INTO p_pre_unit
     FROM desc_preco_item
    WHERE cod_empresa    = p_cod_empresa
      AND num_list_preco = p_pedidos.num_list_preco
      AND cod_item       = p_tela2.cod_it_novo
      AND cod_cliente    = p_pedidos.cod_cliente
   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   ELSE    
      SELECT cod_uni_feder
        INTO p_cod_uni_feder
        FROM clientes a,
             cidades b
       WHERE a.cod_cidade  = b.cod_cidade
         AND a.cod_cliente = p_pedidos.cod_cliente
      
      SELECT pre_unit
        INTO p_pre_unit
        FROM desc_preco_item
       WHERE cod_empresa    = p_cod_empresa
         AND num_list_preco = p_pedidos.num_list_preco
         AND cod_item       = p_tela2.cod_it_novo
         AND cod_uni_feder  = p_cod_uni_feder
         AND Rtrim(Ltrim(cod_cliente))  IS NULL 
      IF SQLCA.sqlcode = 0 THEN
         RETURN TRUE
      ELSE 
         SELECT pre_unit
           INTO p_pre_unit
           FROM desc_preco_item
          WHERE cod_empresa    = p_cod_empresa
            AND num_list_preco = p_pedidos.num_list_preco
            AND cod_item       = p_tela2.cod_it_novo
            AND Rtrim(Ltrim(cod_uni_feder))  IS NULL 
            AND Rtrim(Ltrim(cod_cliente))    IS NULL            
         IF SQLCA.sqlcode = 0 THEN
            RETURN TRUE
         ELSE   
            RETURN FALSE
         END IF
      END IF     
   END IF  
  END FUNCTION 
  
#-----------------------------------------#
 FUNCTION esp0464_pega_nova_lista_cliente()
#-----------------------------------------#  
 DEFINE l_count  INTEGER
 
   LET l_count = 0

   SELECT COUNT(*)
     INTO l_count 
     FROM desc_preco_item a,
          desc_preco_mest b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.cod_item       = p_tela2.cod_it_novo
      AND a.cod_cliente    = p_pedidos.cod_cliente
      AND a.cod_empresa    = b.cod_empresa 
      AND a.num_list_preco = b.num_list_preco
      AND b.dat_fim_vig > TODAY 
   IF l_count > 1 THEN
       LET  p_des_erro = 'ITEM POSSUI MAIS QUE UMA LISTA_CLIENTE ATIVA ' 
       RETURN FALSE
   ELSE     
      IF l_count = 1 THEN  
         SELECT num_list_preco 
           INTO p_pedidos.num_list_preco
           FROM desc_preco_item a,
                desc_preco_mest b
          WHERE a.cod_empresa    = p_cod_empresa
            AND a.cod_item       = p_tela2.cod_it_novo
            AND a.cod_cliente    = p_pedidos.cod_cliente
            AND a.cod_empresa    = b.cod_empresa 
            AND a.num_list_preco = b.num_list_preco
            AND b.dat_fim_vig > TODAY 

         SELECT pre_unit
           INTO p_pre_unit
           FROM desc_preco_item
          WHERE cod_empresa    = p_cod_empresa
            AND num_list_preco = p_pedidos.num_list_preco
            AND cod_item       = p_tela2.cod_it_novo
            AND cod_cliente    = p_pedidos.cod_cliente
         IF SQLCA.sqlcode = 0 THEN
            RETURN TRUE
         ELSE    
            LET p_des_erro = 'ERRO NA LEITURA PRECO_UNIT_CLIENTE ', SQLCA.sqlcode
            RETURN FALSE
         END IF
      ELSE
         RETURN FALSE   
      END IF        
   END IF     
END FUNCTION 

#-----------------------------------------#
 FUNCTION esp0464_pega_nova_lista_uf()
#-----------------------------------------#  
 DEFINE l_count  INTEGER
 
   LET l_count = 0

   SELECT COUNT(*)
     INTO l_count 
     FROM desc_preco_item a,
          desc_preco_mest b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.cod_item       = p_tela2.cod_it_novo
      AND a.cod_uni_feder  = p_cod_uni_feder
      AND Rtrim(Ltrim(a.cod_cliente))  IS NULL 
      AND a.cod_empresa    = b.cod_empresa 
      AND a.num_list_preco = b.num_list_preco
      AND b.dat_fim_vig > TODAY 
   IF l_count > 1 THEN
       LET  p_des_erro = 'ITEM POSSUI MAIS QUE UMA LISTA_UF ATIVA ' 
       RETURN FALSE
   ELSE     
      IF l_count = 1 THEN  
         SELECT num_list_preco 
           INTO p_pedidos.num_list_preco
           FROM desc_preco_item a,
                desc_preco_mest b
          WHERE a.cod_empresa    = p_cod_empresa
            AND a.cod_item       = p_tela2.cod_it_novo
            AND a.cod_uni_feder  = p_cod_uni_feder
            AND Rtrim(Ltrim(a.cod_cliente))  IS NULL 
            AND a.cod_empresa    = b.cod_empresa 
            AND a.num_list_preco = b.num_list_preco
            AND b.dat_fim_vig > TODAY 

         SELECT pre_unit
           INTO p_pre_unit
           FROM desc_preco_item
          WHERE cod_empresa    = p_cod_empresa
            AND num_list_preco = p_pedidos.num_list_preco
            AND cod_item       = p_tela2.cod_it_novo
            AND cod_uni_feder  = p_cod_uni_feder
            AND Rtrim(Ltrim(cod_cliente))  IS NULL 
         IF SQLCA.sqlcode = 0 THEN
            RETURN TRUE
         ELSE    
            LET p_des_erro = 'ERRO NA LEITURA PRECO_UNIT_UF ', SQLCA.sqlcode
            RETURN FALSE
         END IF
      ELSE
         RETURN FALSE   
      END IF        
   END IF     
END FUNCTION 

#-----------------------------------------#
 FUNCTION esp0464_pega_nova_lista_item()
#-----------------------------------------#  
 DEFINE l_count  INTEGER
 
   LET l_count = 0

   SELECT COUNT(*)
     INTO l_count 
     FROM desc_preco_item a,
          desc_preco_mest b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.cod_item       = p_tela2.cod_it_novo
      AND Rtrim(Ltrim(a.cod_uni_feder))  IS NULL
      AND Rtrim(Ltrim(a.cod_cliente))  IS NULL 
      AND a.cod_empresa    = b.cod_empresa 
      AND a.num_list_preco = b.num_list_preco
      AND b.dat_fim_vig > TODAY 
   IF l_count > 1 THEN
       LET  p_des_erro = 'ITEM POSSUI MAIS QUE UMA LISTA_ITEM ATIVA ' 
       RETURN FALSE
   ELSE     
      IF l_count = 1 THEN  
         SELECT num_list_preco 
           INTO p_pedidos.num_list_preco
           FROM desc_preco_item a,
                desc_preco_mest b
          WHERE a.cod_empresa    = p_cod_empresa
            AND a.cod_item       = p_tela2.cod_it_novo
            AND Rtrim(Ltrim(a.cod_uni_feder))  IS NULL
            AND Rtrim(Ltrim(a.cod_cliente))  IS NULL 
            AND a.cod_empresa    = b.cod_empresa 
            AND a.num_list_preco = b.num_list_preco
            AND b.dat_fim_vig > TODAY 

         SELECT pre_unit
           INTO p_pre_unit
           FROM desc_preco_item
          WHERE cod_empresa    = p_cod_empresa
            AND num_list_preco = p_pedidos.num_list_preco
            AND cod_item       = p_tela2.cod_it_novo
            AND Rtrim(Ltrim(cod_uni_feder))  IS NULL
            AND Rtrim(Ltrim(cod_cliente))  IS NULL 
         IF SQLCA.sqlcode = 0 THEN
            RETURN TRUE
         ELSE    
            LET p_des_erro = 'ERRO NA LEITURA PRECO_UNIT_ITEM ', SQLCA.sqlcode
            RETURN FALSE
         END IF
      ELSE
         RETURN FALSE   
      END IF        
   END IF     
END FUNCTION 

#--------------------------#
 FUNCTION esp0464_efetiva()
#--------------------------#
 FOR p_ind = 1 TO 200
   IF p_ped_itens[p_ind].cod_item IS NULL THEN
      EXIT FOR
   END IF 
   
   IF p_ped_itens[p_ind].ies_acao = 'TT' THEN 
      IF NOT esp0464_efetiva_trans_tot() THEN 
         RETURN FALSE
      END IF
   ELSE
      IF p_ped_itens[p_ind].ies_acao = 'TP' THEN 
         IF NOT esp0464_efetiva_trans_par() THEN 
            RETURN FALSE
         END IF 
      ELSE
         IF p_ped_itens[p_ind].ies_acao = 'ES' THEN 
            IF NOT esp0464_efetiva_est() THEN 
               RETURN FALSE
            END IF 
         ELSE
            IF p_ped_itens[p_ind].ies_acao = 'ER' THEN
               IF NOT esp0464_efetiva_err() THEN 
                  RETURN FALSE
               END IF
            END IF    
         END IF
      END IF
   END IF   
 END FOR
 RETURN TRUE 
END FUNCTION

#-----------------------------------#
 FUNCTION esp0464_efetiva_trans_tot()
#-----------------------------------# 
  DEFINE l_qtd_tot_ped  INTEGER

 BEGIN WORK    
  UPDATE ped_itens
     SET qtd_pecas_cancel = qtd_pecas_cancel + p_compl_it[p_ind].qtd_cancel_tot
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_tela.num_pedido
     AND cod_item      = p_ped_itens[p_ind].cod_item  
     AND num_sequencia = p_ped_itens[p_ind].num_sequencia
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("ATUALIZACAO","ped_itens")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  SELECT *
    INTO p_pedidos.*
    FROM pedidos
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_tela.num_pedido

  SELECT *
    INTO p_ped_its.*
    FROM ped_itens
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_tela.num_pedido
     AND cod_item      = p_ped_itens[p_ind].cod_item  
     AND num_sequencia = p_ped_itens[p_ind].num_sequencia

  INITIALIZE p_ped_it_txt.* TO NULL
  
  SELECT *
    INTO p_ped_it_txt.*
    FROM ped_itens_texto
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_tela.num_pedido
     AND num_sequencia = p_ped_itens[p_ind].num_sequencia

  SELECT num_prx_pedido
    INTO p_num_ped_novo
    FROM par_vdp
   WHERE cod_empresa = p_cod_empresa 

  IF SQLCA.sqlcode <> 0 THEN 
     CALL log003_err_sql("LEITURA","PAR_VDP")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  UPDATE par_vdp 
     SET num_prx_pedido = p_num_ped_novo + 1
   WHERE cod_empresa = p_cod_empresa 

  IF SQLCA.sqlcode <> 0 THEN 
     CALL log003_err_sql("UPDATE","PAR_VDP")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  LET p_num_ped_ter  = p_pedidos.num_pedido_cli[1,7]

  
  LET p_desc = p_num_ped_ter CLIPPED,'%'
  
  IF p_seq_ter IS NULL THEN 
     LET sql_prep = "SELECT MAX(num_ped_terceiro) ",
                    "  FROM logix.wms_pedido_venda@kitwms ",
                    " WHERE num_ped_terceiro LIKE '",p_desc CLIPPED,"'"
     
     LET sql_prep = sql_prep CLIPPED
     
     PREPARE var_ped1 FROM sql_prep
     
     DECLARE cq_ped1 CURSOR FOR var_ped1
     
     FOREACH cq_ped1 INTO p_pedidos.num_pedido_cli  
        EXIT FOREACH 
     END FOREACH
     
     LET p_seq_ter = p_pedidos.num_pedido_cli[8,10] 
  END IF 
     
  LET p_seq_ter = p_seq_ter + 1 

  LET p_pedidos.num_pedido_repres = p_num_ped_ter CLIPPED, p_seq_ter USING '&&&'

  LET p_pedidos.num_pedido_cli = p_pedidos.num_pedido_repres

  LET p_num_seq = 1

  INSERT INTO pedidos VALUES (p_cod_empresa,
                              p_num_ped_novo,
                              p_pedidos.cod_cliente, 
                              p_pedidos.pct_comissao, 
                              p_pedidos.num_pedido_repres, 
                              p_pedidos.dat_emis_repres, 
                              p_pedidos.cod_nat_oper, 
                              p_pedidos.cod_transpor, 
                              p_pedidos.cod_consig, 
                              p_pedidos.ies_finalidade, 
                              p_pedidos.ies_frete, 
                              p_pedidos.ies_preco, 
                              p_pedidos.cod_cnd_pgto, 
                              p_pedidos.pct_desc_financ, 
                              p_pedidos.ies_embal_padrao, 
                              p_pedidos.ies_tip_entrega, 
                              p_pedidos.ies_aceite, 
                              'N', 
                              p_dat_cur, 
                              p_pedidos.num_pedido_cli, 
                              p_pedidos.pct_desc_adic, 
                              p_pedidos.num_list_preco, 
                              p_pedidos.cod_repres, 
                              p_pedidos.cod_repres_adic, 
                              p_pedidos.dat_alt_sit, 
                              p_pedidos.dat_cancel, 
                              p_pedidos.cod_tip_venda, 
                              p_pedidos.cod_motivo_can, 
                              p_pedidos.dat_ult_fatur, 
                              p_pedidos.cod_moeda, 
                              p_pedidos.ies_comissao, 
                              p_pedidos.pct_frete, 
                              p_pedidos.cod_tip_carteira, 
                              p_pedidos.num_versao_lista, 
                              p_pedidos.cod_local_estoq)
   
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","PEDIDOS")
     ROLLBACK WORK
     RETURN FALSE
  END IF
  
  INSERT INTO ped_itens VALUES (p_cod_empresa,
                                p_num_ped_novo,
                                p_num_seq,
                                p_compl_it[p_ind].cod_it_novo,
                                p_ped_its.pct_desc_adic,
                                p_compl_it[p_ind].pre_unit,
                                p_compl_it[p_ind].qtd_pecas_cancel,
                                0,
                                0,
                                0,
                                p_ped_its.prz_entrega,
                                p_ped_its.val_desc_com_unit,
                                p_ped_its.val_frete_unit,
                                p_ped_its.val_seguro_unit,
                                0,
                                p_ped_its.pct_desc_bruto)
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","PED_ITENS")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  INSERT INTO ped_itens_texto VALUES (p_cod_empresa, 
                                      p_num_ped_novo,
                                      p_num_seq,
                                      p_ped_it_txt.den_texto_1,
                                      p_ped_it_txt.den_texto_2,
                                      p_ped_it_txt.den_texto_3,
                                      p_ped_it_txt.den_texto_4,
                                      p_ped_it_txt.den_texto_5)

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  SELECT cod_nat_oper_refer
    INTO p_cod_nat_oper_refer
    FROM nat_oper_refer
   WHERE cod_empresa  = p_cod_empresa 
     AND cod_item     = p_compl_it[p_ind].cod_it_novo
     AND cod_nat_oper = p_pedidos.cod_nat_oper 
     
  IF sqlca.sqlcode = 0 THEN 
     INSERT INTO ped_item_nat VALUES (p_cod_empresa, 
                                      p_num_ped_novo,
                                      p_num_seq,
                                      'N',
                                      'N',
                                      NULL,
                                      p_cod_nat_oper_refer,
                                      p_pedidos.cod_cnd_pgto)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
        ROLLBACK WORK
        RETURN FALSE
     END IF
  END IF                                     

  LET sql_prep = "SELECT item ",
                 "  FROM logix.wms_item@kitwms ",
                 " WHERE item_terceiro =  ", p_ped_itens[p_ind].cod_item

  LET sql_prep = sql_prep CLIPPED

  PREPARE var_itv FROM sql_prep
  
  DECLARE cq_itv CURSOR FOR var_itv
  
  FOREACH cq_itv INTO p_cod_item_num 
    EXIT FOREACH
  END FOREACH  

  INITIALIZE p_item_novo_num TO NULL 

  LET sql_prep = "SELECT item ",
                 "  FROM logix.wms_item@kitwms ",
                 " WHERE item_terceiro =  ", p_compl_it[p_ind].cod_it_novo

  LET sql_prep = sql_prep CLIPPED

  PREPARE var_itn FROM sql_prep
  
  DECLARE cq_itn CURSOR FOR var_itn
  
  FOREACH cq_itn INTO p_item_novo_num
    EXIT FOREACH
  END FOREACH  

  LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                 "   SET qtd_cancelada = qtd_cancelada + ",p_compl_it[p_ind].qtd_cancel_tot,
                 ",sit_item_ped_venda = 'C'",
                 " WHERE pedido_venda = ",p_num_ped_wms,
                 "   AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia,                
                 "   AND item             = ",p_cod_item_num                                  

  LET sql_prep = sql_prep CLIPPED

  PREPARE var_uppd1 FROM sql_prep
  
  EXECUTE var_uppd1 

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
     ROLLBACK WORK
     RETURN FALSE
  END IF

  LET sql_prep =   "SELECT (qtd_item - qtd_item_cancelado) ",                            
                    " FROM logix.wms_pedido_venda@kitwms ",
                   " WHERE pedido_venda = '", p_num_ped_wms,"'",
                     " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
  
  LET sql_prep = sql_prep CLIPPED
  
  PREPARE var_ped4 FROM sql_prep
  DECLARE cq_ped4 CURSOR FOR var_ped4
  FOREACH cq_ped4 INTO l_qtd_tot_ped      
    EXIT FOREACH
  END FOREACH 

  IF l_qtd_tot_ped > p_compl_it[p_ind].qtd_pecas_cancel THEN    
     LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                    "   SET qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_cancel_tot,
                    " WHERE pedido_venda = ",p_num_ped_wms,
                    "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
     
     LET sql_prep = sql_prep CLIPPED
     
     PREPARE var_uppd2 FROM sql_prep
     
     EXECUTE var_uppd2 
     
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
        ROLLBACK WORK
        RETURN FALSE
     END IF
 ELSE
     LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                    "   SET qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_cancel_tot,
                    " ,sit_pedido_venda = 'C' ",
                    " WHERE pedido_venda = ",p_num_ped_wms,
                    "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
     
     LET sql_prep = sql_prep CLIPPED
     
     PREPARE var_uppd9 FROM sql_prep
     
     EXECUTE var_uppd9 
     
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
        ROLLBACK WORK
        RETURN FALSE
     END IF
 END IF   

   LET sql_prep1 = "SELECT planta,num_ped_terceiro,terceiro,programa_coleta,cliente_terceiro,restricao,",
                   "rota,dat_entrega,dat_emissao,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume,cancel_exped,",
                   "cnpj_cliente,cliente_interno,lote_transf,transportadora,consignatario,tip_entrega,cliente_origem,",
                   "origem_pedido,sequencia_entrega,fatura_antecip,viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem ",     
                   " FROM logix.wms_pedido_venda@kitwms ",         
                  " WHERE pedido_venda = ", p_num_ped_wms,
                  " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
   
   LET sql_prep1 = sql_prep1 CLIPPED
   
   PREPARE var_pedv FROM sql_prep1
   DECLARE cq_pedv CURSOR FOR var_pedv
   FOREACH cq_pedv INTO p_pedido.planta,                   
                        p_pedido.num_ped_terceiro,         
                        p_pedido.terceiro,                 
                        p_pedido.programa_coleta,          
                        p_pedido.cliente_terceiro,         
                        p_pedido.restricao,              
                        p_pedido.rota,                     
                        p_pedido.dat_entrega,              
                        p_pedido.dat_emissao,              
                        p_pedido.dat_sit_ped_venda,        
                        p_pedido.usuario,                  
                        p_pedido.qtd_item,                 
                        p_pedido.qtd_item_volume,          
                        p_pedido.cancel_exped,            
                        p_pedido.cnpj_cliente,             
                        p_pedido.cliente_interno,          
                        p_pedido.lote_transf,              
                        p_pedido.transportadora,           
                        p_pedido.consignatario,            
                        p_pedido.tip_entrega,              
                        p_pedido.cliente_origem,          
                        p_pedido.origem_pedido,            
                        p_pedido.sequencia_entrega,        
                        p_pedido.fatura_antecip,           
                        p_pedido.viagem,                   
                        p_pedido.tip_proc_ped_venda,       
                        p_pedido.tip_cnfr_exped,
                        p_pedido.pedido_embalagem
                        
    EXIT FOREACH
  END FOREACH  

  LET p_pedido.num_ped_terceiro = p_pedidos.num_pedido_repres

  LET p_num_ped  = 0

  LET sql_prep = "SELECT val_parametro ",
                 "  FROM logix.wms_par_auxiliar@kitwms ",
                 " WHERE parametro = 'WMS006' ",
                 " order by val_parametro"

  LET sql_prep = sql_prep CLIPPED
  
  PREPARE var_par1t FROM sql_prep
  
  DECLARE cq_par1t CURSOR FOR var_par1t
  
  FOREACH cq_par1t INTO p_num_ped  
     EXIT FOREACH 
  END FOREACH

 IF p_num_ped = 0 OR
    p_num_ped IS NULL THEN
    ERROR "PROBLEMA NUMERACAO PEDIDO PAR_AUXILIAR"
    SLEEP 1
    ROLLBACK WORK
    RETURN FALSE
 END IF    

  LET sql_prep = "SELECT val_parametro ",
                 "  FROM logix.mcg_par_global@kitwms ",
                 " WHERE parametro = 'WMS006' "

  LET sql_prep = sql_prep CLIPPED
  
  PREPARE var_par2t FROM sql_prep
  
  DECLARE cq_par2t CURSOR FOR var_par2t
  
  FOREACH cq_par2t INTO p_num_ped_par  
     EXIT FOREACH 
  END FOREACH

  IF p_num_ped_par = 0 OR 
     p_num_ped_par IS NULL THEN
     ERROR "PROBLEMA NUMERACAO PEDIDO MCG_PAR"
     SLEEP 1
     ROLLBACK WORK
     RETURN FALSE
  END IF    


  IF p_num_ped = p_num_ped_par THEN    

    LET p_ind_pari = p_num_ped + 1
    LET p_ind_parf = p_num_ped + 200
    LET p_den_par = 'WMS006'
    
    WHILE p_ind_pari <= p_ind_parf

        LET sql_prep1 = "INSERT INTO logix.wms_par_auxiliar@kitwms ",
                        "(parametro,val_parametro) ",
                        " VALUES (?,?)"
        
        LET sql_prep1 = sql_prep1 CLIPPED
        
        PREPARE var_inspar1t FROM sql_prep1
        
        EXECUTE var_inspar1t USING p_den_par,         
                                   p_ind_pari
        
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("INCLUSAO","wms_par_auxiliar")
           ROLLBACK WORK
           RETURN FALSE
        END IF

        LET p_ind_pari = p_ind_pari + 1
        
    END WHILE 

    LET sql_prep = "UPDATE logix.mcg_par_global@kitwms ",                                           
                   "   SET val_parametro = ",p_ind_pari,
                   " WHERE parametro = 'WMS006'"
                     
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_uppar1t FROM sql_prep
    
    EXECUTE var_uppar1t 
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("ALTERACAO","mcg_par_global")
       ROLLBACK WORK
       RETURN FALSE
    END IF

  END IF 

  LET sql_prep = "DELETE FROM logix.wms_par_auxiliar@kitwms ",
                 " WHERE parametro = 'WMS006'",                            
                 " and val_parametro = ", p_num_ped
                   
  LET sql_prep = sql_prep CLIPPED
  
  PREPARE var_delpar1t FROM sql_prep
  
  EXECUTE var_delpar1t 
  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("DELECAO","wms_par_auxiliar")
     ROLLBACK WORK
     RETURN FALSE
  END IF

    LET sql_prep1 = "INSERT INTO logix.wms_pedido_venda@kitwms ", 
                    "(pedido_venda,planta,num_ped_terceiro,terceiro,programa_coleta, ",    
                    "cliente_terceiro,restricao,rota,dat_entrega,dat_emissao,dat_inclusao, ",       
                    "sit_pedido_venda,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume, ",    
                    "qtd_item_atendido,qtd_item_cancelado,cancel_exped,cnpj_cliente, ",       
                    "cliente_interno,lote_transf,transportadora,consignatario,tip_entrega, ",
                    "cliente_origem,origem_pedido,sequencia_entrega,fatura_antecip, ",     
                    "viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem) ",
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    
    LET sql_prep1 = sql_prep1 CLIPPED
    
    PREPARE var_ins FROM sql_prep1
    
    EXECUTE var_ins USING p_num_ped,          
                          p_pedido.planta,                
                          p_pedido.num_ped_terceiro,      
                          p_pedido.terceiro,             
                          p_pedido.programa_coleta,      
                          p_pedido.cliente_terceiro,     
                          p_pedido.restricao,            
                          p_pedido.rota,                 
                          p_pedido.dat_entrega,          
                          p_pedido.dat_emissao,          
                          p_dat_cur,         
                          'A', 
                          p_dat_cur,     
                          p_user,           
                          p_compl_it[p_ind].qtd_pecas_cancel, 
                          p_pedido.qtd_item_volume,      
                          '0',                             
                          '0',                             
                          p_pedido.cancel_exped,         
                          p_pedido.cnpj_cliente,         
                          p_pedido.cliente_interno,      
                          p_pedido.lote_transf,          
                          p_pedido.transportadora,       
                          p_pedido.consignatario,        
                          p_pedido.tip_entrega,          
                          p_pedido.cliente_origem,       
                          p_pedido.origem_pedido,        
                          p_pedido.sequencia_entrega,    
                          p_pedido.fatura_antecip,       
                          p_pedido.viagem,                
                          p_pedido.tip_proc_ped_venda,    
                          p_pedido.tip_cnfr_exped,
                          p_pedido.pedido_embalagem

    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","wms_pedido_venda")
       ROLLBACK WORK
       RETURN FALSE
    END IF
       
    LET p_item_wms = p_ped_itens[p_ind].cod_item

    LET p_num_seqw = 1  

    LET p_seq_terc = p_num_ped USING '&&&&&&&&&&', '-', p_num_seqw USING '&&&&&'

    LET sql_prep =   "SELECT lote,dat_entrega,tip_cnfr_exped",                             
                      " FROM logix.wms_item_ped_venda@kitwms", 
                     " WHERE pedido_venda = ", p_num_ped_wms,
                       " AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia
    
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_itpd FROM sql_prep
    DECLARE cq_itpd CURSOR FOR var_itpd
    FOREACH cq_itpd INTO p_lote,                    
                          p_dat_entrega,                            
                          p_tip_cnfr_exped
      EXIT FOREACH
    END FOREACH   
    
    LET sql_prep1 = "INSERT INTO logix.wms_item_ped_venda@kitwms ",
                    "(pedido_venda,seq_item_pedido,item,seq_ped_terceiro,lote,qtd_solicitada,qtd_atendida, ",                                                           
                    "qtd_liquid,qtd_cancelada,qtd_canc_retorno,dat_entrega,sit_item_ped_venda,dat_sit_item_ped, ",                                                       
                    "tip_cnfr_exped) ",
                    " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    
    LET sql_prep1 = sql_prep1 CLIPPED
    
    PREPARE var_ins1 FROM sql_prep1
    
    EXECUTE var_ins1 USING p_num_ped,         
                           p_num_seqw,      
                           p_item_novo_num,                 
                           p_seq_terc,     
                           p_lote,                 
                           p_compl_it[p_ind].qtd_pecas_cancel,      
                           '0',         
                           '0',           
                           '0',        
                           '0',     
                           p_dat_entrega,          
                           'A',   
                           p_dat_cur,     
                           p_tip_cnfr_exped

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","wms_item_ped_venda")
      ROLLBACK WORK
      RETURN FALSE
   END IF

   LET p_audit_vdp.cod_empresa = p_cod_empresa
   LET p_audit_vdp.num_pedido = p_tela.num_pedido
   LET p_audit_vdp.tipo_informacao = 'M' 
   LET p_audit_vdp.tipo_movto = 'I'
   LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Transferencia Total do item ',
                           p_ped_itens[p_ind].cod_item,' para o item ',p_item_novo_num,
                           ' Qtde anteriro ', p_compl_it[p_ind].qtd_cancel_tot,' Qtde nova ',
                           p_compl_it[p_ind].qtd_pecas_cancel,' utilizando novo pedido WMS ',
                           p_num_ped, ' Terceiro - ',p_pedido.num_ped_terceiro, ' Logix -',p_num_ped_novo 
   LET p_audit_vdp.num_programa = 'ESP0464'
   LET p_audit_vdp.data =  TODAY
   LET p_audit_vdp.hora =  TIME 
   LET p_audit_vdp.usuario = p_user
   LET p_audit_vdp.num_transacao = 0  
   INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","audit_vdp")
      ROLLBACK WORK
      RETURN FALSE
   END IF       

   LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
   LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
   LET p_audit_ped_ktm.num_ped_atu   = p_num_ped_novo  
   LET p_audit_ped_ktm.cod_item_ant  = p_ped_it_ant[p_ind].cod_item
   LET p_audit_ped_ktm.cod_item_atu  = p_item_novo_num 
   LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
   LET p_audit_ped_ktm.qtd_pecas_atu = p_compl_it[p_ind].qtd_pecas_cancel    
   LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
   LET p_audit_ped_ktm.pre_unit_atu  = p_compl_it[p_ind].pre_unit    
   LET p_audit_ped_ktm.texto         = p_audit_vdp.texto
   LET p_audit_ped_ktm.fat_conv_ant  = 0 
   LET p_audit_ped_ktm.fat_conv_atu  = 0
   LET p_audit_ped_ktm.data          =  TODAY
   LET p_audit_ped_ktm.hora          =  TIME 
   LET p_audit_ped_ktm.usuario       = p_user     
 
   INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
      ROLLBACK WORK
      RETURN FALSE
   END IF       
 
   LET p_msg_fim = "It transferido novo pedido ",p_num_ped_novo," ped WMS ",p_num_ped," Terc ",p_pedido.num_ped_terceiro
 COMMIT WORK
 RETURN TRUE 
END FUNCTION

#-----------------------------------#
 FUNCTION esp0464_efetiva_trans_par()
#-----------------------------------#
   DEFINE l_qtd_saldo_it INTEGER
   
   BEGIN WORK   
   IF p_compl_it[p_ind].ies_ped = 'S' THEN 
      UPDATE ped_itens
         SET qtd_pecas_cancel = qtd_pecas_cancel + p_compl_it[p_ind].qtd_pecas_cancel
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND cod_item      = p_ped_itens[p_ind].cod_item  
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ATUALIZACAO","ped_itens")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT *
        INTO p_ped_its.*
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND cod_item      = p_ped_itens[p_ind].cod_item  
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia

      INITIALIZE p_ped_it_txt.* TO NULL
      
      SELECT *
        INTO p_ped_it_txt.*
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia

      SELECT MAX(num_sequencia)
        INTO p_num_seq
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido

      LET p_num_seq = p_num_seq + 1
      
      INSERT INTO ped_itens VALUES (p_cod_empresa,
                                    p_tela.num_pedido,
                                    p_num_seq,
                                    p_compl_it[p_ind].cod_it_novo,
                                    p_ped_its.pct_desc_adic,
                                    p_compl_it[p_ind].pre_unit,
                                    p_compl_it[p_ind].qtd_pecas_cancel,
                                    0,
                                    0,
                                    0,
                                    p_ped_its.prz_entrega,
                                    p_ped_its.val_desc_com_unit,
                                    p_ped_its.val_frete_unit,
                                    p_ped_its.val_seguro_unit,
                                    0,
                                    p_ped_its.pct_desc_bruto)


      INSERT INTO ped_itens_texto VALUES (p_cod_empresa, 
                                          p_tela.num_pedido,
                                          p_num_seq,
                                          p_ped_it_txt.den_texto_1,
                                          p_ped_it_txt.den_texto_2,
                                          p_ped_it_txt.den_texto_3,
                                          p_ped_it_txt.den_texto_4,
                                          p_ped_it_txt.den_texto_5)
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT cod_nat_oper_refer
        INTO p_cod_nat_oper_refer
        FROM nat_oper_refer
       WHERE cod_empresa  = p_cod_empresa 
         AND cod_item     = p_compl_it[p_ind].cod_it_novo
         AND cod_nat_oper = p_pedidos.cod_nat_oper 
         
      IF sqlca.sqlcode = 0 THEN 
         INSERT INTO ped_item_nat VALUES (p_cod_empresa, 
                                          p_tela.num_pedido,
                                          p_num_seq,
                                          'N',
                                          'N',
                                          NULL,
                                          p_cod_nat_oper_refer,
                                          p_pedidos.cod_cnd_pgto)
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
            ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF                                     
      
      LET p_cod_item_num  = p_ped_itens[p_ind].cod_item
      LET p_item_novo_num = p_compl_it[p_ind].cod_it_novo

      LET sql_prep =   "SELECT (qtd_solicitada - qtd_cancelada) ",                            
                          " FROM logix.wms_item_ped_venda@kitwms ",
                         " WHERE pedido_venda = '", p_num_ped_wms,"'",
                          " AND seq_item_pedido = '",p_ped_itens[p_ind].num_sequencia,"'" 
      
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_itpd3 FROM sql_prep
      DECLARE cq_itpd3 CURSOR FOR var_itpd3
      FOREACH cq_itpd3 INTO l_qtd_saldo_it    
        EXIT FOREACH
      END FOREACH 
      
      IF l_qtd_saldo_it > p_compl_it[p_ind].qtd_pecas_cancel THEN    
         LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                        "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel ,
                        " WHERE pedido_venda = ",p_num_ped_wms,
                        "   AND seq_item_pedido = ",p_ped_itens[p_ind].num_sequencia       
         
         LET sql_prep = sql_prep CLIPPED
         
         PREPARE var_upitpd1 FROM sql_prep
         
         EXECUTE var_upitpd1 
      
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
            ROLLBACK WORK
            RETURN FALSE
         END IF
      ELSE
         LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                        "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel,
                        " ,sit_item_ped_venda = 'C' ",
                        " WHERE pedido_venda = ",p_num_ped_wms,
                        "   AND seq_item_pedido = ",p_ped_itens[p_ind].num_sequencia       
         
         LET sql_prep = sql_prep CLIPPED
         
         PREPARE var_upitpd2 FROM sql_prep
         
         EXECUTE var_upitpd2 
      
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
            ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF

      LET sql_prep = "SELECT MAX(seq_item_pedido)
                        FROM logix.wms_item_ped_venda@kitwms 
                        WHERE pedido_venda = ", p_num_ped_wms

      LET sql_prep = sql_prep CLIPPED

      PREPARE var_sqm FROM sql_prep

      DECLARE cq_sqm CURSOR FOR var_sqm

      FOREACH cq_sqm INTO p_num_seqw
        EXIT FOREACH 
      END FOREACH

      LET sql_prep = "SELECT lote,dat_entrega,tip_cnfr_exped ",
                       " FROM logix.wms_item_ped_venda@kitwms ", 
                       " WHERE pedido_venda = ",p_num_ped_wms,
                       " AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia,
                       " AND item             = ",p_cod_item_num



      LET sql_prep = sql_prep CLIPPED

      PREPARE var_itpd1 FROM sql_prep

      DECLARE cq_itpd1 CURSOR FOR var_itpd1

      FOREACH cq_itpd1 INTO p_lote,p_dat_entrega,p_tip_cnfr_exped
        EXIT FOREACH 
      END FOREACH

      LET p_seq_terc = p_num_ped_wms USING '&&&&&&&&&&', '-', p_num_seq USING '&&&&&'
      
      LET p_num_seqw = p_num_seqw + 1 
      
      LET sql_prep1 = "INSERT INTO logix.wms_item_ped_venda@kitwms ",
                      "(pedido_venda,seq_item_pedido,item,seq_ped_terceiro,lote,qtd_solicitada,qtd_atendida, ",
                      " qtd_liquid,qtd_cancelada,qtd_canc_retorno,dat_entrega,sit_item_ped_venda,dat_sit_item_ped, ",                                                       
                      " tip_cnfr_exped) ",                                                         
                      " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
      
      LET sql_prep1 = sql_prep1 CLIPPED
      
      PREPARE var_insit1 FROM sql_prep1
      
      EXECUTE var_insit1 USING p_num_ped_wms,         
                             p_num_seqw,      
                             p_item_novo_num,                 
                             p_seq_terc,     
                             p_lote,                 
                             p_compl_it[p_ind].qtd_pecas_cancel,      
                             '0',         
                             '0',           
                             '0',        
                             '0',     
                             p_dat_entrega,          
                             'A',   
                             p_dat_cur,     
                             p_tip_cnfr_exped     
                             
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","wms_item_ped_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF

       LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                      "   SET qtd_item = qtd_item + ",p_compl_it[p_ind].qtd_pecas_cancel,
                      "   ,qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_pecas_cancel,
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_uppd10 FROM sql_prep
       
       EXECUTE var_uppd10 
       
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
       
       LET p_audit_vdp.cod_empresa = p_cod_empresa
       LET p_audit_vdp.num_pedido = p_tela.num_pedido
       LET p_audit_vdp.tipo_informacao = 'M' 
       LET p_audit_vdp.tipo_movto = 'I'
       LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Transferencia Parcial do item ',p_ped_itens[p_ind].cod_item,' para o item ',p_item_novo_num,' Qtde ',p_compl_it[p_ind].qtd_pecas_cancel,' utilizando mesmo pedido'
       LET p_audit_vdp.num_programa = 'ESP0464'
       LET p_audit_vdp.data =  TODAY
       LET p_audit_vdp.hora =  TIME 
       LET p_audit_vdp.usuario = p_user
       LET p_audit_vdp.num_transacao = 0  
       INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","audit_vdp")
          ROLLBACK WORK
          RETURN FALSE
       END IF  
       
       LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
       LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
       LET p_audit_ped_ktm.num_ped_atu   = p_tela.num_pedido 
       LET p_audit_ped_ktm.cod_item_ant  = p_ped_it_ant[p_ind].cod_item
       LET p_audit_ped_ktm.cod_item_atu  = p_item_novo_num 
       LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
       LET p_audit_ped_ktm.qtd_pecas_atu = p_compl_it[p_ind].qtd_pecas_cancel    
       LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
       LET p_audit_ped_ktm.pre_unit_atu  = p_compl_it[p_ind].pre_unit 
       LET p_audit_ped_ktm.fat_conv_ant  = 0 
       LET p_audit_ped_ktm.fat_conv_atu  = 0
       LET p_audit_ped_ktm.texto         = p_audit_vdp.texto    
       LET p_audit_ped_ktm.data          =  TODAY
       LET p_audit_ped_ktm.hora          =  TIME 
       LET p_audit_ped_ktm.usuario       = p_user     
       
       INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
          ROLLBACK WORK
          RETURN FALSE
       END IF              
            
       LET p_msg_fim = "novo item criado no pedido ",p_seq_terc
   ELSE
      UPDATE ped_itens
         SET qtd_pecas_cancel = qtd_pecas_cancel + p_compl_it[p_ind].qtd_pecas_cancel
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND cod_item      = p_ped_itens[p_ind].cod_item  
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ATUALIZACAO","ped_itens")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT *
        INTO p_pedidos.*
        FROM pedidos
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido

      SELECT *
        INTO p_ped_its.*
        FROM ped_itens
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND cod_item      = p_ped_itens[p_ind].cod_item  
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia

      INITIALIZE p_ped_it_txt.* TO NULL
      
      SELECT *
        INTO p_ped_it_txt.*
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_tela.num_pedido
         AND num_sequencia = p_ped_itens[p_ind].num_sequencia

      SELECT num_prx_pedido
        INTO p_num_ped_novo
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa 

      IF SQLCA.sqlcode <> 0 THEN 
         CALL log003_err_sql("LEITURA","PAR_VDP")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      UPDATE par_vdp 
         SET num_prx_pedido = p_num_ped_novo + 1
       WHERE cod_empresa = p_cod_empresa 

      IF SQLCA.sqlcode <> 0 THEN 
         CALL log003_err_sql("UPDATE","PAR_VDP")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      LET p_num_ped_ter  = p_pedidos.num_pedido_cli[1,7]

      LET p_desc = p_num_ped_ter CLIPPED,'%'

      IF p_seq_ter IS NULL THEN
         LET sql_prep = "SELECT MAX(num_ped_terceiro) ",
                        "  FROM logix.wms_pedido_venda@kitwms ",
                        " WHERE num_ped_terceiro LIKE '",p_desc CLIPPED,"'"
         
         LET sql_prep = sql_prep CLIPPED
         
         PREPARE var_ped2 FROM sql_prep
         
         DECLARE cq_ped2 CURSOR FOR var_ped2
         
         FOREACH cq_ped2 INTO p_pedidos.num_pedido_cli  
            EXIT FOREACH 
         END FOREACH
         
         LET p_seq_ter = p_pedidos.num_pedido_cli[8,10] 
      END IF 
      
      LET p_seq_ter = p_seq_ter + 1 

      LET p_pedidos.num_pedido_repres = p_num_ped_ter CLIPPED, p_seq_ter USING '&&&'

      LET p_pedidos.num_pedido_cli = p_pedidos.num_pedido_repres

      LET p_num_seq = 1

      INSERT INTO pedidos VALUES (p_cod_empresa,
                                  p_num_ped_novo,
                                  p_pedidos.cod_cliente, 
                                  p_pedidos.pct_comissao, 
                                  p_pedidos.num_pedido_repres, 
                                  p_pedidos.dat_emis_repres, 
                                  p_pedidos.cod_nat_oper, 
                                  p_pedidos.cod_transpor, 
                                  p_pedidos.cod_consig, 
                                  p_pedidos.ies_finalidade, 
                                  p_pedidos.ies_frete, 
                                  p_pedidos.ies_preco, 
                                  p_pedidos.cod_cnd_pgto, 
                                  p_pedidos.pct_desc_financ, 
                                  p_pedidos.ies_embal_padrao, 
                                  p_pedidos.ies_tip_entrega, 
                                  p_pedidos.ies_aceite, 
                                  'N', 
                                  p_dat_cur, 
                                  p_pedidos.num_pedido_cli, 
                                  p_pedidos.pct_desc_adic, 
                                  p_pedidos.num_list_preco, 
                                  p_pedidos.cod_repres, 
                                  p_pedidos.cod_repres_adic, 
                                  p_pedidos.dat_alt_sit, 
                                  p_pedidos.dat_cancel, 
                                  p_pedidos.cod_tip_venda, 
                                  p_pedidos.cod_motivo_can, 
                                  p_pedidos.dat_ult_fatur, 
                                  p_pedidos.cod_moeda, 
                                  p_pedidos.ies_comissao, 
                                  p_pedidos.pct_frete, 
                                  p_pedidos.cod_tip_carteira, 
                                  p_pedidos.num_versao_lista, 
                                  p_pedidos.cod_local_estoq)
       
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","PEDIDOS")
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      INSERT INTO ped_itens VALUES (p_cod_empresa,
                                    p_num_ped_novo,
                                    p_num_seq,
                                    p_compl_it[p_ind].cod_it_novo,
                                    p_ped_its.pct_desc_adic,
                                    p_compl_it[p_ind].pre_unit,
                                    p_compl_it[p_ind].qtd_pecas_cancel,
                                    0,
                                    0,
                                    0,
                                    p_ped_its.prz_entrega,
                                    p_ped_its.val_desc_com_unit,
                                    p_ped_its.val_frete_unit,
                                    p_ped_its.val_seguro_unit,
                                    0,
                                    p_ped_its.pct_desc_bruto)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","PED_ITENS")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      INSERT INTO ped_itens_texto VALUES (p_cod_empresa, 
                                          p_num_ped_novo,
                                          p_num_seq,
                                          p_ped_it_txt.den_texto_1,
                                          p_ped_it_txt.den_texto_2,
                                          p_ped_it_txt.den_texto_3,
                                          p_ped_it_txt.den_texto_4,
                                          p_ped_it_txt.den_texto_5)
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      SELECT cod_nat_oper_refer
        INTO p_cod_nat_oper_refer
        FROM nat_oper_refer
       WHERE cod_empresa  = p_cod_empresa 
         AND cod_item     = p_compl_it[p_ind].cod_it_novo
         AND cod_nat_oper = p_pedidos.cod_nat_oper 
         
      IF sqlca.sqlcode = 0 THEN 
         INSERT INTO ped_item_nat VALUES (p_cod_empresa, 
                                          p_num_ped_novo,
                                          p_num_seq,
                                          'N',
                                          'N',
                                          NULL,
                                          p_cod_nat_oper_refer,
                                          p_pedidos.cod_cnd_pgto)
         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
            ROLLBACK WORK
            RETURN FALSE
         END IF
      END IF                                     

      LET sql_prep = "SELECT item ",
                     "  FROM logix.wms_item@kitwms ",
                     " WHERE item_terceiro =  ", p_ped_itens[p_ind].cod_item
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_itv1 FROM sql_prep
      
      DECLARE cq_itv1 CURSOR FOR var_itv1
      
      FOREACH cq_itv1 INTO p_cod_item_num 
        EXIT FOREACH
      END FOREACH  

      INITIALIZE p_item_novo_num TO NULL
      
      LET sql_prep = "SELECT item ",
                     "  FROM logix.wms_item@kitwms ",
                     " WHERE item_terceiro =  ", p_compl_it[p_ind].cod_it_novo
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_itn1 FROM sql_prep
      
      DECLARE cq_itn1 CURSOR FOR var_itn1
      
      FOREACH cq_itn1 INTO p_item_novo_num
        EXIT FOREACH
      END FOREACH  

      LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                     "   SET qtd_cancelada = qtd_cancelada + ",p_compl_it[p_ind].qtd_pecas_cancel ,
                     " WHERE pedido_venda = ",p_num_ped_wms,
                     "   AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia,                
                     "   AND item             = ",p_cod_item_num                                  
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_upit3 FROM sql_prep
      
      EXECUTE var_upit3 
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                     "   SET qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_pecas_cancel ,
                     " WHERE pedido_venda = ",p_num_ped_wms,
                     "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_uppd3 FROM sql_prep
      
      EXECUTE var_uppd3 
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
         RETURN FALSE
      END IF

      LET sql_prep1 = "SELECT planta,num_ped_terceiro,terceiro,programa_coleta,cliente_terceiro,restricao,",
                      "rota,dat_entrega,dat_emissao,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume,cancel_exped,",
                      "cnpj_cliente,cliente_interno,lote_transf,transportadora,consignatario,tip_entrega,cliente_origem,",
                      "origem_pedido,sequencia_entrega,fatura_antecip,viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem ",     
                      " FROM logix.wms_pedido_venda@kitwms ",         
                     " WHERE pedido_venda = ", p_num_ped_wms,
                     " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
      
      LET sql_prep1 = sql_prep1 CLIPPED
      
      PREPARE var_pedv1 FROM sql_prep1
      DECLARE cq_pedv1 CURSOR FOR var_pedv1
      FOREACH cq_pedv1 INTO p_pedido.planta,                   
                            p_pedido.num_ped_terceiro,         
                            p_pedido.terceiro,                 
                            p_pedido.programa_coleta,          
                            p_pedido.cliente_terceiro,         
                            p_pedido.restricao,              
                            p_pedido.rota,                     
                            p_pedido.dat_entrega,              
                            p_pedido.dat_emissao,              
                            p_pedido.dat_sit_ped_venda,        
                            p_pedido.usuario,                  
                            p_pedido.qtd_item,                 
                            p_pedido.qtd_item_volume,          
                            p_pedido.cancel_exped,            
                            p_pedido.cnpj_cliente,             
                            p_pedido.cliente_interno,          
                            p_pedido.lote_transf,              
                            p_pedido.transportadora,           
                            p_pedido.consignatario,            
                            p_pedido.tip_entrega,              
                            p_pedido.cliente_origem,          
                            p_pedido.origem_pedido,            
                            p_pedido.sequencia_entrega,        
                            p_pedido.fatura_antecip,           
                            p_pedido.viagem,                   
                            p_pedido.tip_proc_ped_venda,       
                            p_pedido.tip_cnfr_exped,
                            p_pedido.pedido_embalagem
                            
        EXIT FOREACH
      END FOREACH  
      
      LET p_pedido.num_ped_terceiro = p_pedidos.num_pedido_repres
      
      LET p_num_ped  = 0
      
      LET sql_prep = "SELECT val_parametro ",
                     "  FROM logix.wms_par_auxiliar@kitwms ",
                     " WHERE parametro = 'WMS006' ",
                     " order by val_parametro"
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_par1p FROM sql_prep
      
      DECLARE cq_par1p CURSOR FOR var_par1p
      
      FOREACH cq_par1p INTO p_num_ped  
         EXIT FOREACH 
      END FOREACH

      IF p_num_ped = 0 OR
         p_num_ped IS NULL THEN
         ERROR "PROBLEMA NUMERACAO PEDIDO PAR_AUXILIAR"
         SLEEP 1
         ROLLBACK WORK
         RETURN FALSE
      END IF    
      
      LET sql_prep = "SELECT val_parametro ",
                     "  FROM logix.mcg_par_global@kitwms ",
                     " WHERE parametro = 'WMS006' "
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_par2p FROM sql_prep
      
      DECLARE cq_par2p CURSOR FOR var_par2p
      
      FOREACH cq_par2p INTO p_num_ped_par  
         EXIT FOREACH 
      END FOREACH

      IF p_num_ped_par = 0 OR
         p_num_ped_par IS NULL THEN
         ERROR "PROBLEMA NUMERACAO PEDIDO MCG_PAR"
         SLEEP 1
         ROLLBACK WORK
         RETURN FALSE
      END IF
                
      IF p_num_ped = p_num_ped_par THEN    
      
        LET p_ind_pari = p_num_ped + 1
        LET p_ind_parf = p_num_ped + 200
        LET p_den_par = 'WMS006'
        
        WHILE p_ind_pari <= p_ind_parf
      
            LET sql_prep1 = "INSERT INTO logix.wms_par_auxiliar@kitwms ",
                            "(parametro,val_parametro) ",
                            " VALUES (?,?)"
            
            LET sql_prep1 = sql_prep1 CLIPPED
            
            PREPARE var_inspar1p FROM sql_prep1
            
            EXECUTE var_inspar1p USING p_den_par,         
                                       p_ind_pari
            
            IF sqlca.sqlcode <> 0 THEN 
               CALL log003_err_sql("INCLUSAO","wms_par_auxiliar")
               ROLLBACK WORK
               RETURN FALSE
            END IF
      
            LET p_ind_pari = p_ind_pari + 1
            
        END WHILE 
      
        LET sql_prep = "UPDATE logix.mcg_par_global@kitwms ",                                           
                       "   SET val_parametro = ",p_ind_pari,
                       " WHERE parametro = 'WMS006'"
                         
        LET sql_prep = sql_prep CLIPPED
        
        PREPARE var_uppar1p FROM sql_prep
        
        EXECUTE var_uppar1p 
        IF sqlca.sqlcode <> 0 THEN 
           CALL log003_err_sql("ALTERACAO","mcg_par_global")
           ROLLBACK WORK
           RETURN FALSE
        END IF
      
      END IF 
      
      LET sql_prep = "DELETE FROM logix.wms_par_auxiliar@kitwms ",
                     " WHERE parametro = 'WMS006'",                            
                     " and val_parametro = ", p_num_ped
                       
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_delpar1p FROM sql_prep
      
      EXECUTE var_delpar1p 
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("DELECAO","wms_par_auxiliar")
         ROLLBACK WORK
         RETURN FALSE
      END IF
      
      LET sql_prep1 = "INSERT INTO logix.wms_pedido_venda@kitwms ", 
                      "(pedido_venda,planta,num_ped_terceiro,terceiro,programa_coleta, ",    
                      "cliente_terceiro,restricao,rota,dat_entrega,dat_emissao,dat_inclusao, ",       
                      "sit_pedido_venda,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume, ",    
                      "qtd_item_atendido,qtd_item_cancelado,cancel_exped,cnpj_cliente, ",       
                      "cliente_interno,lote_transf,transportadora,consignatario,tip_entrega, ",
                      "cliente_origem,origem_pedido,sequencia_entrega,fatura_antecip, ",     
                      "viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem) ",
                      "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
      
      LET sql_prep1 = sql_prep1 CLIPPED
      
      PREPARE var_inspd1 FROM sql_prep1
      
      EXECUTE var_inspd1 USING p_num_ped,          
                            p_pedido.planta,                
                            p_pedido.num_ped_terceiro,      
                            p_pedido.terceiro,             
                            p_pedido.programa_coleta,      
                            p_pedido.cliente_terceiro,     
                            p_pedido.restricao,            
                            p_pedido.rota,                 
                            p_pedido.dat_entrega,          
                            p_pedido.dat_emissao,          
                            p_dat_cur,         
                            'A', 
                            p_dat_cur,     
                            p_user,           
                            p_compl_it[p_ind].qtd_pecas_cancel, 
                            p_pedido.qtd_item_volume,      
                            '0',                             
                            '0',                             
                            p_pedido.cancel_exped,         
                            p_pedido.cnpj_cliente,         
                            p_pedido.cliente_interno,      
                            p_pedido.lote_transf,          
                            p_pedido.transportadora,       
                            p_pedido.consignatario,        
                            p_pedido.tip_entrega,          
                            p_pedido.cliente_origem,       
                            p_pedido.origem_pedido,        
                            p_pedido.sequencia_entrega,    
                            p_pedido.fatura_antecip,       
                            p_pedido.viagem,                
                            p_pedido.tip_proc_ped_venda,    
                            p_pedido.tip_cnfr_exped,
                            p_pedido.pedido_embalagem
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","wms_pedido_venda")
         ROLLBACK WORK
         RETURN FALSE
      END IF
         
      LET p_item_wms = p_ped_itens[p_ind].cod_item

      LET p_num_seqw = 1  
      
      LET p_seq_terc = p_num_ped USING '&&&&&&&&&&', '-', p_num_seqw USING '&&&&&'
      
      LET sql_prep =   "SELECT lote,dat_entrega,tip_cnfr_exped ",                                
                         " FROM logix.wms_item_ped_venda@kitwms ", 
                         " WHERE pedido_venda = ", p_num_ped_wms,
                          "AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia
      
      
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_itpd2 FROM sql_prep
      DECLARE cq_itpd2 CURSOR FOR var_itpd2
      FOREACH cq_itpd2 INTO p_lote,                    
                            p_dat_entrega,                            
                            p_tip_cnfr_exped
      
        EXIT FOREACH
      END FOREACH   
      
      LET sql_prep1 = "INSERT INTO logix.wms_item_ped_venda@kitwms ",
                      "(pedido_venda,seq_item_pedido,item,seq_ped_terceiro,lote,qtd_solicitada,qtd_atendida, ",                                                           
                      "qtd_liquid,qtd_cancelada,qtd_canc_retorno,dat_entrega,sit_item_ped_venda,dat_sit_item_ped, ",                                                       
                      "tip_cnfr_exped) ",
                      " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
      
      LET sql_prep1 = sql_prep1 CLIPPED
      
      PREPARE var_insit2 FROM sql_prep1
      
      EXECUTE var_insit2 USING p_num_ped,         
                               p_num_seqw,      
                               p_item_novo_num,                 
                               p_seq_terc,     
                               p_lote,                 
                               p_compl_it[p_ind].qtd_pecas_cancel,      
                               '0',         
                               '0',           
                               '0',        
                               '0',     
                               p_dat_entrega,          
                               'A',   
                               p_dat_cur,     
                               p_tip_cnfr_exped
      
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","wms_item_ped_venda")
         ROLLBACK WORK
         RETURN FALSE
      END IF

      LET p_audit_vdp.cod_empresa = p_cod_empresa
      LET p_audit_vdp.num_pedido = p_tela.num_pedido
      LET p_audit_vdp.tipo_informacao = 'M' 
      LET p_audit_vdp.tipo_movto = 'I'
      LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Transferencia Parcial do item ',
                              p_ped_itens[p_ind].cod_item,' para o item ',p_item_novo_num,
                              ' Qtde ',p_compl_it[p_ind].qtd_pecas_cancel,' utilizando novo pedido WMS ',
                              p_num_ped, ' Terceiro - ',p_pedido.num_ped_terceiro, ' Logix -',p_num_ped_novo 
      LET p_audit_vdp.num_programa = 'ESP0464'
      LET p_audit_vdp.data =  TODAY
      LET p_audit_vdp.hora =  TIME 
      LET p_audit_vdp.usuario = p_user
      LET p_audit_vdp.num_transacao = 0  
      INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSAO","audit_vdp")
         ROLLBACK WORK
         RETURN FALSE
      END IF       

       LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
       LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
       LET p_audit_ped_ktm.num_ped_atu   = p_num_ped_novo 
       LET p_audit_ped_ktm.cod_item_ant  = p_ped_it_ant[p_ind].cod_item
       LET p_audit_ped_ktm.cod_item_atu  = p_item_novo_num 
       LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
       LET p_audit_ped_ktm.qtd_pecas_atu = p_compl_it[p_ind].qtd_pecas_cancel    
       LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
       LET p_audit_ped_ktm.pre_unit_atu  = p_compl_it[p_ind].pre_unit    
       LET p_audit_ped_ktm.texto         = p_audit_vdp.texto 
       LET p_audit_ped_ktm.fat_conv_ant  = 0 
       LET p_audit_ped_ktm.fat_conv_atu  = 0
       LET p_audit_ped_ktm.data          =  TODAY
       LET p_audit_ped_ktm.hora          =  TIME 
       LET p_audit_ped_ktm.usuario       = p_user     
       
       INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
          ROLLBACK WORK
          RETURN FALSE
       END IF              

       LET p_msg_fim = "It transferido novo pedido ",p_num_ped_novo," ped WMS ",p_num_ped," Terc ",p_pedido.num_ped_terceiro
   END IF 
 COMMIT WORK
 RETURN TRUE 
END FUNCTION

#-----------------------------#
 FUNCTION esp0464_efetiva_est()
#-----------------------------#   
 DEFINE l_qtd_tot_ped  INTEGER,
        l_qtd_saldo_it INTEGER 

 BEGIN WORK
 IF p_compl_it[p_ind].qtd_pecas_cancel > 0 THEN

    LET sql_prep =   "SELECT (qtd_item - qtd_item_cancelado) ",                            
                       " FROM logix.wms_pedido_venda@kitwms ",
                       " WHERE pedido_venda = '", p_num_ped_wms,"'",
                        " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
   
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_ped3 FROM sql_prep
    DECLARE cq_ped3 CURSOR FOR var_ped3
    FOREACH cq_ped3 INTO l_qtd_tot_ped      
      EXIT FOREACH
    END FOREACH 
          
    IF l_qtd_tot_ped > p_compl_it[p_ind].qtd_pecas_cancel THEN
       LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                      "   SET qtd_item_cancelado = qtd_item_cancelado +  ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"         
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_uppd4 FROM sql_prep
       
       EXECUTE var_uppd4 
        
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    ELSE
       LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                
                      "   SET qtd_item_cancelado = qtd_item_cancelado +  ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " ,sit_pedido_venda = 'C' ",
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"          
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_uppd5 FROM sql_prep
       
       EXECUTE var_uppd5 

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    END IF
    LET sql_prep =   "SELECT (qtd_solicitada - qtd_cancelada) ",                            
                        " FROM logix.wms_item_ped_venda@kitwms ",
                       " WHERE pedido_venda = '", p_num_ped_wms,"'",
                        " AND seq_item_pedido = '",p_ped_itens[p_ind].num_sequencia,"'" 
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_itpd4 FROM sql_prep
    DECLARE cq_itpd4 CURSOR FOR var_itpd4
    FOREACH cq_itpd4 INTO l_qtd_saldo_it    
      EXIT FOREACH
    END FOREACH 

    IF l_qtd_saldo_it > p_compl_it[p_ind].qtd_pecas_cancel THEN    
       LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                      "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " WHERE pedido_venda = '", p_num_ped_wms,"'",
                        " AND seq_item_pedido = '",p_ped_itens[p_ind].num_sequencia,"'" 
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_upitpd3 FROM sql_prep
       
       EXECUTE var_upitpd3 
        
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    ELSE
       LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                      "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel,
                      ",sit_item_ped_venda = 'C'",
                      " WHERE pedido_venda = '", p_num_ped_wms,"'",
                        " AND seq_item_pedido = '",p_ped_itens[p_ind].num_sequencia,"'" 
                        
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_upitpd4 FROM sql_prep
       
       EXECUTE var_upitpd4 
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    END IF

    UPDATE ped_itens
       SET qtd_pecas_cancel = qtd_pecas_cancel + p_compl_it[p_ind].qtd_pecas_cancel
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_tela.num_pedido
       AND cod_item      = p_ped_itens[p_ind].cod_item  
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("ATUALIZACAO","ped_itens")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    SELECT *
      INTO p_pedidos.*
      FROM pedidos
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_tela.num_pedido
    
    SELECT *
      INTO p_ped_its.*
      FROM ped_itens
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_tela.num_pedido
       AND cod_item      = p_ped_itens[p_ind].cod_item  
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia

    INITIALIZE p_ped_it_txt.* TO NULL

    SELECT *
      INTO p_ped_it_txt.*
      FROM ped_itens_texto
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_tela.num_pedido
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia


    SELECT num_prx_pedido
      INTO p_num_ped_novo
      FROM par_vdp
     WHERE cod_empresa = p_cod_empresa 

    IF SQLCA.sqlcode <> 0 THEN 
       CALL log003_err_sql("LEITURA","PAR_VDP")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    UPDATE par_vdp 
       SET num_prx_pedido = p_num_ped_novo + 1
     WHERE cod_empresa = p_cod_empresa 

    IF SQLCA.sqlcode <> 0 THEN 
       CALL log003_err_sql("UPDATE","PAR_VDP")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    LET p_num_ped_ter  = p_pedidos.num_pedido_cli[1,7]

    LET p_desc = '%',p_num_ped_ter CLIPPED,'%'

    IF p_seq_ter IS NULL THEN
       LET sql_prep = "SELECT MAX(num_ped_terceiro) ",
                      "  FROM logix.wms_pedido_venda@kitwms ",
                      " WHERE num_ped_terceiro LIKE '",p_desc CLIPPED,"'"
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_ped5 FROM sql_prep
       
       DECLARE cq_ped5 CURSOR FOR var_ped5
       
       FOREACH cq_ped5 INTO p_pedidos.num_pedido_cli  
          EXIT FOREACH 
       END FOREACH
       
       LET p_seq_ter = p_pedidos.num_pedido_cli[8,10] 
    END IF 
    
    LET p_seq_ter = p_seq_ter + 1 

    LET p_pedidos.num_pedido_repres = p_num_ped_ter CLIPPED, p_seq_ter USING '&&&'

    LET p_pedidos.num_pedido_cli = p_pedidos.num_pedido_repres

    INSERT INTO pedidos VALUES (p_cod_empresa,
                                p_num_ped_novo,
                                p_pedidos.cod_cliente, 
                                p_pedidos.pct_comissao, 
                                p_pedidos.num_pedido_repres, 
                                p_pedidos.dat_emis_repres, 
                                p_pedidos.cod_nat_oper, 
                                p_pedidos.cod_transpor, 
                                p_pedidos.cod_consig, 
                                p_pedidos.ies_finalidade, 
                                p_pedidos.ies_frete, 
                                p_pedidos.ies_preco, 
                                p_pedidos.cod_cnd_pgto, 
                                p_pedidos.pct_desc_financ, 
                                p_pedidos.ies_embal_padrao, 
                                p_pedidos.ies_tip_entrega, 
                                p_pedidos.ies_aceite, 
                                'N', 
                                p_dat_cur, 
                                p_pedidos.num_pedido_cli, 
                                p_pedidos.pct_desc_adic, 
                                p_pedidos.num_list_preco, 
                                p_pedidos.cod_repres, 
                                p_pedidos.cod_repres_adic, 
                                p_pedidos.dat_alt_sit, 
                                p_pedidos.dat_cancel, 
                                p_pedidos.cod_tip_venda, 
                                p_pedidos.cod_motivo_can, 
                                p_pedidos.dat_ult_fatur, 
                                p_pedidos.cod_moeda, 
                                p_pedidos.ies_comissao, 
                                p_pedidos.pct_frete, 
                                p_pedidos.cod_tip_carteira, 
                                p_pedidos.num_versao_lista, 
                                p_pedidos.cod_local_estoq)
     
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","PEDIDOS")
       ROLLBACK WORK
       RETURN FALSE
    END IF
    
    INSERT INTO ped_itens VALUES (p_cod_empresa,
                                  p_num_ped_novo,
                                  1,
                                  p_ped_itens[p_ind].cod_item,
                                  p_ped_its.pct_desc_adic,
                                  p_ped_its.pre_unit,
                                  p_compl_it[p_ind].qtd_pecas_cancel,
                                  0,
                                  0,
                                  0,
                                  p_ped_its.prz_entrega,
                                  p_ped_its.val_desc_com_unit,
                                  p_ped_its.val_frete_unit,
                                  p_ped_its.val_seguro_unit,
                                  0,
                                  p_ped_its.pct_desc_bruto)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","PED_ITENS")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    INSERT INTO ped_itens_texto VALUES (p_cod_empresa, 
                                        p_num_ped_novo,
                                        1,
                                        p_ped_it_txt.den_texto_1,
                                        p_ped_it_txt.den_texto_2,
                                        p_ped_it_txt.den_texto_3,
                                        p_ped_it_txt.den_texto_4,
                                        p_ped_it_txt.den_texto_5)
     
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","PED_ITENS_TEXTO")
       ROLLBACK WORK
       RETURN FALSE
    END IF


    SELECT cod_nat_oper_refer
      INTO p_cod_nat_oper_refer
      FROM nat_oper_refer
     WHERE cod_empresa  = p_cod_empresa 
       AND cod_item     = p_ped_itens[p_ind].cod_item
       AND cod_nat_oper = p_pedidos.cod_nat_oper 
       
    IF sqlca.sqlcode = 0 THEN 
       INSERT INTO ped_item_nat VALUES (p_cod_empresa, 
                                        p_num_ped_novo,
                                        1,
                                        'N',
                                        'N',
                                        NULL,
                                        p_cod_nat_oper_refer,
                                        p_pedidos.cod_cnd_pgto)
       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","PED_ITEM_NAT")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    END IF                                     



    LET sql_prep1 = "SELECT planta,num_ped_terceiro,terceiro,programa_coleta,cliente_terceiro,restricao,",
                    "rota,dat_entrega,dat_emissao,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume,cancel_exped,",
                    "cnpj_cliente,cliente_interno,lote_transf,transportadora,consignatario,tip_entrega,cliente_origem,",
                    "origem_pedido,sequencia_entrega,fatura_antecip,viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem ",     
                    " FROM logix.wms_pedido_venda@kitwms ",         
                   " WHERE pedido_venda = ", p_num_ped_wms,
                   " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
    
    LET sql_prep1 = sql_prep1 CLIPPED
    
    PREPARE var_pedv3 FROM sql_prep1
    DECLARE cq_pedv3 CURSOR FOR var_pedv3
    FOREACH cq_pedv3 INTO p_pedido.planta,                   
                          p_pedido.num_ped_terceiro,         
                          p_pedido.terceiro,                 
                          p_pedido.programa_coleta,          
                          p_pedido.cliente_terceiro,         
                          p_pedido.restricao,              
                          p_pedido.rota,                     
                          p_pedido.dat_entrega,              
                          p_pedido.dat_emissao,              
                          p_pedido.dat_sit_ped_venda,        
                          p_pedido.usuario,                  
                          p_pedido.qtd_item,                 
                          p_pedido.qtd_item_volume,          
                          p_pedido.cancel_exped,            
                          p_pedido.cnpj_cliente,             
                          p_pedido.cliente_interno,          
                          p_pedido.lote_transf,              
                          p_pedido.transportadora,           
                          p_pedido.consignatario,            
                          p_pedido.tip_entrega,              
                          p_pedido.cliente_origem,          
                          p_pedido.origem_pedido,            
                          p_pedido.sequencia_entrega,        
                          p_pedido.fatura_antecip,           
                          p_pedido.viagem,                   
                          p_pedido.tip_proc_ped_venda,       
                          p_pedido.tip_cnfr_exped,
                          p_pedido.pedido_embalagem
                          
      EXIT FOREACH
    END FOREACH  
    
    LET p_pedido.num_ped_terceiro = p_pedidos.num_pedido_repres

    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","wms_pedido_venda")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    LET p_num_ped  = 0

    LET sql_prep = "SELECT val_parametro ",
                   "  FROM logix.wms_par_auxiliar@kitwms ",
                   " WHERE parametro = 'WMS006' ",
                   " order by val_parametro"

    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_par1 FROM sql_prep
    
    DECLARE cq_par1 CURSOR FOR var_par1
    
    FOREACH cq_par1 INTO p_num_ped  
       EXIT FOREACH 
    END FOREACH

    IF p_num_ped = 0 OR
       p_num_ped IS NULL THEN
       ERROR "PROBLEMA NUMERACAO PEDIDO PAR_AUXILIAR"
       SLEEP 1
       ROLLBACK WORK
       RETURN FALSE
    END IF    

    LET sql_prep = "SELECT val_parametro ",
                   "  FROM logix.mcg_par_global@kitwms ",
                   " WHERE parametro = 'WMS006' "

    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_par2 FROM sql_prep
    
    DECLARE cq_par2 CURSOR FOR var_par2
    
    FOREACH cq_par2 INTO p_num_ped_par  
       EXIT FOREACH 
    END FOREACH

    IF p_num_ped_par = 0 OR
       p_num_ped_par IS NULL THEN
       ERROR "PROBLEMA NUMERACAO PEDIDO MCG_PAR"
       SLEEP 1
       ROLLBACK WORK
       RETURN FALSE
    END IF    

    IF p_num_ped = p_num_ped_par THEN    

      LET p_ind_pari = p_num_ped + 1
      LET p_ind_parf = p_num_ped + 200
      LET p_den_par = 'WMS006'
      
      WHILE p_ind_pari <= p_ind_parf

          LET sql_prep1 = "INSERT INTO logix.wms_par_auxiliar@kitwms ",
                          "(parametro,val_parametro) ",
                          " VALUES (?,?)"
          
          LET sql_prep1 = sql_prep1 CLIPPED
          
          PREPARE var_inspar1 FROM sql_prep1
          
          EXECUTE var_inspar1 USING p_den_par,         
                                    p_ind_pari
          
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSAO","wms_par_auxiliar")
             ROLLBACK WORK
             RETURN FALSE
          END IF

          LET p_ind_pari = p_ind_pari + 1
          
      END WHILE 

      LET sql_prep = "UPDATE logix.mcg_par_global@kitwms ",                                           
                     "   SET val_parametro = ",p_ind_pari,
                     " WHERE parametro = 'WMS006'"
                       
      LET sql_prep = sql_prep CLIPPED
      
      PREPARE var_uppar1 FROM sql_prep
      
      EXECUTE var_uppar1 
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("ALTERACAO","mcg_par_global")
         ROLLBACK WORK
         RETURN FALSE
      END IF

    END IF 

    LET sql_prep = "DELETE FROM logix.wms_par_auxiliar@kitwms ",
                   " WHERE parametro = 'WMS006'",                            
                   " and val_parametro = ", p_num_ped
                     
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_delpar1 FROM sql_prep
    
    EXECUTE var_delpar1 
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("DELECAO","wms_par_auxiliar")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    LET sql_prep1 = "INSERT INTO logix.wms_pedido_venda@kitwms ", 
                    "(pedido_venda,planta,num_ped_terceiro,terceiro,programa_coleta, ",    
                    "cliente_terceiro,restricao,rota,dat_entrega,dat_emissao,dat_inclusao, ",       
                    "sit_pedido_venda,dat_sit_ped_venda,usuario,qtd_item,qtd_item_volume, ",    
                    "qtd_item_atendido,qtd_item_cancelado,cancel_exped,cnpj_cliente, ",       
                    "cliente_interno,lote_transf,transportadora,consignatario,tip_entrega, ",
                    "cliente_origem,origem_pedido,sequencia_entrega,fatura_antecip, ",     
                    "viagem,tip_proc_ped_venda,tip_cnfr_exped,pedido_embalagem) ",
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    
    LET sql_prep1 = sql_prep1 CLIPPED
    
    PREPARE var_inspd5 FROM sql_prep1
    
    EXECUTE var_inspd5 USING p_num_ped,          
                          p_pedido.planta,                
                          p_pedido.num_ped_terceiro,      
                          p_pedido.terceiro,             
                          p_pedido.programa_coleta,      
                          p_pedido.cliente_terceiro,     
                          p_pedido.restricao,            
                          p_pedido.rota,                 
                          p_pedido.dat_entrega,          
                          p_pedido.dat_emissao,          
                          p_dat_cur,         
                          'A', 
                          p_dat_cur,     
                          p_user,           
                          p_compl_it[p_ind].qtd_pecas_cancel, 
                          p_pedido.qtd_item_volume,      
                          '0',                             
                          '0',                             
                          p_pedido.cancel_exped,         
                          p_pedido.cnpj_cliente,         
                          p_pedido.cliente_interno,      
                          p_pedido.lote_transf,          
                          p_pedido.transportadora,       
                          p_pedido.consignatario,        
                          p_pedido.tip_entrega,          
                          p_pedido.cliente_origem,       
                          p_pedido.origem_pedido,        
                          p_pedido.sequencia_entrega,    
                          p_pedido.fatura_antecip,       
                          p_pedido.viagem,                
                          p_pedido.tip_proc_ped_venda,    
                          p_pedido.tip_cnfr_exped,
                          p_pedido.pedido_embalagem

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF

    LET p_num_seqw = 1  
           
    LET p_item_wms = p_ped_itens[p_ind].cod_item

    LET p_seq_terc = p_num_ped USING '&&&&&&&&&&', '-', p_num_seqw USING '&&&&&'

    LET sql_prep =   "SELECT lote,dat_entrega,tip_cnfr_exped",                             
                       " FROM logix.wms_item_ped_venda@kitwms", 
                       " WHERE pedido_venda = ", p_num_ped_wms,
                       " AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia
    
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_itpd5 FROM sql_prep
    DECLARE cq_itpd5 CURSOR FOR var_itpd5
    FOREACH cq_itpd5 INTO p_lote,                    
                          p_dat_entrega,                            
                          p_tip_cnfr_exped
      EXIT FOREACH
    END FOREACH   
    
    LET sql_prep1 = "INSERT INTO logix.wms_item_ped_venda@kitwms ",
                    "(pedido_venda,seq_item_pedido,item,seq_ped_terceiro,lote,qtd_solicitada,qtd_atendida, ",                                                           
                    "qtd_liquid,qtd_cancelada,qtd_canc_retorno,dat_entrega,sit_item_ped_venda,dat_sit_item_ped, ",                                                       
                    "tip_cnfr_exped) ",
                    " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    
    LET sql_prep1 = sql_prep1 CLIPPED
    
    PREPARE var_insit5 FROM sql_prep1
    
    EXECUTE var_insit5 USING p_num_ped,         
                           p_num_seqw,      
                           p_item_wms,                 
                           p_seq_terc,     
                           p_lote,                 
                           p_compl_it[p_ind].qtd_pecas_cancel,      
                           '0',         
                           '0',           
                           '0',        
                           '0',     
                           p_dat_entrega,          
                           'A',   
                           p_dat_cur,     
                           p_tip_cnfr_exped

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("INCLUSAO","wms_item_ped_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
                                                 
     LET p_audit_vdp.cod_empresa = p_cod_empresa
     LET p_audit_vdp.num_pedido = p_tela.num_pedido
     LET p_audit_vdp.tipo_informacao = 'M' 
     LET p_audit_vdp.tipo_movto = 'I'
     LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Qtd Cancelada no WMS problema estoque',
                             p_compl_it[p_ind].qtd_pecas_cancel,' Novo pedido gerado no WMS ',
                             p_num_ped, ' Terceiro - ',p_pedido.num_ped_terceiro, ' Logix -',p_num_ped_novo 
     LET p_audit_vdp.num_programa = 'ESP0464'
     LET p_audit_vdp.data =  TODAY
     LET p_audit_vdp.hora =  TIME 
     LET p_audit_vdp.usuario = p_user
     LET p_audit_vdp.num_transacao = 0  
     INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","audit_vdp")
        ROLLBACK WORK
        RETURN FALSE
     END IF

     LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
     LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
     LET p_audit_ped_ktm.num_ped_atu   = p_num_ped_novo 
     LET p_audit_ped_ktm.cod_item_ant  = p_ped_it_ant[p_ind].cod_item
     LET p_audit_ped_ktm.cod_item_atu  = p_ped_itens[p_ind].cod_item
     LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
     LET p_audit_ped_ktm.qtd_pecas_atu = p_compl_it[p_ind].qtd_pecas_cancel    
     LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
     LET p_audit_ped_ktm.pre_unit_atu  = p_ped_its.pre_unit 
     LET p_audit_ped_ktm.fat_conv_ant  = 0 
     LET p_audit_ped_ktm.fat_conv_atu  = 0
     LET p_audit_ped_ktm.texto         = p_audit_vdp.texto    
     LET p_audit_ped_ktm.data          =  TODAY
     LET p_audit_ped_ktm.hora          =  TIME 
     LET p_audit_ped_ktm.usuario       = p_user     
     
     INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
        ROLLBACK WORK
        RETURN FALSE
     END IF              

     LET p_msg_fim = "It transferido novo pedido ",p_num_ped_novo," ped WMS ",p_num_ped," Terc ",p_pedido.num_ped_terceiro
 ELSE                                           
    LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                   "   SET qtd_item = qtd_item + ",p_compl_it[p_ind].qtd_somar,
                   " WHERE pedido_venda = ",p_num_ped_wms,
                   "   AND num_ped_terceiro = '",p_tela.num_pedido_cli,"'"
     
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_upped6 FROM sql_prep
     
    EXECUTE var_upped6 

    LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                   "   SET qtd_solicitada = qtd_solicitada + ",p_compl_it[p_ind].qtd_somar,
                   " WHERE pedido_venda = ",p_num_ped_wms,
                   "   AND seq_item_pedido  = ",p_ped_itens[p_ind].num_sequencia       
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_upitpd5 FROM sql_prep
    
    EXECUTE var_upitpd5 

     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
        ROLLBACK WORK
        RETURN FALSE
     END IF
       
    UPDATE ped_itens
       SET qtd_pecas_solic = qtd_pecas_solic + p_compl_it[p_ind].qtd_somar
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_tela.num_pedido
       AND cod_item      = p_ped_itens[p_ind].cod_item  
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","ped_itens")
       ROLLBACK WORK
       RETURN FALSE
    END IF
         
    LET p_audit_vdp.cod_empresa = p_cod_empresa
    LET p_audit_vdp.num_pedido = p_tela.num_pedido
    LET p_audit_vdp.tipo_informacao = 'M' 
    LET p_audit_vdp.tipo_movto = 'I'
    LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Qtd acrecida ',p_compl_it[p_ind].qtd_somar
    LET p_audit_vdp.num_programa = 'ESP0464'
    LET p_audit_vdp.data =  TODAY
    LET p_audit_vdp.hora =  TIME 
    LET p_audit_vdp.usuario = p_user
    LET p_audit_vdp.num_transacao = 0  
    INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","audit_vdp")
       ROLLBACK WORK
       RETURN FALSE
    END IF

     LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
     LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
     LET p_audit_ped_ktm.num_ped_atu   = p_tela.num_pedido
     LET p_audit_ped_ktm.cod_item_ant  = p_ped_itens[p_ind].cod_item
     LET p_audit_ped_ktm.cod_item_atu  = p_ped_itens[p_ind].cod_item
     LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
     LET p_audit_ped_ktm.qtd_pecas_atu = p_ped_it_ant[p_ind].qtd_saldo + p_compl_it[p_ind].qtd_somar    
     LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
     LET p_audit_ped_ktm.pre_unit_atu  = p_ped_it_ant[p_ind].pre_unit    
     LET p_audit_ped_ktm.fat_conv_ant  = 0 
     LET p_audit_ped_ktm.fat_conv_atu  = 0
     LET p_audit_ped_ktm.texto         = p_audit_vdp.texto    
     LET p_audit_ped_ktm.data          =  TODAY
     LET p_audit_ped_ktm.hora          =  TIME 
     LET p_audit_ped_ktm.usuario       = p_user     
     
     INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
        ROLLBACK WORK
        RETURN FALSE
     END IF              
    
    LET p_msg_fim = " ALTERACAO EFETUADA COM SUCESSO"
 END IF
 COMMIT WORK  
 RETURN TRUE 
END FUNCTION

#-----------------------------#
 FUNCTION esp0464_efetiva_err()
#-----------------------------#   
 DEFINE l_qtd_tot_ped  INTEGER,
        l_qtd_saldo_it INTEGER 

 BEGIN WORK
 IF p_compl_it[p_ind].qtd_pecas_cancel > 0 THEN 

    LET sql_prep =   "SELECT (qtd_item - qtd_item_cancelado) ",                            
                      " FROM logix.wms_pedido_venda@kitwms ",
                     " WHERE pedido_venda = '", p_num_ped_wms,"'",
                       " AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"
    
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_ped6 FROM sql_prep
    DECLARE cq_ped6 CURSOR FOR var_ped6
    FOREACH cq_ped6 INTO l_qtd_tot_ped      
      EXIT FOREACH
    END FOREACH 

    IF l_qtd_tot_ped > p_compl_it[p_ind].qtd_pecas_cancel THEN    
       LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                      "   SET qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"

       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_uppd6 FROM sql_prep
       
       EXECUTE var_uppd6 

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    ELSE
       LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                      "   SET qtd_item_cancelado = qtd_item_cancelado + ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " ,sit_pedido_venda = 'C' ",
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"

       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_uppd7 FROM sql_prep
       
       EXECUTE var_uppd7 

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    END IF

    LET sql_prep =   "SELECT (qtd_solicitada - qtd_cancelada) ",                            
                        " FROM logix.wms_item_ped_venda@kitwms ",
                       " WHERE pedido_venda = '", p_num_ped_wms,"'",
                        " AND seq_item_pedido = '",p_ped_itens[p_ind].num_sequencia,"'" 
    
    
    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_itpd6 FROM sql_prep
    DECLARE cq_itpd6 CURSOR FOR var_itpd6
    FOREACH cq_itpd6 INTO l_qtd_saldo_it    
      EXIT FOREACH
    END FOREACH 

    IF l_qtd_saldo_it > p_compl_it[p_ind].qtd_pecas_cancel THEN    
       LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                      "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel ,
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND seq_item_pedido = ",p_ped_itens[p_ind].num_sequencia       
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_upitpd6 FROM sql_prep
       
       EXECUTE var_upitpd6 

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    ELSE
       LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                      "   SET qtd_cancelada = qtd_cancelada +  ",p_compl_it[p_ind].qtd_pecas_cancel,
                      " ,sit_item_ped_venda = 'C' ",
                      " WHERE pedido_venda = ",p_num_ped_wms,
                      "   AND seq_item_pedido = ",p_ped_itens[p_ind].num_sequencia       
       
       LET sql_prep = sql_prep CLIPPED
       
       PREPARE var_upitpd7 FROM sql_prep
       
       EXECUTE var_upitpd7 

       IF sqlca.sqlcode <> 0 THEN 
          CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
          ROLLBACK WORK
          RETURN FALSE
       END IF
    END IF

    UPDATE ped_itens
       SET qtd_pecas_cancel = qtd_pecas_cancel + p_compl_it[p_ind].qtd_pecas_cancel
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_tela.num_pedido
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","ped_itens")
        ROLLBACK WORK
        RETURN FALSE
     END IF

    LET p_audit_vdp.cod_empresa = p_cod_empresa
    LET p_audit_vdp.num_pedido = p_tela.num_pedido
    LET p_audit_vdp.tipo_informacao = 'M' 
    LET p_audit_vdp.tipo_movto = 'I'
    LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Qtd Cancelada por erro de pedido ',p_compl_it[p_ind].qtd_pecas_cancel
    LET p_audit_vdp.num_programa = 'ESP0464'
    LET p_audit_vdp.data =  TODAY
    LET p_audit_vdp.hora =  TIME 
    LET p_audit_vdp.usuario = p_user
    LET p_audit_vdp.num_transacao = 0  
    INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","audit_vdp")
       ROLLBACK WORK
       RETURN FALSE
    END IF

    LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
    LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
    LET p_audit_ped_ktm.num_ped_atu   = p_tela.num_pedido
    LET p_audit_ped_ktm.cod_item_ant  = p_ped_itens[p_ind].cod_item
    LET p_audit_ped_ktm.cod_item_atu  = p_ped_itens[p_ind].cod_item
    LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
    LET p_audit_ped_ktm.qtd_pecas_atu = p_ped_it_ant[p_ind].qtd_saldo - p_compl_it[p_ind].qtd_pecas_cancel    
    LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
    LET p_audit_ped_ktm.pre_unit_atu  = p_ped_it_ant[p_ind].pre_unit 
    LET p_audit_ped_ktm.fat_conv_ant  = 0 
    LET p_audit_ped_ktm.fat_conv_atu  = 0
    LET p_audit_ped_ktm.texto         = p_audit_vdp.texto    
    LET p_audit_ped_ktm.data          =  TODAY
    LET p_audit_ped_ktm.hora          =  TIME 
    LET p_audit_ped_ktm.usuario       = p_user     
    
    INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
    IF sqlca.sqlcode <> 0 THEN 
       CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
       ROLLBACK WORK
       RETURN FALSE
    END IF              
 ELSE                                           
    LET sql_prep = "UPDATE logix.wms_pedido_venda@kitwms ",                                           
                   "   SET qtd_item = qtd_item + ",p_compl_it[p_ind].qtd_somar,
                   " WHERE pedido_venda = ",p_num_ped_wms,
                   "   AND num_ped_terceiro = '",p_tela.num_pedido_cli CLIPPED,"'"

    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_uppd8 FROM sql_prep
    
    EXECUTE var_uppd8 

     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","wms_pedido_venda")
        ROLLBACK WORK
        RETURN FALSE
     END IF

    LET sql_prep = "UPDATE logix.wms_item_ped_venda@kitwms ",                                           
                   "   SET qtd_solicitada = qtd_solicitada + ",p_compl_it[p_ind].qtd_somar,
                   " WHERE pedido_venda = ",p_num_ped_wms,
                   "   AND seq_item_pedido = ",p_ped_itens[p_ind].num_sequencia       

    LET sql_prep = sql_prep CLIPPED
    
    PREPARE var_upitpd8 FROM sql_prep
    
    EXECUTE var_upitpd8 

     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","wms_item_ped_venda")
        ROLLBACK WORK
        RETURN FALSE
     END IF
       
    UPDATE ped_itens
       SET qtd_pecas_solic = qtd_pecas_solic + p_compl_it[p_ind].qtd_somar
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_tela.num_pedido
       AND num_sequencia = p_ped_itens[p_ind].num_sequencia
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("ALTERACAO","ped_itens")
        ROLLBACK WORK
        RETURN FALSE
     END IF
         
     LET p_audit_vdp.cod_empresa = p_cod_empresa
     LET p_audit_vdp.num_pedido = p_tela.num_pedido
     LET p_audit_vdp.tipo_informacao = 'M' 
     LET p_audit_vdp.tipo_movto = 'I'
     LET p_audit_vdp.texto = p_compl_it[p_ind].den_obs CLIPPED,' Qtd acrecida por erro de pedido ',p_compl_it[p_ind].qtd_somar
     LET p_audit_vdp.num_programa = 'ESP0464'
     LET p_audit_vdp.data =  TODAY
     LET p_audit_vdp.hora =  TIME 
     LET p_audit_vdp.usuario = p_user
     LET p_audit_vdp.num_transacao = 0  
     INSERT INTO audit_vdp VALUES (p_audit_vdp.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","audit_vdp")
        ROLLBACK WORK
        RETURN FALSE
     END IF
     
     LET p_audit_ped_ktm.cod_empresa   = p_cod_empresa 
     LET p_audit_ped_ktm.num_ped_ant   = p_tela.num_pedido    
     LET p_audit_ped_ktm.num_ped_atu   = p_tela.num_pedido
     LET p_audit_ped_ktm.cod_item_ant  = p_ped_itens[p_ind].cod_item
     LET p_audit_ped_ktm.cod_item_atu  = p_ped_itens[p_ind].cod_item
     LET p_audit_ped_ktm.qtd_pecas_ant = p_ped_it_ant[p_ind].qtd_saldo    
     LET p_audit_ped_ktm.qtd_pecas_atu = p_ped_it_ant[p_ind].qtd_saldo + p_compl_it[p_ind].qtd_somar    
     LET p_audit_ped_ktm.pre_unit_ant  = p_ped_it_ant[p_ind].pre_unit   
     LET p_audit_ped_ktm.pre_unit_atu  = p_ped_it_ant[p_ind].pre_unit  
     LET p_audit_ped_ktm.fat_conv_ant  = 0 
     LET p_audit_ped_ktm.fat_conv_atu  = 0
     LET p_audit_ped_ktm.texto         = p_audit_vdp.texto    
     LET p_audit_ped_ktm.data          =  TODAY
     LET p_audit_ped_ktm.hora          =  TIME 
     LET p_audit_ped_ktm.usuario       = p_user     
     
     INSERT INTO audit_ped_ktm VALUES (p_audit_ped_ktm.*)
     IF sqlca.sqlcode <> 0 THEN 
        CALL log003_err_sql("INCLUSAO","audit_ped_ktm")
        ROLLBACK WORK
        RETURN FALSE
     END IF              
   END IF
   LET p_msg_fim = " ALTERACAO EFETUADA COM SUCESSO"
 COMMIT WORK
 RETURN TRUE 
END FUNCTION                    