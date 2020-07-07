drop table ethos_nprocop;

--- Ordens que deverão ser desconsideradas na alteração da
--- situação de 4 para 3.  Os  registros desta tabela  são 
--- excluidos atraves da trigger tr_nprocop

create table "informix".ethos_nprocop
  (
    cod_empresa      char(02),
    num_ordem        integer
  );

revoke all on "informix".ethos_nprocop from "public";

create unique index "informix".ix_eth_nprocop_1 on "informix".ethos_nprocop
    (cod_empresa, num_ordem) using btree;
