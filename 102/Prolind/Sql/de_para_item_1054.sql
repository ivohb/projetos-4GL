create table de_para_item_1054 (
   cod_empresa       char(02) not null,
   cod_item_compon   char(15) not null,
   cod_item_sucata   char(15) not null,
   primary key(cod_empresa, cod_item_compon)
);
   