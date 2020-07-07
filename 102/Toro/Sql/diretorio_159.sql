
create table diretorio_159 
  (
    cod_empresa char(2) not null ,
    diretorio char(40) not null 
  );


create index ix_diretorio_159 on diretorio_159 (cod_empresa,
    diretorio) using btree ;


