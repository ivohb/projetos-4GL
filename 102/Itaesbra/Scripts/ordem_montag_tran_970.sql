create table ordem_montag_tran_970 (
cod_empresa          char(2),
num_om               decimal(6,0),
num_pedido           decimal(6,0),
num_seq_item         decimal(5,0),
cod_item             char(15),
num_nf               decimal(8,0),
ser_nf               char(3),
ssr_nf               decimal(2,0),
ies_especie_nf       char(3),
num_seq_nf           smallint,
qtd_devolvida        decimal(15,3),
pre_unit             decimal(17,6),
cod_nat_oper         integer,
num_transacao        serial,
primary key (cod_empresa, num_transacao)
);

insert into ordem_montag_tran_970 select * from ordem_montag_tran

