SET ISOLATION TO DIRTY READ
alter table item_kanban_547 add tipo_item char(10) default 'KANBAN' not null
alter table item_kanban_547 add qtd_dias integer default 2 not null

select * from item_kanban_547 order by cod_empresa, cod_item

select * from min_par_modulo where empresa = '01'
select * from ped_itens_qfp
select * from ped_itens_qfp_547_vv where cod_empresa = '01' AND num_pedido = 10591 ORDER BY prz_entrega
select * from ped_itens_qfp_pe5_547_vv where cod_empresa = '01' AND num_pedido = 10591 and num_sequencia = 2 and cod_item = '20-110-01097'
select * from ped_itens where cod_empresa = '06' and num_pedido = 10591 ORDER BY prz_entrega
select * from ped_it_qfp_pe5_cl_547_vv
select * from prog_temp_547
select * from item_kanban_547 WHERE COD_EMPRESA <> '01'  UPDATE item_kanban_547 SET COD_EMPRESA = '01' WHERE COD_EMPRESA = '06'

select prz_entrega, qtd_solic, qtd_atend, qtd_solic_nova, qtd_solic_aceita, dat_abertura
from ped_itens_qfp_547_vv a, ped_itens_qfp_pe5_547_vv b
where a.cod_empresa = b.cod_empresa and a.num_pedido = b.num_pedido and a.num_sequencia = b.num_sequencia
  and a.num_pedido = 10591 and a.num_sequencia = 8

select * from pedidos_qfp_547_vv
select * from pedidos where cod_empresa = '01' and cod_cliente = '063736714000182'
select * from ped_itens where cod_empresa = '01' and num_pedido = 3029 1005 order by prz_entrega
select * from ped_itens where cod_empresa = '01' and qtd_pecas_atend = 0 and num_Pedido in
  (select num_pedido from pedidos where cod_empresa = '01' and ies_sit_pedido = 'N' and cod_cliente = '063736714000182')
  order by num_pedido, num_sequencia desc

select * from cliente_item where cod_cliente_matriz = '063736714000182' and cod_item = '2660394000T-0A' and cod_item_cliente = 'XO-000GK-0'
select * from cliente_item where cod_cliente_matriz = '063736714000182' and cod_item = '2660406000T-0A' and cod_item_cliente = 'X0-RM01F-0'


SELECT UNIQUE
     a.num_pedido, a.cod_item, c.num_nff_ult, b.cod_cliente, c.cod_item_cliente
FROM ped_itens_qfp_547_vv a,
     pedidos b,
     OUTER pedidos_qfp_547_vv c
WHERE a.cod_empresa = '01'
  AND c.cod_empresa = a.cod_empresa
  AND c.num_pedido  = a.num_pedido
  AND b.cod_empresa     = a.cod_empresa
  AND b.num_pedido      = a.num_pedido

  update ped_itens_qfp_547_vv set num_pedido = 1005