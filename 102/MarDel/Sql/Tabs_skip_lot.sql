create table grupo_skip_lot_5054 (
 cod_grupo         char(03) not null,
 descricao         char(30) not null,
 qtd_entrada       decimal(15,3) not null,
 primary key (cod_grupo)
);

 
create table fornec_item_5054 (
 cod_fornecedor    char(15) not null,
 cod_item          char(15) not null,
 cod_grupo         char(03) not null,
 primary key (cod_fornecedor,cod_item)
);

