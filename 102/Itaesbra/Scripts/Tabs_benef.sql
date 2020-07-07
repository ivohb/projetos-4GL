
create table num_solic_970 (
 cod_empresa      char(02),
 prefixo          integer,
 num_solic        integer,
 dat_geracao      char(19)
);

create unique index ix_num_solic_970
on num_solic_970(cod_empresa, prefixo);

CREATE TABLE cliente_nf_970 (
   cod_cliente     CHAR(15),
   primary KEY(cod_cliente)
);
