create table processo_apont_1054 (
 cod_empresa    char(02) not null,
 usuario        char(08) not null,
 dat_processo   char(20) not null,
 num_processo   integer not null,
 ies_estornado  char(01) not null,
 num_ordem      integer,
 qtd_boas       decimal(10,3),
 qtd_refug      decimal(10,3),
 primary key (cod_empresa, usuario, dat_processo)
);


create table trans_apont_1054 (
 cod_empresa    char(02) not null,
 num_processo   integer not null,
 num_transac    integer not null,
 num_seq_apont  integer not null,
 cod_operacao   char(01) not null
);

create index trans_apont_1054 on trans_apont_1054
(cod_empresa, num_processo);



create table estorno_erro_1054 
  (
    cod_empresa  char(02) not null ,
    usuario      char(08) not null,
    dat_processo char(20) not null ,
    num_processo integer not null ,
    den_critica  char(80)
  );



