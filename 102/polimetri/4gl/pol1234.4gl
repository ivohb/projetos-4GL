#-------------------------------------------------------------------#
# SISTEMA.: GENÉRICO                                                #
# PROGRAMA: POL1234.4GL                                             #
# OBJETIVO: ANALISA AS REGRAS DO TRAVA90 E BLOQUEIA A OC            #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 28/10/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
   DEFINE p_status_oc            CHAR(01)
END GLOBALS

DEFINE p_cod_empresa        LIKE ordem_sup.cod_empresa,
       p_num_oc             LIKE ordem_sup.num_oc,
       p_num_versao         LIKE ordem_sup.num_versao,
       p_ies_situa_oc       LIKE ordem_sup.ies_situa_oc,
       p_cod_item           LIKE ordem_sup.cod_item,
       p_cod_lin_prod       LIKE item.cod_lin_prod,
       p_num_conta_deb_desp LIKE dest_ordem_sup.num_conta_deb_desp,
       p_cod_secao_receb    LIKE dest_ordem_sup.cod_secao_receb
         
DEFINE p_msg             CHAR(500),
       p_men             CHAR(500),
       p_erro            CHAR(10),
       p_sem_trava       SMALLINT,
       p_sem_controle    SMALLINT,
       p_conta_existe    SMALLINT,
       p_status          SMALLINT,
       p_val_media       DECIMAL(12,2),
       p_dat_entrega     DATE,
       p_qtd_acrescimo   DECIMAL(13,3),
       p_qtd_acre_ant    DECIMAL(13,3),
       p_qtd_ajuste      DECIMAL(10,3),
       p_mes_entrega     INTEGER,
       p_mes_atual       INTEGER,
       p_bloquear        SMALLINT,
       p_var_txt         CHAR(30),
       p_versao          CHAR(18),
       p_nom_programa    CHAR(08),
       p_count           INTEGER,
       p_ordem           INTEGER,
       p_ver_oc          INTEGER,
       p_qtd_corte       INTEGER,
       p_dat_programacao DATE,
       p_dat_origem      DATE,
       p_dat_ini         DATE,
       p_dat_fim         DATE,
       p_id_registro     INTEGER,
       p_seq_periodo     INTEGER,
       p_chave_processo  DECIMAL(12,0),
       p_id_prog_ord     INTEGER

DEFINE p_trava90         RECORD LIKE tabela_trava90_454.*,
       p_mapa_controle   RECORD LIKE mapa_controle_prod_454.*

       
DEFINE p_mapa_dias       RECORD 
	cod_empresa CHAR (2),
	data_processamento DATE,
	qtd_dias_mes DECIMAL (4, 2),
	qtd_saldo_dias_mes DECIMAL (4, 2),
	qtd_dias_mes_1 DECIMAL (4, 2),
	qtd_dias_mes_2 DECIMAL (4, 2),
	qtd_dias_mes_3 DECIMAL (4, 2),
	qtd_dias_mes_4 DECIMAL (4, 2)
END RECORD	
         
MAIN

END MAIN

#--------------------------#
FUNCTION pol1234_controle()#
#--------------------------#

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120
   DEFER INTERRUPT
   LET p_versao = "pol1234-10.02.09"

END FUNCTION

#-------------------------------------#
 FUNCTION pol1234_trava90(p_parametro)#
#-------------------------------------#

   DEFINE p_parametro     RECORD
          cod_empresa     LIKE ordem_sup.cod_empresa,
          num_oc          LIKE ordem_sup.num_oc,
          nom_programa    CHAR(08),
          dat_programacao DATE,
          qtd_ajuste      DECIMAL(10,3),
          seq_periodo     INTEGER,
          chave_processo  DECIMAL(12,0),
          id_prog_ord     INTEGER
   END RECORD
   
   CALL pol1234_controle()
   
   LET p_cod_empresa = p_parametro.cod_empresa
   LET p_num_oc = p_parametro.num_oc
   LET p_nom_programa = p_parametro.nom_programa
   LET p_dat_programacao = p_parametro.dat_programacao
   LET p_qtd_ajuste = p_parametro.qtd_ajuste
   LET p_seq_periodo = p_parametro.seq_periodo
   LET p_chave_processo = p_parametro.chave_processo
   LET p_id_prog_ord = p_parametro.id_prog_ord
   
   SELECT ies_situa_oc,
          num_versao,
          cod_item
     INTO p_ies_situa_oc,
          p_num_versao,
          p_cod_item
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_sup')
      RETURN FALSE
   END IF
   
   IF p_ies_situa_oc MATCHES '[PAXR]' THEN
   ELSE
      LET p_erro = p_num_oc
      LET p_msg = 'OC ',p_erro CLIPPED, ' Status ', p_ies_situa_oc, '\n\n',
                  'O Status atual da OC não\n permite essa operação.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   SELECT num_conta
     INTO p_num_conta_deb_desp
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      LET p_msg = 'Item; ', p_cod_item CLIPPED, ' não encontrada na tab item_sup'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item_sup')
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_lin_prod
     INTO p_cod_lin_prod
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item')
      RETURN FALSE
   END IF

   IF NOT pol1234_analisa_oc() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1234_analisa_oc()#
#----------------------------#
   
   DEFINE p_dif              DECIMAL(12,3),
          p_dias_cobertura   DECIMAL(12,3),
          p_dias_corte       DECIMAL(12,3),
          p_estoque_final    DECIMAL(12,3),
          p_estoque_trava    DECIMAL(12,3),
          p_lote_trava       DECIMAL(12,3),
          p_limite_trava     DECIMAL(12,3),
          p_qtd_soma         DECIMAL(12,3),
          p_qtd_dia          DECIMAL(12,3),
          p_med_consumo      DECIMAL(12,3),
          p_qtd_dias_oc      DECIMAL(12,3),
          p_soma_dias        DECIMAL(12,3),
          p_obs              CHAR(200)
   
   SELECT *
     INTO p_mapa_controle.*
     FROM mapa_controle_prod_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS = 100 THEN
      LET p_sem_controle = TRUE
   ELSE
      IF STATUS = 0 THEN
         LET p_sem_controle = FALSE
      ELSE
         CALL log003_err_sql('SELECT','mapa_controle_prod_454')
         RETURN FALSE
      END IF
   END IF

   SELECT num_conta
     FROM conta_contabil_454
    WHERE cod_empresa = p_cod_empresa
      AND num_conta = p_num_conta_deb_desp

   IF STATUS = 100 THEN
      LET p_conta_existe = FALSE
   ELSE
      IF STATUS = 0 THEN
         LET p_conta_existe = TRUE
      ELSE
         CALL log003_err_sql('SELECT','conta_contabil_454')
         RETURN FALSE
      END IF
   END IF
   
   {REGRA 1- SE O ITEM NÃO FOR ENCONTRADO NO BANCO DO CONTROLE DE PRODUÇÃO e 
      FOR DAS CONTAS CONTABÉIS 1.1.07.04.01/1.1.07.04.02/1.1.07.03.01 
      LIBERAR SEM PASSAR PELAS PRÓXIMAS CONDIÇÕES. 
    REGRA 2- SE O ITEM NÃO FOR ENCONTRADO NO BANCO DO CONTROLE DE PRODUÇÃO e 
      NÃO FOR  DAS CONTAS CONTABÉIS 1.1.07.04.01/1.1.07.04.02/1.1.07.03.01, BLOQUEAR.}
   
   IF p_sem_controle THEN
      IF p_conta_existe THEN
         RETURN TRUE
      ELSE
         LET p_msg = 'REGRA 02: ITEM NAO CONSTA DO CONTROLE DE PRODUCAO E NAO E DE CONSUMO'
         CALL pol1234_altera_staus_oc('X') RETURNING p_status
      END IF
      RETURN p_status
   END IF

   {REGRA 3- SE ESTOQUE FINAL M+2 = 999 OU = 9.999 BLOQUEAR
     Se o campo da DIAS_COBERTURA_MES2 for maior ou igual a 999 BLOQUEAR a OC. 
     MENSAGEM: Compras ultrapassa consumo total atual - Item em desativação?}

   IF p_mapa_controle.dias_cobertura_mes_2 >= 999 THEN
      LET p_msg = 'REGRA 03: COMPRAS ULTRAPASSAM CONSUMO TOTAL ATUAL - ITEM EM DESATIVACAO!'
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF

   {REGRA 4- SE CONSUMO M+4 = 0 BLOQUEAR
     Se o campo da QTD_PROG_MES_4 for igual a 0 (zeros), bloquear a OC.
     MENSAGEM: Item não tem consumo para o 5º mês - Item em desativação?}

   IF p_mapa_controle.qtd_prog_mes_4 = 0 THEN
      LET p_msg = 'REGRA 04: ITEM NAO TEM CONSUMO PARA O 5º MES - ITEM EM DESATIVACAO!'
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF

   SELECT *
     INTO p_mapa_dias.*
     FROM mapa_dias_mes_454
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','mapa_dias_mes_454')
      RETURN FALSE
   END IF

   LET p_dat_origem = DATE(p_mapa_dias.data_processamento)
   LET p_mes_atual = MONTH(TODAY)
   LET p_mes_entrega = MONTH(p_dat_programacao) 

   SELECT SUM(qtd_ajuste)
     INTO p_qtd_acre_ant
     FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      AND dat_entrega_prev <= p_dat_programacao
      AND dat_origem >= p_dat_origem
      AND tip_ajuste = 'A'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'QTD_PROG_PERIODO')
      RETURN FALSE
   END IF

   IF p_qtd_acre_ant IS NULL THEN
      LET p_qtd_acre_ant = 0
   END IF

   SELECT SUM(qtd_ajuste)
     INTO p_qtd_corte
     FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      AND dat_entrega_prev <= p_dat_programacao
      AND dat_origem >= p_dat_origem
      AND tip_ajuste = 'C'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'QTD_PROG_PERIODO')
      RETURN FALSE
   END IF

   IF p_qtd_corte IS NULL THEN
      LET p_qtd_corte = 0
   END IF

   {IF p_qtd_corte > 0 AND p_qtd_ajuste > 0 THEN
      IF NOT pol1234_abate_do_corte() THEN
         RETURN FALSE
      END IF
   END IF}

   LET p_qtd_acrescimo = p_qtd_ajuste
   LET p_qtd_acre_ant = p_qtd_acre_ant - p_qtd_acrescimo
   
   IF p_qtd_corte > p_qtd_acre_ant THEN
      LET p_qtd_corte = p_qtd_corte - p_qtd_acre_ant
   ELSE
      LET p_qtd_corte = 0
   END IF

   IF p_qtd_acrescimo > p_qtd_corte THEN
      LET p_qtd_acrescimo = p_qtd_acrescimo - p_qtd_corte
      LET p_qtd_corte = 0
   ELSE
      LET p_qtd_acrescimo = 0
   END IF
   
   LET p_obs = ' Corte, p/ regra 5: ', p_qtd_corte,
               ' Acresc.p/ regra 6: ', p_qtd_acrescimo,
               ' Acresc. antes: ', p_qtd_acre_ant
   
   #CALL log0030_mensagem(p_obs,'info')
   
   SELECT *
     INTO p_trava90.*
     FROM tabela_trava90_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_lin_prod = p_cod_lin_prod  
      AND ies_versao_atual = 'S'               

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tabela_trava90_454')
      RETURN FALSE
   END IF

   IF p_mes_entrega >= p_mes_atual THEN
      LET p_dif = p_mes_entrega - p_mes_atual
   ELSE
      LET p_dif = (p_mes_entrega + 12) - p_mes_atual
   END IF

   IF p_dif > 2 THEN
      LET p_var_txt = p_mes_entrega
      LET p_msg = 'REGRA 08: COMPRA BLOQUEADA DEVIDO A DATA SER SUPERIOR A DATA DO PLANEJAMENTO NORMAL. MES ENTREGA:', p_var_txt
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF
      
   IF p_dif = 0 THEN
      LET p_qtd_soma = p_mapa_controle.qtd_prog_mes_1 + p_mapa_controle.qtd_prog_mes_2
      LET p_qtd_dia = p_mapa_dias.qtd_dias_mes_1 + p_mapa_dias.qtd_dias_mes_2
      LET p_dias_cobertura = p_mapa_controle.dias_cobertura_mes
      LET p_estoque_final = p_mapa_controle.qtd_estoque_fim_mes
   END IF

   IF p_dif = 1 THEN
      LET p_qtd_soma = p_mapa_controle.qtd_prog_mes_2 + p_mapa_controle.qtd_prog_mes_3
      LET p_qtd_dia = p_mapa_dias.qtd_dias_mes_2 + p_mapa_dias.qtd_dias_mes_3
      LET p_dias_cobertura = p_mapa_controle.dias_cobertura_mes_1
      LET p_estoque_final = p_mapa_controle.qtd_estoque_fim_mes_1
   END IF

   IF p_dif = 2 THEN
      LET p_qtd_soma = p_mapa_controle.qtd_prog_mes_3 + p_mapa_controle.qtd_prog_mes_4
      LET p_qtd_dia = p_mapa_dias.qtd_dias_mes_3 + p_mapa_dias.qtd_dias_mes_4
      LET p_dias_cobertura = p_mapa_controle.dias_cobertura_mes_2
      LET p_estoque_final = p_mapa_controle.qtd_estoque_fim_mes_2
   END IF


   LET p_val_media = (p_qtd_soma / 2) * p_mapa_controle.cus_unit
      
   IF p_val_media <= p_trava90.val_med_mensal THEN
      LET p_estoque_trava = p_trava90.estoq_quando_menor
      LET p_lote_trava    = p_trava90.lote_quando_menor
      LET p_limite_trava  = p_trava90.limit_quando_menor
   ELSE
      LET p_estoque_trava = p_trava90.estoq_quando_maior
      LET p_lote_trava    = p_trava90.lote_quando_maior
      LET p_limite_trava  = p_trava90.limit_quando_maior
   END IF
   
   LET p_dias_corte = 
          p_dias_cobertura - (p_qtd_corte / (p_estoque_final / p_dias_cobertura))

   LET p_obs = ' Dias cobertura: ', p_dias_cobertura,
               ' Dias corte: ', p_dias_corte,
               ' dif: ', p_dif,
               ' Estoque trava: ', p_estoque_trava
   
   #CALL log0030_mensagem(p_obs,'info')
  
      {REGRA 5- SE ESTOQUE FINAL DO PERÍODO QUE ESTÁ SENDO COLOCADO O PEDIDO 
        ESTIVER ACIMA DO Nº DE DIAS DA TABELA ACIMA, BLOQUEAR.
        Validar o resultado na coluna ESTOQUE TRAVA da tabela : Em seguida para 
        calcular se o ESTOQUE TRAVA vai bloquear, devemos efetuar o seguinte cálculo:  
        Com base no mês da entrega devemos verificar a primeira regra. Verificar a 
        coluna DIAS_COBERTURA_MES? (o mês vai corresponder ao mês da data da enrtrega) 
        e verificar se a quantidade de dias desse campo é maior que o da regra, 
        a ordem de compra dever se bloquada. }
      
   IF p_dias_corte > p_estoque_trava THEN
      LET p_var_txt = p_mes_entrega
      LET p_msg = 'REGRA 05: ESTOQUE DO ITEM ACIMA DO LIMITE DA TABELA PARA O PERIODO - MES: ', p_var_txt
      LET p_var_txt = p_dias_corte
      LET p_msg = p_msg CLIPPED, ' ESTOQUE ITEM: ', p_var_txt
      LET p_var_txt = p_estoque_trava
      LET p_msg = p_msg CLIPPED, ' ESTOQUE DA TABELA: ', p_var_txt
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF
      
   LET p_med_consumo = p_qtd_soma / p_qtd_dia
   LET p_qtd_dias_oc = p_qtd_acrescimo / p_med_consumo

      {REGRA 6- SE LOTE A SER COMPRADO COBRIR MAIS QUE OS DIAS DE LOTE TRAVA DA TABELA ACIMA BLOQUEAR
       Validar o resultado na coluna LOTE TRAVA da tabela: verificar se atende a regra de LOTE TRAVA.  
         Para verificar a regra 6 verificar se o LOTE A SER COMPRADO COBRIR MAIS QUE OS DIAS DE LOTE 
         TRAVA DA TABELA ACIMA BLOQUEAR.  Ou seja pegar QTD_PROG_MES_? Somar as quantidades para 
         os dois proximos meses subsequentes a partir da data de entrega da OC e somar em outra 
         variavel a quantidade de dias úteis para esses dois meses ( o numero de dias úteis pro
          mes está na tabela (MAPA_DIAS_MES). Para calculo da média do consumo medio por dia dividir 
          a somatoria da quantidade pelo numero de dias úteis.   Em seguida para calcular a quantidade 
          de dias que a OC vai atender dividir a quantidade do item da OC pela media de consumo diario 
          calculado.  Com o resultado verificar se o numero é maior do que o numero do LOTE TRAVA, 
          se for bloquear a OC.}
      
   IF p_qtd_dias_oc > p_lote_trava THEN
      LET p_var_txt = p_mes_entrega
      LET p_msg = 'REGRA 06: A QUANTIDADE DE COMPRAS ESTA ACIMA DO LIMITE DA TABELA - MES: ', p_var_txt
      LET p_var_txt = p_qtd_dias_oc
      LET p_msg = p_msg CLIPPED, ' QTD COMPRAS EM DIA: ', p_var_txt
      LET p_var_txt = p_lote_trava
      LET p_msg = p_msg CLIPPED, ' LOTE DA TABELA: ', p_var_txt
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF
      
   LET p_soma_dias = p_dias_corte + (p_qtd_ajuste / p_med_consumo)

      {REGRA 7- SE A SOMA DOS DIAS DO LOTE QUE ESTÁ SENDO COMPRADO MAIS O ESTOQUE NO FINAL DO 
       PERÍODO FOR SUPERIOR AO LIMITE DA TABELA ACIMA, BLOQUEAR
       Validar o resultado na coluna LIMITE da tabela : é necessário somar o numero de dias de 
       dias de atendimento obtido da tabela MAPA_CONTROLE_PROD_454 da regra 5 com o numero de 
       dias que a OC que está sendo criada vai atender calculado na regra 6 e verificar se o 
       resultado é maior que o numero de dias da coluna LIMITE, se for maior bloquear a OC}

   IF p_soma_dias > p_limite_trava THEN
      LET p_var_txt = p_mes_entrega
      LET p_msg = 
        'REGRA 07: A QUANTIDADE DE COMPRAS MAIS ESTOQUE DA TABELA ULTRAPASSA LIMITE DA TABELA- MES: ', p_var_txt
      LET p_var_txt = p_soma_dias
      LET p_msg = p_msg CLIPPED, ' QTD COMPRAS EM DIA + ESTOQUE DIAS: ', p_var_txt
      LET p_var_txt = p_limite_trava
      LET p_msg = p_msg CLIPPED, ' LIMITE DA TABELA: ', p_var_txt
      CALL pol1234_altera_staus_oc('X') RETURNING p_status
      RETURN p_status
   END IF
   
   RETURN TRUE      
   
END FUNCTION
                               
#-----------------------------------------#
FUNCTION pol1234_altera_staus_oc(p_sit_oc)#
#-----------------------------------------#

   DEFINE p_sit_oc, p_sit_prog CHAR(01)
   
   UPDATE ordem_sup
      SET ies_situa_oc = p_sit_oc
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ordem_sup')
      RETURN FALSE
   END IF
   
   IF p_nom_programa = 'POL1157' THEN
      IF NOT pol1234_ins_mensagem() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
         
   IF p_sit_oc = 'X' THEN
      LET p_men = 'A ordem ficará bloqueada pelo seguinte motivo:\n',
            p_msg CLIPPED, '\n\nContinuar assim mesmo?.'
      IF log0040_confirm(20,25,p_men) THEN
         IF NOT pol1234_ins_mensagem() THEN
            RETURN FALSE
         END IF
      ELSE
         RETURN FALSE
      END IF
   END IF
   
   LET p_status_oc = p_sit_oc
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1234_ins_mensagem()#
#------------------------------#

   SELECT num_oc
     FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND chave_processo = p_chave_processo
   
   IF STATUS = 100 THEN 
      INSERT INTO oc_bloqueada_454
       VALUES(p_chave_processo,
              p_cod_empresa,
              p_num_oc,
              p_msg)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando', 'oc_bloqueada_454')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'oc_bloqueada_454')
         RETURN FALSE
      END IF      
   END IF         
   
   INSERT INTO item_criticado_bi_454
    VALUES(p_chave_processo,
           p_cod_empresa,
           p_num_oc,
           p_cod_item,
           p_seq_periodo,
           p_msg,
           p_cod_lin_prod,
           p_id_prog_ord)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'item_criticado_bi_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1234_abate_do_corte()#
#--------------------------------#

   DEFINE p_qtd_abat DECIMAL(10,3),
          p_corte    DECIMAL(10,3)
   
   LET p_qtd_abat = p_qtd_ajuste
   
   DECLARE cq_abat CURSOR FOR
    SELECT qtd_ajuste,
           id_registro
     FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item
      AND MONTH(dat_entrega_prev) = MONTH(p_dat_programacao)
      AND YEAR(dat_entrega_prev) = YEAR(p_dat_programacao)
      AND dat_origem >= p_dat_origem
      AND tip_ajuste = 'C'
      AND qtd_ajuste > 0
   
   FOREACH cq_abat INTO p_corte, p_id_registro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_ABAT')
         RETURN FALSE
      END IF
      
      IF p_corte >= p_qtd_abat THEN
         UPDATE prog_ord_sup_454 
            SET qtd_ajuste = qtd_ajuste - p_qtd_abat
          WHERE id_registro = p_id_registro
         LET p_qtd_abat = 0
      ELSE
         UPDATE prog_ord_sup_454 
            SET qtd_ajuste = qtd_ajuste - p_corte
          WHERE id_registro = p_id_registro
         LET p_qtd_abat = p_qtd_abat - p_corte
      END IF

      IF p_qtd_abat <= 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION      


   