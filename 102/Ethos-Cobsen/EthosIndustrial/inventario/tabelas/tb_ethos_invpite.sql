drop table ethos_invpite;

--- Itens em Inventario que Deverao ser Reprocessados na
--- Opcao "Processar Cargas" da pasta Carga das Contagens

create table "informix".ethos_invpite
  (
    cod_empresa      char(02)      not null,
    dat_selecao      date          not null,
    hor_selecao      char(8)       not null,
    cod_item         char(15)
  );

revoke all on "informix".ethos_invpite from "public";

create unique index "informix".ix_eth_invpite_1 on "informix".ethos_invpite
    (cod_empresa, dat_selecao, hor_selecao, cod_item) using btree;
