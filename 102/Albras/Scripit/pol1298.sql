select * from ordem_compra_drummer
select * from erro_oc_304
select * from ordem_sup where cod_empresa = '21' and num_oc = 12981
select * from dest_ordem_sup where cod_empresa = '21' and num_oc = 12981
select * from ordem_sup_compl where cod_empresa = '21' and num_oc = 12981
select * from prog_ordem_sup where cod_empresa = '21' and num_oc = 12981
select * from ordem_sup_audit where cod_empresa = '21' and num_oc = 12981
select * from item where ies_tip_item = 'C' and cod_empresa = '21'

LPC003       LPC005
select * from sup_oc_grade where ordem_compra >= 1162