select * from item_altern
select * from log_val_parametro where parametro = 'gera_est_trans_relac'
select * from parametros_885

select * from par_estoque
select * from par_pcp
select * from estoque_operac where cod_empresa = '01'
select * from estoque_operac_ct where cod_empresa = '01'
-- delete from cons_insumo_885
select * from ordens_bob_885
select * from oper_bob_885
select * from ordens where cod_empresa = '02' and ies_situa = '3'
select * from apont_msg_885
SELECT * FROM proces_apont_885
select *   from apont_papel_885 order by 2,7
select * from apont_erro_885 where codempresa = '02'
select *  from cons_insumo_885 order by 11
select * from man_apont_885 order by seq_leitura
select * from man_apont_hist_912
select * from de_para_maq_885 where cod_empresa = '02'
select * from turno

select * from familia_insumo_885
select * from apont_trans_885 where  cod_empresa = '02' ORDER BY 2
select * from apont_sequencia_885 where cod_empresa = '02' ORDER BY 2

select * from pedidos where cod_empresa = '02' and num_pedido = 2479
select * from ped_itens where cod_empresa = '02' and num_pedido = 2479
select * from tipo_pedido_885 where cod_empresa = '02' and num_pedido = 2479
select * from item_bobina_885 where  cod_empresa = '02' and num_pedido = 2479
select * from desc_nat_oper_885 where cod_empresa = '02' and num_pedido = 2479

select * from ordens where cod_empresa = '02' and num_docum = '2483/1'
select * from ordens where cod_empresa = '02' and num_ordem = 11285
select * from ord_compon where cod_empresa = '02' and num_ordem = 11285
select * from necessidades where cod_empresa = '02' and num_ordem = 11285
select * from ord_oper where cod_empresa = '02' and num_ordem = 11285

select * from consumo where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
select * from item where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
select * from item_man where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
select * from item_ctr_grade where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
                                                                                                   bob  retr refugo
select * from estoque where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007') --62023 0 1000,923
select * from estoque_lote where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
select * from estoque_lote_ender where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
select * from estoque_lote_ender where cod_empresa = '02' and cod_item = 'CD100' AND num_lote = 'M21619391979'
select * from estoque_lote where cod_empresa = '02' and cod_item = 'CD100' AND num_lote = 'M21619391979'
select * from estoque_loc_reser where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007') and qtd_reservada > 0
select * from estoque_trans where cod_empresa = '02' and cod_item in ('CD100','959990001','010040007')
and dat_movto = '11/01/2015' order by 2


select * from item_vdp where cod_empresa = '01' and cod_item = '2313-039-6'
select * from grupo_produto_885 where cod_grupo = '02'
select * from apont_papel_885
select *  from man_apo_mestre where empresa = '02' order by 2
select *  from man_apo_detalhe where empresa = '02'
select *  from man_tempo_producao where empresa = '02' order by 2
select * from man_item_produzido where empresa = '02' and seq_reg_mestre >= 2044       -- mov_estoque 23826408
select * from chf_componente where empresa = '02' and sequencia_registro  >= 10863458
select * from man_comp_consumido where empresa = '02' and seq_reg_mestre >= 2044
-- delete from apo_oper
select * from apo_oper where cod_empresa = '02' and num_processo >= 10863469
select * from cfp_apms  where cod_empresa = '02' and num_seq_registro >= 10863469
select * from cfp_appr  where cod_empresa = '02' and num_seq_registro >= 10863458
select * from cfp_aptm  where cod_empresa = '02' and num_seq_registro >= 10863458
select * from man_relc_tabela  where empresa = '02'
select * from man_def_producao  where empresa = '02'