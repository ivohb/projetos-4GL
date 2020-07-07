{ TABLE "ana".oper_ega_man912 row size = 13 number of columns = 3 index size = 12 
              }
create table "ana".oper_ega_man912 
  (
    cod_empresa char(2) not null ,
    cod_operac char(5) not null ,
    cod_operac_ega decimal(9,0) not null 
  );
revoke all on "ana".oper_ega_man912 from "public" as "ana";


create unique index "ana".ix_ope_ega_1 on "ana".oper_ega_man912 
    (cod_empresa,cod_operac) using btree ;


