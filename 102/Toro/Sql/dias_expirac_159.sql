create table dias_expirac_159 
  (
    cod_empresa char(2) not null ,
    cod_familia char(3) not null ,
    num_dias decimal(4,0)
  );


create index dias_expirac_159 on dias_expirac_159 
    (cod_empresa,cod_familia) using btree ;


