{ TABLE "informix".de_para_embal row size = 20 number of columns = 3 index size = 
              10 }
create table "informix".de_para_embal 
  (
    cod_empresa char(2) not null ,
    cod_embal_vdp char(3) not null ,
    cod_embal_item char(15) not null 
  );
revoke all on "informix".de_para_embal from "public" as "informix";


create unique index "informix".ix3949_1 on "informix".de_para_embal 
    (cod_empresa,cod_embal_vdp) using btree ;


