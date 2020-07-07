
create table cli_ferrero_713 
  (
    cod_cliente char(15) not null 
  );


create index ix_cli_ferrero_713 on cli_ferrero_713 
    (cod_cliente) using btree ;


