{ TABLE "admlog".familia_mrp_304 row size = 5 number of columns = 2 index size = 
              10 }
create table "admlog".familia_mrp_304 
  (
    cod_empresa char(2) not null ,
    cod_familia char(3) not null 
  );
revoke all on "admlog".familia_mrp_304 from "public" as "admlog";


create unique index "admlog".ix_familia on "admlog".familia_mrp_304 
    (cod_empresa,cod_familia) using btree ;


