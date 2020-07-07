#---------------------------------------------------------------#
#--Objetivo: Efetuar apontamento de pedidos de chapa da Cibrapel#
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
          p_msg                CHAR(150),
          p_mensagem           CHAR(150),
          p_qtd_criticado      INTEGER,
          p_qtd_apontado       INTEGER,
          p_qtd_trim           DECIMAL(10,3),
          p_item_trim          CHAR(15),
          p_ordem_trim         INTEGER,
          p_statusRegistro     CHAR(01), 
          p_tipoRegistro       CHAR(01),
          p_criticou           SMALLINT,
          p_qtd_estoque        DECIMAL(10,3),
          p_transac_consumo    INTEGER,
          p_transac_apont      INTEGER,
          p_num_trans_atual    INTEGER,
          p_qtd_movto          DECIMAL(10,3),
          p_num_seq_orig       INTEGER,    
          p_cod_tip_apon       CHAR(01),
          p_ies_tip_movto      CHAR(01)
          
   DEFINE p_num_ordem          INTEGER,                 
          p_num_docum          CHAR(15),                   
          p_cod_item           CHAR(15),                   
          p_num_lote           CHAR(15),                   
          p_ies_situa          CHAR(01),                   
          p_dat_abert          DATE,                       
          p_cod_grupo_item     CHAR(15),                   
          p_tipo_item          CHAR(02),                   
          p_count              INTEGER,                    
          p_ind                SMALLINT,                   
          p_index              SMALLINT,                   
          p_erro               CHAR(10),                   
          p_dat_ini            DATETIME YEAR TO SECOND,    
          p_dat_fim            DATETIME YEAR TO SECOND,    
          p_num_pedido         INTEGER,                    
          p_grava_oplote       CHAR(01),                   
          p_rastreia           CHAR(01),                    
          p_ies_oper_final     CHAR(01),
          p_ctr_estoque        CHAR(01),
          p_ctr_lote           CHAR(01),
          p_sobre_baixa        CHAR(01),
          p_datageracao        DATETIME YEAR TO SECOND

DEFINE p_seq_reg_mestre     INTEGER,
       p_num_seq_reg        INTEGER,
       p_tip_movto          CHAR(01),
       p_ies_ctr_lote       CHAR(01),
       p_tip_producao       CHAR(01)
          
DEFINE p_parametros         LIKE par_pcp.parametros,               
       p_ies_largura        LIKE item_ctr_grade.ies_largura,
       p_ies_altura         LIKE item_ctr_grade.ies_altura,
       p_ies_diametro       LIKE item_ctr_grade.ies_diametro,
       p_ies_comprimento    LIKE item_ctr_grade.ies_comprimento,
       p_ies_serie          LIKE item_ctr_grade.reservado_2,
       p_ies_dat_producao   LIKE item_ctr_grade.ies_dat_producao,
       p_cod_cent_cust      LIKE de_para_maq_885.cod_cent_cust,
       p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,        
       p_cod_oper_rp        LIKE par_pcp.cod_estoque_rp,           
       p_cod_oper_sucata     LIKE par_pcp.cod_estoque_rn,   
       p_cod_familia        LIKE item.cod_familia,                 
       p_ies_tip_item       LIKE item.ies_tip_item,
       p_cod_lin_prod       LIKE item.cod_lin_prod,
       p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
       p_ies_apontado       LIKE desc_nat_oper_885.ies_apontado,
       p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd

   DEFINE p_man                RECORD LIKE man_apont_885.*

DEFINE p_dat_movto             DATE,
       p_dat_proces            DATE,
       p_hor_operac            CHAR(08)

DEFINE p_qtd_baixar         LIKE estoque_lote.qtd_saldo,        
       p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,        
       p_cod_compon         LIKE ord_compon.cod_item_compon,       
       p_cod_local_baixa    LIKE ord_compon.cod_local_baixa 

END GLOBALS

#--variáveis modular de uso geral--#

DEFINE p_qtd_apontar        LIKE estoque_lote.qtd_saldo,       
       p_qtd_refugar        LIKE estoque_lote.qtd_saldo        
       
#-------------------------------#
FUNCTION pol1269a_aponta_chapa()#
#-------------------------------#
      
   DECLARE cq_op CURSOR WITH HOLD FOR
    SELECT numsequencia,
					 codempresa,
					 coditem,
					 numordem,
					 numpedido,
					 codmaquina,
					 inicio,
					 fim,
					 qtdprod,
					 tipmovto,
					 largura,
					 diametro,
					 tubete,
					 comprimento,
					 pesoteorico,
					 consumorefugo,
					 iesdevolucao,
					 datageracao
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')
       AND tipoitem = 'CH'                 #CHAPA
     ORDER BY numordem, qtdprod DESC

   FOREACH cq_op INTO 
           p_man.num_seq_apont,
           p_man.empresa,
           p_man.item,
           p_man.ordem_producao,
           p_man.num_pedido,
           p_man.cod_recur,
           p_dat_ini,
           p_dat_fim,
           p_man.qtd_movto,
           p_man.tip_movto,
           p_man.largura,
           p_man.diametro,
           p_man.altura,
           p_man.comprimento,
           p_man.peso_teorico,
           p_man.consumo_refugo,
           p_man.ies_devolucao,
           p_datageracao 
           
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_OP'
         RETURN FALSE
      END IF                                           

      DELETE FROM man_apont_885 
       WHERE empresa = p_cod_empresa
      
      SELECT COUNT(empresa)
        INTO p_count
        FROM man_apont_885
       WHERE empresa = p_cod_empresa
        
      IF p_count > 0 THEN
         LET p_msg = 'ERRO: NAO FOI POSSIVEL LIMPAR A TABELA MAN_APONT_885'
         RETURN FALSE
      END IF                                           
      
      LET p_dat_movto  = DATE(p_dat_fim)
      LET p_dat_proces = DATE(p_datageracao)
      LET p_hor_operac = EXTEND(p_datageracao, HOUR TO SECOND)

      IF p_man.cod_recur IS NULL THEN  
         LET p_msg = 'O CODIGO DA MAQUINA ESTA NULO'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF

      IF p_man.ordem_producao IS NULL THEN  
         LET p_msg = 'O NUMERO DA OF ESTA NULO'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF

      IF p_man.qtd_movto IS NULL THEN  
         LET p_msg = 'A QUANTIDADE A APONTAR ESTA NULA'
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF
      
      #guarda dados do trim, p/ checagem de estorno
      
      LET p_ordem_trim = p_man.ordem_producao
      LET p_item_trim = p_man.item
      LET p_qtd_trim = p_man.qtd_movto

      #Chapa sempre terá uma chapa filha a qual deverá ser
      #apontada no lugar da chapa original (chapa que o trim manda)
      
      SELECT cod_item_compon,
             qtd_necessaria
        INTO p_cod_compon,
             p_qtd_necessaria
        FROM ord_compon
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = p_man.ordem_producao

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM DA TABELA ORD_COMPON'
         RETURN FALSE
      END IF                                           
      
      #Busca na tabela ordens a OF da chapa filha
      
      SELECT num_docum,
             cod_item
        INTO p_num_docum,
             p_man.item
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = p_man.ordem_producao

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM DA TABELA ORD_COMPON'
         RETURN FALSE
      END IF                                           

      SELECT num_ordem
        INTO p_num_ordem
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_docum = p_num_docum
         AND cod_item = p_cod_compon
         AND cod_item_pai = p_man.item

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM DA TABELA ORD_COMPON'
         RETURN FALSE
      END IF                                           
      
      LET p_man.ordem_producao = p_num_ordem
      LET p_man.item = p_cod_compon
      LET p_man.qtd_movto = p_man.qtd_movto * p_qtd_necessaria
      
      #Se movimento = F, só apontar a operação final
      #Se movimento = R, apontar mesmo sem ser operação final  
      
      IF NOT pol1269_le_recursos() THEN
         RETURN FALSE
      END IF
      
      IF p_man.tip_movto = 'R' OR p_ies_oper_final = 'S' THEN           
      ELSE
         LET p_statusRegistro = 'I' #ignora o registro
         LET p_tipoRegistro = 'I'
         IF NOT pol1269_grava_apont_trim() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF
                           
      CALL log085_transacao("BEGIN")  
      
      IF NOT pol1269a_proces_apont() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1269a_proces_apont()#
#-------------------------------#
      
   DISPLAY p_man.ordem_producao TO num_ordem
      
   #lds CALL LOG_refresh_display()
      
   LET p_statusRegistro = '2'  #status de criticado
   LET p_tipoRegistro = 'I'
   LET p_criticou = FALSE
         
   IF NOT pol1269a_consiste_apont() THEN
      RETURN FALSE
   END IF

   IF NOT p_criticou THEN
      LET p_man.seq_leitura = 1
      LET p_man.ies_chapa = 'S'
      IF NOT pol1269_ins_apont() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1269a_efetua_apont() THEN
         RETURN FALSE
      END IF
      IF NOT p_criticou THEN
         LET p_statusRegistro = '1' #apontado com sucesso
         LET p_tipoRegistro = '1'
       
         LET p_qtd_apontado = p_qtd_apontado + 1
         DISPLAY p_qtd_apontado TO qtd_apontado
         #lds CALL LOG_refresh_display()	

      END IF
   END IF
   
   IF NOT pol1269_grava_apont_trim() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1269a_consiste_apont()#
#---------------------------------#

   IF NOT pol1269_ck_sequencia() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269_ck_consumo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269_ck_ordem() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1269_pega_turno() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269_ck_movto() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1269_ck_datas() THEN
      RETURN FALSE
   END IF

   IF NOT pol1269a_pega_dimensional() THEN
      RETURN FALSE
   END IF

   IF p_man.qtd_movto < 0 THEN
      IF NOT pol1269_ck_estorno() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT p_criticou THEN  #Se for um apontamento, ver existencia 
         IF NOT pol1269_ck_material() THEN  #de material p/ baixar
            RETURN FALSE
         END IF
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1269a_pega_dimensional()#
#-----------------------------------#

   LET p_man.largura = 0
   LET p_man.altura  = 0
   LET p_man.diametro = 0
   LET p_man.comprimento = 0
   
   IF NOT pol1269_le_item_ctr_grade(p_man.item) THEN
      RETURN FALSE
   END IF

   IF p_ies_largura     = 'N' AND
      p_ies_comprimento = 'N' THEN
      RETURN TRUE
   END IF

   IF NOT pol1269a_le_item_chapa() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1269a_le_item_chapa()
#-------------------------------#

   SELECT largura,
          comprimento
     INTO p_man.largura,
          p_man.comprimento
     FROM item_chapa_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_man.num_pedido
      AND num_sequencia = p_man.num_seq_pedido
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO A ITEM_CHAPA_885'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1269a_efetua_apont()#
#-------------------------------#

   DECLARE cq_apont CURSOR WITH HOLD FOR
    SELECT *
      FROM man_apont_885
     WHERE empresa = p_cod_empresa
     ORDER BY seq_leitura

   FOREACH cq_apont INTO p_man.*

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONTAMENTO DA TABELA MAN_APONT_885'
         RETURN FALSE
      END IF          
      
      IF p_man.qtd_movto > 0 THEN   #Apontamento 
         
         IF p_man.tip_movto = 'F' THEN  #apto de peças boas
            SELECT pct_desc_qtd            #verifica se o pedido tem desconto de quantidade
              INTO p_pct_desc_qtd
              FROM desc_nat_oper_885
             WHERE cod_empresa = p_cod_empresa
               AND num_pedido = p_man.num_pedido
      
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA DESC_NAT_OPER_885'
               RETURN FALSE
            END IF          
            
            IF p_pct_desc_qtd <= 0 THEN
               LET p_qtd_apontar = p_man.qtd_movto
               LET p_qtd_refugar = 0
            ELSE
               LET p_qtd_refugar = p_man.qtd_movto * p_pct_desc_qtd / 100
               LET p_qtd_apontar = p_man.qtd_movto - p_qtd_refugar
            END IF
      
            IF p_qtd_apontar > 0 THEN
               LET p_man.qtd_movto = p_qtd_apontar
               LET p_man.tip_movto = 'L'
               IF NOT pol1269b_aponta_producao() THEN #aponta a produção como liberada
                  RETURN FALSE
               END IF
               IF NOT pol1269_baixa_material() THEN  #consome a matéria prima
                  RETURN FALSE
               END IF
            END IF

            IF p_qtd_refugar > 0 THEN
               LET p_man.qtd_movto = p_qtd_refugar
               LET p_man.tip_movto = 'R'
               IF NOT pol1269b_aponta_producao() THEN  #aponta a produção como refugo
                  RETURN FALSE
               END IF
               IF NOT pol1269_baixa_material() THEN   #consome a matéria prima
                  RETURN FALSE
               END IF
               LET p_qtd_movto = p_qtd_refugar
               IF NOT pol1269_baixa_refugo() THEN     #faz a saída da produção de refugo(operação especial)
                  RETURN FALSE
               END IF
            END IF
         
         ELSE
            LET p_man.tip_movto = 'S'              #apontar sucata
            LET p_man.qtd_movto = p_man.peso_teorico
            
            IF NOT pol1269b_aponta_producao() THEN #aponta a produção como liberada
               RETURN FALSE
            END IF
            IF NOT pol1269_baixa_material() THEN  #consome a matéria prima
               RETURN FALSE
            END IF
         END IF
            
         IF NOT pol1269_baixa_consumo_trim() THEN
            RETURN FALSE
         END IF
      
      END IF
      
      #---estorno---#
      IF p_man.qtd_movto < 0 THEN
         IF NOT pol1269b_estorna_producao() THEN
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
                                    
   RETURN TRUE

END FUNCTION

      