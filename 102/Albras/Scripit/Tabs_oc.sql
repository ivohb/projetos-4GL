
create table ordem_compra_drummer
  (
  empresa          char(2) not null ,
	item             char(30) not null ,
	dat_entrega_prev date not null,
	qtd_planejada    decimal(14,4) not null ,
  num_oc_drummer   char(30),
	num_oc_logix     DECIMAL(9,0)
);

create unique index ix_ord_cpr_1 on ordem_compra_drummer
    (empresa,num_oc_drummer) ;


create table erro_oc_304 (
 cod_empresa   char(02),
 dat_proces    date,
 hor_proces    char(08),
 mensagem      char(150)
);

create index ix_erro_oc_304_1 on erro_oc_304
    (cod_empresa);



