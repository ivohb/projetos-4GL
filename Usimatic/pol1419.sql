select * from frm_zoom where zoom_name like '%funciona%'  -- zoom_desc_preco_mest
SELECT *  FROM frm_toolbar where resource_name like '%expo%'
SELECT *  FROM frm_toolbar where resource_name like '%grupo%' -- VISUALIZAR_GRUPOS GRUPO_FISCAL_ITEM item_x_grupo
SELECT *  FROM frm_toolbar where resource_name like '%ERRO%' ZOOM_ERROS ERRO_INC

select * from path_logix_v2 where cod_empresa = '01' and cod_sistema = 'EDI' -- c:\ivo\edi\
select top 10 * from ped_itens where cod_empresa = '01' and num_sequencia > 5 order by num_pedido desc
select * from empresa
select * from item where cod_empresa = '01' and cod_item in ( 'KK0B' , 'KK1B' , 'KK2B')
select * from item where cod_empresa = '01' and cod_familia = '201'
select * from clientes where cod_cliente = '011636645000131'
select * from cliente_item where  cod_empresa = '01' and cod_item = '10113' and cod_cliente_matriz = '011636645000131'
select * from cliente_item where  cod_empresa = '01' and cod_cliente_matriz = '011636645000131' and cod_item_cliente = 'KK2B'
select * from cliente_item where  cod_empresa = '01' and cod_cliente_matriz = '000005063000130'
   and cod_item_cliente like 'MIT00%'

select * from qfptran_komatsu
select * from cliente_komatsu
select * from periodo_firme_komatsu
select * from forecast_komatsu;
select * from plano_komatsu;
select * from prog_komatsu where item_logix = 'KK2B' ORDER BY DAT_PROG
select * from w_data_komatsu;
SELECT * FROM NUM_PLANO_VENDAS where cod_empresa = '01'
 and ano_ini_plano <= 2020  and ano_fim_plano >= 2020
 and mes_ini_plano <= 11  and mes_fim_plano >= 11
 and cod_tip_carteira = '01'

select *  from pve_plano_vendas where empresa = '01' and plano_vendas = 2020 and cliente = '000005063000130'
 and item = 'KK0B' and ano_plano_vendas = 2020 and mes_plano_vendas = 11 and carteira = '01'
 AND mercado = 'IN' and pais = '001'

select * from  w_prog_komatsu

-- delete from programacao_komatsu

select pve_plano_vendas.qtd_plano_vendas, pve_plano_vendas.pre_unit_pl_vendas
  from pve_plano_vendas
  where pve_plano_vendas.empresa = '01'
   and pve_plano_vendas.cliente = '000005063000130'
   and pve_plano_vendas.item = 'KK0B'
   and pve_plano_vendas.carteira = '01'
   and pve_plano_vendas.mercado = 'IN'
   and pve_plano_vendas.pais = '001'
  and pve_plano_vendas.plano_vendas NOT IN
 ( SELECT w_prog_komatsu.plano_vendas from w_prog_komatsu
   where w_prog_komatsu.cod_item = pve_plano_vendas.item
   and w_prog_komatsu.ano_plano = pve_plano_vendas.ano_plano_vendas
   and w_prog_komatsu.mes_plano = pve_plano_vendas.mes_plano_vendas)

CREATE TABLE w_prog_komatsu (
    plano_vendas          VARCHAR(15),
    cod_item              VARCHAR(15),
    ano_plano             DECIMAL(4,0),
    mes_plano             DECIMAL(2,0),
);