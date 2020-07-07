--- ITENS POR EMBALAGEM TABELA UTILIZADA NA APLICAÇÃO ETHOSI0033.

drop table ethosi_itens_emb;

create table "informix".ethosi_itens_emb
  (
    cod_empresa          char(02),
    cod_item_emb         char(15),
    cod_item             char(15),
    cod_cliente          char(15),
    capacidade_qtd       decimal(14,7)
 );

revoke all on "informix".ethosi_itens_emb from "public";

create unique index "informix".ix_ethi_ite_emb_1 
       on "informix".ethosi_itens_emb
      (cod_empresa, cod_item_emb, cod_item,
       cod_cliente) using btree;

create index "informix".ix_ethi_ite_emb_2 
       on "informix".ethosi_itens_emb
      (cod_empresa, cod_item_emb, 
       cod_cliente) using btree;

create index "informix".ix_ethi_ite_emb_3
       on "informix".ethosi_itens_emb
      (cod_empresa, cod_item, 
       cod_cliente) using btree;


alter table ethosi_itens_emb lock mode (row);
