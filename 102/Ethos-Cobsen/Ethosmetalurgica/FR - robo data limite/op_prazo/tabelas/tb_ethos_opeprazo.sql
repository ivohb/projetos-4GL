drop table ethos_opeprazo;

--- PRAZO DE ENTREGA POR OPERAÇÃO

create table "informix".ethos_opeprazo
  (
    cod_empresa          char(02),
    cod_item_princ       char(15),
    num_pedido           decimal(6,0),
    num_seq_pedido       decimal(10,0),
    num_ordem            decimal(9,0),
    dat_entrega_princ    date,
    num_ordem_filho      decimal(9,0),
    cod_item             char(15),
    nivel_compon_ori     char(02),
    nivel_componente     char(02),
    cod_componente       char(15),
    num_seq_operac       decimal(3,0),
    cod_operac           char(7),
    den_operac           char(30),
    parametro            char(10),
    dias_execucao        decimal(3,0),
    data_calc_limite     date,
    prazo_operacao       date,
    prog_calc_prazo      char(15),
    data_processamento   date
  );

revoke all on "informix".ethos_opeprazo from "public";

create index "informix".ix_eth_opepra_1 on "informix".ethos_opeprazo
    (cod_empresa, cod_item_princ, num_pedido, num_seq_pedido,
     num_ordem, nivel_componente, cod_componente, 
     num_seq_operac, cod_operac) using btree;

create index "informix".ix_eth_opepra_2 on "informix".ethos_opeprazo
    (cod_empresa, cod_item_princ, num_pedido, num_seq_pedido,
     num_ordem, nivel_componente, cod_componente, 
     num_seq_operac, cod_operac, dias_execucao) using btree;

create index "informix".ix_eth_opepra_3 on "informix".ethos_opeprazo
    (cod_empresa, num_ordem, dat_entrega_princ) using btree;

create index "informix".ix_eth_opepra_4 on "informix".ethos_opeprazo
    (cod_empresa, num_ordem_filho) using btree;

create index "informix".ix_eth_opepra_5 on "informix".ethos_opeprazo
    (cod_empresa, num_pedido) using btree;

create index "informix".ix_eth_opepra_6 on "informix".ethos_opeprazo
    (cod_empresa, dat_entrega_princ) using btree;

create index "informix".ix_eth_opepra_7 on "informix".ethos_opeprazo
    (cod_empresa, num_ordem, dat_entrega_princ,
     cod_item_princ, num_pedido, num_seq_pedido) using btree;

create index "informix".ix_eth_opepra_8 on "informix".ethos_opeprazo
    (cod_empresa, cod_item_princ, num_pedido, 
     num_seq_pedido, nivel_componente, 
     num_ordem_filho, num_seq_operac) using btree;

create index "informix".ix_eth_opepra_9 on "informix".ethos_opeprazo
    (cod_empresa, data_processamento, cod_item_princ, num_pedido, 
     num_seq_pedido, nivel_componente, 
     num_ordem_filho, num_seq_operac) using btree;

create index "informix".ix_eth_opepra_10 on "informix".ethos_opeprazo
    (cod_empresa, prog_calc_prazo, num_ordem, 
     dat_entrega_princ, cod_operac) using btree;

