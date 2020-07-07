select * from embal_plast_regina
select * from cli_ferrero_713
select * from dir_ferrero_713
select * from ordem_montag_tran where cod_empresa = '01'
select * from ordem_montag_mest where cod_empresa = '01'
select * from estrut_item_indus

select * from wtransac
select * from wnota
select * from clientes where cod_cliente = '003013136000558'
select * from fat_nf_mestre where empresa = '01' and trans_nota_fiscal in (41779, 41781, 42450)

select * from fat_nf_item_fisc where empresa = '01' and trans_nota_fiscal = 1
select * from fat_nf_texto
select * from fat_nf_item where empresa = '01' and trans_nota_fiscal in (41779, 41781, 42450)
select * from ordem_montag_embal where cod_empresa = '01' and num_om in (27243, 28659)

 select * from fat_nf_mestre where empresa = '01' and cliente = '003013136000558' and usu_incl_nf = 'admlog' and trans_nota_fiscal in
 (select trans_nota_fiscal from fat_nf_item where empresa = '01' and ord_montag in (select num_om from ordem_montag_embal where cod_empresa = '01'))
 order by cliente

select * from fat_nf_mestre where empresa = '01' and trans_nota_fiscal in