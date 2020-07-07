SET ISOLATION TO DIRTY READ
ALTER TABLE man_apo_logix_405 modify qtd_baixar DECIMAL(14,7)
ALTER TABLE man_apo_nest_405 add operador char(15)  default '522'
select * from apo_impres_ar_405

select * from emitente_405
select * from email_env_265
select * from man_erro_405
select * from min_par_modulo
select parametro_texto , observacao from min_par_modulo where empresa = '01' and parametro = 'EMIT_APONT_912'
select parametro_texto , observacao from min_par_modulo where empresa = '01' and parametro = 'EMAIL_APONT_912'

-- DELETE FROM man_apo_logix_405
select * from consumo_tmp_405
select * from sucata_tmp_405
select * from min_par_modulo
select * from uni_funcional   uf 117020500 cc 40 op s400
select * from funcionario where cod_empresa = '01' and num_matricula = '6098'
select cod_tip_despesa from item_sup where cod_empresa = '01' and cod_item = 'MO-2004'  tp 115
SELECT * FROM man_apo_nest_405 WHERE num_programa = '0203GM1'
SELECT * FROM erro_critico_405
SELECT * FROM man_erro_405

SELECT * FROM NF_SUP ORDER BY NUM_AVISO_REC

--UPDATE man_apo_nest_405 SET qtd_boas = 0, qtd_refugo = 0, cod_item_compon = 'CH-3017' WHERE num_programa = 'PROGRAMA UM'
SELECT * FROM man_apo_logix_405 WHERE num_programa = '0203GM1'

SELECT * FROM ordens WHERE ies_situa = '4' and cod_item = '100000019404' and (qtd_boas+qtd_refug+qtd_sucata) = 0
SELECT * FROM ordens WHERE num_ordem = 1331673
SELECT * FROM ordens WHERE num_ordem = 1340523
SELECT * FROM ord_oper WHERE num_ordem = 1331673
SELECT * FROM ord_oper WHERE num_ordem = 1340523
SELECT * FROM ord_compon WHERE num_ordem = 1331673
SELECT * FROM ord_compon WHERE num_ordem = 1340523
SELECT * FROM necessidades WHERE num_ordem = 1331673
SELECT * FROM necessidades WHERE num_ordem = 1340523

SELECT * FROM man_op_componente_operacao WHERE ordem_producao = 1331673
SELECT * FROM man_op_componente_operacao WHERE ordem_producao = 1340523

SELECT * FROM item WHERE  cod_empresa = '01' AND ies_tip_item = 'C' AND cod_item = 'SOL060'
SELECT * FROM estoque WHERE  cod_empresa = '01' AND cod_item = 'SOL060'
SELECT * FROM estoque_lote WHERE  cod_empresa = '01' AND cod_item = 'SOL060'   local 9217
SELECT * FROM estoque_lote_ender WHERE  cod_empresa = '01' AND cod_item = 'SOL060'    local 9517
SELECT * FROM estoque_trans WHERE  cod_empresa = '01' AND cod_item = 'SOL060' AND dat_movto >= '01/09/2012'
SELECT * FROM estoque_trans WHERE  cod_empresa = '01' AND cod_item = '100000019404' AND dat_movto >= '01/09/2012'


SELECT * FROM item WHERE cod_item = 'MO-2004' AND cod_empresa = '01'
SELECT * FROM estoque WHERE cod_item = 'MO-2004' AND cod_empresa = '01'
SELECT * FROM estoque_lote WHERE cod_item = 'MO-2004' AND cod_empresa = '01' 3000 local 9216
SELECT * FROM estoque_lote_ender WHERE cod_empresa = '01' AND cod_item = 'MO-2004'
SELECT * FROM estoque_trans WHERE cod_item = 'MO-2004' AND cod_empresa='01' AND dat_proces >= '01/06/2012'

select * from consumo_tmp_405
select * from sucata_tmp_405

SELECT * FROM item WHERE  cod_empresa = '01' AND cod_item = 'CH-3017'
SELECT * FROM estoque WHERE  cod_empresa = '01' AND cod_item = 'CH-3017'
SELECT * FROM estoque_lote WHERE  cod_empresa = '01' AND cod_item = 'CH-3017'
SELECT * FROM estoque_lote_ender WHERE  cod_empresa = '01' AND cod_item = 'CH-3017'
SELECT * FROM estoque_trans WHERE cod_item='10000000930010' AND cod_empresa='01' AND dat_proces >= '01/06/2012'

SELECT * FROM estoque_trans WHERE cod_item='10000000750020' AND cod_empresa='01' AND dat_proces='28/02/2012'
SELECT * FROM estoque_trans WHERE cod_item='10000000750030' AND cod_empresa='01' AND dat_proces='28/02/2012'

SELECT * FROM man_apo_mestre WHERE ordem_producao = 1331918
SELECT * FROM man_apo_mestre WHERE ordem_producao = 1342752
SELECT * FROM man_tempo_producao WHERE seq_reg_mestre = 1201299
SELECT * FROM man_tempo_producao WHERE seq_reg_mestre = 1201294
SELECT * FROM man_apo_detalhe WHERE seq_reg_mestre = 1201299
SELECT * FROM man_apo_detalhe WHERE seq_reg_mestre = 1201294

SELECT * FROM apo_oper WHERE num_ordem = 1331918
SELECT * FROM apo_oper WHERE num_ordem = 1342752
SELECT * FROM cfp_apms WHERE num_seq_registro IN (4082943,4082944)
SELECT * FROM cfp_apms WHERE num_seq_registro in (4082936,4082937)
SELECT * FROM cfp_appr WHERE num_seq_registro IN (4082943,4082944)
SELECT * FROM cfp_appr WHERE num_seq_registro in (4082936,4082937)
SELECT * FROM cfp_aptm WHERE num_seq_registro IN (4082943,4082944)
SELECT * FROM cfp_aptm WHERE num_seq_registro in (4082936,4082937)
SELECT * FROM man_relc_tabela WHERE seq_reg_mestre = 1201299
SELECT * FROM man_relc_tabela WHERE seq_reg_mestre = 1201294
SELECT * FROM apont_proces_405
SELECT * FROM man_item_produzido  WHERE seq_reg_mestre = 1201299
SELECT * FROM man_item_produzido  WHERE seq_reg_mestre = 1201294
SELECT * FROM man_def_producao  WHERE seq_reg_mestre = 1201299
SELECT * FROM man_def_producao  WHERE seq_reg_mestre = 1201294
SELECT * FROM man_comp_consumido  WHERE seq_reg_mestre = 1201299
SELECT * FROM man_comp_consumido  WHERE seq_reg_mestre = 1201294
SELECT * FROM chf_componente WHERE sequencia_registro IN (4082943,4082944)
SELECT * FROM chf_componente WHERE sequencia_registro in (4082936,4082937)
SELECT * FROM apont_proces_405

SELECT * FROM item WHERE  cod_empresa = '01' AND cod_item = '10000000750030'
update item SET ies_ctr_estoque = 'S' WHERE  cod_empresa = '01' AND cod_item = '10000000750030'

select * from log_versao_prg where num_programa = 'SUP0710'

SELECT * FROM man_formulario_pdm_caracterist
select * from MAN_FORMULARIO_PDM