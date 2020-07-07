create table par_mrp_454
(
   cod_empresa  char(02) not null,
   dat_ini      date not null,
   dat_fim      date not null,
   cod_lin_prod dec(2,0) not null
);

create unique index par_mrp_454 on
par_mrp_454(cod_empresa, cod_lin_prod);

   