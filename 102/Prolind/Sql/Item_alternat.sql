

create table item_alternat_1054 (
 id_registro     integer  not null,
 cod_empresa     char(02) not null,
 tip_docum       char(01) not null, --O=Ordem P=Pedido
 num_docum       char(10) not null,
 cod_item        char(15) not null,
 neces_item      decimal(10,3),
 item_alternat   char(15) not null,
 neces_alternat  decimal(10,3),
 usuario         char(08) not null,
 dat_troca       date not null,
 hor_troca       char(08) not null,
 PRIMARY KEY (id_registro)
);


create table audit_alternat_1054 (
 id_registro     integer  not null,
 texto           char(78)
);

create index audit_alternat_1054 on
audit_alternat_1054 (id_registro);


