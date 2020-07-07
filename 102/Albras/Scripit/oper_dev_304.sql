{ TABLE "thiago".oper_dev_304 row size = 10 number of columns = 3 index size = 7 
              }
create table "thiago".oper_dev_304 
  (
    cod_empresa char(2) not null ,
    cod_oper_ent char(4),
    cod_oper_sai char(4) not null 
  );
revoke all on "thiago".oper_dev_304 from "public" as "thiago";


create unique index "admlog".oper_dev_304_ix on "thiago".oper_dev_304 
    (cod_empresa) using btree ;


