create table nf_retorno_cairu 
  (
    cod_empresa char(2) not null,
    num_aviso_rec decimal(6,0) not null,
    num_nff1 decimal(6),
    num_nff2 decimal(6),
    num_nff3 decimal(6),
    num_nff4 decimal(6),
    num_nff5 decimal(6)
  );

create unique index ix_nfcairu_1 on nf_retorno_cairu (cod_empresa,
    num_aviso_rec);




