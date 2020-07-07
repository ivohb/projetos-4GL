
create table item_kanban_547 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_item_cliente char(30) not null ,
    dat_inicio date,
    dat_termino date,
    tipo_item char(10) 
        default 'KANBAN' not null ,
    qtd_dias integer 
        default 0 not null 
  );

create unique index ix_it_kan_547 on item_kanban_547 
(cod_empresa, cod_item);


