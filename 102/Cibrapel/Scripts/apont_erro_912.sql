create table apont_erro_912 (
  cod_empresa     char(02),
  seq_reg_mestre  integer,
  erro            char(250)
);

create index ix_erro on apont_erro_912
 (cod_empresa, seq_reg_mestre);
 