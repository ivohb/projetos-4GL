
SELECT DISTINCT nom_caminho FROM path_logix_v2 WHERE cod_sistema = 'JAR' AND cod_empresa  = '01'
SELECT * FROM apont_proces_405

select * from log_versao_prg where num_programa = 'SUP0710'
select * from emitente_405
select * from email_env_265
select * from man_erro_405
select * from min_par_modulo where empresa = '01'
select * from log_usu_dir_relat where usuario = 'ibarbosa'
select * from usuarios
select parametro_texto , observacao from min_par_modulo where empresa = '01' and parametro = 'EMIT_APONT_912'
select parametro_texto , observacao from min_par_modulo where empresa = '01' and parametro = 'EMAIL_APONT_912'

-- DELETE FROM man_apo_logix_405
select * from consumo_tmp_405
select * from sucata_tmp_405
SELECT * FROM man_apo_nest_405 WHERE num_programa = '0203GM'
SELECT * FROM erro_critico_405
SELECT * FROM man_erro_405

select * from man_apo_nest_405
--UPDATE man_apo_nest_405 SET qtd_boas = 0, qtd_refugo = 0, cod_item_compon = 'CH-3017' WHERE num_programa = 'PROGRAMA UM'
SELECT * FROM man_apo_logix_405 WHERE num_programa = '0203GM'

SELECT * FROM ordens WHERE ies_situa = '4' and cod_item = '100000019404' and (qtd_boas+qtd_refug+qtd_sucata) = 0
SELECT * FROM ordens WHERE num_ordem IN (1340523,1331673)
SELECT * FROM ordens WHERE num_ordem IN (1340523,1331673)
SELECT * FROM ord_compon WHERE num_ordem IN (1340523,1331673)
SELECT * FROM necessidades WHERE num_ordem

SELECT * FROM man_op_componente_operacao WHERE ordem_producao IN (1340523,1331673)

SELECT * FROM item WHERE  cod_empresa = '01' AND ies_tip_item = 'C' AND cod_item = 'SOL060'
SELECT * FROM estoque WHERE  cod_empresa = '01' AND cod_item = 'SOL060'
SELECT * FROM estoque_lote WHERE  cod_empresa = '01' AND cod_item = 'SOL060'   local 9217
SELECT * FROM estoque_lote_ender WHERE  cod_empresa = '01' AND cod_item = 'SOL060'    local 9514
SELECT * FROM estoque_trans WHERE  cod_empresa = '01' AND cod_item = 'SOL060' AND dat_movto >= '01/09/2012'
SELECT * FROM estoque_trans WHERE  cod_empresa = '01' AND cod_item = '100000019404' AND dat_movto >= '01/09/2012'

SELECT * FROM man_apo_mestre WHERE ordem_producao = 1331918
SELECT * FROM man_apo_mestre WHERE ordem_producao = 1342752
SELECT * FROM man_tempo_producao WHERE seq_reg_mestre = 1201299
SELECT * FROM man_tempo_producao WHERE seq_reg_mestre = 1201294
SELECT * FROM man_apo_detalhe WHERE seq_reg_mestre = 1201299
SELECT * FROM man_apo_detalhe WHERE seq_reg_mestre = 1201294
