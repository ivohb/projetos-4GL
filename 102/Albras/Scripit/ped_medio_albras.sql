{ TABLE "ana".ped_medio_albras row size = 42 number of columns = 6 index size = 30 
              }
create table "ana".ped_medio_albras 
  (
    cod_empresa char(2) not null ,
    num_pedido decimal(6,0) not null ,
    cod_item char(15) not null ,
    num_sequencia decimal(5,0) not null ,
    val_preco_medio decimal(17,6) not null ,
    qtd_total decimal(10,3) not null 
  );
revoke all on "ana".ped_medio_albras from "public" as "ana";


create unique index "ana".ix4007_1 on "ana".ped_medio_albras (cod_empresa,
    num_pedido,cod_item,num_sequencia) using btree ;


