create table desc_dup_polimetri 
  (
    cod_empresa char(2) not null,
    num_docum char(10) not null,
    ies_evento char(1),
    ies_tip_docum char(2) not null,
    cod_portador decimal(4,0) not null,
    data_movto date not null,
    val_saldo decimal(15,2) not null, 
    num_lote integer
  );
revoke all on desc_dup_polimetri from "public";

create unique index ix_desc_dup_1 on desc_dup_polimetri 
    (cod_empresa,num_docum,ies_tip_docum);




