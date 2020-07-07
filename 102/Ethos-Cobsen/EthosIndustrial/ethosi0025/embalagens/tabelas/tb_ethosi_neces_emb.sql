--- NECESSIDADE DE EMBALAGEM POR CLIENTE/ITEM/DIA RATEADA CONFORME 
--- CADASTRO ETHOSI0033. TABELA UTILIZADA NA APLICAÇÃO ETHOSI0025.

drop table ethosi_neces_emb;

create table "informix".ethosi_neces_emb
  (
    cod_empresa            char(02),
    usuario                char(50),
    dat_entrega            date,
    cod_cliente            char(15),
    nro_embalagem          decimal(15,0),
    cod_item_emb           char(15),
    cod_item               char(15),
    qtde_a_fat_emb         decimal(14,7),
    reg_ethosi_emb_it_dia  decimal(15,0),
    qtde_embalagem         decimal(14,7),
    peso_pro_embalagem     decimal(12,5)
 );

revoke all on "informix".ethosi_neces_emb from "public";

create unique index "informix".ix_ethi_nec_emb_1
       on "informix".ethosi_neces_emb
      (cod_empresa, usuario, dat_entrega, 
       cod_cliente, nro_embalagem, cod_item_emb, 
       cod_item) using btree;

create index "informix".ix_ethi_nec_emb_2
       on "informix".ethosi_neces_emb
      (cod_empresa, usuario, dat_entrega, 
       cod_cliente, cod_item_emb, 
       cod_item) using btree;

create unique index "informix".ix_ethi_nec_emb_3
       on "informix".ethosi_neces_emb
      (cod_empresa, usuario, dat_entrega, 
       cod_cliente, cod_item_emb, 
       cod_item, nro_embalagem) using btree;


alter table ethosi_neces_emb lock mode (row);
