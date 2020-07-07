SET ISOLATION TO DIRTY READ
select * from item_alternat_1054
select * from audit_alternat_1054
select * from ord_cancel_1054

select * from estrutura where cod_empresa = '01' and cod_item_pai = '2311-002-2'
select * from estrutura where cod_empresa = '01' and cod_item_pai = '10000000010030'
select * from estrutura where cod_empresa = '01' and cod_item_pai = '10000000010020'
select * from estrutura where cod_empresa = '01' and cod_item_pai = '10000000010010'
select * from item where cod_empresa = '01' and cod_item = '002.030/11-IT1'
select * from item where cod_empresa = '01' and cod_item in (select cod_item_compon from estrutura where cod_empresa = '01' and cod_item_pai = '2311-002-2')

TROCAR 151860027 POR 151860171 ou 002.030/11-IT1  O ITEM ORIGENAL ESTÁ NAS OPS 2052 (NEC. 40) E 2115 (NEC. 20) O ALTRN. TEM QUE TER 60 EM ESTOQUE
select * from estoque_lote where cod_empresa = '01' and cod_item = '151860171'
select * from estoque_lote_ender where cod_empresa = '01' and cod_item = '151860171'
select * from estoque where cod_empresa = '01' and cod_item = '151860171'

select * from estoque_lote where cod_empresa = '01' and cod_item = '151860027'
select * from estoque_lote_ender where cod_empresa = '01' and cod_item = '151860027'
select * from estoque where cod_empresa = '01' and cod_item = '151860027'

select * from estoque_trans where cod_empresa = '01' and dat_movto = '19/02/2014'
select * from estoque_trans_end where cod_empresa = '01' and dat_movto = '19/02/2014'

select * from ordens where cod_empresa = '01' and ies_situa in ('3','4') and num_ordem in (2052, 2053, 2115)
select * from ordens where cod_empresa = '01' and ies_situa in ('3','4') and cod_item = 'TKB529473-05C'
select * from ordens where cod_empresa = '01' and ies_situa in ('3','4') and cod_item = '10000000010020'
select * from ordens where cod_empresa = '01' and ies_situa in ('3','4') and num_docum = '1111'

select * from necessidades where cod_empresa = '01' and num_ordem = 2052 --   pai 2311-002-2 filhos 010740006 (P) e 151860027 (C)
select * from ord_compon where cod_empresa = '01' and num_ordem = 2052
select * from necessidades where cod_empresa = '01' and num_ordem = 2053 --   pai 010740006 filho 151810044 (P)
select * from ord_compon where cod_empresa = '01' and num_ordem in (2052, 2053, 7735)
select * from necessidades where cod_empresa = '01' and num_ordem = 2115 --   pai 151810044 filho 151860027 (C)
select * from ord_compon where cod_empresa = '01' and num_ordem = 2115


select * from necessidades where cod_empresa = '01' and num_ordem = 1335875
select * from ord_compon where cod_empresa = '01' and num_ordem = 1335875
select * from ord_oper where cod_empresa = '01' and num_ordem = 1335875

select * from necessidades where cod_empresa = '01' and num_ordem = 1339964
select * from ord_compon where cod_empresa = '01' and num_ordem = 1339964
select * from ord_oper where cod_empresa = '01' and num_ordem = 1339964


   SELECT qtd_necessaria, cod_item_compon
      FROM ord_compon a, ordens b
      WHERE a.cod_empresa = '01'
        AND a.cod_item_compon = '151860027  '
        AND a.num_ordem = b.num_ordem
        AND b.num_docum = '1111'
        AND b.ies_situa IN ('3','4')
        AND b.cod_empresa = a.cod_empresa

        SELECT sum(b.qtd_necessaria - b.qtd_saida) as qtd_neces
          FROM ordens a, necessidades b
         WHERE a.cod_empresa = '01'
           AND a.ies_situa IN ('3','4')
           AND a.num_ordem = 2052
           AND b.cod_empresa = a.cod_empresa
           AND b.num_ordem = a.num_ordem
           AND b.cod_item = '151860027'

        SELECT sum(b.qtd_necessaria - b.qtd_saida) as qtd_neces
          FROM ordens a, necessidades b
         WHERE a.cod_empresa = '01'
           AND a.ies_situa IN ('3','4')
           AND a.num_docum = '1111'
           AND b.cod_empresa = a.cod_empresa
           AND b.num_ordem = a.num_ordem
           AND b.cod_item = '151860027'

      SELECT a.num_ordem, a.ies_situa, a.cod_item,
         (a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata),
          (b.qtd_necessaria - b.qtd_saida)
          FROM ordens a, necessidades b
         WHERE a.cod_empresa = '01'
           AND a.ies_situa IN ('3','4')
           AND b.cod_empresa = a.cod_empresa
           AND b.num_ordem = a.num_ordem
           AND b.cod_item = '151860027'
      order by a.num_ordem



    SELECT sum(qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
      FROM ordens
     WHERE cod_empresa  = '01'
       AND num_docum    = '1111'
       AND cod_item     = '002.030/11-IT1 '
       AND ies_situa    IN ('4')