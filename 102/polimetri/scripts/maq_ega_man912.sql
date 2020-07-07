{ TABLE "admlog".maq_ega_man912 row size = 25 number of columns = 4 index size = 
              40 }
create table "admlog".maq_ega_man912 
  (
    cod_empresa char(2) not null ,
    cod_maquina char(5) not null ,
    cod_maquina_ega decimal(3,0) not null ,
    cod_equip char(15) not null 
  );
revoke all on "admlog".maq_ega_man912 from "public" as "admlog";


create unique index "admlog".maq_ega_man912_1 on "admlog".maq_ega_man912 
    (cod_empresa,cod_maquina,cod_maquina_ega) using btree ;
create unique index "admlog".maq_ega_man912_2 on "admlog".maq_ega_man912 
    (cod_empresa,cod_maquina_ega,cod_equip) using btree ;


