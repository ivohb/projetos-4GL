
create table proc_apont_man912 
  (
    processando char(1) not null ,
    hor_ini datetime hour to second,
    cod_empresa char(2)
  );
revoke all on proc_apont_man912 from "public" as "admlog";




