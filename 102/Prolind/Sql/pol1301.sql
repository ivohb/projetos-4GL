delete from log_dados_sessao_logix

select dt_impor, week_of_year(dt_impor) from cfg_pedido_912
where week_of_year(dt_impor) = 2 and year(dt_impor) = 2015

select * from frm_zoom  where zoom_name like '%local%'
select * from familia
select * from item where cod_empresa = '01' and cod_item in ('010740006','151810044')
select * from cent_trabalho
select * from componente
select * from ordens where cod_empresa = '01' and ies_situa = '4'
  AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) order by DAT_LIBERAC DESC
select * from ord_oper where cod_empresa = '01'
 and num_ordem in (select num_ordem from ordens where cod_empresa = '01' and ies_situa = '4') --  2053 15/11/2015 / 2115 18/11/2015
select * from operacao

SELECT cod_item, cod_operac, num_seq_operac, cod_cent_trab,
qtd_boas, qtd_refugo, qtd_sucata FROM ord_oper
where  qtd_planejada > (qtd_boas + qtd_refugo + qtd_sucata)

select * from ordens where cod_empresa = '01' and cod_item in ('010740006','151810044')
select * from cfg_val_cotas912
select * from pol1301_1054 ORDER BY cod_item, num_ordem, num_seq_operac   -- 1 / 2313-039-6
--delete from pol1301_1054
SELECT * FROM tx_profissional

select * from pol1301_1054
select * from lote_pol1301 where cod_empresa = '01' and num_lote = 1
select * from lote_item_pol1301 where  cod_empresa = '01' and num_lote = 1
select * from processo_apont_pol1301 where cod_empresa = '01' and num_lote = 1 and num_processo = 11
select * from processo_item_pol1301 where cod_empresa = '01' and num_processo = 11
select * from man_apont_pol1301 where cod_empresa = '01' and num_processo = 11
select * from apont_erro_pol1301
select * from trans_apont_pol1301  where cod_empresa = '01' and num_processo = 11
select * from estorno_erro_pol1301
select * from sequencia_apo_pol1301 where cod_empresa = '01' and num_processo = 11
-- delete from man_apont_pol1301
                                                                                111/109      1111         1111
select * from ordens where cod_empresa = '01' and num_ordem in (2,2053,2115) -- 2313-039-6 / 010740006 / 151810044
select * from necessidades where cod_empresa = '01' and num_ordem in (2,2053,2115)
select * from ord_compon where cod_empresa = '01' and num_ordem in (2,2053,2115)
select * from ord_oper where cod_empresa = '01' and num_ordem in (2,2053,2115) ORDER BY 2,5
select * from consumo where cod_empresa = '01' and cod_item in ('2313-039-6','010740006','151810044') -- OND PAL
select * from consumo_compl where cod_empresa = '01' and cod_item in ('2313-039-6','010740006','151810044')
select * from cent_trabalho
select * from MAN_PROCESSO_ITEM
select * from local  -- zoom_local

select * from item where cod_empresa = '01' and cod_item in ('151810044','010490014','010200010')
select * from item_man where cod_empresa = '01' and cod_item in ('151810044','010490014','010200010')

select * from item where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')
select * from item_man where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')                                                                         0            8          4780        10,6
select * from estoque_lote where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')
select * from estoque_lote_ender where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')
select * from estoque where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')
select * from estoque_loc_reser where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')
select * from estoque_trans where cod_empresa = '01'
   and cod_item in ('2313-039-6','010740006','151810044','010490014','010760001','010200010','696910001')

select * from item where cod_empresa = '01' and den_item like '%SUCATA%'

--em qualquer operação
select max(seq_reg_mestre) from man_apo_mestre where empresa = '01'
select * from man_apo_mestre where seq_reg_mestre IN (112,113)
select * from man_tempo_producao where seq_reg_mestre IN (112,113)
select * from man_apo_detalhe  where seq_reg_mestre IN (112,113)
select * from man_item_produzido  where seq_reg_mestre IN (112,113)
select * from man_comp_consumido where seq_reg_mestre IN (112,113)

select * from ordens where cod_empresa = '01' and num_ordem = 2053 -- 6 5 5  item 010740006
select * from ordens where cod_empresa = '01' and num_ordem = 2115 -- 0 0 0  item 151810044
select * from ord_oper where cod_empresa = '01' and num_ordem = 2053 -- LIXA 6 0 0 SOLDA 90 5 5
select * from ord_oper where cod_empresa = '01' and num_ordem = 2115 -- LIXA 32 0 0 PINTA 0 0 0
select * from ord_compon where cod_empresa = '01' and num_ordem = 2053 -- 151810044 0,5
select * from ord_compon where cod_empresa = '01' and num_ordem = 2115 -- 010490014 0,3 / 010200010  0,2
select * from necessidades where cod_empresa = '01' and num_ordem = 2053 -- 2053 = 8
select * from necessidades where cod_empresa = '01' and num_ordem = 2115 -- 2115 = 0 / 2116 = 0

select * from estoque_lote where cod_empresa = '01'
   and cod_item in ('010200010','010490014','010740006','151810044') order by cod_item -- 8,6 / 4780 / 6L 5R
select * from estoque_lote_ender where cod_empresa = '01'
    and cod_item in ('010200010','010490014','010740006','151810044') order by cod_item
select * from estoque where cod_empresa = '01'
    and cod_item in ('010200010','010490014','010740006','151810044') order by cod_item -- 8,6 / 4780 / 6L 5R
select * from estoque_loc_reser where cod_empresa = '01'
    and cod_item in ('010200010','010490014','010740006','151810044') order by cod_item -- 8,6 / 4780 / 6L 5R
select * from estoque_trans where cod_empresa = '01'
   and num_docum in ('2053','2115')

select * from apo_oper  where cod_empresa = '01' and num_processo IN (99,100)
select max(num_processo) from apo_oper where cod_empresa = '01'
select * from cfp_apms where num_seq_registro  IN (99,100)
select * from cfp_appr
select * from cfp_aptm
--somente na operação final
select * from man_relc_tabela  where seq_reg_mestre  IN (99,100)
select * from chf_componente WHERE empresa = '01'  AND sequencia_registro  IN (99,100) --em abos os casos





