drop table ethos_invusu;

--- usuarios participantes do Inventario.

create table "informix".ethos_invusu
  (
    cod_empresa      char(02),
    cod_usuario      char(08)
  );

revoke all on "informix".ethos_invusu from "public";

create unique index "informix".ix_invusu_1 on "informix".ethos_invusu
    (cod_empresa, cod_usuario) using btree;

