{ TABLE "admlog".arranjo_drummer row size = 15 number of columns = 4 index size = 
              12 }
create table "admlog".arranjo_drummer 
  (
    cod_empresa char(2) not null ,
    cod_arranjo char(5) not null ,
    cod_cent_trab char(5) not null ,
    cod_cent_cust decimal(4,0) not null 
  );
revoke all on "admlog".arranjo_drummer from "public" as "admlog";


create unique index "admlog".arranjo_drummer on "admlog".arranjo_drummer 
    (cod_empresa,cod_arranjo) using btree ;


