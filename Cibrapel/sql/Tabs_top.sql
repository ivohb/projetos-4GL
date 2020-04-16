CREATE TABLE ar_aparas_885 (-- não copiar

cod_empresa    varchar(2) NOT null ,
num_aviso_rec  integer  NOT null,
cod_status     varchar(1) NOT null,
ies_autorizado varchar(1) NOT null,
tip_frete      varchar(1),
reg_lagos      varchar(1),
val_pedagio    decimal(10,2),
ies_financeiro char(01),             -- A = gerou adiantamento  T = gerou titulos 
motorista      char(20),
placa          char(08)
);


create unique index ar_aparas_885 on ar_aparas_885 
    (cod_empresa,num_aviso_rec);

CREATE TABLE parametros_885( --copiar
	cod_empresa        char(2),
	cod_item_sucata_dq char(15),
	num_lote_sucata_dq char(15), 
	cod_faturista      char(8),
	pct_umid_pad       decimal(5, 2),
	cod_item_refugo    char(15),
	cod_item_sucata    char(15),
	cod_item_retrab    char(15),
	num_lote_refugo    char(15), 
	num_lote_retrab    char(15), 
	num_lote_sucata    char(15), 
	oper_sai_tp_refugo char(4),
	oper_ent_tp_refugo char(4),
	oper_entr_sucata   char(4),
	oper_sucateamento  char(4),
	cod_pacote_bob     char(3),
	dat_corte          datetime,
	tol_bx_aparas      decimal(10,3),
	primary key(cod_empresa)
) 


CREATE TABLE umd_aparas_885(-- não copiar
	cod_empresa     char(2) NOT null,
	num_aviso_rec   int NOT null,
	num_seq_ar      smallint NOT null,
	pct_umd_med     decimal(4, 2) NOT null,
	ies_consid      char(1) NOT null,
	cod_motivo      char(2),
	fat_conversao   char(10) NOT null,
	cod_item_tr     char(15),
	pct_desc        decimal(4, 2),
	preco_cotacao   decimal(17, 6) NOT null,
	ies_troca_preco char(1) NOT null,
	preco_item_tr   decimal(17, 6)
);

create unique index umd_aparas_885 on umd_aparas_885 
    (cod_empresa,num_aviso_rec,num_seq_ar);



CREATE TABLE cont_aparas_885(-- não copiar
	cod_empresa     char(2) NOT null,
	num_aviso_rec   int NOT null,
	num_seq_ar      smallint NOT null,
	num_lote        char(15) NOT null,
	qtd_fardo       smallint NOT null,
	qtd_contagem    decimal(12, 3) NOT null,
	qtd_calculada   decimal(12, 3) NOT null,
	pre_calculado   decimal(17, 6) NOT null,
	qtd_liber       decimal(12, 3) NOT null,
	qtd_liber_excep decimal(12, 3) NOT null,
	qtd_rejeit      decimal(12, 3) NOT null,
	qtd_liber_calc  decimal(12, 3) NOT null,
	qtd_excep_calc  decimal(12, 3) NOT null,
	qtd_rejeit_calc decimal(12, 3) NOT null,
	dat_inspecao    datetime,
	num_transac     integer
) ;


create unique index cont_aparas_885 on cont_aparas_885 
    (cod_empresa,num_aviso_rec,num_seq_ar,num_lote);



CREATE TABLE etiq_aparas_885(-- não copiar
	cod_empresa    char(2) NOT null,
	num_registro   int NOT null,
	num_nf         int NOT null,
	num_aviso_rec  int NOT null,
	num_seq_ar     smallint NOT null,
	dat_entrada    datetime NOT null,
	cod_fornecedor char(15) NOT null,
	nom_fornecedor char(50) NOT null,
	cod_item       char(15) NOT null,
	num_lote       char(15) NOT null,
	qtd_fardo      smallint NOT null,
	tip_movto      char(1) NOT null,
	cod_status     smallint NOT null
);


CREATE TABLE user_liber_ar_885(--  copiar
	cod_usuario char(8) NOT null,
	primary key(cod_usuario)
) 


CREATE TABLE insp_trans_885(-- não copiar
	cod_empresa   char(2) NOT null,
	num_aviso_rec int NOT null,
	num_seq_ar    smallint NOT null,
	num_transac   int NOT null,
	cod_operacao  char(4),
	tip_movto     char(1),
	sequencia     int
) 


CREATE TABLE insumo_885(-- não copiar
	num_sequencia  int ,
	cod_empresa    char(2) ,
	num_lote       char(15) ,
	cod_item       char(15) ,
	largura        int ,
	diametro       int ,
	tubete         int ,
	num_nf         char(7) ,
	num_ar         decimal(6, 0) ,
	cod_fornecedor char(15) ,
	nom_fornecedor char(36) ,
	dat_emis_nf    datetime ,
	dat_movto      datetime ,
	qtd_movto      decimal(12, 3) ,
	val_movto      decimal(17, 2) ,
	qtd_fardos     decimal(8, 2) ,
	tip_movto      char(1) ,
	cod_status     int ,
	ies_bobina     char(1) ,
	num_seq_ar     int ,
	dat_entrada_nf datetime,
	dat_geracao    char(19),
	tipestoque    char(01)
);

create table familia_insumo_885 --  copiar
  (
    cod_empresa char(2) not NULL ,
    cod_familia char(3) not  NULL,
    ies_apara   char(1) not  NULL,
    ies_bobina  char(1) not  NULL,
    ies_canudo  char(1) not  NULL
  );

create unique index familia_insumo_885 on familia_insumo_885 
    (cod_empresa,cod_familia);



 create table cotacao_preco_885 --  copiar
  (
    cod_empresa    char(2) not  null,
    cod_item       char(15) not null ,
    cod_fornecedor char(15) not  null,
    pre_unit_fob   decimal(17,6) not null ,
    pre_unit_cif   decimal(17,6),
    cnd_pgto       decimal(3,0) not null,
    dat_val_ini    datetime  not null,
    dat_val_fim    datetime  not null,
    id_registro    integer,         
    regiao_lagos   CHAR(01)      
    
  );

create index cotacao_preco_885_x1 on cotacao_preco_885 
    (cod_empresa,cod_item,cod_fornecedor);
    
create unique index cotacao_preco_ix on cotacao_preco_885 
    (cod_empresa,cod_fornecedor,cod_item);
    

