
create table ctr_stat_kanaflex 
  (
    cod_empresa char(2) not null ,
    num_nff decimal(6,0) not null ,
    ser_nf  char(03),
    sser_nf decimal(3,0),
    ies_situa char(1) not null 
    primary key (cod_empresa,num_nff,ies_situa)  constraint pk_ctr_stat
  );



  create unique index ix_ctr_stat_kana on ctr_stat_kanaflex
  (cod_empresa, num_nff, ser_nf, sser_nf);


