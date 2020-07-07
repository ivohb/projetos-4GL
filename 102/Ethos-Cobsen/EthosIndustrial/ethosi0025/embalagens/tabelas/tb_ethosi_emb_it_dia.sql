--- EMBALAGENS POR CLIENTE/ITEM/DIA CONFORME CADASTRADO NO ETHOSI0033
--- UTILIZADA PARA SABER A QTDE DE EMBALAGENS QUE SERÃO UTILIZADAS.
--- TABELA UTILIZADA NA APLICAÇÃO ETHOSI0025.

drop table ethosi_emb_it_dia;

create table "informix".ethosi_emb_it_dia
  (
    cod_empresa          char(02),
    usuario              char(50),
    dat_entrega          date,
    cod_item_emb         char(15),
    cod_cliente          char(15),
    cod_item             char(15),
    qtde_a_fatur_emb     decimal(14,7),
    registro             decimal(15,0)
 );

revoke all on "informix".ethosi_emb_it_dia from "public";


create unique index "informix".ix_ethi_ite_emb_dia_1 
       on "informix".ethosi_emb_it_dia
      (registro) using btree;

create index "informix".ix_ethi_ite_emb_dia_2
       on "informix".ethosi_emb_it_dia
      (cod_empresa, usuario, dat_entrega,
       cod_item_emb, cod_cliente,
       cod_item) using btree;

create index "informix".ix_ethi_ite_emb_dia_3
       on "informix".ethosi_emb_it_dia
      (cod_empresa, usuario) using btree;

alter table ethosi_emb_it_dia lock mode (row);
