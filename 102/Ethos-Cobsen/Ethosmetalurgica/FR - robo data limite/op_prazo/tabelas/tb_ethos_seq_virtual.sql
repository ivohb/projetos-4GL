--- sequencia das Operacoes para data-las

drop table ethos_seq_virtual;

create table "informix".ethos_seq_virtual
  (
    cod_empresa          char(02),
    num_pedido           decimal(6,0),
    num_seq_pedido       decimal(10,0),
    num_ordem            decimal(9,0),
    num_seq_operac       decimal(3,0),
    cod_operac           char(7)
  );

revoke all on "informix".ethos_seq_virtual from "public";


create index "informix".ix_eth_seq_vir_1 on "informix".ethos_seq_virtual
    (cod_empresa, num_ordem) using btree;

create index "informix".ix_eth_seq_vir_2 on "informix".ethos_seq_virtual
    (cod_empresa, num_pedido, num_seq_pedido, num_ordem) using btree;
