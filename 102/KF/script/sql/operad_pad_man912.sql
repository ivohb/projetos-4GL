
create table operad_pad_man912 
  (
    cod_empresa char(2) not null ,
    cod_turno char(1) not null ,
    operador_padrao char(8) not null 
  );



create unique index operad_pad_man912 on operad_pad_man912 
    (cod_empresa,cod_turno)  ;


