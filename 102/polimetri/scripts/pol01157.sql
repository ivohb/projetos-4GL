SET ISOLATION TO DIRTY READ
select * from log_versao_prg where num_programa = 'SUP6440'
select * from mapa_compras_454
select a.* from mapa_compras_data_454 a, item b, man_par_prog_454 c
 where a.cod_empresa = '01' and a.seq_campo in (9,11) and a.qtd_dia > 0 and c.empresa = a.cod_empresa and c.item = a.cod_item
  and b.cod_empresa = a.cod_empresa and b.cod_item = a.cod_item order by a.cod_item, a.seq_periodo

select * from mapa_periodos_454 where cod_empresa = '01' and cod_frequencia = '1' and seq_periodo = 7
select * from man_par_prog_454 where item in ('BF.005', 'BF.006', 'BF.020', 'BZ.035', 'BZ.092')
select * from mapa_atualiz_454

select * from item where cod_empresa = '01' and ies_tip_item = 'C'
select * from item where cod_empresa = '01' and cod_item = 'BF.020'
select * from item_sup where cod_empresa = '01' and cod_item = 'BF.005'
select * from item_man where cod_empresa = '01' and cod_item = 'BZ.092'

select * from mapa_compras_data_454 where seq_campo in (8,11) AND QTD_DIA > 0
select * from periodo_tmp_454
select * from  mapa_compras_hist_454

select * FROM ordem_sup WHERE cod_empresa = '01' AND ies_versao_atual = 'S' AND ies_situa_oc IN ('A')
 and cod_item in ('BF.005', 'BF.020',  'BZ.092')

select * FROM ordem_sup WHERE cod_empresa = '01' and cod_item = 'BF.005' ORDER BY 2
select * FROM ordem_sup WHERE cod_empresa = '01' and cod_item = 'BF.020'
select * FROM ordem_sup WHERE cod_empresa = '01' and cod_item = 'BZ.092'
select * from prog_ordem_sup where cod_empresa = '01' and num_oc = 421975
select * from prog_ordem_sup where cod_empresa = '01' and num_oc IN (421845,421846) ORDER BY 2,3,4
select * from dest_ordem_sup where cod_empresa = '01' and num_oc = 421962
select * from estrut_ordem_sup where cod_empresa = '01' and num_oc = 421964
select * from estrutura where cod_item_pai = 'BF.020'

 SELECT num_oc, num_versao, ies_situa_oc, (qtd_solic - qtd_recebida), * FROM ordem_sup
     WHERE cod_empresa = '01' AND cod_item    = 'BF.005' AND ies_versao_atual = 'S'   AND ies_situa_oc IN ('A')
       AND dat_entrega_prev >= '21/07/2012' AND dat_entrega_prev <= '31/07/2012'


select tabname  from systables
where tabname like '%feria%'
select * from feriado where cod_empresa = '01' order by dat_ref
select * from feriado_sup
select * from feriado_rhu
select * from log_feriado_estado
select * from log_feriado_pais
