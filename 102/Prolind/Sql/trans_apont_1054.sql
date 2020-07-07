create table trans_apont_1054 (
 cod_empresa    char(02) not null,
 num_processo   integer not null,
 num_transac    integer not null,
 num_seq_apont  integer not null,
 cod_operacao   char(01) not null
);

create index trans_apont_1054 on trans_apont_1054
(cod_empresa, num_processo);
