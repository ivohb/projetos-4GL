
create table aviso_rec_cairu 
  (
    cod_empresa char(2) not null ,
    num_aviso_rec decimal(6,0) not null,
    cod_item_benef char(15)
  );

create unique index ix_cairu on aviso_rec_cairu (cod_empresa,
    num_aviso_rec,cod_item_benef);




