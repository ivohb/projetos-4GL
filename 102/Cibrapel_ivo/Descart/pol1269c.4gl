#---------------------------------------------------------------#
#--Objetivo: Efetuar apontamento de tabuleiro da Cibrapel       #
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
          p_sequencia          INTEGER,
          p_criticou           SMALLINT,
          p_qtd_estoque        DECIMAL(10,3),
          p_transac_consumo    INTEGER,
          p_transac_apont      INTEGER,
          p_num_trans_atual    INTEGER,
          p_qtd_movto          DECIMAL(10,3),
          p_num_seq_orig       INTEGER,    
          p_cod_tip_apon       CHAR(01),
          p_ies_tip_movto      CHAR(01),
          p_ies_implant        CHAR(01)
          
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
       p_qtd_refugar        LIKE estoque_lote.qtd_saldo,
       p_cod_item_sucata    LIKE parametros_885.cod_item_sucata,   
       p_num_lote_sucata    LIKE parametros_885.num_lote_sucata,   
       p_cod_local_sucata   LIKE item.cod_local_estoq,
       p_apont_sucata       LIKE estoque_lote.qtd_saldo,
       p_oper_sucata        LIKE parametros_885.oper_entr_sucata,
       p_tot_apont          LIKE estoque_lote.qtd_saldo
       
#--------------------------------#
FUNCTION pol1269c_aponta_outros()#
#--------------------------------#

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
       AND tipoitem <> 'CH'                #tabuleiros/caixas
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
      
      IF p_man.consumo_refugo = ' ' OR p_man.consumo_refugo = 0 THEN
         LET p_man.consumo_refugo = NULL
      END IF
            
      LET p_sequencia = p_man.num_seq_apont
      
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
      
      IF NOT pol1269c_proces_apont() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1269c_proces_apont()#
#-------------------------------#
      
   DISPLAY p_man.ordem_producao TO num_ordem
      
   #lds CALL LOG_refresh_display()
      
   LET p_statusRegistro = '2'  #status de criticado
   LET p_tipoRegistro = 'I'
   LET p_criticou = FALSE
         
   IF NOT pol1269c_consiste_apont() THEN
      RETURN FALSE
   END IF

   IF NOT p_criticou THEN
      LET p_man.ies_chapa = 'N'
      LET p_man.seq_leitura = 2       #insere na man_apont_885 o registro de
      IF NOT pol1269_ins_apont() THEN #apontamento do item do pedido (acessório/caixa)
         RETURN FALSE
      END IF
      
      #cria um registro de apontamento para a chapa prevista na estrutura da ordem,
      #a menos que esteja utilizando consumo de regugo (sucata)
      
      IF p_man.consumo_refugo IS NULL THEN
         IF NOT pol1269c_gera_apon_da_chapa() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT p_criticou THEN
         IF NOT pol1269c_efetua_apont() THEN
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
   END IF
   
   IF NOT pol1269_grava_apont_trim() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1269c_consiste_apont()#
#---------------------------------#

   IF NOT pol1269_ck_sequencia() THEN
      RETURN FALSE
   END IF

   IF p_man.consumo_refugo IS NULL THEN
      IF NOT pol1269_ck_consumo() THEN
         RETURN FALSE
      END IF
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

   IF NOT pol1269c_pega_dimensional() THEN
      RETURN FALSE
   END IF

   IF p_man.qtd_movto < 0 THEN
      IF NOT pol1269_ck_estorno() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT p_criticou THEN  #Se for um apontamento, ver existencia 
         IF NOT pol1269c_ck_material() THEN  #de material p/ baixar
            RETURN FALSE
         END IF
      END IF
   END IF
      
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1269c_ck_sucata()#
#----------------------------#

   SELECT cod_item_sucata,
          num_lote_sucata,
          oper_entr_sucata
     INTO p_cod_item_sucata,          
          p_num_lote_sucata,
          p_oper_sucata
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB PARAMETROS_885:ITEM SUCATA'  
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_sucata
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_sucata
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO TABELA ITEM:COD.LOCAL SUCATA'
      RETURN FALSE
   END IF

   IF NOT pol1269_le_estoque(p_cod_item_sucata, p_cod_local_sucata) THEN
      RETURN FALSE
   END IF

   IF p_qtd_estoque < p_man.consumo_refugo THEN
      LET p_apont_sucata = p_man.consumo_refugo - p_qtd_estoque
   ELSE
      LET p_apont_sucata = 0
   END IF        
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1269c_pega_dimensional()#
#-----------------------------------#

   LET p_man.largura = 0
   LET p_man.altura  = 0
   LET p_man.diametro = 0
   LET p_man.comprimento = 0
   
   RETURN TRUE
   
END FUNCTION

#Checar existencia de estoque para consumir, exceto se o componente 
#for chapa, pois chapa será apontanda antes de ser consumida, a menos
#que o apontamento esteja usando consumo de refugos (sucatas). 
#É uma chapa o item cuja familia seja igual a 201
#Descartar também componentes que não sobfrem baixa

#------------------------------#
FUNCTION pol1269c_ck_material()#
#------------------------------#
   
   DECLARE cq_structure CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao

   FOREACH cq_structure INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_STRUCTURE'  
         RETURN FALSE
      END IF  

      IF NOT pol1269_le_item_man(p_cod_compon) THEN
         RETURN FALSE
      END IF
     
      IF p_cod_familia = '201' THEN    #descartar chapas
         CONTINUE FOREACH
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto
      
      IF p_ies_tip_item = 'T' THEN
         CONTINUE FOREACH
      END IF

      IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
         
      IF NOT pol1269_le_estoque(p_cod_compon, p_cod_local_baixa) THEN
         RETURN FALSE
      END IF

      IF p_qtd_estoque < p_qtd_baixar THEN
         LET p_msg = 'ITEM: ',p_cod_compon CLIPPED, ' SEM ESTOQUE P/ BAIXAR '
         IF NOT pol1269_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF        
   
   END FOREACH
         
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1269c_gera_apon_da_chapa()#
#-------------------------------------#
   
   DEFINE p_op_chapa        LIKE ordens.num_ordem, 
          p_item_chapa      LIKE ordens.cod_item,
          p_achou           SMALLINT
   
   LET p_achou = FALSE
   
   #identifica a chapa do pedido
   
   DECLARE cq_it_chapa CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao

   FOREACH cq_it_chapa INTO 
           p_item_chapa, 
           p_qtd_necessaria

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_IT_CHAPA'  
         RETURN FALSE
      END IF  

      SELECT cod_familia
        INTO p_cod_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_item_chapa

      IF p_cod_familia = '201' THEN    #familia de chapas
         LET p_achou = TRUE
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF NOT p_achou THEN
      LET p_msg = 'COMPONENTE CHAPA NAO LOCALIZADO NA ESTRUTURA DA OF'
      IF NOT pol1269_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
      
   #identifica a ordem da chapa
   
   SELECT num_ordem
     INTO p_op_chapa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = p_num_docum
      AND cod_item_pai = p_man.item
      AND cod_item = p_item_chapa
      AND ies_situa = '4'
       
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORDENS - OF DA CHAPA'  
      RETURN FALSE
   END IF  
      
	 LET p_man.ordem_producao = p_op_chapa
	 LET p_man.item = p_item_chapa

   SELECT a.cod_operac,
          a.num_seq_operac,
          a.cod_cent_trab,
          a.cod_arranjo,
          a.cod_cent_cust
     INTO p_man.operacao,          
          p_man.sequencia_operacao,
          p_man.centro_trabalho,   
          p_man.arranjo,
          p_man.centro_custo
     FROM	consumo a, consumo_compl b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item = p_item_chapa
      AND b.cod_empresa = a.cod_empresa
      AND b.num_processo = a.parametro
      AND b.ies_oper_final = 'S'
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELAS CONSUMO/CONSUMO_COMPL'
      RETURN FALSE
   END IF  
   
   LET p_man.qtd_movto = p_man.qtd_movto * p_qtd_necessaria

   IF NOT pol1269_ck_material() THEN
      RETURN FALSE
   END IF
   
   IF p_criticou THEN
      RETURN TRUE
   END IF   
   
	 LET p_man.tip_movto = 'F'
	 LET p_man.comprimento = 0
	 LET p_man.largura = 0
	 LET p_man.altura = 0
	 LET p_man.diametro = 0
	 LET p_man.seq_leitura = 1 #a chapa será apontada antes de apontar o acessório ou caixa
	 LET p_man.ies_chapa = 'S'
	 
   IF NOT pol1269_ins_apont() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1269c_efetua_apont()#
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
         LET p_tot_apont = p_man.qtd_movto
         IF p_man.consumo_refugo IS NULL OR p_man.consumo_refugo <= 0 THEN
         ELSE
            IF NOT pol1269c_ck_sucata() THEN
               RETURN FALSE
            END IF
            IF p_apont_sucata > 0 THEN
               LET p_ies_tip_movto = 'N'
               LET p_ies_implant = 'S'
               IF NOT pol1269c_aponta_sucata() THEN
                  RETURN FALSE
               END IF
               LET p_ies_implant = NULL
            END IF
         END IF
         
         IF p_man.tip_movto = 'F' THEN  #apto de peças boas
            LET p_pct_desc_qtd = 0
         
            IF p_man.ies_chapa = 'N' THEN
               SELECT pct_desc_qtd            #verifica se o pedido tem desconto de quantidade
                 INTO p_pct_desc_qtd
                 FROM desc_nat_oper_885
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido = p_man.num_pedido
      
               IF STATUS <> 0 THEN
                  LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA DESC_NAT_OPER_885'
                  RETURN FALSE
               END IF          
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
               IF p_man.ies_chapa = 'S' THEN
                  IF NOT pol1269_baixa_material() THEN  #baixa matéria prima da chapa
                     RETURN FALSE
                  END IF
                  IF NOT pol1269_baixa_consumo_trim() THEN #baixa papel enviado pelo trim
                     RETURN FALSE
                  END IF
               ELSE
                  IF NOT pol1269c_baixa_material() THEN  #baixa matéria prima do acessório/caixa
                     RETURN FALSE
                  END IF
               END IF
            END IF

            IF p_qtd_refugar > 0 THEN
               LET p_man.qtd_movto = p_qtd_refugar
               LET p_man.tip_movto = 'R'
               IF NOT pol1269b_aponta_producao() THEN  #aponta a produção como refugo
                  RETURN FALSE
               END IF
               IF NOT pol1269c_baixa_material() THEN   #baixa matéria prima do acessório/caixa
                  RETURN FALSE
               END IF
               LET p_qtd_movto = p_qtd_refugar
               IF NOT pol1269_baixa_refugo() THEN     #faz a saída da produção (some c/ o refugo)
                  RETURN FALSE
               END IF
            END IF
         
         ELSE
            LET p_man.tip_movto = 'S'              #apontar sucata
            LET p_man.qtd_movto = p_man.peso_teorico
            
            IF NOT pol1269b_aponta_producao() THEN #aponta a produção como liberada
               RETURN FALSE
            END IF
            IF NOT pol1269c_baixa_material() THEN  #baixa matéria prima do acessório/caixa
               RETURN FALSE
            END IF
            IF NOT pol1269_baixa_consumo_trim() THEN
               RETURN FALSE
            END IF
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

#Se for apontamento de acessório, baixar chapa e 
#outros insumos da estrutura da OF
#Se for apontamento de caixa, baixar chapa, acessório
#e outros insumos da estrutura da OF
#NÂO baixar chapa, se estiver usando 
#retrabalho (p_man.consumo_refugo não nulo). Nesse caso,
#baixar do item sucata e a quantidade a baixar será
#calcula em função de p_man.qtd_movto e p_man.consumo_refugo.

#---------------------------------#
FUNCTION pol1269c_baixa_material()#
#---------------------------------#
   
   LET p_cod_tip_apon = 'B'

   DECLARE cq_structure CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.ordem_producao

   FOREACH cq_structure INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_STRUCTURE'  
         RETURN FALSE
      END IF  

      IF NOT pol1269_le_item_man(p_cod_compon) THEN
         RETURN FALSE
      END IF

      IF p_cod_familia = '201' THEN #chapa
         IF p_man.consumo_refugo IS NOT NULL THEN   
            CONTINUE FOREACH    #descartar consumo pela estrutura
         END IF
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto

      
      IF p_ies_tip_item = 'T' THEN
         CONTINUE FOREACH
      END IF

      IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
         
      IF NOT pol1269_bx_pelo_fifo() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   IF p_man.consumo_refugo IS NOT NULL THEN 
      LET p_cod_compon = p_cod_item_sucata
      LET p_cod_local_baixa = p_cod_local_sucata
      LET p_qtd_necessaria = p_man.consumo_refugo / p_tot_apont
      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_movto
      LET p_ctr_lote = 'S'
      
      IF NOT pol1269_bx_pelo_fifo() THEN
         RETURN FALSE
      END IF
   END IF
           
   RETURN TRUE

END FUNCTION

#--------------------------------#   
FUNCTION pol1269c_aponta_sucata()#
#--------------------------------#   

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
      
   LET p_cod_tip_apon = 'A'
      
   LET p_item.cod_empresa   = p_cod_empresa
   LET p_item.cod_item      = p_cod_item_sucata
   LET p_item.cod_local     = p_cod_local_sucata
   LET p_item.num_lote      = p_num_lote_sucata
   LET p_item.comprimento   = 0
   LET p_item.largura       = 0
   LET p_item.altura        = 0
   LET p_item.diametro      = 0    
   LET p_item.cod_operacao  = p_oper_sucata   
   LET p_item.ies_situa     = 'L'
   LET p_item.qtd_movto     = p_apont_sucata
   LET p_item.dat_movto     = p_dat_movto
   LET p_item.ies_tip_movto = 'N'
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.num_prog      = p_man.nom_prog
   LET p_item.num_docum     = 0
   LET p_item.num_seq       = 0   
   LET p_item.tip_operacao  = 'E' #Entrada   
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.turno
   LET p_item.trans_origem  = 0
   
   IF p_num_lote_sucata IS NULL OR p_num_lote_sucata = ' ' THEN
      LET p_item.ies_ctr_lote  = 'N'
   ELSE
      LET p_item.ies_ctr_lote  = 'S'
   END IF
   
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
   
   LET p_transac_apont = p_num_trans_atual

   IF NOT pol1269_ins_transacoes() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
