drop table erro_critico_1345;
create table erro_critico_1345 (
  cod_empresa       char(02),
  dat_proces        char(19),
  erro              char(150)
);

create index ix_erro_critico_1345
 on erro_critico_1345(cod_empresa);
 
 