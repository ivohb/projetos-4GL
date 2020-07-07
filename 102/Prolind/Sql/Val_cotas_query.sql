select * from cfg_val_cotas912 c
inner join pedidos p on
c.cod_empresa = p.cod_empresa
and c.num_pedido = p.num_pedido_cli[1,10]
and c.pos[1,3] = p.num_pedido_cli[12,14]
and c.pos[4,6] = p.num_pedido_repres
where p.cod_empresa = 'XX'
and p.num_pedido = 'XXXXX'