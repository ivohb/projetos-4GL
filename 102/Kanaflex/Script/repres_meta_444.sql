
create table repres_meta_444 
  (
    cod_repres decimal(4,0) not null ,
    ano decimal(4,0) not null ,
    mes decimal(2,0) not null 
  );


create unique index repres_meta_444 on repres_meta_444 
    (cod_repres,ano,mes);


