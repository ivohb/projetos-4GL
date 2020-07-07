create table cli_hayward 
  (
    cod_cliente char(15) not null ,
    nom_contato char(30) not null ,
    set_contato char(8),
    tel_contato char(15),
    fax_contato char(15),
    email_contato char(60),
    obs_contato char(60),
    dat_alter   date,
    nom_usuario char(8)
  );

create index ix_clihayw on cli_hayward (cod_cliente) 
    using btree ;


