--- tabela dos pedidos/sequencia incluidos para o programa
--- 'atupreco' ter a data desta inclyusão. 

drop table ethosi_ped_inclus;

create table "informix".ethosi_ped_inclus
  (
       cod_empresa          char(02),
       num_pedido           decimal(10,0),
       num_sequencia        decimal(9,0),
       data_inclusão        date,
       usuario              char(15)
);

revoke all on "informix".ethosi_ped_inclus from "public";

create unique index "informix".ix_ethi_ped_incl_1 
    on "informix".ethosi_ped_inclus
    (cod_empresa, num_pedido, num_sequencia
    ) using btree;

alter table ethosi_ped_inclus lock mode (row);
