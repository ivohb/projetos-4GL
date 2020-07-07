{ TABLE "admlog".ar_proces_304 row size = 6 number of columns = 2 index size = 11 
              }
create table "admlog".ar_proces_304 
  (
    cod_empresa char(2) not null ,
    num_aviso_rec decimal(6,0) not null 
  );
revoke all on "admlog".ar_proces_304 from "public" as "admlog";


create unique index "admlog".ix_ar_proces_304 on "admlog".ar_proces_304 
    (cod_empresa,num_aviso_rec) using btree ;


