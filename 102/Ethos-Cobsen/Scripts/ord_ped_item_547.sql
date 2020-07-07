
create table ord_ped_item_547 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null ,
    num_pedido decimal(6,0) not null ,
    num_sequencia decimal(5,0) not null ,
    primary key (cod_empresa,num_ordem)  constraint "informix".u7701_54480
  );


create index ix_ord_ped_item_547 on ord_ped_item_547 
    (cod_empresa,num_pedido,num_sequencia) ;


