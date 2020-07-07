select * from it_analise_petrom
select * from ITEM_PETROM
select * from item_refer_petrom
select * from ESPECIFIC_PETROM
select * from tipo_caract_petrom
select * from par_laudo_petrom
select * from analise_petrom
select * from validade_lote_455
select * from laudo_usu_petrom
select * from laudo_mest_petrom
select * from laudo_item_petrom
-- delete from laudo_item_petrom
select * from ordem_montag_item where num_om = 19         9,858
select * from ordem_montag_mest

   SELECT distinct tip_laudo, bloqueia_laudo
     FROM par_laudo_petrom
    WHERE cod_empresa = '01'
      AND cod_item    = '001'
      AND cod_cliente IS NULL

alter table laudo_mest_petrom add    ser_nff char(3)
 alter table laudo_mest_petrom add   ies_es  char(01)

 select * from ordem_montag_mest where num_om = 1
 select * from ordem_montag_item where num_om = 1
 select * from fat_nf_mestre where  nota_fiscal = 4924
 select * from fat_nf_item where trans_nota_fiscal = 29
 select * from item where cod_item = '2184444-15-20'

