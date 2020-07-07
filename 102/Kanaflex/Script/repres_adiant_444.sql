
create table repres_adiant_444 
  (
    cod_repres decimal(4,0) not null ,
    ano_mes char(7) not null ,
    val_base decimal(12,2) not null ,
    val_adiant decimal(12,2) not null ,
    val_irrf decimal(12,2) not null 
  );


create unique index repres_adiant_444 on repres_adiant_444 
    (cod_repres,ano_mes);


