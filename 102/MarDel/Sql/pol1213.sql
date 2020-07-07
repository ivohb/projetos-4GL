SET ISOLATION TO DIRTY READ
select * from min_par_modulo where parametro LIKE '%FIAT%'
select * from fornec_nf_5054
select * from cliente_nf_5054
select * from tipo_nf_5054
select * from item_cliente_5054


select * from nota_temp_5054

select * from nf_sup where cod_empresa = '01' and dat_entrada_nf >= '01/01/2013' and cod_fornecedor = '1100-MO'
select * from aviso_rec where cod_empresa = '01' and num_aviso_rec = 102294
select * from fornecedor where cod_fornecedor = '1100-MO
select * from fat_nf_mestre where empresa = '01' and date(dat_hor_emissao) >= '01/01/2012' and cliente = '1011'
select * from fat_nf_item where empresa = '01' and trans_nota_fiscal in (1,2)
select * from fat_nf_item_fisc where empresa = '01' and trans_nota_fiscal in (1,2)
itens 1 110011
select * from clientes where cod_cliente = '1011'
select * from item
select * from cliente_item where cod_empresa = '01' and cod_item = '111010303200   '
select * from cliente_item where cod_empresa = '01' and cod_cliente_matriz = '1011' and cod_item in ('1','110011')
016701716000156

2.124

select * from mat_temp_5054
select * from item_cliente_5054

select * from estoque where cod_empresa = '01' and qtd_liberada > 0
 and cod_item in (select cod_item from item_cliente_5054 where cod_empresa = '01')

 select * from cliente_item where cod_empresa = '01' and cod_cliente_matriz = '1011' and cod_item in
 ('ABR002', 'ABR005', '10000000010020', '100000000400', '10000000330110 ')