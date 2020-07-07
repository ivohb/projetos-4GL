
create table par_desc_oper 
  (
    cod_emp_ofic char(2) not null,
    cod_emp_oper char(2) not null ,
    max_desc_oper decimal(5,2) not null ,
    per_jur_dia decimal(5,4) not null ,
    cod_nat_oper integer not null ,
    ies_estoque char(1) not null ,
    ies_pedido char(1) not null ,
    dat_process date not null 
  );

create index ix_pardes_1 
 on par_desc_oper (cod_emp_ofic);
    




