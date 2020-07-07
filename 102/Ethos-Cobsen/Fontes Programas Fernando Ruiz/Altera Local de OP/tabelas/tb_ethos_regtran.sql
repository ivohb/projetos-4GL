--- Tabela provisória para transferir os estoque dos locais
--- 9002 para o número da OP por conta do  POL1186  não ter
--- considerado o local da OP e sim o local do cadastrdo do
--- item.  Nesta  tabela  fica o registro lógico  da tabela
--- estoque_trans que deverá ser transferido o estoque para
--- local correto com o número da op.

drop table ethos_regtran;

create table "informix".ethos_regtran
  (
    cod_empresa      char(02),
    reg_log          decimal(15,0)
    qtde_trans       decimal(17,6)
  );

revoke all on "informix".ethos_regtran from "public";

create unique index "informix".ix_eth_regtran_1 on "informix".ethos_regtran
    (cod_empresa, reg_log) using btree;


alter table ethos_regtran lock mode (row);