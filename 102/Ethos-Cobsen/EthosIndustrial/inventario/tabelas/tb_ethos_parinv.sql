--- parametros do Inventário

drop table ethos_parinv;

create table "informix".ethos_parinv
  (
    cod_empresa      char(02),
    dat_selecao      date,
    hor_selecao      char(8),
    caminho          char(100),
    nom_usuario      char(08),
    inv_concluido    char(01)
  );

revoke all on "informix".ethos_parinv from "public";

create unique index "informix".ix_eth_parinv_1 on "informix".ethos_parinv
    (cod_empresa, dat_selecao, hor_selecao) using btree;

