select * from pedidos where cod_empresa = '01' and num_pedido = 124440
select * from ped_itens where cod_empresa = '01' and num_pedido = 124440
select * from item where cod_empresa = '01' and cod_item = '21045'

select * from ordens where cod_empresa = '01' and num_docum = '124440/4'
select * from ord_compon where cod_empresa = '01' and num_ordem = 494434
           SELECT *
             FROM ord_compon a, item b
            WHERE a.cod_empresa = '01'
              AND a.num_ordem = 494434
             -- AND a.num_ordem > m_ordem_antiga
              AND a.ies_tip_item <> 'C'
              AND b.cod_empresa = a.cod_empresa
              AND b.cod_item = a.cod_item_compon
              AND b.cod_familia  in ('200','201','202','205')
              AND substring(a.cod_item_compon,1,1) < 'A'

select * from ordens_885 where numpedido = 124440 and numseqitem = 4

select * from estrut_grade where cod_empresa = '01'
 and cod_item_pai = '21045'


--------------------------------------------

select * from pedidos where cod_empresa = '01' and num_pedido = 124812
select * from ped_itens where cod_empresa = '01' and num_pedido = 124812
select * from item where cod_empresa = '01' and cod_item = '12620'

select * from ordens where cod_empresa = '01' and num_docum = '124812/10'
select * from ord_compon where cod_empresa = '01' and num_ordem = 497017
           SELECT *
             FROM ord_compon a, item b
            WHERE a.cod_empresa = '01'
              AND a.num_ordem = 497017
             -- AND a.num_ordem > m_ordem_antiga
              AND a.ies_tip_item <> 'C'
              AND b.cod_empresa = a.cod_empresa
              AND b.cod_item = a.cod_item_compon
              AND b.cod_familia  in ('200','201','202','205')
              AND substring(a.cod_item_compon,1,1) < 'A'

select * from ordens_885 where numpedido = 124440 and numseqitem = 4

select * from estrut_grade where cod_empresa = '01'
 and cod_item_pai = '12620'

select * from estrut_grade where cod_empresa = '01'
 and cod_item_pai = '12620A'

select * from estrut_grade where cod_empresa = '01'
 and cod_item_pai = '12620CX'