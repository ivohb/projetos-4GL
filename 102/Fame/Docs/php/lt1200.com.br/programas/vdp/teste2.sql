select a.ies_tip_docto,'G',a.mes_ref,
a.ano_ref,a.cod_empresa,a.cod_supervisor ,a.num_nff,a.num_docum,
a.dat_emissao,a.cod_cliente,
a.val_tot_mercadoria,a.val_tot_docum,a.observacao,
a.cod_supervisor,a.num_pedido,
a.num_pedido_repres,a.dat_emis_repres,a.dat_pedido 
from lt1200_comissoes a,
 logix:canal_venda b where a.mes_ref='05' and a.ano_ref='2006' and
 a.ies_tipo_lancto='A' and b.cod_nivel_4=a.cod_repres 