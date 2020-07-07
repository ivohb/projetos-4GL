
create table par_cliente_159 
  (
    cod_empresa char(2) not null ,
    cod_cliente char(15) not null ,
    ies_verifica_etiq char(1) not null ,
    ies_verifica_item char(1)
  );


create index ix_par_cliente_159 on par_cliente_159 
    (cod_empresa,cod_cliente) using btree ;


