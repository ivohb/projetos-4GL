--pol0604 - de_para_maq_885 deletar da Ó
delete from de_para_maq_885 where cod_empresa like 'O%';

-- pol0605 - cliente_885 - loc_entrega_885 - cliente_msg_885
-- dropar e recriar a tabela loc_entrega_885
delete from cliente_885
select * from cliente_msg_885
select * from loc_entrega_885


--pol0607 - par_item_885 só tem registros na 01
select * from par_item_885 where cod_empresa like '%O%'

--pol0617 - gramatura_885 tem na Ó1, 01, Ó3, 03
delete from gramatura_885 where cod_empresa like '%O%'
select count(*) from gramatura_885

--pol0618 - ordens_885 só tem na Ó1 e Ó2
select * from ordens_885 where statusregistro = '1' and codempresa = 'O1'
delete from ordens_885 where statusregistro = '1' and datentrega <= '31/12/2013'
select * from loc_entrega_885 where codcliente = '004945225000171'
select * from ordem_erro_885
update item_chapa_885 set cod_empresa = '01' where cod_empresa = 'O1'
update item_caixa_885 set cod_empresa = '01' where cod_empresa = 'O1'
update item_bobina_885 set cod_empresa = '02' where cod_empresa = 'O2'
select * from item_chapa_885
update tipo_pedido_885 set cod_empresa = '01' where cod_empresa = 'O1'

select * from tipo_pedido_885 where cod_empresa = '01'
select * from item_chapa_885 where cod_empresa = 'O1'
select * from item_chapa_885 where num_pedido = 1
select * from item where cod_item = 'KKB'04000600
select * from item_vdp where cod_item = 'KKB04000600'
select * from item_man where cod_item = 'KKB04000600'
select * from cliente_item where  cod_cliente_matriz = '004945225000171'
select * from estrutura where cod_item_pai = 'KKB04000600' and cod_empresa = '01'
select * from gramatura_885 where cod_item = 'KKB'
select * from item_chapa_885 where num_pedido = 1
select * from ordens where cod_empresa = '01' and cod_item = 'KKB' and cod_item_pai = '0'
select * from ordens where cod_empresa = '01' and num_docum in ('62139/1', '67000/2', '67213/1', '1/1')
select * from pedidos where  cod_empresa = '01' and num_pedido = 1
select * from ped_itens where cod_empresa = '01' and num_pedido = 1
select * from estoque where cod_empresa = '01' and cod_item = 'KKB'
select * from estoque_lote where cod_empresa = '01' and cod_item = 'KKB'
select * from estoque_lote_ender where cod_empresa = '01' and cod_item = 'KKB'
select * from necessidades where cod_empresa = '01' and num_ordem = 244734
select * from ord_compon where cod_empresa = '01' and num_ordem = 244734
select * from necessidades where cod_empresa = '01' and num_docum = '1/1'
select * from ord_compon where cod_empresa = '01' and num_ordem = 244736

select min(numsequencia) from ordens_885 where codempresa = 'O1' --27464
select max(numsequencia) from ordens_885 where codempresa = 'O1' --149055
update ordens_885 set codempresa = '01' where codempresa = 'O1' and numsequencia < 50000
update ordens_885 set codempresa = '01' where codempresa = 'O1' and numsequencia < 80000
update ordens_885 set codempresa = '01' where codempresa = 'O1' and numsequencia < 110000
update ordens_885 set codempresa = '01' where codempresa = 'O1' and numsequencia < 150000
update ordens_885 set codempresa = '02' where codempresa = 'O2'

select count(*) from tipo_pedido_885 where cod_empresa = 'O1'
select count(*) from tipo_pedido_885 where cod_empresa = 'O2'
update tipo_pedido_885 set cod_empresa = '01' where cod_empresa = 'O1'
update tipo_pedido_885 set cod_empresa = '02' where cod_empresa = 'O2'

select * from item_chapa_885 where cod_empresa = 'O1'
update item_chapa_885 set cod_empresa = '01' where cod_empresa = 'O1'
select * from item_caixa_885 where cod_empresa = 'O1'
update item_caixa_885 set cod_empresa = '01' where cod_empresa = 'O1'
select * from item_bobina_885 where cod_empresa = 'O2'
update item_bobina_885 set cod_empresa = '02' where cod_empresa = 'O2'

--pol0635 - cli_tolerancia_885 contém alguns registros na 01, más todos estão na Ó1
delete from cli_tolerancia_885 where  cod_empresa = '01'
update cli_tolerancia_885 set cod_empresa = '01' where cod_empresa = 'O1'

--pol0638 - carteira_cli_885 contém alguns na zero e muitos na Ó

select * from carteira_cli_885 where cod_empresa like '01'
select * from carteira_cli_885 where cod_empresa like 'O1'
delete from carteira_cli_885 where  cod_empresa = '01'
delete from carteira_cli_885 where  cod_empresa = '02'
update carteira_cli_885 set cod_empresa = '01' where cod_empresa = 'O1'
update carteira_cli_885 set cod_empresa = '02' where cod_empresa = 'O2'

-- pol0644 - grupo_produto_885
delete from grupo_produto_885 where  cod_empresa = '01'
delete from grupo_produto_885 where  cod_empresa = '02'
update grupo_produto_885 set cod_empresa = '01' where cod_empresa = 'O1'
update grupo_produto_885 set cod_empresa = '02' where cod_empresa = 'O2'
select * from grupo_produto_885

--pol0647 - apontamentos criticados - apont_trim_885 / apont_erro_885
select count(*) from apont_trim_885
update apont_erro_885 set codempresa = '01' where codempresa = 'O1'
update apont_erro_885 set codempresa = '02' where codempresa = 'O2'
select * from apont_trim_885 order by 1
delete from apont_trim_885 where numsequencia <= 48256121 --deletar de 1 em 1 milhão
update apont_trim_885 set codempresa = '01' where numsequencia < 49556121
update apont_trim_885 set codempresa = '01' where numsequencia >= 49556121 and numsequencia <  50556121
update apont_trim_885 set codempresa = '01' where numsequencia >= 50556121 and numsequencia <  51556121
update apont_trim_885 set codempresa = '01' where numsequencia >= 51556121 and numsequencia <  52556121
update apont_trim_885 set codempresa = '01' where numsequencia >= 52556121
select * from apont_trim_885 where codempresa <> '01'

-- pol0653 - exportação de insumos - familia_insumo_885 / pol0653_msg_885 / insumo_885
select * from familia_insumo_885 where cod_EMpresa = '01'
delete from familia_insumo_885 where cod_empresa in ('O1', 'O2')
select * from pol0653_msg_885

select * from parametros_885
alter table parametros_885  add dat_corte datetime

--pol0654 - exportação OP p/ Trim Papel - pol0654_msg_885 / ordens_bob_885
select * from pol0654_msg_885
select * from ordens_bob_885 where codempresa = 'O1'
delete from ordens_bob_885 where statusregistro = '1' and datentrega <= '31/12/2013'
delete from ordens_bob_885 where codempresa = 'O1'
select * from ordens where ies_situa = '3' and cod_empresa = '02'
select * from necessidades where ies_situa = '3' and cod_empresa = '02'
select * from tipo_pedido_885 where cod_empresa = '02' and num_pedido = 9
update tipo_pedido_885 set cod_empresa = '02' where cod_empresa = 'O2'
select * from ordens_bob_885  where codempresa = '02'
select * from pedidos where num_pedido = 9 and cod_empresa = 'O2'
select * from ped_itens where num_pedido = 9 and cod_empresa = 'O2'

--pol0700 - familia_insumo_885
select count(*) from familia_insumo_885 where cod_empresa like '%O%'
select count(*) from familia_insumo_885 where cod_empresa like '%0%'
delete from familia_insumo_885 where cod_empresa like '%O%'

-- pol0701 - cotacao_preco_885 / p_audit_cotacao
alter table cotacao_preco_885 add id_registro    integer
alter table cotacao_preco_885 add regiao_lagos   CHAR(01)
select * from cotacao_preco_885 where cod_empresa <> '02'
select * from audit_cotacao_885

--pol0705 - de_para_turno_885
select count( * ) from de_para_turno_885 where cod_empresa = '01'
delete from de_para_turno_885 where cod_empresa like '%O%' --deletar da Ó

--pol0710 - oper_entrada_885
select count (*) from oper_entrada_885 where cod_empresa like '%O%' -- mais na zero que na Ó
delete from oper_entrada_885 where cod_empresa like '%O%'

-- pol0725 - desc_nat_oper_912
select * from desc_nat_oper_912 where cod
select count (*) from desc_nat_oper_912 where cod_empresa like '%O%' -- 388 registros
select count (*) from desc_nat_oper_912 where cod_empresa like '%0%' -- 49 registros
delete  from desc_nat_oper_912 where cod_empresa like '%0%'
update desc_nat_oper_912 set cod_empresa = '01' where cod_empresa = 'O1'
update desc_nat_oper_912 set cod_empresa = '02' where cod_empresa = 'O2'
update desc_nat_oper_912 set cod_empresa = '03' where cod_empresa = 'O3'
update desc_nat_oper_912 set cod_empresa = '04' where cod_empresa = 'O4'

-- pol0731 - ft_item_885 - só tem ó1 e Ó3 - não está sendo utilizado
select count (*) from ft_item_885 where cod_empresa like '%O%' -- 20291 registros
select count (*) from ft_item_885 where cod_empresa like '%0%' -- 1 registros
delete  from ft_item_885 where cod_empresa like '%0%'
update ft_item_885 set cod_empresa = '01' where cod_empresa = 'O1'
update ft_item_885 set cod_empresa = '03' where cod_empresa = 'O3'
select * from ft_item_885 where cod_empresa like '01'

-- pol0746 - frete_rota_885
select count (*) from frete_rota_885 where cod_empresa like '%O%' -- 8135 registros
select count (*) from frete_rota_885 where cod_empresa like '%0%' -- 10 registros - apagar
delete  from frete_rota_885 where cod_empresa like '%0%'
update frete_rota_885 set cod_empresa = '01' where cod_empresa = 'O1'
update frete_rota_885 set cod_empresa = '02' where cod_empresa = 'O2'
update frete_rota_885 set cod_empresa = '03' where cod_empresa = 'O3'
select * from frete_rota_885 where cod_empresa like '01'

--pol0748 - desc_transp_885 - tem na Ó1 e Ó3
select count (*) from desc_transp_885 where cod_empresa like '%O%'
select count (*) from desc_transp_885 where cod_empresa like '%0%'
delete  from desc_transp_885 where cod_empresa like '%0%'
update desc_transp_885 set cod_empresa = '01' where cod_empresa = 'O1'
update desc_transp_885 set cod_empresa = '03' where cod_empresa = 'O3'

pol0752 - ger_com_885
select * from ger_com_885

pol0753 - repres_885
select * from repres_885

--pol0768 - veiculo_885
select * from veiculo_885

--pol0779 - parametros_885 - tem na 0 e na Ó
select count (*) from parametros_885 where cod_empresa like '%O%'
select count (*) from parametros_885 where cod_empresa like '%0%'
delete  from parametros_885 where cod_empresa like '%O%'
select * from parametros_885

--pol0800 - apontamento de sucata

--pol0911 - motivo_885 - só tem na zero2
select * from motivo_885 where cod_empresa = '02'

--pol0938 - familia_baixar_885 - só tem na 01 e 03
select * from familia_baixar_885

--pol1062 - user_liber_ar_885
select * from user_liber_ar_885

pol1063 - repres_email_885
select * from repres_email_885

--Apontamento
update tipo_pedido_885 set cod_empresa = '01' where cod_empresa = 'O1'
update tipo_pedido_885 set cod_empresa = '02' where cod_empresa = 'O2'