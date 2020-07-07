{ TABLE "admlog".mov_ega_man912 row size = 12 number of columns = 5 index size = 
              15 }
create table "admlog".mov_ega_man912 
  (
    cod_empresa char(2) not null ,
    cod_mov_ega char(5) not null ,
    cod_mov_logix char(3) not null ,
    ies_liberar char(1) not null ,
    aponta_como_boa char(1) not null 
  );
revoke all on "admlog".mov_ega_man912 from "public" as "admlog";


create unique index "admlog".ix_mov_man912 on "admlog".mov_ega_man912 
    (cod_empresa,cod_mov_ega,cod_mov_logix) using btree ;


