drop table cap_fabrica_405 ;
create table cap_fabrica_405   (
   cod_empresa      char(02) not null,
   cod_item         char(15) not null,
   cap_fab_dia      decimal(5,0) not null,
   primary key(cod_empresa, cod_item)
);

drop table tip_pedido_405 ;
create table tip_pedido_405   (
   cod_empresa        char(02) not null,
   tip_pedido         char(02) not null,
   prz_minimo         decimal(5,0) not null,
   primary key(cod_empresa, tip_pedido)
);
   
   