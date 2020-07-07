drop table ethos_carcol;

--- Itens contados pelo Coletor (Carga do Coletor)

create table "informix".ethos_carcol
  (
    cod_empresa      char(02)      not null,
    dat_selecao      date          not null,
    hor_selecao      char(8)       not null,
    arquivo          char(30)      not null,
    contagem         char(01)      not null,
    cod_usuario      char(08)      not null,
    cod_item         char(15),
    cod_local        char(10),
    num_lote         char(15),
    controle         char(10),
    qtde             decimal(12,3),
    aceito           char(01),
    diverg           char(01),
    tex_diverg       char(200),
    reg_pai          decimal(12,0),
    registro         decimal(12,0),
    totaliza         char(01)
  );

revoke all on "informix".ethos_carcol from "public";


drop index ix_carcol_1;
create unique index "informix".ix_carcol_1 on "informix".ethos_carcol
    (cod_empresa, registro) using btree;

drop index ix_carcol_2;
create index "informix".ix_carcol_2 on "informix".ethos_carcol
    (cod_empresa, reg_pai) using btree;

drop index ix_carcol_3;
create index "informix".ix_carcol_3 on "informix".ethos_carcol
    (cod_empresa, dat_selecao, hor_selecao) using btree;

drop index ix_carcol_4;
create index "informix".ix_carcol_4 on "informix".ethos_carcol
    (cod_empresa, dat_selecao, hor_selecao, arquivo)
    using btree;

drop index ix_carcol_5;
create index "informix".ix_carcol_5 on "informix".ethos_carcol
    (cod_empresa, dat_selecao, hor_selecao, cod_item, cod_local,
     num_lote, arquivo, cod_usuario, diverg, controle)
     using btree;

drop index ix_carcol_6;
create index "informix".ix_carcol_6 on "informix".ethos_carcol
    (cod_empresa, dat_selecao, hor_selecao, totaliza)
     using btree;


drop index ix_carcol_7;
create index "informix".ix_carcol_7 on "informix".ethos_carcol
    (cod_empresa, dat_selecao, hor_selecao, cod_item,
     totaliza) using btree;

--- Controle: 0 = contar o proprio item.
---           1 = contar os filhos.
---           2 = gerado automatico pelo controle 1
