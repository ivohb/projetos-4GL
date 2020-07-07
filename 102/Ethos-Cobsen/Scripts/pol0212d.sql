select * from item_fornec where cod_empresa = '01' and cod_item = 'BH-0008'  and cod_fornecedor = '060608866000454'
select * from item_barra where cod_item in ('100000034209' , 'BH-0008')
 .reservado_03[1,1]=’S’).

select * from grupo_skip_lot_5054
select * from fornec_item_5054

select * from log_versao_prg where num_programa = 'SUP0090'

drop procedure grava_fornec

select * from ped_itens_qfp
select * from ped_itens_qfp_pe5

                 SELECT UNIQUE ped_itens_qfp.num_pedido,
                 ped_itens_qfp.cod_item, pedidos_qfp.num_nff_ult,
                 pedidos.cod_cliente,pedidos_qfp.cod_item_cliente
                 FROM ped_itens_qfp, pedidos, OUTER pedidos_qfp
                 WHERE ped_itens_qfp.cod_empresa = '01'
                 AND pedidos_qfp.cod_empresa = ped_itens_qfp.cod_empresa
                 AND pedidos_qfp.num_pedido  = ped_itens_qfp.num_pedido
                 AND pedidos.cod_empresa     = ped_itens_qfp.cod_empresa
                 AND pedidos.num_pedido      = ped_itens_qfp.num_pedido

    SELECT *
      FROM ped_itens_qfp
     WHERE ped_itens_qfp.cod_empresa = '01'
       AND ped_itens_qfp.num_pedido  = 1006
       AND ped_itens_qfp.cod_item    = '21-000-00020'
     ORDER BY prz_entrega

    SELECT *
      FROM ped_itens_qfp
     WHERE ped_itens_qfp.cod_empresa = '01'
       AND ped_itens_qfp.num_pedido  = 1007
       AND ped_itens_qfp.cod_item    = '21-000-00021'
     ORDER BY prz_entrega
