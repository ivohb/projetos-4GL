 SET ISOLATION TO DIRTY READ
 select * from min_par_modulo
 select * FROM TIP_ESTOQUE_915
 select * from it_analise_915
  select * from item_915
 select * from especific_915
 select * from analise_mest_915
  select * from analise_915
select * from tipo_caract_915

-- delete from analise_915
select * from analise_mest_915
select * from analise_915
alter table analise_915 add identif_estoque char(30)
select * from analise_audit_915
select * from laudo_mest_915
select * from laudo_item_915
select * from pa_laudo_915
select * from laudo_audit_915
select * from fat_nf_mestre where empresa = '11' and nota_fiscal = 3
select * from fat_nf_item where empresa = '11' and item = '1'
select * from fat_resv_item_nf
select * from estoque_loc_reser
select * from ordem_montag_grade

select * from pedidos where cod_empresa = '11' and num_pedido = 10000
select * from ped_itens where cod_empresa = '11' and num_pedido = 10000
select * from ordem_montag_mest where cod_empresa = '11' and num_om = 25009
select * from ordem_montag_item where cod_empresa = '11' and num_om = 25009
select * from ordem_montag_grade where cod_empresa = '11' and num_om = 25009
select * from estoque_loc_reser where cod_empresa = '11' and cod_item = '1' and num_lote = '100' and num_reserva = 16
select * from est_loc_reser_end where cod_empresa = '11' and num_reserva in (16,5,31)

select * from pedidos where num_pedido = 10000
 select * from wms_item_ctr_est where ind_item_ctr_wms = 'S' -- tabela para identificar se o item tem WMS
 select * from wms_tip_estoque
  select * from wms_restricao_estoque
  select * from SUP_INV_RELC_ETIQUETA_FALTA
  select * from item where cod_item = '1'
 select * from WMS_IDENTIF_ESTOQUE where item = '1' and empresa = '11' ORDER BY 2 --tabela para zoom das identificações
 select tip_estoque, restricao from WMS_IDENTIF_ESTOQUE where item = '1' and identif_estoque = '111090701144712012 ' --obtenção do tipo de estoq e restr~ção
 select * from WMS_TIP_ESTOQUE_RESTRICAO where tip_estoque = 'TE0004' and restricao = 'RS0001' --obter situação do estoque
 SELECT * FROM WMS_PROCESSO_MOVIMENT

 select * from LOG_VAL_PARAMETRO where parametro = 'oper_ent_alter_tip_est_rest'
 select * from LOG_VAL_PARAMETRO where parametro = 'oper_sai_alter_tip_est_rest'

 select * from ESTOQUE_OPERAC_CT where cod_empresa = '11'

   SELECT * FROM wms_parametro_usuario WHERE empresa = '11' AND usuario = 'admlog' AND rotina = 5

 select * from item where cod_empresa = '11' and cod_item = '1'
 select * from estoque where cod_empresa = '11' and cod_item = '1'
 select * from estoque_lote where cod_empresa = '11' and cod_item = '1' and num_lote = '100'
 select * from estoque_lote_ender where cod_empresa = '11' and cod_item = '1' and num_lote = '100'
 select * from estoque_trans where cod_empresa = '11' and cod_item = '1' and qtd_movto = 490 and dat_proces = '05/09/2014'
 select * from estoque_trans_end where cod_empresa = '11' and cod_item = '1' and qtd_movto = 490 and dat_proces = '05/09/2014'
 select * from estoque_obs where cod_empresa = '11'
 select * from sup_mov_orig_dest

  --PARA SABER SE NA RESERVA ESTÁ A IDENTIFICAÇÃO VIRTUAL, BASTA VERIFICAR SE A MESMA COMEÇA COM O DIGITO 6 E TEM TAMNHO 18
 --se na est_loc_reser_end tiver a identificação de estoque virtual, fazer o seguinte:
 -- -ler a estoque_TRANS_END PASSANDO A IDENTIFICAÇÃO VIRTUAL. SERÁ ENCONTRADAS DUAS TRANSAÇÇOES.
 -- -LET A sup_mov_orig_dest COM A MENOR TRANSAÇÃO ENCONTRADA. COM ISSO ENCONTRARÁ A TRANSAÇÃO ORIGEM
 -- -LER A ESTOQUE_TRANS_END CON A TRANSAÇÃO ORIGINAL E PRONTO.

 select * from est_loc_reser_end where cod_empresa = '11'

select distinct b.tabname
from syscolumns a, systables b
where a.tabid = b.tabid
  and a.colname like "%restricao%"


  alter table laudo_mest_915 add identif_estoque char(30)
  select * from laudo_mest_915

    SELECT a.seq_item_nf,
           a.item,
           a.des_item,
           a.qtd_item
      FROM fat_nf_item a,
           fat_nf_mestre b
     WHERE b.empresa = '11'
       AND b.trans_nota_fiscal = 18
       AND a.empresa = b.empresa
       AND a.trans_nota_fiscal = b.trans_nota_fiscal

Tabela wms_endereco campo inventario = 'S' significa que o item/local/identificação/endereço está em inventario daí não pode trocar o status para não bagunçar o processo

select inventario, * from wms_endereco
select * from estoque_lote_ender