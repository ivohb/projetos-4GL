select * from item where cod_empresa = '21' and cod_item in
('LP0002','LP0003','LP3001','LP0005','LPC001','LPC002','LPC003','LPC003')
select * from item_man where cod_empresa = '21' and cod_item in
('LP0002','LP0003','LP3001','LP0005','LPC001','LPC002','LPC003','LPC003')
select * from estoque where cod_empresa = '21' and cod_item in
('LP0002','LP0003','LP3001','LP0005','LPC001','LPC002','LPC003','LPC003')
select * from estoque_lote where cod_empresa = '21' and cod_item in
('LP0002','LP0003','LP3001','LP0005','LPC001','LPC002','LPC003','LPC003')
select * from estoque_lote_ender where cod_empresa = '21' and cod_item in
('LP0002','LP0003','LP3001','LP0005','LPC001','LPC002','LPC003','LPC003')
select * from ordens where cod_empresa = '21' and num_ordem BETWEEN 106 AND 109

select * from ordens where cod_empresa = '21' and num_ordem = 106  -- LP0002 NIVEL 1 item_man.ies_apontamento = 1
select * from ord_compon where cod_empresa = '21' and num_ordem = 106
select * from necessidades where cod_empresa = '21' and num_ordem = 106
select * from ord_oper where cod_empresa = '21' and num_ordem = 106

select * from ordens where cod_empresa = '21' and num_ordem = 107  -- LP0003  NIVEL 2 item_man.ies_apontamento = 1
select * from ord_compon where cod_empresa = '21' and num_ordem = 107
select * from necessidades where cod_empresa = '21' and num_ordem = 107
select * from ord_oper where cod_empresa = '21' and num_ordem = 107

select * from ordens where cod_empresa = '21' and num_ordem = 108    -- LP3001  NIVEL 3 item_man.ies_apontamento = 1
select * from ord_compon where cod_empresa = '21' and num_ordem = 108
select * from necessidades where cod_empresa = '21' and num_ordem = 108
select * from ord_oper where cod_empresa = '21' and num_ordem = 108

select * from ordens where cod_empresa = '21' and num_ordem = 109    -- LP0005 NIVEL 4 item_man.ies_apontamento = 2
select * from ord_compon where cod_empresa = '21' and num_ordem = 109
select * from necessidades where cod_empresa = '21' and num_ordem = 109
select * from ord_oper where cod_empresa = '21' and num_ordem = 109

select * from processo_apont_1054
select * from man_apont_1054
select * from sequencia_apo_1054
select * from apont_erro_1054
select * from estorno_erro_1054
select * from trans_apont_1054

--delete from processo_apont_1054

alter table man_apont_1054 modify cod_operac char(5)
alter table man_apont_1054 modify cod_cent_trab char(5)
alter table man_apont_1054 modify cod_arranjo char(5)
alter table man_apont_1054 modify num_seq_operac decimal(3,0)

select * from man_apo_mestre where data_producao = '12/11/2015'
select * from man_apo_detalhe where seq_reg_mestre >= 51
select * from man_tempo_producao where seq_reg_mestre >= 51
select * from man_item_produzido
select * from man_comp_consumido
select * from man_relc_tabela
select * from apo_oper
select * from cfp_apms
select * from cfp_appr
select * from cfp_aptm
select * from chf_componente

select * from estoque_trans where cod_empresa = '21' and num_transac >= 471
select * from