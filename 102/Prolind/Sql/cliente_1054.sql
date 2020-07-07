

create table cliente_1054 
  (
    cod_cliente char(15) not null ,
    cod_see char(3)  default '07'
  );


create unique index ix_cliente_1054 on cliente_1054 
    (cod_cliente);
