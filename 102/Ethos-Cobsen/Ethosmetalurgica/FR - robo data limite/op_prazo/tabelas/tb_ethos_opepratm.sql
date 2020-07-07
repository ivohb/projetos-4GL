drop table ethos_opepratm;

--- PRAZO DE ENTREGA POR OPERAÇÃO - TEMPORARIA

create table "informix".ethos_opepratm
  (
    cod_empresa          char(02),
    cod_item_princ       char(15),
    num_pedido           decimal(6,0),
    num_seq_pedido       decimal(10,0),
    num_ordem            decimal(9,0),
    nivel_componente     char(02),
    num_seq_operac       decimal(3,0),
    cod_operac           char(7),
    prazo_operacao       date
  );

revoke all on "informix".ethos_opepratm from "public";

create index "informix".ix_eth_opeptm_1 on "informix".ethos_opepratm
    (cod_empresa, cod_item_princ, num_pedido, num_seq_pedido,
     num_ordem, nivel_componente, 
     num_seq_operac, cod_operac, prazo_operacao) using btree;

