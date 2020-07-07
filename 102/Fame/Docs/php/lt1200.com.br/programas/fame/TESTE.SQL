  set isolation to dirty read;
UNLOAD to cancel.txt
SELECT sum(e.pre_unit*e.qtd_pecas_cancel)
{ a.data,b.num_pedido,e.num_sequencia,e.pre_unit*e.qtd_pecas_cancel,a.texto,'a'
}             from audit_vdp a,
                  pedidos b,
                  ped_itens e
             where a.cod_empresa ='01'
               and a.data between '02/05/2006' and '02/05/2006'
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,3]='SEQ'
               and a.tipo_informacao='I'
               and b.num_pedido=a.num_pedido
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and trim(e.cod_item)=trim(a.texto[18,26])
               and e.num_sequencia=(trim(a.texto[6,12])/1)


union all
             select sum(pre_unit*e.qtd_pecas_cancel)
{
   a.data,b.num_pedido,e.num_sequencia,pre_unit*e.qtd_pecas_cancel,a.texto,'b'
}
             from audit_vdp a,
                  pedidos b,
                  ped_itens e
             where a.cod_empresa ='01'
               and a.data between '02/05/2006' and '02/05/2006'
               and a.tipo_movto='C'
               and a.tipo_informacao='I'
               and a.num_programa='VDP1080'
               and a.texto[1,16]='PEDIDO CANCELADO'
               and b.num_pedido=a.num_pedido
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
