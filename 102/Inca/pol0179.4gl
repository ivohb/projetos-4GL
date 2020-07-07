#-----------------------------------------------------------------#
# SISTEMA.: VENDA E DISTRIBUICAO DE PRODUTOS                      #
# PROGRAMA: POL0179                                               #
# MODULOS.: POL0179 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG0090 - LOG0270 - LOG1300 - LOG1400       #
#           VDP2670                                               #
# OBJETIVO: CANCELAMENTO TOTAL/PARCIAL DE PEDIDOS                 #
# DATA....: 10/02/2002                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_ped_itens             RECORD LIKE ped_itens.*,
         p_pedidos               RECORD LIKE pedidos.*,
         p_pedidosr              RECORD LIKE pedidos.*,
         p_prev_producao         RECORD LIKE previsao_producao.*,
####     p_ctr_meta              RECORD LIKE ctr_meta.*,
         p_par_vdp               RECORD LIKE par_vdp.*,
         p_cod_empresa           LIKE empresa.cod_empresa,
         p_den_empresa           LIKE empresa.den_empresa,
         p_user                  LIKE usuario.nom_usuario,
         p_qtd_cancel            LIKE ped_itens.qtd_pecas_cancel,
         p_ies_estatistica       LIKE nat_operacao.ies_estatistica,
         p_ies_cons, p_last_row  SMALLINT,
         p_count                 SMALLINT,
         pa_curr                 SMALLINT,
         sc_curr                 SMALLINT,
         p_status                SMALLINT,
         p_funcao                CHAR(15),
         p_houve_erro            SMALLINT,
         p_msg                   CHAR(300)
         

  DEFINE t_ped_itens             ARRAY[1080] OF RECORD
              num_sequencia        LIKE ped_itens.num_sequencia,
              cod_item             LIKE ped_itens.cod_item,
              qtd_pecas_saldo      LIKE ped_itens.qtd_pecas_solic,
              qtd_pecas_reserv     LIKE ped_itens.qtd_pecas_reserv,
              qtd_pecas_cancel     LIKE ped_itens.qtd_pecas_cancel
                                 END RECORD

  DEFINE p_cod_cliente           LIKE clientes.cod_cliente,
         p_nom_cliente           LIKE clientes.nom_cliente,
         p_cod_cidade            LIKE clientes.cod_cidade,
         p_cod_uni_feder         LIKE cidades.cod_uni_feder,
         p_den_cidade            LIKE cidades.den_cidade,
         p_cod_motivo            LIKE mot_cancel.cod_motivo,
         p_den_motivo            LIKE mot_cancel.den_motivo,
         p_qtd_ele_itens         SMALLINT,
         p_dat_cancel            DATE

  DEFINE p_comando               CHAR(80),
         p_caminho               CHAR(80),
         p_help                  CHAR(80),
         p_cancel                INTEGER,
         p_nom_tela              CHAR(80),
         p_mensag                CHAR(200),
         p_tipo_i                LIKE audit_vdp.tipo_informacao,
         p_tipo_m                LIKE audit_vdp.tipo_movto

  DEFINE p_tot_ped_novo        DECIMAL(17,2),
         p_total_pedido        DECIMAL(17,2),
         p_ies_sit_pedido      LIKE pedidos.ies_sit_pedido,
         p_cont                SMALLINT,
         p_pct_desc_adic       LIKE pedidos.pct_desc_adic,
         p_novo_ped_carteir    DECIMAL(17,2),
         p_tot_ped_ant         DECIMAL(17,2),
         p_saldo               LIKE ped_itens.qtd_pecas_solic
# DEFINE  p_versao  CHAR(17) #Favor Nao Alterar esta linha (SUPORTE)
  DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0179-10.02.01"
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
  SET LOCK MODE TO WAIT 180
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho 
  OPTIONS
    HELP FILE p_help

  CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
     CALL pol0179_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0179_controle()
#--------------------------#
  CALL  pol0179_cria_t_mestre()

  CALL log006_exibe_teclas("01", p_versao)
  INITIALIZE p_pedidos.*, p_ies_estatistica TO NULL
  LET p_qtd_cancel = 0
  SELECT * INTO p_par_vdp.* FROM par_vdp
   WHERE par_vdp.cod_empresa = p_cod_empresa

  CALL log130_procura_caminho("POL0179") RETURNING p_nom_tela 
  OPEN WINDOW w_pol01790 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, COMMENT LINE LAST -1, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND KEY("T") "Total"    "Cancelamento total do Pedido"
      HELP 2010
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","POL0179","MO") THEN 
         CALL pol0179_processa_cancelamento_total()
         IF p_houve_erro = FALSE THEN 
            CALL log085_transacao("COMMIT")
            IF sqlca.sqlcode = 0 THEN 
            ELSE 
               CALL log003_err_sql("PROCESSA_CANCEL_TOT ","PEDIDOS  ")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE 
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
    COMMAND KEY("I") "parcial_Item"   "Cancelamento parcial Itens do Pedido"
      HELP 2011
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","POL0179","CO") THEN 
         LET p_funcao = "ITEM"
         CALL pol0179_processa_cancelamento_parcial()
         IF p_houve_erro = FALSE THEN 
            CALL log085_transacao("COMMIT")
            IF sqlca.sqlcode = 0 THEN 
            ELSE 
               CALL log003_err_sql("PROCESSA_CANCEL_1 ","PEDIDOS  ")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE 
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0179_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
      DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 008
####  CALL vdp267_atualiza_ctr_meta("CANCELAMENTO")
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol01790
END FUNCTION

#-----------------------#
FUNCTION pol0179_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
 FUNCTION pol0179_cria_t_mestre()
#-------------------------------#
WHENEVER ERROR CONTINUE
DROP TABLE t_mestre
DROP TABLE t_item
DROP TABLE t_item_bnf

 CREATE  TEMP   TABLE t_mestre
 (num_pedido            DECIMAL(6,0),
  cod_repres            DECIMAL(4,0),
  cod_nat_oper          INTEGER,
  cod_cnd_pgto          DECIMAL(3,0),
  pct_desc_adic         DECIMAL(4,2),
  cod_moeda             DECIMAL(3,0) 
 );

CREATE  TEMP   TABLE t_item
 (num_pedido            DECIMAL(6,0),
  cod_item              CHAR(15),
  num_sequencia         DECIMAL(5,0),
  pre_unit              DECIMAL(13,2),
  qtd_pecas_solic       DECIMAL(10,3), 
  prz_entrega           DATE,
  pct_desc_adic         DECIMAL(4,2)
 );

    CREATE TEMP TABLE t_item_bnf
          (num_pedido            DECIMAL(6,0),
           cod_item              CHAR(15),
           num_sequencia         DECIMAL(5,0),
           pre_unit              DECIMAL(13,2),
           qtd_pecas_solic       DECIMAL(10,3), 
           prz_entrega           DATE,
           pct_desc_adic         DECIMAL(4,2)
          );

WHENEVER ERROR STOP 

END FUNCTION

#-----------------------------------------------#
 FUNCTION pol0179_processa_cancelamento_parcial()
#-----------------------------------------------#
  LET p_houve_erro = FALSE
  CALL log085_transacao("BEGIN")

  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  CALL set_count(0)
  LET p_count = 0
  CALL log006_exibe_teclas("02 03 07", p_versao)
  CURRENT WINDOW IS w_pol01790
  LET p_dat_cancel = TODAY
  INPUT p_pedidos.cod_empresa, p_pedidos.num_pedido, p_cod_motivo ,p_dat_cancel
             FROM cod_empresa, num_pedido, cod_motivo ,dat_cancel 
  
   AFTER FIELD cod_empresa
      SELECT count(*)
        INTO p_count 
        FROM empresa
       WHERE cod_empresa = p_pedidos.cod_empresa
      IF p_count = 0 THEN 
         ERROR "COD. EMPRESA INVALIDO"
         NEXT FIELD cod_empresa
      ELSE
         LET p_cod_empresa = p_pedidos.cod_empresa
      END IF 

   AFTER FIELD num_pedido
    IF pol0179_verifica_pedido() THEN 
       IF p_pedidos.ies_sit_pedido = "9" THEN 
          ERROR " PEDIDO ja' cancelado "
          NEXT FIELD num_pedido
       ELSE 
          CALL pol0179_busca_nom_cliente_den_cidade()
          DISPLAY p_cod_cliente,
                  p_nom_cliente,
                  p_den_cidade,
                  p_cod_uni_feder TO cod_cliente,
                                     nom_cliente,
                                     den_cidade,
                                     cod_uni_feder
       END IF
    ELSE
       ERROR " PEDIDO nao cadastrado ou ordem de montagem aberta "
       NEXT FIELD num_pedido
    END IF

    BEFORE FIELD cod_motivo
           DISPLAY "( Zoom )" AT 3,67

    AFTER  FIELD cod_motivo
           DISPLAY "--------" AT 3,67
           IF p_cod_motivo IS NOT NULL THEN 
              IF pol0179_verifica_cod_motivo() THEN 
                 DISPLAY p_den_motivo TO den_motivo
              ELSE 
                 ERROR " MOTIVO DE CANCELAMENTO nao cadastrado "
                 NEXT FIELD cod_motivo
              END IF
           END IF

      BEFORE FIELD dat_cancel
            IF p_dat_cancel IS NULL THEN 
               LET p_dat_cancel = TODAY
                DISPLAY p_dat_cancel TO dat_cancel
            END IF

      AFTER FIELD dat_cancel
            IF p_dat_cancel IS NULL THEN 
               ERROR " Data invalida."
               NEXT FIELD dat_cancel
            END IF
            IF p_dat_cancel > TODAY THEN 
               ERROR " Data maior que data atual nao e aceita."
               NEXT FIELD dat_cancel
            END IF

    ON KEY (control-w)
           CALL pol0179_help()
    ON KEY (control-z)
       CASE
         WHEN infield(cod_motivo)
           CALL log009_popup(6,21,"MOTIVO CANCELAMENTO","mot_cancel",
                           "cod_motivo","den_motivo",
                           "vdp0030","N","") RETURNING p_cod_motivo
           CALL log006_exibe_teclas("01 02 03 07", p_versao)
           CURRENT WINDOW IS w_pol01790
           DISPLAY p_cod_motivo TO cod_motivo
       END CASE

  END INPUT
  IF int_flag THEN 
     LET p_pedidos.*     = p_pedidosr.*
     CLEAR FORM
     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_pol01790
     ERROR " Cancelamento cancelado "
     LET int_flag = 0
     RETURN
  ELSE 
     LET int_flag = 0
  END IF
  IF p_funcao = "ITEM" THEN 
     LET p_funcao = "PARCIAL"
     IF pol0179_carrega_itens() THEN 
        IF pol0179_cancela_quantidade() THEN 
           CALL log006_exibe_teclas("01", p_versao)
           CURRENT WINDOW IS w_pol01790
        ELSE 
           CALL log006_exibe_teclas("01", p_versao)
           CURRENT WINDOW IS w_pol01790
           ERROR " Cancelamento cancelado "
           LET int_flag = 0
        END IF
     ELSE 
        CALL log006_exibe_teclas("01", p_versao)
        CURRENT WINDOW IS w_pol01790
        ERROR " PEDIDO sem itens "
     END IF
  END IF
 END FUNCTION

#-------------------------------#
 FUNCTION pol0179_carrega_itens()
#-------------------------------#
 DECLARE cq_ped_itens_1 CURSOR FOR
 SELECT * FROM ped_itens
  WHERE ped_itens.num_pedido = p_pedidos.num_pedido
    AND ped_itens.cod_empresa = p_cod_empresa
##  AND (ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend -
##       ped_itens.qtd_pecas_cancel) > 0 
   ORDER BY num_sequencia
 OPEN cq_ped_itens_1
 FETCH cq_ped_itens_1 INTO p_ped_itens.*
 IF sqlca.sqlcode = NOTFOUND THEN 
    CLOSE cq_ped_itens_1    
    RETURN false
 END IF
 LET p_count   = 0
 LET p_tot_ped_novo = 0
 WHILE sqlca.sqlcode <> NOTFOUND
   LET p_count = p_count + 1
   CALL set_count(p_count)
   IF p_count > 1080 THEN 
      ERROR "Pedido com mais de 1080 itens "
      EXIT WHILE
   END IF
   LET t_ped_itens[p_count].num_sequencia    =  p_ped_itens.num_sequencia
   LET t_ped_itens[p_count].cod_item         =  p_ped_itens.cod_item
   LET t_ped_itens[p_count].qtd_pecas_reserv =  p_ped_itens.qtd_pecas_reserv +
                                                p_ped_itens.qtd_pecas_romaneio
   LET t_ped_itens[p_count].qtd_pecas_saldo  =  p_ped_itens.qtd_pecas_solic -
                                                p_ped_itens.qtd_pecas_atend -
                                                p_ped_itens.qtd_pecas_cancel
   IF t_ped_itens[p_count].qtd_pecas_saldo < 0 THEN 
      LET t_ped_itens[p_count].qtd_pecas_saldo = 0
   END IF
   IF p_funcao = "PARCIAL" THEN 
      LET t_ped_itens[p_count].qtd_pecas_cancel =  0
   ELSE
      LET t_ped_itens[p_count].qtd_pecas_cancel = 
          t_ped_itens[p_count].qtd_pecas_saldo
   END IF
   IF p_funcao = "PARCIAL" THEN 
   ELSE
      LET p_saldo = t_ped_itens[p_count].qtd_pecas_saldo
      IF p_saldo IS NULL THEN  
         LET p_saldo = 0
      END IF 
      IF p_ped_itens.pre_unit IS NULL THEN 
         LET p_ped_itens.pre_unit = 0 
      END IF 
 
      CALL pol0179_calcula_valor_pedido(p_pedidos.num_pedido,
                                       t_ped_itens[p_count].num_sequencia,
                                       p_pedidos.pct_desc_adic,
                                       p_ped_itens.pct_desc_adic,
                                       p_saldo,
                                       p_ped_itens.pre_unit) 
      RETURNING p_total_pedido
      IF p_total_pedido IS NOT NULL THEN
         LET p_tot_ped_novo = p_tot_ped_novo + p_total_pedido 
      END IF
   END IF
   FETCH cq_ped_itens_1 INTO p_ped_itens.*
  END WHILE
  LET p_qtd_ele_itens = p_count
  CLOSE cq_ped_itens_1
  RETURN true
END FUNCTION
       
#------------------------------------#
 FUNCTION pol0179_cancela_quantidade()
#------------------------------------#
  DEFINE p_pct_desc_adic_i     LIKE ped_itens.pct_desc_adic,
         p_pre_unitw           LIKE ped_itens.pre_unit

 INPUT ARRAY t_ped_itens WITHOUT DEFAULTS FROM s_ped_itens.*
    BEFORE FIELD qtd_pecas_cancel
           LET pa_curr = arr_curr()
           LET sc_curr = scr_line()
           IF pa_curr > p_count THEN 
              EXIT INPUT
           END IF

    AFTER  FIELD qtd_pecas_cancel
           IF t_ped_itens[pa_curr].qtd_pecas_cancel < 0 THEN 
              ERROR " Quantidade a cancelar menor que zero. "
              NEXT FIELD qtd_pecas_cancel
           END IF
           IF t_ped_itens[pa_curr].qtd_pecas_cancel > 
              t_ped_itens[pa_curr].qtd_pecas_saldo THEN 
              ERROR " Quantidade a cancelar maior que o saldo "
              NEXT FIELD qtd_pecas_cancel
           END IF
           LET p_qtd_cancel = p_qtd_cancel + t_ped_itens[pa_curr].qtd_pecas_cancel
      LET p_saldo = t_ped_itens[pa_curr].qtd_pecas_cancel
      IF p_saldo IS NULL THEN  
         LET p_saldo = 0
      END IF 

      SELECT pct_desc_adic, pre_unit
        INTO p_pct_desc_adic_i, p_pre_unitw
        FROM ped_itens
       WHERE ped_itens.cod_empresa = p_cod_empresa
         AND ped_itens.num_pedido  = p_pedidos.num_pedido
         AND ped_itens.num_sequencia = t_ped_itens[pa_curr].num_sequencia

      IF p_pre_unitw IS NULL THEN 
         LET p_pre_unitw = 0 
      END IF 
      IF p_pct_desc_adic_i IS NULL THEN
         LET p_pct_desc_adic_i = 0 
      END IF
 
      CALL pol0179_calcula_valor_pedido(p_pedidos.num_pedido,
                                       t_ped_itens[pa_curr].num_sequencia,
                                       p_pedidos.pct_desc_adic,
                                       p_pct_desc_adic_i,
                                       p_saldo,
                                       p_pre_unitw) 
      RETURNING p_total_pedido
      IF p_total_pedido IS NOT NULL THEN
         LET p_tot_ped_novo = p_tot_ped_novo + p_total_pedido 
      END IF
 ON KEY (control-w)
        CALL pol0179_help()
END INPUT
 IF int_flag THEN 
    RETURN false
 ELSE
    LET int_flag = 0
    IF log004_confirm(17,43) THEN 
       CALL pol0179_efetiva_cancelamento_itens()
       IF p_pedidos.ies_sit_pedido <> "A" AND
          p_pedidos.ies_sit_pedido <> "F" THEN 
         #IF pol0179_verifica_credito_cliente() = FALSE THEN 
         #   ERROR " Limite de Credito para Cliente Excedido. "      
         #   LET p_houve_erro = TRUE
         #ELSE
         #   CALL pol0179_atualiza_ped_carteira()
         #END IF 
       END IF  
       MESSAGE " Cancelamento efetuado com sucesso " ATTRIBUTE(REVERSE)
    END IF
    RETURN true
 END IF
END FUNCTION

#---------------------------------#
 FUNCTION pol0179_verifica_pedido()
#---------------------------------#
 DEFINE  p_contador       SMALLINT   
     
 LET p_contador = 0

 SELECT pedidos.*
   INTO p_pedidos.*
   FROM pedidos
  WHERE pedidos.cod_empresa   = p_cod_empresa
    AND pedidos.num_pedido    = p_pedidos.num_pedido
 IF sqlca.sqlcode = 0 THEN  
    SELECT count(*) 
      INTO p_contador
      FROM ordem_montag_item a, ordem_montag_mest b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_pedido  = p_pedidos.num_pedido
       AND b.ies_sit_om <> "F"  
       AND a.cod_empresa = b.cod_empresa 
       AND a.num_om = b.num_om 
    IF p_contador > 0 THEN 
       RETURN false 
    ELSE
       RETURN true
    END IF
 ELSE
    RETURN false
 END IF
END FUNCTION

#-----------------------------#
 FUNCTION pol0179_exibe_dados()
#-----------------------------#
 DISPLAY ARRAY t_ped_itens TO s_ped_itens.*

 IF int_flag THEN 
    RETURN false
 ELSE
    RETURN true
 END IF
END FUNCTION

#----------------------------------------------#
 FUNCTION pol0179_busca_nom_cliente_den_cidade()
#----------------------------------------------#
  SELECT clientes.cod_cliente,
         clientes.nom_cliente,
         clientes.cod_cidade
    INTO p_cod_cliente,
         p_nom_cliente,
         p_cod_cidade
    FROM clientes
   WHERE clientes.cod_cliente  = p_pedidos.cod_cliente

  SELECT den_cidade,
         cod_uni_feder
    INTO p_den_cidade,
         p_cod_uni_feder
    FROM cidades
   WHERE cidades.cod_cidade = p_cod_cidade
END FUNCTION
         
#--------------------------------------------#
 FUNCTION pol0179_efetiva_cancelamento_itens()
#--------------------------------------------#
{****************** PREVISAO DE PRODUCAO - INICIO ***********************}
 DEFINE p_semana, p_ano SMALLINT,
        p_audit_logix   RECORD LIKE audit_logix.*
{****************** PREVISAO DE PRODUCAO - TERMINO **********************}
 WHENEVER ERROR CONTINUE 
 FOR p_count = 1 TO p_qtd_ele_itens
     IF t_ped_itens[p_count].qtd_pecas_cancel IS NULL OR
        t_ped_itens[p_count].qtd_pecas_cancel = 0 THEN 
     ELSE 
        DECLARE cu_ped_itens CURSOR WITH HOLD FOR
        SELECT *
          FROM ped_itens
         WHERE ped_itens.cod_empresa   = p_cod_empresa
           AND ped_itens.num_pedido    = p_pedidos.num_pedido
           AND ped_itens.num_sequencia = t_ped_itens[p_count].num_sequencia
           FOR UPDATE
        OPEN cu_ped_itens
        FETCH cu_ped_itens INTO p_ped_itens.*
        IF sqlca.sqlcode = 0 THEN 
           UPDATE ped_itens
              SET ped_itens.qtd_pecas_cancel = p_ped_itens.qtd_pecas_cancel +
                                               t_ped_itens[p_count].qtd_pecas_cancel
            WHERE num_pedido              = p_ped_itens.num_pedido
              AND ped_itens.num_sequencia = p_ped_itens.num_sequencia
              AND ped_itens.cod_empresa   = p_cod_empresa              
           IF sqlca.sqlcode = 0 THEN 
              INITIALIZE p_mensag TO NULL
              LET p_tipo_i = "I"
              LET p_tipo_m = "C"
              CALL pol0179_verifica_alteracoes_ped_itens()
              CALL pol0179_insert_t_item() 
           ELSE 
              CALL log003_err_sql("ATUALIZACAO","PED_ITENS2")
              LET p_houve_erro = TRUE
           END IF
 
           LET p_semana = log027_numero_semana(p_ped_itens.prz_entrega)
           LET p_ano = YEAR(p_ped_itens.prz_entrega)

{****************** PREVISAO DE PRODUCAO - INICIO ***********************}

           UPDATE previsao_producao
              SET qtd_pedido = (qtd_pedido - 
                                t_ped_itens[p_count].qtd_pecas_cancel)
            WHERE previsao_producao.cod_item    = p_ped_itens.cod_item
              AND previsao_producao.num_semana  = p_semana
              AND previsao_producao.ano         = p_ano
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("UPDATE","PREVISAO_PRODUCAO1")  
             LET p_houve_erro = TRUE
          END IF
          LET p_audit_logix.cod_empresa = p_cod_empresa
          LET p_audit_logix.texto = "CANCELAMENTO PREVISAO PRODUCAO DO ITEM ",
                                     p_ped_itens.cod_item CLIPPED,
                                    " SEMANA ",p_semana,
                                    " ANO ", p_ano,
                                    " QTD. ", t_ped_itens[p_count].qtd_pecas_cancel
          LET p_audit_logix.num_programa = "POL0179"
          LET p_audit_logix.data = TODAY
          LET p_audit_logix.hora = TIME
          LET p_audit_logix.usuario = p_user
          INSERT INTO audit_logix VALUES(p_audit_logix.*)
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("INSERT","AUDIT_LOGIX1")
             LET p_houve_erro = TRUE
          END IF

{****************** PREVISAO DE PRODUCAO - TERMINO **********************}
        
             INSERT INTO ped_itens_cancel VALUES (p_ped_itens.cod_empresa,
                                                  p_ped_itens.num_pedido,
                                                  p_ped_itens.num_sequencia,
                                                  p_ped_itens.cod_item,
                                                  p_dat_cancel,
                                                  p_cod_motivo,
                                                  t_ped_itens[p_count].qtd_pecas_cancel,
                                                  0)
             IF sqlca.sqlcode = 0 THEN             
             ELSE 
                CALL log003_err_sql("INCLUSAO","PED_ITENS_CANCEL2")
                LET p_houve_erro = TRUE
             END IF
      END IF
      CLOSE cu_ped_itens
      CALL pol0179_incl_ped_of_pcp()
 END IF
 END FOR
 WHENEVER ERROR STOP 
 END FUNCTION

#-----------------------------------#
 FUNCTION  pol0179_insert_t_item()  
#-----------------------------------#
DEFINE p_temp_item      RECORD
               	num_pedido      LIKE ped_itens.num_pedido ,    
                cod_item        LIKE ped_itens.cod_item ,      
                num_sequencia   LIKE ped_itens.num_sequencia,
                pre_unit        LIKE ped_itens.pre_unit ,      
                qtd_pecas_solic LIKE ped_itens.qtd_pecas_solic,
                prz_entrega     LIKE ped_itens.prz_entrega,    
                pct_desc_adic   LIKE ped_itens.pct_desc_adic  
                        END RECORD
  DEFINE p_saldo         LIKE ped_itens.qtd_pecas_solic
      SELECT * INTO p_temp_item.*   
        FROM t_item   
       WHERE t_item.num_pedido = p_ped_itens.num_pedido
         AND t_item.cod_item   = p_ped_itens.cod_item    
         AND t_item.num_sequencia = p_ped_itens.num_sequencia
         IF sqlca.sqlcode = NOTFOUND 
         THEN LET p_saldo  = t_ped_itens[p_count].qtd_pecas_cancel 
              INSERT INTO t_item VALUES (p_ped_itens.num_pedido      , 
                                         p_ped_itens.cod_item       ,
                                         p_ped_itens.num_sequencia ,
                                         p_ped_itens.pre_unit       ,
                                         p_saldo ,
                                         p_ped_itens.prz_entrega    ,
                                         p_ped_itens.pct_desc_adic  )
         END IF
         SELECT * 
         FROM t_mestre
         WHERE t_mestre.num_pedido  = p_ped_itens.num_pedido 
         IF sqlca.sqlcode = NOTFOUND
         THEN INSERT INTO t_mestre VALUES (p_pedidos.num_pedido  ,         
                                           p_pedidos.cod_repres  ,         
                                           p_pedidos.cod_nat_oper ,
                                           p_pedidos.cod_cnd_pgto ,
                                           p_pedidos.pct_desc_adic ,       
                                           p_pedidos.cod_moeda   )         
         END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION pol0179_processa_cancelamento_total()
#---------------------------------------------# 
  LET p_houve_erro = FALSE
  CALL log085_transacao("BEGIN")

  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  CALL set_count(0)
  LET p_count = 0
  CALL log006_exibe_teclas("02 07", p_versao)
  CURRENT WINDOW IS w_pol01790
  LET p_dat_cancel = TODAY
  INPUT p_pedidos.cod_empresa,p_pedidos.num_pedido, p_cod_motivo , p_dat_cancel
        FROM cod_empresa, num_pedido, cod_motivo ,dat_cancel
 
 AFTER FIELD cod_empresa
    SELECT count(*)
      INTO p_count 
      FROM empresa
     WHERE cod_empresa = p_pedidos.cod_empresa
    IF p_count = 0 THEN 
       ERROR "COD. EMPRESA INVALIDO"
       NEXT FIELD cod_empresa
    ELSE
       LET p_cod_empresa = p_pedidos.cod_empresa
    END IF 

  AFTER FIELD num_pedido
    IF pol0179_verifica_pedido() THEN 
       IF p_pedidos.ies_sit_pedido = "9" THEN 
          ERROR " PEDIDO ja' cancelado "
          NEXT FIELD num_pedido
       ELSE 
          IF pol0179_verifica_om() THEN 
             ERROR " PEDIDO com ordem de montagem nao pode ser cancelado total "
             NEXT FIELD num_pedido
          ELSE 
             IF pol0179_verifica_saldo_res_rom() THEN 
###             ERROR " PEDIDO com SALDO de Reserva/Romaneio nao pode ser cancelado total"
###             NEXT FIELD num_pedido
             ELSE 
                CALL pol0179_busca_nom_cliente_den_cidade()
                DISPLAY p_cod_cliente,
                        p_nom_cliente,
                        p_den_cidade,
                        p_cod_uni_feder TO cod_cliente,
                                           nom_cliente,
                                           den_cidade,
                                           cod_uni_feder
             END IF
          END IF
       END IF
    ELSE 
       ERROR " PEDIDO nao cadastrado ou ORDEM DE MONTAGEM aberta "
       NEXT FIELD num_pedido
    END IF

    BEFORE FIELD cod_motivo
           DISPLAY "( Zoom )" AT 3,67

    AFTER  FIELD cod_motivo
           DISPLAY "--------" AT 3,67
           IF p_cod_motivo IS NOT NULL THEN 
              IF pol0179_verifica_cod_motivo() THEN 
                 DISPLAY p_den_motivo TO den_motivo
              ELSE 
                 ERROR " MOTIVO DE CANCELAMENTO nao cadastrado "
                 NEXT FIELD cod_motivo
              END IF
           END IF

     BEFORE FIELD dat_cancel
           IF p_dat_cancel IS NULL THEN 
              LET p_dat_cancel = TODAY
              DISPLAY p_dat_cancel TO dat_cancel
           END IF

     AFTER FIELD dat_cancel
           IF p_dat_cancel IS NULL THEN 
              ERROR " Data invalida."
              NEXT FIELD dat_cancel
           END IF
           IF p_dat_cancel > TODAY THEN 
              ERROR " Data maior que data atual nao e aceita."
              NEXT FIELD dat_cancel
           END IF

    ON KEY (control-w)
           CALL pol0179_help()
    ON KEY (control-z)
       CASE
         WHEN infield(cod_motivo)
           CALL log009_popup(6,21,"MOTIVO CANCELAMENTO","mot_cancel",
                           "cod_motivo","den_motivo",
                           "vdp0030","N","") RETURNING p_cod_motivo
           CALL log006_exibe_teclas("01 02 03 07", p_versao)
           CURRENT WINDOW IS w_pol01790
           DISPLAY p_cod_motivo TO cod_motivo
       END CASE

  END INPUT
  IF int_flag THEN 
     LET p_pedidos.*     = p_pedidosr.*
     CLEAR FORM
     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_pol01790
     ERROR " Cancelamento cancelado "
     LET int_flag = 0
     RETURN
  ELSE 
     LET int_flag = 0
  END IF
  LET p_funcao = "TOTAL"
  IF pol0179_carrega_itens() THEN 
     MESSAGE " Itens do Pedido. " ATTRIBUTE(REVERSE)
     IF pol0179_exibe_dados() THEN 
        IF log004_confirm(17,43) THEN 
           MESSAGE ""
           CALL pol0179_efetiva_cancelamento_itens()
           CALL pol0179_atualiza_mestre()
           IF p_pedidos.ies_sit_pedido <> "A" AND
              p_pedidos.ies_sit_pedido <> "F" THEN 
             #IF pol0179_verifica_credito_cliente() = FALSE THEN 
             #   ERROR " Limite de Credito para Cliente Excedido. "      
             #   LET p_houve_erro = TRUE
             #ELSE
             #   CALL pol0179_atualiza_ped_carteira()
             #END IF 
           END IF  
           IF p_houve_erro = FALSE THEN 
              MESSAGE " Cancelamento efetuado com sucesso " ATTRIBUTE(REVERSE)
           END IF 
           CALL log006_exibe_teclas("01", p_versao)
           CURRENT WINDOW IS w_pol01790
        END IF
     ELSE 
        CALL log006_exibe_teclas("01", p_versao)
        CURRENT WINDOW IS w_pol01790
        ERROR " Cancelamento cancelado "
        LET int_flag = 0
     END IF
  ELSE 
     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_pol01790
     ERROR " PEDIDO sem itens "
  END IF

 END FUNCTION

#------------------------------------#
 FUNCTION pol0179_verifica_cod_motivo()
#------------------------------------#
 SELECT den_motivo
   INTO p_den_motivo
   FROM mot_cancel
   WHERE mot_cancel.cod_motivo = p_cod_motivo
 IF sqlca.sqlcode = 0
 THEN RETURN true
 ELSE RETURN false
 END IF
 END FUNCTION

#---------------------#
 FUNCTION pol0179_help()
#---------------------#
  CASE
    WHEN infield(num_pedido)       CALL showhelp(3057)
    WHEN infield(cod_motivo)       CALL showhelp(3067)
    WHEN infield(qtd_pecas_cancel) CALL showhelp(3069)
    WHEN infield(dat_cancel)       CALL showhelp(3068)
  END CASE
END FUNCTION

#-----------------------------#
 FUNCTION pol0179_verifica_om()
#-----------------------------#
 WHENEVER ERROR CONTINUE
 SELECT UNIQUE num_om
   FROM ordem_montagem
  WHERE ordem_montagem.cod_empresa = p_cod_empresa
    AND ordem_montagem.num_pedido  = p_pedidos.num_pedido
 IF sqlca.sqlcode = 0 OR
    sqlca.sqlcode = -284  OR
    sqlca.sqlcode = -250 THEN 
    RETURN true
 ELSE 
    RETURN false
 END IF
 WHENEVER ERROR STOP
 END FUNCTION

#----------------------------------------#
 FUNCTION pol0179_verifica_saldo_res_rom()
#----------------------------------------#
  DEFINE p_saldo_res_rom     LIKE ped_itens.qtd_pecas_reserv
  
  SELECT SUM(qtd_pecas_reserv + qtd_pecas_romaneio)
    INTO p_saldo_res_rom 
    FROM ped_itens
   WHERE ped_itens.cod_empresa = p_cod_empresa
     AND ped_itens.num_pedido  = p_pedidos.num_pedido
  
  IF sqlca.sqlcode = 0 THEN 
     IF p_saldo_res_rom > 0 THEN 
        RETURN true
     ELSE 
        RETURN false
     END IF
  ELSE
     RETURN false
  END IF
END FUNCTION

#--------------------------------#
 FUNCTION pol0179_atualiza_mestre()
#--------------------------------#
 DECLARE cu_pedidos CURSOR WITH HOLD FOR
   SELECT *
     FROM pedidos
     WHERE pedidos.cod_empresa   = p_cod_empresa
       AND pedidos.num_pedido    = p_pedidos.num_pedido
     FOR UPDATE
   OPEN cu_pedidos
   FETCH cu_pedidos INTO p_pedidos.*
   IF sqlca.sqlcode = 0
   THEN UPDATE pedidos
          SET (pedidos.ies_sit_pedido, pedidos.cod_motivo_can) =
              ("9", p_cod_motivo)
         WHERE pedidos.num_pedido  = p_pedidos.num_pedido
           AND pedidos.cod_empresa = p_cod_empresa            
        IF sqlca.sqlcode = 0 THEN              
           INITIALIZE p_mensag TO NULL 
           LET p_tipo_i = "M"
           LET p_tipo_m = "C"
           CALL pol0179_verifica_alteracoes_pedido()
        ELSE 
           CALL log003_err_sql("ATUALIZACAO","PEDIDOS2")
           LET p_houve_erro = TRUE
        END IF
   ELSE CALL log003_err_sql("CONSULTA","PEDIDOS")
          LET p_houve_erro = TRUE
  END IF
   CLOSE cu_pedidos
 END FUNCTION

#--------------------------------#
 FUNCTION pol0179_incl_ped_of_pcp()
#--------------------------------#
#
# INCLUI O ITEN NA TABELA DE PEDIDOS ORDEM DE FABRICACAO OU NA TABELA
# DE PEDIDOS P.C.P CONFORME A INDICACAO NA TABELA DE LINHA DE PRODUTO
# BUSCA A LINHA DE PRODUTO DO ITEM NA TABELA DE PRODUTOS
#
  DEFINE  p_ped_ord_fabr         RECORD LIKE ped_ord_fabr.*,
          p_ped_pcp              RECORD LIKE ped_pcp.*
  DEFINE  p_cod_lin_prod         LIKE item.cod_lin_prod,
          p_cod_lin_recei        LIKE item.cod_lin_recei,
          p_cod_seg_merc         LIKE item.cod_seg_merc,
          p_cod_cla_uso          LIKE item.cod_cla_uso,
          p_ies_emite_of         LIKE linha_prod.ies_emite_of

 SELECT cod_lin_prod,
        cod_lin_recei,
        cod_seg_merc,
        cod_cla_uso
   INTO p_cod_lin_prod,
        p_cod_lin_recei,
        p_cod_seg_merc,
        p_cod_cla_uso
   FROM item     
   WHERE item.cod_item    = p_ped_itens.cod_item
     AND item.cod_empresa = p_cod_empresa 
 IF sqlca.sqlcode = 0
 THEN
 ELSE RETURN
 END IF
 SELECT ies_emite_of
   INTO p_ies_emite_of
   FROM linha_prod
   WHERE linha_prod.cod_lin_prod  = p_cod_lin_prod
     AND linha_prod.cod_lin_recei = p_cod_lin_recei
     AND linha_prod.cod_seg_merc  = p_cod_seg_merc
     AND linha_prod.cod_cla_uso   = p_cod_cla_uso
 IF sqlca.sqlcode = 0
 THEN
 ELSE RETURN
 END IF
 CASE WHEN p_ies_emite_of = "1"
           LET p_ped_ord_fabr.cod_empresa       = p_cod_empresa
           LET p_ped_ord_fabr.num_pedido        = p_ped_itens.num_pedido
           LET p_ped_ord_fabr.num_sequencia     = p_ped_itens.num_sequencia
           LET p_ped_ord_fabr.ies_ord_fabr_nova = "A"
           LET p_ped_ord_fabr.nom_usuario = p_user
           INSERT INTO ped_ord_fabr VALUES (p_ped_ord_fabr.*)
           IF sqlca.sqlcode = 0 THEN 
              RETURN
           ELSE 
              CALL log003_err_sql("INCLUSAO","PED_ORD_FABR2")
              LET p_houve_erro = TRUE
           END IF
      WHEN p_ies_emite_of = "2"
           LET p_ped_pcp.cod_empresa       = p_cod_empresa
           LET p_ped_pcp.num_pedido        = p_ped_itens.num_pedido
           LET p_ped_pcp.num_sequencia     = p_ped_itens.num_sequencia
           LET p_ped_pcp.qtd_cancelada     = t_ped_itens[p_count].qtd_pecas_cancel
           INITIALIZE p_ped_pcp.prz_entrega_ant TO NULL
           LET p_ped_pcp.nom_usuario = p_user
           INSERT INTO ped_pcp VALUES (p_ped_pcp.*)
           IF sqlca.sqlcode = 0 THEN 
              RETURN
           ELSE 
              CALL log003_err_sql("INCLUSAO","PED_PCP2")
              LET p_houve_erro = TRUE
           END IF
 END CASE
 END FUNCTION

#--------------------------------------------#
 FUNCTION pol0179_verifica_alteracoes_pedido()
#--------------------------------------------#
  DEFINE p_data     DATE,
         p_hora     CHAR(08)

  LET p_data = TODAY
  LET p_hora = TIME

  IF p_funcao = "PARCIAL" THEN
     LET p_mensag = "PEDIDO CANCELADO PARCIALMENTE. QUANTIDADE CANCELADAS ",
                    t_ped_itens[p_count].qtd_pecas_cancel, ". ITEM: ",
                    t_ped_itens[p_count].cod_item
  ELSE
     LET p_mensag = "PEDIDO CANCELADO TOTAL. "
  END IF
  CALL vdp876_monta_audit_vdp(p_cod_empresa, 
                              p_pedidos.num_pedido,
                              p_tipo_i,
                              p_tipo_m,
                              p_mensag,
                              "POL0179",
                              p_data,
                              p_hora,
                              p_user)
END FUNCTION 

#-----------------------------------------------#
 FUNCTION pol0179_verifica_alteracoes_ped_itens()
#-----------------------------------------------#
  DEFINE p_data     DATE,
         p_hora     CHAR(08)

  LET p_data = TODAY
  LET p_hora = TIME

  IF p_funcao = "PARCIAL" THEN
     LET p_mensag = "ITEM DO PEDIDO CANCELADO PARCIALMENTE. QUANTIDADE CANCELADAS ",
                    t_ped_itens[p_count].qtd_pecas_cancel, ". ITEM: ",
                    t_ped_itens[p_count].cod_item
  ELSE
     LET p_mensag = "ITEM DO PEDIDO CANCELADO. QUANTIDADE CANCELADAS ",
                    t_ped_itens[p_count].qtd_pecas_cancel, ". ITEM: ",
                    t_ped_itens[p_count].cod_item
  END IF
  CALL vdp876_monta_audit_vdp(p_cod_empresa, 
                              p_pedidos.num_pedido,
                              p_tipo_i,
                              p_tipo_m,
                              p_mensag,
                              "POL0179",
                              p_data,
                              p_hora,
                              p_user)
END FUNCTION 

#------------------------------------------#
 FUNCTION pol0179_verifica_credito_cliente()
#------------------------------------------#
  DEFINE p_cli_credito        RECORD LIKE cli_credito.*,
         p_indice             LIKE credito_indice.indice,
         p_tot_ped_carteira   LIKE cli_credito.val_ped_carteira,
         p_val_limite_cred    LIKE cli_credito.val_limite_cred  

  SELECT cli_credito.*
    INTO p_cli_credito.*
    FROM cli_credito
   WHERE cli_credito.cod_cliente = p_pedidos.cod_cliente 
 
  IF sqlca.sqlcode = NOTFOUND THEN 
     RETURN FALSE
  END IF 
      
  LET p_novo_ped_carteir = 0
  SELECT credito_indice.indice
    INTO p_indice
    FROM credito_indice
   WHERE credito_indice.cod_empresa  = p_cod_empresa
  IF sqlca.sqlcode <> 0 THEN
     LET p_indice = 1
  END IF 
  LET p_val_limite_cred = p_cli_credito.val_limite_cred * p_indice
  LET p_tot_ped_carteira = p_cli_credito.val_ped_carteira +
                           p_cli_credito.val_dup_aberto
  LET p_tot_ped_ant      = 0
  LET p_novo_ped_carteir = p_tot_ped_carteira - p_tot_ped_novo -
                           p_cli_credito.val_dup_aberto
  RETURN TRUE 
END FUNCTION 
 
#-------------------------------------------------------------------#
 FUNCTION pol0179_calcula_valor_pedido(p_num_pedido, p_num_sequencia,
                                      p_pct_desc_m, p_pct_desc,
                                      p_qtd_pecas,  p_pre_unit)
#-------------------------------------------------------------------# 
 DEFINE  p_num_pedido             LIKE pedidos.num_pedido,
         p_num_sequencia          LIKE ped_itens.num_sequencia,
         p_pct_desc_m             LIKE pedidos.pct_desc_adic,
         p_total_pedido           DECIMAL(17,2),
         p_pct_desc               LIKE ped_itens.pct_desc_adic,
         p_qtd_pecas              LIKE ped_itens.qtd_pecas_solic,
         p_pre_unit               LIKE ped_itens.pre_unit

 INITIALIZE p_total_pedido TO NULL

 CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                   p_num_pedido,
                                   0,
                                   p_pct_desc_m) RETURNING p_pct_desc_m
 
 CALL pol0179_calcula_pre_unit(p_pct_desc_m, p_pre_unit) RETURNING p_pre_unit

 CALL vdp784_busca_desc_adic_unico(p_cod_empresa,
                                   p_num_pedido,
                                   p_num_sequencia,
                                   p_pct_desc) RETURNING p_pct_desc 

 CALL pol0179_calcula_pre_unit(p_pct_desc, p_pre_unit) RETURNING p_pre_unit

 LET p_total_pedido = p_pre_unit * p_qtd_pecas

 RETURN p_total_pedido

END FUNCTION 

#---------------------------------------#
 FUNCTION pol0179_atualiza_ped_carteira()
#---------------------------------------#
  UPDATE cli_credito SET val_ped_carteira = p_novo_ped_carteir 
   WHERE cod_cliente = p_pedidos.cod_cliente

  IF sqlca.sqlcode <> 0 THEN 
     CALL log003_err_sql("ATUALIZACAO","CLI_CREDITO")
     LET p_houve_erro = FALSE
  END IF 

 END FUNCTION 

#-------------------------------------------------------------------#
 FUNCTION pol0179_calcula_pre_unit(p_desc_bruto_tab,p_pre_unit_bruto)
#-------------------------------------------------------------------#
 DEFINE      p_desc_bruto_tab  LIKE desc_preco_item.pct_desc,
             p_pre_unit_1      DECIMAL(17,1),
             p_pre_unit_2      DECIMAL(17,2),
             p_pre_unit_3      DECIMAL(17,3),
             p_pre_unit_4      DECIMAL(17,4),
             p_pre_unit_5      DECIMAL(17,5),
             p_pre_unit_6      DECIMAL(17,6),
             p_pre_unit_bruto  LIKE item_vdp.pre_unit_brut

 CASE p_par_vdp.par_vdp_txt[43]
   WHEN 1
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN 
        LET p_pre_unit_1 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE 
        LET p_pre_unit_1 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_1
   WHEN 2
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN
        LET p_pre_unit_2 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE
        LET p_pre_unit_2 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_2
   WHEN 3
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN 
        LET p_pre_unit_3 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE  
        LET p_pre_unit_3 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_3
   WHEN 4
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN 
        LET p_pre_unit_4 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE
        LET p_pre_unit_4 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_4
   WHEN 5
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN 
        LET p_pre_unit_5 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE 
        LET p_pre_unit_5 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_5
   WHEN 6
     IF p_par_vdp.par_vdp_txt[97,97] = "D" THEN 
        LET p_pre_unit_6 = (p_pre_unit_bruto - (p_pre_unit_bruto * 
                            p_desc_bruto_tab / 100))
     ELSE
        LET p_pre_unit_6 = (p_pre_unit_bruto * p_desc_bruto_tab)
     END IF
     RETURN p_pre_unit_6
 END CASE
END FUNCTION

