select * from ped_itens a, pedidos b where a.cod_empresa = '01'
and b.cod_empresa = '01' and a.num_pedido = b.num_pedido and b.ies_sit_pedido = 'N'
and a.qtd_pecas_atend = 0 and a.qtd_pecas_cancel = 0
and a.prz_entrega between '01/03/2012' and '31/03/2012'
and cod_item in (select cod_item from item_man where cod_empresa = '01')

select * from ped_dem_5000

select * from ordens where cod_empresa = '01' and num_ordem >= 1347866
select * from man_oper_compl where empresa = '01' and ordem_producao >= 1347860
select * from man_op_componente_operacao where empresa = '01' and ordem_producao >= 1347860
select * from ord_oper_txt where cod_empresa = '01' and num_ordem >= 1347866
select * from ord_oper where cod_empresa = '01' and num_ordem = 1347866 item 130000502200   oper 019 seq 1 rot rot padrao alt 1
select * from man_estrut_oper

       SELECT man_estrut_oper.empresa,
              man_estrut_oper.item_componente,
              item.ies_tip_item,
              man_estrut_oper.qtd_necess,
              man_estrut_oper.pct_refugo,
              man_estrut_oper.parametro_geral
         FROM man_estrut_oper, item
        WHERE man_estrut_oper.empresa            = '01'
          AND man_estrut_oper.item               = '130000502200'
          AND man_estrut_oper.roteiro            = 'PADRAO'
          AND man_estrut_oper.num_altern_roteiro = 1
          AND man_estrut_oper.sequencia_operacao = 1
          AND man_estrut_oper.empresa            = item.cod_empresa
          AND man_estrut_oper.item_componente    = item.cod_item
          AND (man_estrut_oper.dat_valid_inicial IS NULL OR
               man_estrut_oper.dat_valid_inicial <= '21/02/2012')
          AND (man_estrut_oper.dat_valid_final   IS NULL OR
               man_estrut_oper.dat_valid_final   >= '21/02/2012')
        ORDER BY man_estrut_oper.parametro_geral[6, 10]
