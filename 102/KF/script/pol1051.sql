SELECT cod_cliente FROM cli_edi_1099
select * from item_prog_kf_1099

SELECT pedidos.num_pedido,
       ped_itens.num_sequencia,
       ped_itens.cod_item,
       pedidos.cod_cliente,
      (ped_itens.qtd_pecas_solic - (ped_itens.qtd_pecas_atend + ped_itens.qtd_pecas_cancel + ped_itens.qtd_pecas_reserv)),
       ped_itens.prz_entrega
  FROM pedidos, ped_itens
 WHERE pedidos.cod_empresa    = '01'
   AND pedidos.cod_empresa    = ped_itens.cod_empresa
   AND pedidos.num_pedido     = ped_itens.num_pedido
   AND pedidos.ies_sit_pedido <> '9'
   AND (qtd_pecas_solic - (qtd_pecas_atend + qtd_pecas_cancel + qtd_pecas_reserv)) > 0
   AND pedidos.cod_cliente IN (SELECT cod_cliente FROM cli_edi_1099)
   AND ped_itens.prz_entrega  >= '01/08/2011'
   AND ped_itens.prz_entrega  <= '11/08/2011'
   order by ped_itens.prz_entrega

   select * from estrutura where cod_item_pai in ('100000035700','100000035800')
   select * from estoque_lote where cod_item in ('100000035700','100000035800')

   select * from caminho_1099
   select * from w_edi_volksvagen
   create table processo_edi_1099 (
   cod_empresa  char(02),
   num_processo integer)