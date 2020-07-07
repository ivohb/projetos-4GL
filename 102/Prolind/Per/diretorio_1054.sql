
              
create table diretorio_1054 
  (
    cod_empresa char(2) not null ,
    diretorio char(40) not null 
  );

create index ix_diretorio_1054 on diretorio_1054 (cod_empresa,
    diretorio);


