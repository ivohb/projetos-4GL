
select * from log_val_parametro where empresa = '01' and parametro = 'gera_est_trans_relac'
select * from par_pcp
select *  from ordens_885
select * from item_altern
select * from log_val_parametro where parametro = 'gera_est_trans_relac'
select * from parametros_885 -- 002.030/11-IT1
select * from par_estoque
select * from par_pcp
select * from estoque_operac where cod_empresa = '01' BRPS
select * from estoque_operac_ct where cod_empresa = '01'

-- delete from apont_erro_885
select * from apont_msg_885 where cod_empresa = '01'
SELECT * FROM proces_apont_885
select * from apont_trim_885 ORDER BY 1
select * from consumo_trimbox_885 where numsequencia = 56336313
select * from apont_erro_885 where codempresa = '01'
select * from man_apont_885 order by seq_leitura
select * from man_apont_hist_912
select * from de_para_maq_885
select * from turno
select * from familia_insumo_885
select * from apont_trans_885 where  cod_empresa = '01' ORDER BY 2,3
select *  from apont_sequencia_885 where cod_empresa = '01' ORDER BY 2

select * from pedidos where cod_empresa = '01' and num_pedido = 73453
select * from ped_itens where cod_empresa = '01' and num_pedido = 73453
select * from desc_nat_oper_885 where cod_empresa = '01' and num_pedido = 73453

select * from ordens where  num_docum = '73454/1'
select * from ordens where num_ordem = 263351         --OF do acessório
select * from ord_compon where num_ordem = 263351
select * from necessidades where num_ordem = 263351
select * from ordens where num_ordem = 263352         --OF da chapa do acessório
select * from ord_compon where num_ordem = 263352
select * from necessidades where num_ordem = 263352

select * from item_vdp where cod_empresa = '01' and cod_item = '2313-039-6'
select * from grupo_produto_885 where cod_grupo = '02'
select * from man_apo_mestre where empresa = '01' and seq_reg_mestre >= 2056
select * from man_apo_detalhe where empresa = '01' and seq_reg_mestre >= 2056
select * from man_tempo_producao where empresa = '01' and seq_reg_mestre >= 2056
select * from man_item_produzido where empresa = '01' and seq_reg_mestre >= 2056
select * from man_comp_consumido where empresa = '01' and seq_reg_mestre >= 2056
select * from chf_componente where empresa = '01' and sequencia_registro >= 10863480
-- delete from apo_oper
select * from apo_oper where cod_empresa = '01' and num_processo >= 10863480
select * from cfp_apms  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from cfp_appr  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from cfp_aptm  where cod_empresa = '01' and num_seq_registro >= 10863480
select * from man_relc_tabela  where empresa = '01' and seq_reg_mestre >= 2055
select * from man_def_producao  where empresa = '01' and seq_reg_mestre >= 2055
select * from insumo_885 where cod_empresa = '02' and num_ar = 50691
 Refug 010060001 Retrab 010040005 Sucata 010040008 Sucata dq 010040009
                                                              chapa nova   chapa  amido       papel
select * from item where cod_empresa = '01' and cod_item in ('7857A','CCC','151530002','151550009')
select * from item_man where cod_empresa = '01' and cod_item in ('7857A','CCC','151530002','151550009')
select * from estoque where cod_empresa = '01' and cod_item in ('7857A','CCC','151530002','151550009')
select * from estoque_lote where cod_empresa = '01' and cod_item in ('7857A','CCC','13737','7857','KK1B','KK1B02000700')
                                                                      500    62352    2     1050   39749,013     0
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in ('7857A','CCC','151530002','151550009')
select * from estoque_loc_reser where cod_empresa = '01' and cod_item in ('7857A','CCC','151530002','151550009')
select * from estoque_trans where cod_empresa='01' and dat_movto>='28/01/2015' order by 2
select * from est_trans_relac where cod_empresa='01' and dat_movto>='20/01/2015'

select * from item where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from item_man where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from estoque where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from estoque_lote where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from estoque_loc_reser where cod_empresa = '01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
select * from estoque_trans where cod_empresa='01' and cod_item in ('CCC','050610001','050630001','CD100','MI100')
   and dat_movto>='28/01/2015' order by 2
select * from est_trans_relac where cod_empresa='01' and dat_movto>='20/01/2015'


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
select * from frete_solicit_885
select * from frete_compl_885
select * from romaneio_885
select * from roma_item_885
select * from roma_erro_885

select * from ordem_montag_lote
select * from estoque_loc_reser where num_reserva = 964
select * from est_loc_reser_end where num_reserva = 964
select * from ordem_montag_grade where cod_empresa = '01' and num_om >= 117818
select * from ordem_montag_item where cod_empresa = '01' and num_om >= 117818
select * from ordem_montag_mest where cod_empresa = '01' and num_om >= 117818
select * from ordem_montag_embal where cod_empresa = '01' and num_om >= 117818
select * from om_list  where cod_empresa = '01' and num_om >= 117818
select * from nf_solicit
select * from nf_solicit_885
select * from fat_solic_ser_comp
select * from fat_solic_mestre
select * from fat_solic_fatura
select * from fat_solic_embal

