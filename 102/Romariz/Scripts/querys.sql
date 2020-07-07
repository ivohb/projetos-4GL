SET ISOLATION TO DIRTY READ
alter table analise_915 add dat_validade date
    dat_emis_nf date,
    dat_fabricacao date,
    dat_validade   date

ALTER TABLE laudo_item_915 MODIFY val_resultado char(250)
ALTER TABLE laudo_item_915 drop  txt_resultado

ALTER TABLE especific_915 MODIFY  unidade char(15)

SELECT * FROM tipo_caract_915
select * from analise_915 where cod_item = '11000A' and lote_tanque = '999999999'
select * from analise_vali_915
select * from analise_audit_915
select * from especific_915 where cod_item = '11000A'
select * from est_corresp_915
select * from it_analise_915
select * from item_refer_915 where cod_item = '100000035700'
select * from item_915
select * from item where cod_item = '100000035700'  familia 058
select * from item where cod_item = '100000035800'  familia 058
-- delete from laudo_mest_915
select * from laudo_item_915
select * from laudo_mest_915
select * from laudo_audit_915
select * from laudo_usu_915
select * from pa_laudo_915
select * from par_laudo_915 where cod_item = '11000A' and cod_empresa = '01'
select * from tipo_caract_915
select * from txt_desbl_915
select * from validade_lote_915
select * from vdp_num_docum where empresa = '01' and tip_docum = 'FATPRDSV'
select * from ordem_montag_item where cod_empresa = '01' and cod_item in ('100000035700','100000035800')
select * from ordem_montag_item where cod_empresa = '01' and num_om = 43107

select * from pedidos where num_pedido = 31809 and cod_cliente = '1005'
select * from ped_itens where num_pedido = 31809 and num_sequencia = 2
select * from ordem_montag_mest where cod_empresa = '01' and num_om = 43107
select * from ordem_montag_item where cod_empresa = '01' and num_om = 43107
select * from ordem_montag_grade where cod_empresa = '01' and num_om = 43107
select * from ordem_montag_lote where cod_empresa = '01' and num_lote_om = 16234
select * from estoque_lote_ender where cod_empresa = '01' and cod_item = '100000035700'
select * from estoque_lote where cod_empresa = '01' and cod_item = '100000035700'
select * from estoque_lote where cod_empresa = '01' and cod_item = '100000035700'
select * from estoque_loc_reser where cod_empresa = '01' and num_reserva = 541030
select * from estoque_loc_reser where cod_empresa = '01' and cod_item = '100000035700'
select * from est_loc_reser_end where cod_empresa = '01' and num_reserva = 541030

select * from fat_nf_mestre where empresa = '01' and trans_nota_fiscal in (49875,49877) NF 55373 e 55375
select * from fat_nf_item where item = '100000035800' and empresa = '01' trans: 49875 / 49877
select * from estoque_trans where cod_item = '100000035800' and num_docum = '49875'
select * from fat_nf_item where empresa = '01' and trans_nota_fiscal = 50172
select * from fat_nf_item where empresa = '01' and item in (select cod_item from analise_915)
select * from ordem_montag_item where cod_empresa = '01' and cod_item in (select cod_item from analise_915)


select * from pct_ajust_man912

alter table pct_ajust_man912 add prog_export_op  char(07) default 'pol0455' not null;
alter table pct_ajust_man912 add prog_import_op  char(07) default 'pol1110' not null

