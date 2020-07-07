SET ISOLATION TO DIRTY READ
alter table item_criticado_bi_454 add dat_programacao date
-- delete from mapa_compras_hist_454 where cod_item = '10000000020020 '
select * from mapa_compras_hist_454 where cod_item = '10000000020020 ' and chave_processo = '20131227' order by 1
select * from mapa_compras_454           PRIMARY KEY(cod_empresa,cod_item)
select * from mapa_compras_data_454 where chave_processo = '20131227'     27/11/2013 09/12/2013 03/01/2014
select * from mapa_periodos_454 where cod_frequencia = 1
select * from man_par_prog_454 where item IN ('SOL060', '10000000020020')
select * from mapa_controle_prod_454 where cod_item IN ('SOL060', '10000000020020')
SELECT * FROM MAPA_DIAS_MES_454
-- delete from conta_contabil_454
select * from usuario_oc_bloq_454
SELECT * FROM audit_oc_bloq_454
SELECT * FROM oc_bloqueada_454
select * from item_criticado_bi_454
select * from tabela_trava90_454
select * from conta_contabil_454
select * from corte_tmp_454
select * from prog_ord_sup_454 where dat_origem = '27/12/2013'
03/01/2014 30/12/2013 03/01/2014 30/12/2013
-- delete from ordem_sup where cod_empresa = '01'  and cod_item = '10000000020020'
select * from ordem_sup where cod_empresa = '01'  and cod_item in ('10000000020020','SOL060','SOL013') and ies_situa_oc = 'A'
SELECT * FROM item where cod_empresa = '01' and ies_tip_item = 'B'
SELECT * FROM item where cod_empresa = '01' and cod_item IN ('SOL060', '10000000020020')
select * from ordem_sup where cod_empresa = '01' and cod_item = '10000000020020'
select * from ordem_sup where cod_empresa = '01' and cod_item = '110011'
select * from prog_ordem_sup where cod_empresa = '01' and NUM_OC = 422012
select * from prog_ordem_sup where cod_empresa = '01' and NUM_OC = 422013

select * from ordem_sup_compl where cod_empresa = '01' and NUM_OC >= 421994
SELECT * FROM dest_ordem_sup WHERE NUM_OC = 421994
select * from ordem_sup_txt WHERE NUM_OC = 421994
select * from estrut_ordem_sup where num_oc = 421994
select * from PROG_ordem_sup where cod_empresa = '01' and  num_oc = 313




select * from plano_contas
select tabname from systables where tabname like '%plano_cont%'
select * from linha_prod
select * from log_versao_prg where num_programa = 'SUP0360'

