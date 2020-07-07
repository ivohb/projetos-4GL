select * from parametros_885

select * from item where cod_item = '696910001' and cod_empresa = '01'
select * from estoque where cod_item = '696910001'
select * from estoque_lote where cod_item = '696910001'
select * from estoque_lote_ender where cod_item = '696910001'
select * from estoque_trans where cod_item = '696910001' and dat_proces = '2014-10-21'
select * from estoque_trans_end where cod_item = '696910001' and dat_movto = '2014-10-21'
select * from estoque_auditoria where num_programa = 'POL0800'
select * from estoque_trans_rev
