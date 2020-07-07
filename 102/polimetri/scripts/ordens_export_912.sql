{ TABLE "admlog".ordens_export_912 row size = 6 number of columns = 2 index size 
              = 11 }
create table "admlog".ordens_export_912 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null 
  );
revoke all on "admlog".ordens_export_912 from "public" as "admlog";


create index "admlog".ordens_export_912 on "admlog".ordens_export_912 
    (cod_empresa,num_ordem) using btree ;


