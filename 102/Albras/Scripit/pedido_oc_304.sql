{ TABLE "admlog".pedido_oc_304 row size = 60 number of columns = 8 index size = 45 
              }
create table "admlog".pedido_oc_304 
  (
    cod_empresa char(2) not null ,
    num_pedido integer not null ,
    num_sequencia integer not null ,
    cod_item char(15) not null ,
    qtd_saldo decimal(10,3) not null ,
    cod_compon char(15) not null ,
    qtd_necessaria decimal(14,7) not null ,
    num_oc integer not null 
  );
revoke all on "admlog".pedido_oc_304 from "public" as "admlog";


create index "admlog".pedido_oc_304_ix on "admlog".pedido_oc_304 
    (cod_empresa,num_pedido,num_sequencia) using btree ;
create unique index "admlog".pedido_oc_304_ix2 on "admlog".pedido_oc_304 
    (cod_empresa,num_pedido,num_sequencia,cod_compon) using btree 
    ;


