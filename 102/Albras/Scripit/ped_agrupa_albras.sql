{ TABLE "Administ".ped_agrupa_albras row size = 35 number of columns = 6 index size 
              = 0 }
create table "Administ".ped_agrupa_albras 
  (
    cod_empresa char(2) not null ,
    num_pedido decimal(6,0) not null ,
    num_sequencia decimal(3,0) not null ,
    cod_item char(15) not null ,
    pre_unit decimal(15,2) not null ,
    num_agrup smallint
  );
revoke all on "Administ".ped_agrupa_albras from "public" as "Administ";




