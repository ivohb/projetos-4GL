
create table prog_entrega_454 
  (
    pedido decimal(6,0),
    cod_fornecedor char(15),
    cod_item char(15),
    num_sequencia decimal(5,0),
    prz_entrega date,
    saldo decimal(18,7),
    cod_item_cli char(30),
    num_ped_cli char(12)
  );


create table fornec_edi_454
  (
    cod_fornecedor char(15) not null 
  );


create unique index fornec_edi_454 on
    fornec_edi_454 (cod_fornecedor);


create table item_edi_454
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_item_cli char(30),
    cod_uni_med char(2),
    pct_refugo decimal(5,2),
    contato char(11),
    num_ped_cli char(12)
  );


create unique index item_edi_454 on item_edi_454 
    (cod_empresa, cod_item);



create table processo_edi_454
  (
    cod_empresa char(2) not null ,
    num_processo integer
  );

create unique index processo_edi_454 on 
  processo_edi_454 (cod_empresa,num_processo);



create table unimed_edi_454
  (
    cod_uni_med char(3) not null ,
    des_uni_med char(25) not null 
  );


create unique index unimed_edi_454 on 
    unimed_edi_454 (cod_uni_med);
