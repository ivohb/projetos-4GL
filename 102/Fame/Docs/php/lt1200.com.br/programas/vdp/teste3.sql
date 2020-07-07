  set isolation to dirty read;
SELECT unique 'NF','G','05','2006','01'
,a.cod_repres,a.num_nff,a.num_nff,a.dat_emissao,
a.cod_cliente,a.val_tot_mercadoria,a.val_tot_nff,'',d.cod_nivel_3,
f.num_pedido,f.num_pedido_repres, f.dat_emis_repres,f.dat_pedido
 from
logix:nf_mestre a,
 logix:representante b,
 lt1200_representante c,
logix:canal_venda d ,
 logix:nf_item e,
 logix:pedidos f
 where
 a.cod_empresa='01' and a.dat_emissao between '27/04/2006' and '30/05/2006'
 and a.ies_situacao <>'C' and b.cod_repres=a.cod_repres and
 c.cod_repres=b.cod_repres and c.tipo='A' and c.pct_nff > 0 and
 d.cod_nivel_4=a.cod_repres
{ and
 (a.cod_empresa||a.num_nff||trim(a.cod_cliente)||round(a.cod_repres))

not in
 (
select(a.cod_empresa||trim(a.num_nff)||trim(a.cod_cliente)||round(a.cod_repres))
from lt1200_comissoes a where a.ies_tipo_lancto=='G' and a.cod_empresa='01')
and e.cod_empresa=a.cod_empresa and e.num_nff=a.num_nff and
f.cod_empresa=e.cod_empresa and f.num_pedido=e.num_pedido
}