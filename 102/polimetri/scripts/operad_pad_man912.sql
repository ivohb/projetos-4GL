{ TABLE "ana".operad_pad_man912 row size = 11 number of columns = 3 index size = 
              8 }
create table "ana".operad_pad_man912 
  (
    cod_empresa char(2) not null ,
    cod_turno char(1) not null ,
    operador_padrao char(8) not null 
  );
revoke all on "ana".operad_pad_man912 from "public" as "ana";


create unique index "ana".operad_pad_man912 on "ana".operad_pad_man912 
    (cod_empresa,cod_turno) using btree ;


