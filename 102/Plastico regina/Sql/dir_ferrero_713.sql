
create table dir_ferrero_713 
  (
    cod_empresa char(2) not null ,
    diretorio char(40) not null 
  );

create index ix_dir_ferrero_713 on dir_ferrero_713 
    (cod_empresa,diretorio) using btree ;


