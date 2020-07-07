{ TABLE "admlog".ord_ajust_man912 row size = 13 number of columns = 3 index size 
              = 11 }
create table "admlog".ord_ajust_man912 
  (
    cod_empresa char(2),
    num_ordem integer,
    qtd_planej decimal(10,3)
  );
revoke all on "admlog".ord_ajust_man912 from "public" as "admlog";


create unique index "admlog".ord_ajust_man912 on "admlog".ord_ajust_man912 
    (cod_empresa,num_ordem) using btree ;


