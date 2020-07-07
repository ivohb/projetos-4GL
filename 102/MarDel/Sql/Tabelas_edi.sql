create table caminho_5054 (
   cod_empresa char(02) not null,
   nom_caminho char(40) not null
);

create unique index caminho_5054 on
 caminho_5054(cod_empresa);
 
create table item_edi_vw_5054 
  (
    cod_empresa char(2) not null,
    cod_item char(15) not null,
    cod_item_vw char(30),
    cod_uni_med char(2),
    pct_refugo decimal(5,2),
    contato char(11),
    num_ped_vw char(12)
  );

create unique index item_edi_vw_5054 
on item_edi_vw_5054(cod_empresa, cod_item);

create table unimed_edi_vw_5054 
  (
    cod_uni_med char(03) not null ,
    des_uni_med char(25) not null 
  );

create unique index unimed_edi_vw_5054 on 
 unimed_edi_vw_5054(cod_uni_med);


create table fornec_edi_vw_5054 
  (
    cod_fornecedor char(15) not null
  );

create unique index fornec_edi_vw_5054 on 
 fornec_edi_vw_5054(cod_fornecedor);


create table processo_edi_vw_5054 
  (
    cod_empresa  char(02) not null,
    num_processo integer
  );

create unique index processo_edi_vw_5054 on 
 processo_edi_vw_5054(cod_empresa,num_processo);


