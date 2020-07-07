

create table peca_gemea_5054 
  (
    cod_empresa    char(2) not null ,
    cod_peca_princ char(15) not null ,
    cod_peca_gemea char(15) not null ,
    qtd_peca_gemea integer not null 
  );

create unique index ix_peca_gemea_5054 on 
    peca_gemea_5054 (cod_empresa,cod_peca_princ,cod_peca_gemea);

create table peca_ciclo_5054 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_operac char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    qtd_ciclo_peca integer not null ,
    qtd_peca_ciclo integer not null 
  );


create unique index peca_ciclo_5054 on 
  peca_ciclo_5054 (cod_empresa, cod_item, num_seq_operac)

create table ordens_export_5054
  (
    cod_empresa char(2),
    num_ordem integer
  );


create index ordens_export_5054 on ordens_export_5054 
    (cod_empresa,num_ordem);