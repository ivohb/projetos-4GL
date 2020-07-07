{ TABLE "admlog".est_oper_polimetri row size = 10 number of columns = 3 index size 
              = 7 }
create table "admlog".est_oper_polimetri 
  (
    cod_empresa char(2) not null ,
    cod_oper_ent char(4) not null ,
    cod_oper_sai char(4) not null 
  );
revoke all on "admlog".est_oper_polimetri from "public" as "admlog";


create unique index "admlog".ix_est_polimetri_1 on "admlog".est_oper_polimetri 
    (cod_empresa) using btree ;


