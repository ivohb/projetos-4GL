select * from frm_zoom where zoom_name like '%funciona%'  -- zoom_desc_preco_mest
SELECT *  FROM frm_toolbar where resource_name like '%expo%'
SELECT *  FROM frm_toolbar where resource_name like '%grupo%' -- VISUALIZAR_GRUPOS GRUPO_FISCAL_ITEM item_x_grupo
SELECT *  FROM frm_toolbar where resource_name like '%ERRO%' ZOOM_ERROS ERRO_INC

select * from path_logix_v2 where cod_empresa = '06' and cod_sistema = 'EDI' -- c:\ivo\edi\
select top 10 * from ped_itens where cod_empresa = '06' and num_sequencia > 5 order by num_pedido desc
select * from empresa
select * from item where cod_empresa = '06' and cod_item = 'KKBC'
select * from clientes where cod_cliente = '011636645000131'
select * from cliente_item where  cod_empresa = '06' and cod_cliente_matriz = '011636645000131' and cod_item = 'KKBC'
select * from cliente_item where  cod_empresa = '06' and cod_cliente_matriz = '011636645000131' and cod_item_cliente = 'MIT001'
select * from pedidos where cod_empresa = '06' and num_pedido = 134634
select * from ped_itens where cod_empresa = '06' and  num_pedido = 134634

select pedidos.num_pedido, ped_itens.cod_item from pedidos
   inner join ped_itens
      on ped_itens.cod_empresa = pedidos.cod_empresa and ped_itens.num_pedido = pedidos.num_pedido
   and (ped_itens.qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio) > 0
 where pedidos.cod_empresa = '06' and pedidos.cod_cliente = '011636645000131' and pedidos.ies_sit_pedido <> '9'
   and pedidos.num_pedido not in
     (select distinct pedidos_komatsu.num_pedido from pedidos_komatsu where pedidos_komatsu.id_arquivo = 1)

 select * from ped_itens where cod_empresa = '06' and  num_pedido = 134634

select * from ped_itens_texto where cod_empresa = '06' and num_pedido = 134634
select * from ped_seq_ped_cliente where empresa = '06' and pedido = 134634
select * from qfptran_komatsu
select * from cliente_komatsu
select * from periodo_firme_komatsu
select * from arquivo_komatsu
select * from programacao_komatsu
select * from pedidos_komatsu
select * from itens_komatsu
select * from erro_komatsu
-- delete from programacao_komatsu
select cod_cliente, item_cliente
  from programacao_komatsu
 where cod_empresa = '06'
   and id_arquivo = 1
 group by cod_cliente, item_cliente

select prazo, ordem, pos, pendente
  from programacao_komatsu
 where cod_empresa = '06'
   and id_arquivo = 1
   and cod_cliente = '011636645000131'
   and item_cliente = 'MIT001'
