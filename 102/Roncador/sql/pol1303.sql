select * from log_versao_prg where num_programa = 'CON10001'
select * from log_acs_usu_prog where num_programa = 'CON10001'
select * from log_acs_usu_prog where num_programa = ''
delete from log_versao_prg

delete from log_dados_sessao_logix
select * from frm_zoom where zoom_name like '%patrimo%'
select * from min_par_modulo
select * from GRUPO_PATRIM
select * from plano_contas
select * from conta_contabil_ronc -- 1.01.01.01.01   1.01.01.02.01
select * from parcela_ronc
select * from patrimonio   -- zoom_patrimonio

select * from sup_resv_est_trans

select a.num_reserva, a.cod_item, b.den_item_reduz, a.qtd_reservada,
       b.cod_unid_med, c.dat_movto
  from estoque_loc_reser a, item b, estoque_trans c where cod_empresa = '01'
   and num_transac in

select * from estoque_loc_reser where cod_empresa = '01' and ies_situacao = 'L'
 and dat_solicitacao >= '2011-01-19'
 and cod_item in (select cod_item from item where cod_empresa = '01')
 and num_conta_deb in (select num_conta from conta_contabil_ronc where cod_empresa = '01')
 order by dat_solicitacao desc


select * from patrimonio WHERE COD_EMPRESA = '01' order by 3
select * from PATRPARC where cod_empresa = '01' and num_invent = '001'
select * from PAR_PAT
SELECT * FROM MOEDA
SELECT * FROM COTACAO where cod_moeda = 1 and dat_ref = '2011/01/21'
select * from AGRUPAM
select * from GRP_PATR_ITEM
select * from MOEDA_PAT
select * from pat_dad_compl_ent where inventario = '001'
select *  from estoque_hist where cod_empresa = '01'
select ano_mes_ref, cus_unit_medio  from estoque_hist where cod_empresa = '01'
  and cod_item = '727210001' and ano_mes_ref <= 201101 order by ano_mes_ref desc