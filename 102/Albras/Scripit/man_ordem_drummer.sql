drop table man_ordem_drummer;
create table man_ordem_drummer 
  (
    empresa        char(2) not null ,
    ordem_producao char(30),
    item_pai       char(30) not null ,
    item           char(30) not null ,
    dat_recebto    date not null ,
    qtd_ordem      decimal(12,2) not null ,
    ordem_mps      char(30) not null ,
    status_ordem   char(1) not null ,
    status_import  char(1),
    dat_liberacao  date not null ,
    qtd_pecas_boas decimal(12,2) not null ,
    docum          char(10),
    num_projeto    char(10),
	  id_ordem_mps   decimal(17,0)
  );

create unique index ix_man_ord_drum_1 on man_ordem_drummer 
    (empresa,ordem_mps) ;



create table ordens_x_ordens (
   cod_empresa     char(02),
   op_drummer      char(30),
   op_logix        integer,
   dat_proces      char(10)
);

create index ix_ordens_x_ordens_1 on
ordens_x_ordens(cod_empresa, op_drummer);
