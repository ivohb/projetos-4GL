drop table embalagem_padrao_405;
create table embalagem_padrao_405
(id_embal              integer,
 cod_cliente           char(15),
 cod_item_embal        char(15),
 den_item_embal        varchar(50),
 primary key(id_embal)
);

create unique index ix_embalagem_padrao_405 on 
embalagem_padrao_405(cod_cliente, cod_item_embal);

drop table embalagem_compon_405;
create table embalagem_compon_405
(id_embal              integer,
 cod_item_compon       char(15),
 qtd_necess            decimal(10,3)
);


create index ix_embal_405 on 
embalagem_compon_405(id_embal, cod_item_compon);

drop table item_embal_405;
create table item_embal_405 (
 id_registro           integer,
 cod_cliente           char(15),
 cod_item              char(15),
 cod_item_embal        char(15),
 qtd_item_embal        decimal(10,3),
 primary key(id_registro)
);

create unique index ix_item_embal_405 on 
item_embal_405(cod_cliente, cod_item);

-- tempor�rias:

   CREATE   TABLE fat_pre_periodo_405 (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
   );

   CREATE INDEX ix_fat_pre_periodo_405 ON fat_pre_periodo_405
    (num_pedido, cod_item);

   CREATE TABLE fat_real_periodo_405 (
       num_pedido        DECIMAL(6,0),
       num_pedido_cli    CHAR(30),
       num_sequencia     DECIMAL(3,0),
       cod_item          CHAR(15),
       prz_entrega       DATE,
       qtd_faturar       DECIMAL(10,3),
       cod_item_embal    CHAR(15),
       qtd_item_embal    DECIMAL(10,3),
       qtd_embalagem     INTEGER
   );
         
   CREATE INDEX ix_fat_real_periodo_405 ON fat_real_periodo_405
    (num_pedido, cod_item);