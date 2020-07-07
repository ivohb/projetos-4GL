
create table apont_parada_454 
  (
    cod_empresa char(2) not null ,
    id_registro integer not null ,
    dat_inicial date not null ,
    hor_inicial datetime hour to second not null ,
    dat_final   date not null ,
    hor_final   datetime hour to second not null ,
    cod_parada  CHAR(3) not null 
  );




