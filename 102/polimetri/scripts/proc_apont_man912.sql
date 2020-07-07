{ TABLE "admlog".proc_apont_man912 row size = 7 number of columns = 3 index size 
              = 0 }
create table "admlog".proc_apont_man912 
  (
    processando char(1) not null ,
    hor_ini datetime hour to second,
    cod_empresa char(2)
  );
revoke all on "admlog".proc_apont_man912 from "public" as "admlog";




