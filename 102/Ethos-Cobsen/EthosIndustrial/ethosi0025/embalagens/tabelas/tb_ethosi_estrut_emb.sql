--- ESTRUTURA DAS EMBALAGENS DOS ITENS, TABELA UTILIZADA
--- NA APLICAÇÃO ETHOSI0024.

drop table ethosi_estrut_emb;

create table "informix".ethosi_estrut_emb
  (
    cod_empresa          char(02),
    cod_item             char(15),
    cod_item_emb         char(15),
    cod_cliente          char(15),
    qtd_fat_ini          decimal(10,3),
    qtd_fat_fim          decimal(10,3),
    qtd_necessaria       decimal(14,7)
 );

revoke all on "informix".ethosi_estrut_emb from "public";

create unique index "informix".ix_ethi_est_emb_1 
       on "informix".ethosi_estrut_emb
      (cod_empresa, cod_item, cod_item_emb,
       cod_cliente, qtd_fat_ini, qtd_fat_fim) using btree;

create index "informix".ix_ethi_est_emb_2 
       on "informix".ethosi_estrut_emb
      (cod_empresa, cod_item, 
       cod_cliente) using btree;

alter table ethosi_estrut_emb lock mode (row);
