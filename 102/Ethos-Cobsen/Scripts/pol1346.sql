LogixTst
select * from semana where cod_empresa = '01'
select * from item_man where cod_empresa = '01' and cod_item in ('20-200-04717','20-110-01548')
select * from limite_proces_547
select * from limite_erro_547
select * from estrut_ordem_547 where num_pedido = 19229 and seq_pedido = 36  order by ord_processo desc, seq_operac desc


-- delete from estrut_ordem_547
select * from ordens where cod_empresa = '01' and num_ordem = 15452417 -- 27/07 - 1 = 26/7  2 dias pra fazer / pai
select * from ordens where cod_empresa = '01' and num_ordem = 15452471  -- 18/7             1 dias pra fazer / filha
select * from ordens where cod_empresa = '01' and num_ordem = 15452834  -- 11/7             2 dias pra fazer / neta
select * from ordens where cod_empresa = '01' and num_ordem = 15452838  -- 11/7             2 dias pra fazer / neta
select * from ord_oper where cod_empresa = '01' and num_ordem = 15372742  -- 5 10
select * from info_tecnicas where cod_empresa = '01' and cod_compon = 'TODOS' AND cod_pdr_info_tec = 995 -- 2
select * from ord_ped_item_547 where cod_empresa = '01' and num_ordem = 15372698
select * from ped_itens where num_pedido = 19229 and num_sequencia = 36
15409446   15409145

21330
    select * from ord_oper_txt where cod_empresa = '01' and ies_tipo = 'Q'
      and num_ordem in (select num_ordem from ordens where cod_empresa = '01'
        and num_ordem in(select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 21736 and num_sequencia = 29 )) order by num_ordem, num_processo

   SELECT o.num_ordem, o.cod_item, o.cod_item_pai,
           o.dat_entrega, o.ies_situa, ord.num_pedido, ord.num_sequencia
      FROM ordens o, ord_ped_item_547 ord
     WHERE o.cod_empresa = '01'
       AND o.ies_situa = '3'
       AND o.cod_item_pai = '0'
       --and o.num_ordem = 15409446
       AND o.num_ordem NOT IN
           (SELECT x.num_ordem FROM limite_proces_547 x
             WHERE x.cod_empresa = '01')
       AND o.cod_empresa = ord.cod_empresa
       AND o.num_ordem = ord.num_ordem
       AND o.cod_item in (select cod_item from item_man where cod_empresa = '01' and cod_etapa = 'G')
   order by num_ordem desc


   select * from ordens where cod_empresa = '01'
        and num_ordem in (select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 22187 and num_sequencia = 1 )
 select * from ordens where cod_empresa = '01'
        and num_ordem in (select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 22400 and num_sequencia = 3 )

select * from ord_oper where cod_empresa = '01' and num_ordem = 15409366 15409368 15409366
22400 3   22402 1   22078 7   20571 1    22187 1
select * from info_tecnicas where cod_empresa = '01' and cod_compon = 'TODOS' AND cod_pdr_info_tec = 993 and num_seq = 10
select * from ordens where cod_empresa = '01' and num_ordem = 15409357 -- 16/07/2018
select * from limite_proces_547
select * from estrut_ordem_547 where num_pedido =  22400 and seq_pedido = 3  order by ord_processo desc, seq_operac desc
select * from sequenc_calc_547 where num_pedido =  22400 and seq_pedido = 3

    select * from ord_oper_txt where cod_empresa = '01' and ies_tipo = 'Q'
      and num_ordem in (select num_ordem from ordens where cod_empresa = '01'
        and num_ordem in(select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 21736 and num_sequencia = 29 )) order by 2, 6 desc

    select * from ord_oper_txt where cod_empresa = '01' and ies_tipo = 'Q'
      and num_ordem in (select num_ordem from ordens where cod_empresa = '01'
        and num_ordem in(select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 19229 and num_sequencia = 36 )) order by 2, 6 desc

    select * from ord_oper_txt where cod_empresa = '01' and ies_tipo = 'Q'
      and num_ordem in (select num_ordem from ordens where cod_empresa = '01'
        and num_ordem in(select num_ordem from ord_ped_item_547 where cod_empresa = '01'
        and num_pedido = 22400 and num_sequencia = 3 )) order by 2, 6 desc


    SELECT id_registro, num_ordem,
           cod_operac, num_processo,
           qtd_dias, ord_processo
      FROM estrut_ordem_547
     WHERE cod_empresa = '01'
       AND num_pedido = 19229
       AND seq_pedido = 36
     ORDER BY ord_processo DESC, seq_operac DESC

       SELECT num_ordem, cod_operac, seq_operac, ord_processo
         FROM estrut_ordem_547
        WHERE cod_empresa = '01'
          AND num_pedido = 19229
          AND seq_pedido = 36
          AND cod_operac = '00005'
          AND ord_processo < 3

          SELECT cod_operac, seq_operac
            FROM estrut_ordem_547
           WHERE cod_empresa = '01'
             AND num_pedido = 19229
             AND seq_pedido = 36
             AND num_ordem = 15372742
             AND seq_operac > 1
           ORDER BY seq_operac DESC


    SELECT id_registro,
           num_ordem,
           cod_operac,
           seq_operac
      FROM estrut_ordem_547
     WHERE cod_empresa = '01'
       AND num_pedido = 19229
       AND seq_pedido = 36
       AND qtd_dias = 0


       SELECT dat_limite
         FROM estrut_ordem_547
        WHERE cod_empresa = '01'
          AND num_pedido = 19229
          AND seq_pedido = 36
          AND num_ordem = 15372740
          --AND cod_operac = '00011'
          AND seq_operac <> 2
        ORDER BY seq_operac DESC