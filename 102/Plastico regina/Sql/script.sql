select * from cli_ferrero_713
select * from wnota
select * from wtransac



select * from fat_nf_mestre  where empresa = '01' and usu_incl_nf = 'admlog' and nota_fiscal in
 (select num_nff from ordem_montag_mest  where cod_empresa = '01' and num_om  in
   (select num_om from ordem_montag_embal   where cod_empresa = '01' and cod_embal_int > 0))
45968, 45969, 45970, 45971, 45975

select * from ordem_montag_embal  where cod_empresa = '01' and num_om in
( select ord_montag from fat_nf_item where empresa = '01' and trans_nota_fiscal in (38322,38323,38324,38325,38330) )

select * from fat_nf_mestre where empresa = '01' and cliente = '1000'
select * from fat_nf_item where empresa = '01' and trans_nota_fiscal in (38322,38323,38324,38325,38330)
select * from fat_nf_item_fisc
select * from clientes where cod_cliente in('1000','1014')
select * from nat_operacao
select * from cond_pgto
select * from texto_nf
select * from ordem_montag_mest where cod_empresa = '01' and num_om = 10
select * from ordem_montag_embal  where cod_empresa = '01' and cod_embal_int > 0
select * from embal_plast_regina
select * from item
select * from item_de_terc
select * from embalagem
