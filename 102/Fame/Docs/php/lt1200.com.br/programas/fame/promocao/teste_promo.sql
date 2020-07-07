{        SELECT 'D',c.cod_cliente,a.cod_empresa,a.num_om,a.num_nff,
               a.dat_emis,'1',c.num_pedido,sum(b.qtd_reservada),sum(0)
             from ordem_montag_mest a,
                  ordem_montag_item b,
                  pedidos c,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where a.cod_empresa ='01'
               and b.num_om=a.num_om
               and b.cod_empresa=a.cod_empresa
               and c.ies_sit_pedido in ('N','2','F','3','1','B')
               and c.num_pedido=b.num_pedido

               and k.cod_empresa=b.cod_empresa
               and k.cod_item=b.cod_item
               and k.cod_grupo_item in('048','049')
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=b.cod_item
               and m.cod_empresa=b.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
}
        SELECT 'D',c.cod_cliente,a.cod_empresa,a.num_om,a.num_nff,
               a.dat_emis,'1',c.num_pedido,sum(0),sum(b.qtd_reservada)
             from ordem_montag_mest a,
                  ordem_montag_item b,
                  pedidos c,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where a.cod_empresa ='01'
               and b.num_om=a.num_om
               and b.cod_empresa=a.cod_empresa
               and c.ies_sit_pedido in ('N','2','F','3','1','B')
               and c.num_pedido=b.num_pedido

               and k.cod_empresa=b.cod_empresa
               and k.cod_item=b.cod_item
               and k.cod_grupo_item in('008','022','045')
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=b.cod_item
               and m.cod_empresa=b.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
group by 1,2,3,4,5,6,7,8
