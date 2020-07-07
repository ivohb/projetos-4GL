






create table aen_ega_logix_912 
  (
    cod_lin_prod decimal(2,0) not null ,
    cod_lin_recei decimal(2,0) not null ,
    cod_seg_merc decimal(2,0) not null ,
    cod_cla_uso decimal(2,0) not null 
  );

create unique index aen_ega_logix_912 on 
    aen_ega_logix_912 (cod_lin_prod,cod_lin_recei,cod_seg_merc,
    cod_cla_uso);


