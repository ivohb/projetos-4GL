select * from desc_nat_oper_885 where cod_empresa = '01' and num_pedido = 1
select * from empresa where cod_empresa = '01'
select * from pedidos where cod_empresa = '01' and num_pedido = 2
select * from ped_itens where cod_empresa = '01' and num_pedido = 2
select * from nat_operacao where cod_nat_oper = 101
select * from tipo_carteira WHERE cod_tip_carteira = '2'
select * from clientes where num_cgc_cpf = '004.506.441/0001-10' --cidade 20000 (Rio Janeiro)
select * from clientes where cod_cliente = '2107' -- cliente // cidade 12200 (SJ dos campos)
select * from clientes where cod_cliente = '1114' --Transportador

select * from  desc_transp_885
select * from frete_rota_885
select * from solicit_fat_885
select * from nf_solicit_885
select * from desc_transp_885
select * from frete_solicit_885
select * from frete_roma_885
select * from romaneio_885
select * from roma_item_885
select * from roma_erro_885

select * from ordem_montag_lote
select * from estoque_loc_reser where num_reserva = 964
select * from est_loc_reser_end where num_reserva = 964
select * from ordem_montag_grade where num_om = 30
select * from ordem_montag_item where num_om = 30
select * from ordem_montag_mest where num_om = 30
select * from ordem_montag_embal where num_om = 30
select * from om_list
select * from nf_solicit
select * from fat_solic_ser_comp
select * from fat_solic_mestre
select * from fat_solic_fatura
select * from fat_solic_embal

select * from grupo_item
select * from item_vdp where cod_empresa = '01' and cod_item = '010740006'
select * from item where cod_empresa = '01' and cod_item in ('010740006')
select * from estoque where cod_empresa = '01' and cod_item in ('010740006')
select * from estoque_lote where cod_empresa = '01' and cod_item in ('010740006')
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in ('010740006')
select * from estoque_loc_reser where cod_empresa = '01' and cod_item in ('010740006')
select * from est_loc_reser_end where cod_empresa = '01' and num_reserva =


select * from ordens where num_ordem = 1          -- item chapa novo 2311-002-2
select * from ord_compon where num_ordem = 1
select * from necessidades where num_ordem = 1
select * from ordens where num_ordem = 2          -- item chapa origem = '2313-039-6'
select * from ord_compon where num_ordem = 2
select * from necessidades where num_ordem = 2

select * from item where cod_empresa = '01' and cod_item in ('2311-002-2','2313-039-6')
select * from item_man where cod_empresa = '01' and cod_item in ('2311-002-2','2313-039-6')
select * from estoque where cod_empresa = '01' and cod_item in ('2311-002-2','2313-039-6')
select * from estoque_lote where cod_empresa = '01' and cod_item in ('2311-002-2','2313-039-6')
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in ('2311-002-2','2313-039-6')

select * from item_chapa_885 where cod_empresa = '01' and num_pedido = 1