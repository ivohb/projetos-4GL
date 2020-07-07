
DBSCHEMA Schema Utility       INFORMIX-SQL Version 12.10.FC7







{ TABLE "informix".fat_nf_item row size = 424 number of columns = 48 index size = 41 }

create table "informix".fat_nf_item 
  (
    empresa char(2) not null ,
    trans_nota_fiscal integer not null ,
    seq_item_nf integer not null ,
    pedido integer not null ,
    seq_item_pedido integer not null ,
    ord_montag integer not null ,
    tip_item char(1) not null ,
    item char(15) not null ,
    des_item char(76) not null ,
    unid_medida char(3) not null ,
    peso_unit decimal(17,6) not null ,
    qtd_item decimal(17,6) not null ,
    fator_conv decimal(11,6) not null ,
    lista_preco smallint,
    versao_lista_preco smallint,
    tip_preco char(1) not null ,
    natureza_operacao integer not null ,
    classif_fisc char(10) not null ,
    item_prod_servico char(1) not null ,
    preco_unit_bruto decimal(17,6) not null ,
    pre_uni_desc_incnd decimal(17,6) not null ,
    preco_unit_liquido decimal(17,6) not null ,
    pct_frete decimal(7,4) not null ,
    val_desc_item decimal(17,2) not null ,
    val_desc_merc decimal(17,2) not null ,
    val_desc_contab decimal(17,2) not null ,
    val_desc_duplicata decimal(17,2) not null ,
    val_acresc_item decimal(17,2) not null ,
    val_acre_merc decimal(17,2) not null ,
    val_acresc_contab decimal(17,2) not null ,
    val_acre_duplicata decimal(17,2) not null ,
    val_fret_consig decimal(17,2) not null ,
    val_segr_consig decimal(17,2) not null ,
    val_frete_cliente decimal(17,2) not null ,
    val_seguro_cliente decimal(17,2) not null ,
    val_bruto_item decimal(17,2) not null ,
    val_brt_desc_incnd decimal(17,2) not null ,
    val_liquido_item decimal(17,2) not null ,
    val_merc_item decimal(17,2) not null ,
    val_duplicata_item decimal(17,2) not null ,
    val_contab_item decimal(17,2) not null ,
    fator_conv_cliente decimal(11,6),
    uni_med_cliente char(3),
    cest integer,
    fator_conv_trib decimal(13,9),
    uni_med_trib char(3),
    qtd_item_trib decimal(17,6),
    preco_unit_trib decimal(17,6),
    primary key (empresa,trans_nota_fiscal,seq_item_nf)  constraint "informix".pk_fatitem
  );

revoke all on "informix".fat_nf_item from "public" as "informix";


create index "informix".ix1_fat_nf_item on "informix".fat_nf_item 
    (empresa,trans_nota_fiscal) using btree ;
create index "informix".ix_fat_nf_item2 on "informix".fat_nf_item 
    (empresa,pedido,seq_item_pedido) using btree ;


