
create table par_ppte_159 
  (
    cod_empresa char(2) not null ,
    cod_local char(10) not null 
  );

create unique index ix_par_ppte_159_1 on par_ppte_159 
    (cod_empresa,cod_local) using btree ;


