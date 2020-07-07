SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,b.num_pedido_repres,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,e.qtd_pecas_cancel as qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.prz_entrega,e.num_sequencia,
		  year(a.data) as ano ,month(a.data) as mes,
		  (month(a.data)||'/'||year(a.data) ) as mesano,
                  b.cod_nat_oper as cod_tip_cli,
                  day(a.data) as dia
             from audit_vdp a,
                  pedidos b,
                  ped_itens e
             where a.cod_empresa ='".$empresa."'
               and a.data between '".$ini."' and '".$fim."'
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,3]='SEQ'
               and b.num_pedido=a.num_pedido
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and trim(e.cod_item)=trim(a.texto[18,26])
               and e.num_sequencia=(trim(a.texto[6,12])/1)


union all
        SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,b.num_pedido_repres,
                  b.ies_frete,b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,e.qtd_pecas_cancel as qtd_pecas_solic,e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.prz_entrega,e.num_sequencia,
		  year(a.data) as ano ,month(a.data) as mes,
		  (month(a.data)||'/'||year(a.data) ) as mesano,
                  b.cod_nat_oper as cod_tip_cli,
                  day(a.data) as dia
             from audit_vdp a,
                  pedidos b,
                  ped_itens e
             where a.cod_empresa ='".$empresa."'
               and a.data between '".$ini."' and '".$fim."'
               and a.tipo_movto='C'
               and a.num_programa='VDP1080'
               and a.texto[1,16]='PEDIDO CANCELADO'
               and b.num_pedido=a.num_pedido               
               and b.cod_empresa=a.cod_empresa
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido

   order by  18,19,3,2            ";
