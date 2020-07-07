create table embal_plast_regina 
  (
    cod_empresa char(2) not null ,
    cod_embal char(3) not null ,
    cod_item char(15) not null ,
    qtd_embal decimal(12,7) not null ,
    pre_unit decimal(15,2) not null 
  );
  
create unique index ix_embal_plast_1 on embal_plast_regina 
    (cod_empresa,cod_embal,cod_item);


