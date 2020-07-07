drop table cliente_item_455;
create table cliente_item_455 (
 id_registro       integer,
 cod_cliente       char(15),
 cod_item          char(15),
 qtd_dias          integer,
 primary key(id_registro)
);

create unique index ix_cliente_item_455
 on cliente_item_455(cod_cliente, cod_item);
 