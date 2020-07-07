select * from log_versao_prg where num_programa = 'POL1283'
  SELECT dat_fecha_ult_man,  dat_fecha_ult_sup  FROM par_estoque   WHERE cod_empresa = '01'

select * from apont_trim_885 order by inicio
select * from baixas_pendentes_885 where cod_empresa = '01' order by dat_producao

select baixas_pendentes_885.* from baixas_pendentes_885 where baixas_pendentes_885.cod_empresa = '01'
   and cod_compon in
   (select ordens.cod_item from ordens
     where ordens.cod_empresa = '01'
       and num_ordem = baixas_pendentes_885.num_ordem)
order by baixas_pendentes_885.cod_compon


select baixas_pendentes_885.* from baixas_pendentes_885 where baixas_pendentes_885.cod_empresa = '01'
   and baixas_pendentes_885.cod_compon in
   (select item.cod_item from item where cod_empresa = '01' and item.ies_tip_item <> 'C')
order by baixas_pendentes_885.cod_compon



delete  from baixas_pendentes_885 where baixas_pendentes_885.cod_empresa = '01'
   and baixas_pendentes_885.cod_compon in
   (select item.cod_item from item where cod_empresa = '01' and item.ies_tip_item <> 'C')


select estoque_trans.* from estoque_trans where estoque_trans.cod_empresa = '01'
   and estoque_trans.num_prog = 'POL1275' and estoque_trans.cod_operacao = 'BPRD' and estoque_trans.cod_item = '11738'
   and estoque_trans.cod_item in
   (select item.cod_item from item where cod_empresa = '01' and item.ies_tip_item <> 'C')
   and estoque_trans.num_transac not in
   (select estoque_trans_rev.num_transac_normal from estoque_trans_rev
     where estoque_trans_rev.cod_empresa = '01')


   select * from estoque_trans_rev where cod_empresa = '01' and num_transac_normal in (25235773,25235775)
   select  * from estoque_trans where cod_empresa = '01' and num_transac in (25235773,25235775)

      select * from apont_trans_885 where num_transac in  ( 25235773,  25235775)

      select * from estoque where cod_empresa = '01' and cod_item = '11738'   -- 5494,5
      select * from estoque_lote where cod_empresa = '01' and cod_item = '11738'
      select * from estoque_lote_ender where cod_empresa = '01' and cod_item = '11738'
