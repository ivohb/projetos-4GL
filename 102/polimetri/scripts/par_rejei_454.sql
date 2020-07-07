{ TABLE "admlog".par_rejei_454 row size = 39 number of columns = 4 index size = 7 
              }
create table "admlog".par_rejei_454 
  (
    cod_empresa char(2) not null ,
    cod_local_rejei char(10) not null ,
    cod_oper_baixa char(4) not null ,
    num_conta char(23) not null 
  );
revoke all on "admlog".par_rejei_454 from "public" as "admlog";


create unique index "admlog".ix_par_rejei_454 on "admlog".par_rejei_454 
    (cod_empresa) using btree ;


