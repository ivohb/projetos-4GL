
create table apont_erro_1054 
  (
    cod_empresa char(2) not null ,
    num_processo integer not null ,
    num_ordem integer not null ,
    cod_item char(15) not null ,
    qtd_boas decimal(10,3),
    qtd_refug decimal(10,3),
    den_critica char(50)
  );



