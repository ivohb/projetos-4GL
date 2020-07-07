create table uni_funcio_adm_265 (
   cod_uni_feder   char(02) not null,
   cod_uni_funcio  char(10) not null
);

create unique index uni_funcio_adm_265
on uni_funcio_adm_265(cod_uni_feder);

