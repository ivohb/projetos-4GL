
create table ordem_compra_drummer
  (
  empresa          char(2) not null,
	item             char(30) not null,
	dat_entrega_prev date not null,
	dat_abertura_oc  date not null,
	qtd_planejada    decimal(14,4) not null ,
  num_oc_drummer   char(30) not null,
	num_oc_logix     DECIMAL(9,0),
	dat_emissao      date,
	status_import    char(01),
	erro_import      char(150)
);

create unique index ix_ord_cpr_1 on ordem_compra_drummer
    (empresa,num_oc_drummer) ;

