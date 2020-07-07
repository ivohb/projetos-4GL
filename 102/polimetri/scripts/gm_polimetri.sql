{ TABLE "toni".gm_polimetri row size = 17 number of columns = 2 index size = 22 }
create table "toni".gm_polimetri 
  (
    cod_empresa char(2) not null constraint "toni".n5204_43617,
    cod_cliente char(15) not null constraint "toni".n5204_43618
  );
revoke all on "toni".gm_polimetri from "public" as "toni";


create unique index "toni".ix_gm_polimetri on "toni".gm_polimetri 
    (cod_empresa,cod_cliente) using btree ;


