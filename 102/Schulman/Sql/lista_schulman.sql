
create table lista_schulman( 
cod_empresa	          char(02),
num_Lista	            integer,
den_lista	            varchar(30),
dat_val_ini	          date,
dat_val_fim	          date,
bloqueia_pedido	      char(01),
bloqueia_faturamento  char(01),
cod_moeda	            integer,
unid_medida	          char(03),
cod_cliente	          char(15),
area_e_linha	        char(08),
cod_item	            char(15),
preco_unit	          char(20),
preco_ant             char(20),
preco_minimo          char(20),
nom_arquivo           varchar(80),
dat_carga             date
);

create index ix1_lista_schulman on
lista_schulman(cod_empresa, num_Lista);

create index ix2_lista_schulman on
lista_schulman(cod_empresa, nom_arquivo);


