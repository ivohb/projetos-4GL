select * from parametros_885 -- 002.030/11-IT1
select * from par_estoque
select * from par_pcp
select * from estoque_operac where cod_empresa = '02'
select * from desc_nat_oper_885 where cod_empresa = '02'
-- delete from apont_msg_885
select * from apont_msg_885
SELECT * FROM proces_apont_885
select * from apont_trim_885
select * from apont_papel_885
select * from consumo_trimbox_885
select * from apont_erro_885 where codempresa = '02'
select * from man_apont_885 order by seq_leitura
select * from man_apont_hist_912
select * from de_para_maq_885
select * from turno
select * from familia_insumo_885
select * from apont_trans_885 where  cod_empresa = '02' ORDER BY 2
select * from apont_sequencia_885 where cod_empresa = '02' ORDER BY 2
select * from pedidos where cod_empresa = '01' and num_pedido = 1
select * from ped_itens where cod_empresa = '01' and num_pedido = 1

select * from ordens where num_ordem in (select num_ordem from ord_oper)
 and num_ordem in (select num_ordem from ord_compon)
 and num_ordem in (select num_ordem from necessidades)

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

select * from consumo where cod_empresa = '01' and cod_item IN ('2311-002-2','2313-039-6','010740006')
select * from consumo_compl where cod_empresa = '01'  and cod_item IN ('2311-002-2','2313-039-6','010740006')
select * from item where cod_empresa = '02' and cod_item IN ('010490014')
select * from item_vdp where cod_empresa = '01' and cod_item IN ('2311-002-2','2313-039-6','696910001')
select * from grupo_produto_885 where cod_grupo = '02'

select * from consumo where cod_empresa = '01' and cod_item = '151810044'  --ITEM CHAPA ORIGINAL     0000120   0000121
select * from consumo_compl where cod_empresa = '01'  and cod_item = '151810044'
select * from item where cod_empresa = '01' and cod_item = '2313-039-6'
select * from item_vdp where cod_empresa = '01' and cod_item = '2313-039-6'
select * from grupo_produto_885 where cod_grupo = '02'

select * from pedidos where cod_empresa = '01'
select * from ped_itens where cod_empresa = '01' and num_pedido = 2
select * from ordens where cod_empresa = '01' and num_ordem = 2053   --ordem do acessorio
select * from ord_compon where num_ordem = 2053
select * from necessidades where num_ordem = 2053

select * from ordens where cod_empresa = '01' and num_ordem = 2115 --ordem da chapa do acessorio
select * from ord_compon where num_ordem = 2115
select * from necessidades where num_ordem = 2115

select * from ordens where num_ordem = 268          -- ORDEM DA BOBINA
select * from ord_oper where num_ordem = 268
select * from ord_compon where num_ordem = 268
select * from necessidades where num_ordem = 268
select * from pedidos where cod_empresa = '02'
select * from ped_itens where cod_empresa = '02'
                                                              bobina      cola        chapa       sucata       chapa nova
select * from item where cod_empresa = '01' and cod_item in ('010490014','010200010','2313-039-6','696910001','2311-002-2')
                                                              acess.        chapa       grampo
select * from item where cod_empresa = '01' and cod_item in ('010740006 ','151810044','152150006')
select * from item where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT1','002.030/11-IT3')
                                                                  BOBINA       APARAS
select * from item_man where cod_empresa = '02' and cod_item in ('010010001','152210046')
select * from estoque where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT1','002.030/11-IT3')
select * from estoque_lote where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT1','002.030/11-IT3')
select * from estoque_lote_ender where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT1','002.030/11-IT3')
select * from item_ctr_grade where cod_empresa = '01' and cod_item in ('010740006 ','151810044','152150006','010010001')
select * from item_chapa_885 where num_pedido = 1 and num_sequencia = 1
select * from item_bobina_885 where num_pedido = 3 and num_sequencia = 1
select * from tipo_pedido_885

select * from estoque_trans where cod_empresa = '02' and cod_item in ('010010001','152210046','002.030/11-IT3') order by 2 --2811
select * from estoque_trans_end where cod_empresa = '02' and  cod_item in ('010010001','152210046','002.030/11-IT1','002.030/11-IT3')
select * from estoque_trans_rev where cod_empresa = '02'


select * from man_apo_mestre where empresa = '02' order by 2
select * from man_apo_detalhe where empresa = '02'
select * from man_tempo_producao where empresa = '02' order by 2
select * from man_item_produzido where empresa = '02' order by 2
select * from chf_componente where empresa = '02' order by 2
select * from man_comp_consumido where empresa = '02' order by 2
-- delete from apo_oper
select * from cfp_apms  where cod_empresa = '02'
select * from cfp_appr  where cod_empresa = '02'
select * from cfp_aptm  where cod_empresa = '02'
select * from man_relc_tabela  where empresa = '02'
select * from man_def_producao  where empresa = '02'
select * from apo_oper where cod_empresa = '02'