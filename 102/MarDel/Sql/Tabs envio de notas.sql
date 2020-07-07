create table fornec_nf_5054 (
 cod_fornecedor char(15)
)

create unique index fornec_nf_5054 on
fornec_nf_5054(cod_fornecedor);

create table cliente_nf_5054 (
 cod_cliente char(15)
)

create unique index cliente_nf_5054 on
cliente_nf_5054(cod_cliente);



create table item_cliente_5054 (
 id_registro   int identity(1,1) primary key,
 cod_empresa char(02),
 cod_cliente char(15),
 cod_item    char(15),
 tip_item    char(01)
)

create unique index item_cliente_5054 on
item_cliente_5054(cod_empresa, cod_cliente, cod_item);


create table tipo_nf_5054 (
 id_registro   int identity(1,1) primary key,
 tipo_logix    char(03),
 tipo_fiat     char(02),
 entrada_saida char(01)
)

create unique index tipo_nf_5054_1 on
tipo_nf_5054(tipo_logix, entrada_saida);

create unique index tipo_nf_5054_2 on
tipo_nf_5054(tipo_logix, entrada_saida, tipo_fiat);


create table nota_diverg_5054 (
   datproces   char(20),
   erro        char(120)
);

create index nota_diverg_5054 on nota_diverg_5054(datproces);

create table nota_exportada_5054 (
   cod_empresa        char(02),
   ar_transac         integer,
   ies_nota           char(01),
   primary key(cod_empresa, ar_transac, ies_nota)
);
