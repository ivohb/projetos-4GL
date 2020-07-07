{ TABLE "admlog".port_des_polimetri row size = 6 number of columns = 3 index size 
              = 11 }
create table "admlog".port_des_polimetri 
  (
    cod_empresa char(2) not null constraint "toni".n5853_44416,
    cod_portador decimal(4,0) not null constraint "toni".n5853_44417,
    ies_tip_portador char(1) not null constraint "toni".n5853_44418
  );
revoke all on "admlog".port_des_polimetri from "public" as "admlog";


create unique index "admlog".ix_port_des_1 on "admlog".port_des_polimetri 
    (cod_empresa,cod_portador,ies_tip_portador) using btree ;
    


