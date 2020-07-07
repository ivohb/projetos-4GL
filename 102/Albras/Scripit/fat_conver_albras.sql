{ TABLE "osvaldo".fat_conver_albras row size = 41 number of columns = 5 index size 
              = 37 }
create table "osvaldo".fat_conver_albras 
  (
    cod_empresa char(2) not null ,
    cod_cliente char(15) not null ,
    cod_item char(15) not null ,
    cod_unid_med char(3) not null ,
    fat_conver decimal(10,4) not null ,
    primary key (cod_empresa,cod_cliente,cod_item)  constraint "osvaldo".pk_ftc_alb_1
  );
revoke all on "osvaldo".fat_conver_albras from "public" as "osvaldo";




