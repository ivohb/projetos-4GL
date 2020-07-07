select * from par_romaneio_970
select * from embal_itaesbra  where cod_empresa = '01' and cod_cliente = '1000' and cod_item = '100000024800' --  5 pç/embal
select * from embal_itaesbra  where cod_empresa = '01' and cod_cliente = '1000' and cod_item = '100000000500' -- 10 pç/embal
select * FROM embalagem WHERE cod_embal in (13,14)
select * from user_romaneio_304
select * from de_para_embal
select * from lote_tmp_304
select * from resumo_embal
select * from w_om_list
select * from om_list

select * from obf_config_fiscal
select * from obf_oper_fiscal where nat_oper_grp_desp = 6
update obf_oper_fiscal set nat_oper_grp_desp = 1001 where nat_oper_grp_desp = 6
select * from nat_operacao where cod_nat_oper = 1001
select * from vdp_valid_nat_oper where cod_nat_oper = 1001
select * from cotacao
select * from pedidos where num_pedido in (831,832) and cod_empresa = '01'
select * from pedidos where cod_cliente = '1000'
select * from ped_itens where num_pedido = 831 and cod_empresa = '01'
select * from ordem_montag_mest where cod_empresa = '01' and num_om >= 43612
select * from ordem_montag_item where cod_empresa = '01' and num_om >= 43612
select * from ordem_montag_embal  where cod_empresa = '01' and num_om >= 43604
select * from ordem_montag_lote
SELECT cod_embal_int, sum(qtd_embal_int) FROM ordem_montag_embal where cod_empresa = '01' and num_om = 43603 group by cod_embal_int

select * from item where cod_empresa = '01' and ies_ctr_lote = 'N'  and cod_item = '100020024500'
select * from embal_itaesbra where cod_cliente = '1000' and cod_item = '100020024500'
select * from estoque where cod_item = '100020024500'
select * from estoque_lote where cod_item = '100020024500'
select * from estoque_lote where cod_item = '100000000500'
select * from estoque_loc_reser where cod_item = '100000000500' and qtd_reservada > 0
select * from estoque_lote_ender where cod_item = '100020024500'
select * from estoque_loc_reser where cod_item = '100020024500' and qtd_reservada > 0
select * from est_loc_reser_end where num_reserva = 541050

select * from item where cod_empresa = '01' and cod_item = '100000000500'
select * from estoque_lote where cod_item = '100000000500'
select * from estoque_lote_ender where cod_item = '100000000500'
select * from estoque_loc_reser where cod_item = '100000000500' and qtd_reservada > 0


select * from fat_solic_mestre where empresa = '01'
select * from fat_solic_fatura where trans_solic_fatura = 2615
select * from fat_solic_embal where trans_solic_fatura = 2615