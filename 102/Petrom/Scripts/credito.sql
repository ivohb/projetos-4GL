alter table perguntas_455 add condicao_debitar  Char(02) default ' ' not null
alter table analise_pergunta_455 add observacao Char(600)
alter table analise_455 add observacao Char(70)
select * from log_versao_prg where num_programa = 'VDP1090'
SET ISOLATION TO DIRTY READ
select * from envia_email_912
select * from usuarios  where cod_usuario in ('admlog','ivo', 'igesca')
select * from  usuario_funcao_455
select * from indicadores_455
select * from validade_indicador_455 where cod_cliente = '1000'
select * from perguntas_455
select * from formulas_455
--  delete from analise_usuario_455
select * from analise_455  order by cod_cliente
select * from analise_pergunta_455 order by cod_cliente, cod_pergunta, num_versao
select * from analise_indicador_455
select * from analise_usuario_455 order by cod_cliente, num_versao
select * from pct_faturamento_455
select * from pct_lucro_455

select * from clientes where cod_cliente = '4000'
select * from cli_credito where cod_cliente = '4000'
SELECT * FROM cre_cli_cca_compl
select * from cre_audit_cli_cca
select * from credcad_cod_cli
SELECT * FROM credcad_cli where  cod_cliente = '4000'

select * from CREDCAD_RATEIO where  cod_cliente = '4000'

