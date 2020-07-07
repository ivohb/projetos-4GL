drop view vi_cta_dupl_inv
create view vi_cta_dupl_inv(
       cod_empresa,
       dat_selecao,
       hor_selecao,
       contagem,
       item,
       descricao,
       tipo,
       unidade,
       cod_local,
       num_lote,
       qtde_contada)
as
select a.cod_empresa,
       a.dat_selecao,
       a.hor_selecao,
       a.contagem,
       a.cod_item,
       b.den_item,
       b.ies_tip_item,
       b.cod_unid_med,
       a.cod_local,
       a.num_lote,
       count(*) qtde_contada
  from ethos_carcol a
  left join item    b
         on (a.cod_empresa = b.cod_empresa)
        and (a.cod_item    = b.cod_item)
 where a.cod_empresa = '06'
   and a.aceito      = 'S'
 group by 1,2,3,4,5,6,7,8,9,10



drop view saldo_em_terc_nf
create view saldo_em_terc_nf(
       cod_empresa,
       item,
       descricao,
       unidade,
       lote,
       saldo_nf_em_terceiro)
as
select a.cod_empresa,
       a.cod_item,
       c.den_item,
       c.cod_unid_med,
       case
       when b.lote is null or b.lote = '               '
       then "0"
       else b.lote
       end lote,
       cast(sum(b.qtd_tot_remessa - b.qtd_tot_receb) as decimal(17,3)) saldo_nf_em_terceiro
  from      item_em_terc     a
  left join sup_itterc_grade b
         on (b.empresa     = a.cod_empresa)
        and (b.nota_fiscal = a.num_nf)
        and (b.seq_item_nf = a.num_sequencia)
        and (b.fornecedor  = a.cod_fornecedor)
  left join item c
         on (a.cod_empresa = c.cod_empresa)
        and (a.cod_item    = c.cod_item)
 where a.cod_empresa = '06'
   and c.ies_ctr_estoque = 'S'
   and(a.qtd_tot_remessa - a.qtd_tot_recebida) > 0
 group by 1,2,3,4,5




drop view saldo_em_terc_est
create view saldo_em_terc_est(
       cod_empresa,
       item,
       lote,
       saldo_est_em_terceiro)
as
select cod_empresa,
       cod_item,
       case
       when num_lote is null or num_lote = '               '
       then "0"
       else num_lote
       end num_lote,
       cast(sum(qtd_saldo) as decimal(17,3)) saldo_est_em_terceiro
  from estoque_lote
 where cod_empresa = '06'
   and cod_local = 'TERCEIROS'
group by 1,2,3


create view vi_ult_preco(
       cod_empresa,
       cod_item,
       ult_custo_unit)
as
select c.cod_empresa,
       c.cod_item,
       cast(c.cus_unit_medio as decimal(17,6))
  from estoque_hist c
 where c.ano_mes_ref = (select max(e.ano_mes_ref)
                          from estoque_hist e
                         where e.cod_empresa    = c.cod_empresa
                           and e.cod_item       = c.cod_item
                           and e.cus_unit_medio > 0)


drop view vi_em_terc_prov1
create view vi_em_terc_prov1(
       cod_empresa,
       item,
       descricao,
       unidade,
       lote,
       saldo_nf_em_terceiro,
       saldo_est_em_terceiro,
       custo_medio)
as
select a.cod_empresa,
       a.item,
       a.descricao,
       a.unidade,
       a.lote,
       cast(a.saldo_nf_em_terceiro as decimal(17,3)) saldo_nf_em_terceiro,
       cast(b.saldo_est_em_terceiro as decimal(17,3)) saldo_est_em_terceiro,
       cast(c.ult_custo_unit as decimal(17,6)) custo_medio
 from     saldo_em_terc_nf  a
left join saldo_em_terc_est b
       on (a.cod_empresa = b.cod_empresa)
      and (a.item        = b.item)
      and (a.lote        = b.lote)
left join vi_ult_preco c
       on (a.cod_empresa = c.cod_empresa)
      and (a.item        = c.cod_item)
where a.cod_empresa = '06'
union
select a.cod_empresa,
       a.item,
       d.den_item descricao,
       d.cod_unid_med unidade,
       a.lote,
       cast(b.saldo_nf_em_terceiro as decimal(17,3)) saldo_nf_em_terceiro,
       cast(a.saldo_est_em_terceiro as decimal(17,3)) saldo_est_em_terceiro,
       cast(c.ult_custo_unit as decimal(17,6)) custo_medio
 from      saldo_em_terc_est a
left join  saldo_em_terc_nf  b
       on (a.cod_empresa = b.cod_empresa)
      and (a.item        = b.item)
      and (a.lote        = b.lote)
left join vi_ult_preco c
       on (a.cod_empresa = c.cod_empresa)
      and (a.item        = c.cod_item)
left join item d
       on (a.cod_empresa = d.cod_empresa)
      and (a.item        = d.cod_item)
where a.cod_empresa = '06'
 group by 1,2,3,4,5,6,7,8


drop view vi_em_terc_prov2
create view vi_em_terc_prov2(
       cod_empresa,
       item,
       descricao,
       unidade,
       lote,
       saldo_nf_em_terceiro,
       saldo_est_em_terceiro,
       custo_medio)
as
select cod_empresa,
       item,
       descricao,
       unidade,
       lote,
       case
       when saldo_nf_em_terceiro is null
       then cast("0" as decimal(17,3))
       else saldo_nf_em_terceiro
       end saldo_nf_em_terceiro,
       case
       when saldo_est_em_terceiro is null
       then cast("0" as decimal(17,3))
       else saldo_est_em_terceiro
       end saldo_est_em_terceiro,
       case
       when custo_medio is null
       then cast("0" as decimal(17,6))
       else custo_medio
       end custo_medio
  from vi_em_terc_prov1

drop view vi_terc_nf_est
create view vi_terc_nf_est(
       cod_empresa,
       item,
       descricao,
       unidade,
       lote,
       saldo_nf_em_terceiro,
       saldo_est_em_terceiro,
       diferenca_qtde,
       custo_medio,
       diferenca_valor)
as
select cod_empresa,
       item,
       descricao,
       unidade,
       case
       when lote = '0'
       then null
       else lote
       end lote,
       saldo_nf_em_terceiro,
       saldo_est_em_terceiro,
       cast((saldo_nf_em_terceiro - saldo_est_em_terceiro) as decimal(17,3)) difrenca_qtde,
       custo_medio,
       cast((custo_medio * (saldo_nf_em_terceiro - saldo_est_em_terceiro)) as decimal(17,2)) diferenca_valor
  from vi_em_terc_prov2
 where saldo_nf_em_terceiro <> saldo_est_em_terceiro
