{ TABLE "admlog".par_ajust_454 row size = 12 number of columns = 3 index size = 7 
              }
create table "admlog".par_ajust_454 
  (
    cod_empresa char(2) not null ,
    cod_oper_ent char(5) not null ,
    cod_oper_sai char(5) not null 
  );
revoke all on "admlog".par_ajust_454 from "public" as "admlog";


create unique index "admlog".par_ajust_454 on "admlog".par_ajust_454 
    (cod_empresa) using btree ;


