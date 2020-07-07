{ TABLE "admlog".pedido_mrp_304 row size = 14 number of columns = 4 index size = 
              0 }
create table "admlog".pedido_mrp_304 
  (
    cod_empresa char(2) not null ,
    num_pedido integer not null ,
    num_seq integer not null ,
    num_oc integer not null 
  );
revoke all on "admlog".pedido_mrp_304 from "public" as "admlog";




