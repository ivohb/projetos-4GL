--- TABELA PARA O RELATÓRIO DO RESUMO GERAL DO PERÍODO DAS EMBALAGENS
--- UTILIZADA NA APLICAÇÃO ETHOSI0025.

drop table ethosi_rel_res_ger;

create table "informix".ethosi_rel_res_ger
  (
    cod_empresa          char(02),
    usuario              char(50),
    sequencia_relat      decimal(09,0),
    item_embalagem       char(15),
    den_embalagem        char(18),
    qtd_necess_embal     decimal(17,7),
    item_embal_cli       char(30),
    peso_embalagem       decimal(17,7)
 );

revoke all on "informix".ethosi_rel_res_ger from "public";

create unique index "informix".ix_ethi_rel_res_ger_1 
       on "informix".ethosi_rel_res_ger
      (cod_empresa, usuario,
       sequencia_relat) using btree;

alter table ethosi_rel_res_ger lock mode (row);
