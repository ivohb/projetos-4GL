create table maq_pw1_man912 
  (
    cod_empresa char(2) not null ,
    cod_maquina char(5) not null ,
    cod_equip char(15) not null 
  );
revoke all on maq_pw1_man912 from "public" 


create unique index maq_pw1_man912_1 on maq_pw1_man912
    (cod_empresa,cod_maquina)  ;



