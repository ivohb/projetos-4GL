
create table oper_pw1_man912 
  (
    cod_empresa char(2) not null ,
    cod_operac char(5) not null 
  );
revoke all on oper_pw1_man912 from "public" as "ana";


create unique index ix_ope_pw1_1 on oper_pw1_man912 
    (cod_empresa,cod_operac) ;


