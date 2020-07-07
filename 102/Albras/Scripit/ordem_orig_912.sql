
drop table ordem_orig_912;
create table ordem_orig_912 (
 cod_empresa    char(02),
 num_ordem      integer,
 dat_entrega    date,
 dat_liberac    date,
 dat_proces     date
);

create index ix_ordem_orig_912
 on ordem_orig_912(cod_empresa, num_ordem);
 
 