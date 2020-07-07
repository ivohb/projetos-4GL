create table validade_lote_455(
   cod_empresa      char(02) not null,
   cod_item         char(15) not null,
   lote_tanque      char(10) not null,
   dat_fabricacao   date     not null
);

create unique index ix_validade_lote_455
   on validade_lote_455(cod_empresa, cod_item, lote_tanque);