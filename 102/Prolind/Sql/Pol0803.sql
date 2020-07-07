select tabname from systables
where tabname like '%comple%' order by 1
SELECT * FROM tx_profissional

base IURD    CAMINHO PARA INSTALAÇÃO DE PROGRAMAS: \\vsfs01\install$
SET ISOLATION TO DIRTY READ
select * from de_para_item_1054
select * from man_apont_1054 WHERE NUM_PROCESSO = 7
select * from processo_apont_1054
select * from sequencia_apo_1054
select * from ord_apont_1054
select * from man_apont_1054 where num_processo = 6 and cod_status = 'A' ORDER BY num_seq_apont DESC
select * from apont_erro_1054
select * from estorno_erro_1054
select * from item where cod_empresa = '21' and den_item like '%SUCA%'
select * from estrut_grade where cod_empresa = '21' and cod_item_pai = 'LP0001'
select * from ordens_complement
select * from trans_apont_1054 where num_processo = 7  and num_seq_apont = 5 and cod_operacao = 'E'
select * from ordens where cod_empresa = '21' and num_ordem = 124 --pai/filho
select * from ord_oper where cod_empresa = '21' and num_ordem = 124
select * from necessidades where cod_empresa = '21' and num_ordem = 124
select * from ord_compon where cod_empresa = '21' and num_ordem = 124
SELECT * FROM REC_ARRANJO WHERE cod_empresa = '21' AND cod_arranjo IN ('IN450', 'MONTG')
SELECT * FROM recurso WHERE cod_empresa = '21' AND cod_recur IN ('OPER', 'MONT')

         SELECT *
           FROM estoque_operac_ct
          WHERE cod_empresa  = '21'
            AND cod_operacao = p_cod_operacao

select * from ordens where cod_empresa = '21' and num_ordem = 123
select * from necessidades where cod_empresa = '21' and num_ordem = 123 -- trocar esse 5720001004A-00 por 4493168DE1V-01
select * from ord_compon where cod_empresa = '21' and num_ordem = 123
select * from ord_oper where cod_empresa = '21' and num_ordem = 123
select * from consumo where cod_item = 'LP0001'
select * from item_man where cod_item = 'LP0001'

select * from item where cod_empresa = '21' and cod_item = 'LP0001'
select * from estoque_lote where cod_empresa = '21' and cod_item = 'LP0001'                  -- 2510
select * from estoque_lote_ender where cod_empresa = '21' and cod_item = 'LP0001'
select * from estoque where cod_empresa = '21' and cod_item = 'LP0001'
select * from item where cod_empresa = '21' and cod_item = 'LP0001'

select * from item where cod_empresa = '21' and cod_item = 'LPC001'
select * from estoque_lote where cod_empresa = '21' and cod_item = 'LPC001'
select * from estoque_lote_ender where cod_empresa = '21' and cod_item = 'LPC001'
select * from estoque where cod_empresa = '21' and cod_item = 'LPC001'                        -- 65489,368
select * from item where cod_empresa = '21' and cod_item = 'LPC001'

select * from item where cod_empresa = '21' and cod_item = 'LP3003'
select * from estoque_lote where cod_empresa = '21' and cod_item = 'LP3003'                   -- 1
select * from estoque_lote_ender where cod_empresa = '21' and cod_item = 'LP3003'
select * from estoque where cod_empresa = '21' and cod_item = 'LP3003'
select * from item where cod_empresa = '21' and cod_item = 'LP3003'
select * from estoque_trans where cod_empresa = '21' and dat_proces = '31/07/2014'

select * from man_item_produzido where moviment_estoque >= 408
select * from man_comp_consumido where mov_estoque_pai >= 408

    SELECT a.num_ordem,
           a.cod_item,
           (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata),
           b.cod_item,
           (b.qtd_necessaria - b.qtd_saida)
      FROM ordens a, necessidades b
     WHERE a.cod_empresa = '01'
       AND a.num_docum = '11'
       AND b.cod_empresa = a.cod_empresa
       AND b.num_ordem = a.num_ordem
       AND b.cod_item = '41272XB3L7'


select * from item where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001') -- F/P/C
select * from item_man where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001')
select * from estrutura where cod_empresa = '01' and cod_item_pai = '5720001901P-00'
select * from estrutura where cod_empresa = '01' and cod_item_pai = '5720001004A-00'
select * from estoque where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001')
select * from estoque_lote where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001')
select * from estoque_lote_ender where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001')
select * from estoque_loc_reser where cod_empresa = '01' and cod_item in ('5720001901P-00', '5720001004A-00', 'PIN001')

select * from estoque_trans where cod_empresa = '01'  and dat_proces = '15/01/2014' and num_docum = '250'
select * from estoque_trans_end where cod_empresa = '01'  and num_transac >= 398

--em qualquer operação
select * from man_apo_mestre where seq_reg_mestre >= 80
select * from man_tempo_producao where seq_reg_mestre >= 80
select * from man_apo_detalhe
select * from ord_oper where num_ordem = 250
select * from apo_oper  where cod_empresa = '01' and num_processo >= 76
select max(num_processo) from apo_oper where cod_empresa = '01'
select * from cfp_apms where num_seq_registro >= 76
select * from cfp_appr
select * from cfp_aptm
--somente na operação final
select * from ordens
select * from necessidades where cod_empresa = '01' and num_ordem in (250, 309)
select * from man_relc_tabela
select * from man_item_produzido  where seq_reg_mestre >= 80
select * from man_comp_consumido where seq_reg_mestre >= 80 --na saida do componente
select * from chf_componente WHERE empresa = '01'  AND sequencia_registro >= 76 --em abos os casos

alter table man_apo_detalhe add nome_programa char(10)