CREATE TABLE ped_itens_ethos(
   cod_empresa    char(02),
   num_pedido     integer,
   num_sequencia  integer,
   ship_date      date,
   primary key (cod_empresa, num_pedido, num_sequencia)
);



