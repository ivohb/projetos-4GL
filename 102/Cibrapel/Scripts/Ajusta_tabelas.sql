drop table cliente_885;
drop table loc_entrega_885;

create table cliente_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);

create table cliente_885
  (
    numsequencia integer,
    codcliente char(15),
    nomcliente char(20),
    razaosocial char(99),
    cod_prefer decimal(1,0),
    codseguimento char(3),
    nomseguimento char(20),
    codrepresentante decimal(4,0),
    nomerepresentante char(36),
    tiporegistro char(1),
    statusregistro char(1),
    datatualizacao datetime,
    tipocliente char(1),
    tipopessoa char(1)
  );

create table loc_entrega_885
  (
    numsequencia integer,
    codcliente char(15),
    razaosocial char(99),
    nrloja char(15),
    nrlocalentrega char(15),
    numcnpj char(19),
    inscestatual char(16),
    email char(50),
    endereco char(120),
    bairro char(40),
    cep char(9),
    telefone1 char(20),
    telefone2 char(20),
    municipio char(50),
    uf char(2),
    codcidade char(5),
    distancia integer,
    tempoviagem integer,
    tiporegistro char(1),
    statusregistro char(1),
    datatualizacao datetime,
    nomprograma char(8)
  );

create table ordem_erro_885 (
  num_docum        char(15),
  mensagem         char(76),
  dat_hor_proces   datetime
);

alter table ordens_885 add ordcompon int;
alter table ordens_885 add qtdcompon decimal(10, 3);

drop table apont_trans_885;

CREATE TABLE apont_trans_885(
	cod_empresa   char(2) NOT NULL,
	num_seq_apont int NOT NULL,
	num_transac   int NOT NULL,
	cod_tip_apon  char(1) NOT NULL, -- A=Apontamento B=Baixa do material
	cod_tip_movto char(1) NOT NULL,  -- N=Normal R=Revers�o
	ies_implant   char(01)
) ;

CREATE TABLE apont_sequencia_885(
	cod_empresa         char(2) NOT NULL,
	num_seq_apont       int NOT NULL,
	num_seq_apo_mestre  int NOT NULL,
	num_seq_apo_oper    int NOT NULL
);

drop table apont_trim_885;
drop table apont_erro_885;

create table apont_msg_885 (
  cod_empresa      char(02),
  dat_hor_proces   datetime,
  mensagem         char(150),
  primary key (cod_empresa)
);

CREATE TABLE proces_apont_885(
  cod_empresa char(2) NOT null,
	ies_proces char(1) NOT null,
	primary key (cod_empresa)
);

CREATE TABLE apont_trim_885(
	numsequencia int ,
	codempresa char(2) ,
	numpedido int ,
	coditem char(15) ,
	numordem int ,
	codmaquina char(10) ,
	codturno char(5) ,
	inicio datetime ,
	fim datetime ,
	qtdprod decimal(10, 3) ,
	tipmovto   char(1) ,
	itemcompon char(15) ,
	ordcompon  int,
	qtdcompon  decimal(10, 3) ,
	tiporegistro char(1) ,
	statusregistro char(1) ,
	num_lote char(15) ,
	largura int ,
	diametro int ,
	tubete int ,
	comprimento int ,
	pesoteorico decimal(10, 3) ,
	consumorefugo decimal(10, 3) ,
	simula_id1 int ,
	simula_id2 int ,
	iesdevolucao char(1) ,
	usuario char(10) ,
	datageracao datetime default getdate(),
	tipoitem char(02)
);

CREATE TABLE consumo_trimbox_885(
	codempresa   char(02),          --obrigat�rio
	numsequencia integer,           --obrigat�rio
	coditem      char(15),          --obrigat�rio
	qtdconsumida decimal(10,3),     --obrigat�rio
	numlote      char(15),
	comprimento  integer,
	largura      integer,
	altura       integer,
	diametro     integer,
	datageracao  datetime,         --obrigat�rio
	coditemorig  char(15)          --obrigat�rio
);

create unique index ix_numsequencia on apont_trim_885
    (codempresa,numsequencia);

create table apont_erro_885
  (
    codempresa char(2),
    numsequencia integer,
    numordem integer,
    mensagem char(150)      --concatenar as mensagens
  );

drop table man_apont_hist_885;
drop table man_apont_885;

CREATE TABLE man_apont_885(
	    empresa                  CHAR(2),
	    num_seq_apont            INTEGER,
	    ordem_producao           INTEGER,
	    num_pedido               INTEGER,
	    num_seq_pedido           INTEGER,
	    item                     CHAR(15),
	    lote                     CHAR(15),
	    dat_ini_producao         datetime,
	    dat_fim_producao         datetime,
	    cod_recur                CHAR(5),
	    operacao                 CHAR(5),
	    sequencia_operacao       DECIMAL(3, 0),
	    cod_roteiro              char(15),
	    altern_roteiro           DECIMAL(2,0),
	    centro_trabalho          CHAR(5),
	    centro_custo             DECIMAL(4,0),
	    arranjo                  CHAR(5),
	    qtd_movto                DECIMAL(10, 3),
	    tip_movto                CHAR(1),
	    comprimento              INTEGER,
	    largura                  INTEGER,
	    altura                   INTEGER,
	    diametro                 INTEGER,
	    peso_teorico             DECIMAL(10, 3),
	    consumo_refugo           DECIMAL(17, 7),
	    local                    CHAR(10),
	    qtd_hor                  DECIMAL(11, 7),
	    matricula                CHAR(8),
	    sit_apont                CHAR(1),
	    turno                    CHAR(1),
	    hor_inicial              CHAR(08),
	    hor_fim                  CHAR(08),
	    refugo                   INTEGER,
	    parada                   CHAR(3),
	    unid_funcional           CHAR(10),
	    unid_produtiva           char(05),
	    dat_atualiz              datetime,
	    terminado                CHAR(1),
	    eqpto                    CHAR(15),
	    ferramenta               CHAR(15),
	    integr_min               CHAR(1),
	    nom_prog                 CHAR(8),
	    nom_usuario              CHAR(8),
	    num_versao               DECIMAL(2, 0),
	    versao_atual             CHAR(1),
	    cod_status               CHAR(1),
	    ies_devolucao            CHAR(1),
	    seq_leitura              INTEGER,
	    ies_chapa                CHAR(01),
	    bobinaconsumida          CHAR(15),
	    itemconsumido            CHAR(15)
);

drop TABLE apont_papel_885;
CREATE TABLE apont_papel_885(
	numsequencia     int ,
	numlote          char(30) ,
	numcorrida       int ,
	numconjugacao    int ,
	numtirada        int ,
	numposicao       int ,
	codmaquina       char(10) ,
	codjunbo         char(7) ,
	codjunbo2        char(7) ,
	numordem         int ,
	nomreduzcli      char(30) ,
	codcliente       char(15) ,
	coditem          char(15) ,
	codturma         char(2) ,
	largura          int ,
	diametro         int ,
	tubete           int ,
	comprimento      int ,
	pesobalanca      decimal(10, 3) ,
	estorno          smallint ,
	datproducao      datetime ,
	tempoproducao    int ,
	statusregistro   int ,
	codempresa       char(2) ,
	tipmovto         char(1) ,
	iesdevolucao     char(1) ,
	usuario          char(10),
	datageracao      datetime,
	datiniproducao   datetime,
	bobinaconsumida  char(15),
	itemconsumido    char(15)
);

drop table cons_insumo_885;
CREATE TABLE cons_insumo_885(
	numsequencia   int ,
	codcarga       char(15) ,
	codmaqpapel    char(10) ,
	inicarga       datetime ,
	fimcarga       datetime ,
	codempresa     char(2) ,
	codcorrida     int ,
	numordem       int ,
	coditem        char(25) ,
	qtdconsumida   decimal(10, 3) ,
	numlote        char(25) ,
	estorno        smallint ,
	statusregistro int ,
	datconsumo     datetime ,
	datregistro    datetime ,
	qtdrefugada    decimal(10, 3) ,
	iesrefugo      char(1) ,
	usuario        char(10) ,
	coditemrefugo  char(15) ,
	numloterefugo  char(15)
);


drop table insumo_885;

create table pol0653_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);

CREATE TABLE parametros_885(
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

create table pol0654_msg_885 (
  dat_hor_proces   datetime,
  mensagem         char(76)
);

alter table ordens_bob_885 add iesretrabalho  char(01);

create table oper_bob_885 (
   codempresa    char(02),
   numordem      INTEGER,
   codoperac     char(10),
   numseqoperac  INTEGER,
   qtdhoras      decimal(12,5)
);


alter table cotacao_preco_885 add id_registro    integer;
alter table cotacao_preco_885 add regiao_lagos   CHAR(01) default 'N';
alter table umd_aparas_885 alter column fat_conversao char(20) not null;
alter table cont_aparas_885 add num_transac int;
alter table ar_aparas_885 add ies_financeiro char(01);
alter table ar_aparas_885 add motorista      char(20);
alter table ar_aparas_885 add placa          char(08);


drop table parametros_885;

CREATE TABLE parametros_885(
	cod_empresa        char(2) NOT NULL,
	cod_item_sucata_dq char(15) NOT NULL,
	num_lote_sucata_dq char(15),
	cod_faturista      char(8) NOT NULL,
	pct_umid_pad       decimal(5, 2) NOT NULL,
	cod_item_refugo    char(15) NOT NULL,
	cod_item_sucata    char(15) NOT NULL,
	cod_item_retrab    char(15) NOT NULL,
	cod_apara_nobre    char(15),
	num_lote_refugo    char(15),
	num_lote_retrab    char(15),
	num_lote_sucata    char(15),
	num_Lote_nobre     char(15),
	num_lote_impurezas char(15),
	oper_sai_tp_refugo char(4),
	oper_ent_tp_refugo char(4),
	oper_entr_sucata   char(4),
	oper_sucateamento  char(4),
	cod_pacote_bob     char(3),
	dat_corte          datetime,
	primary key(cod_empresa)
);

insert into parametros_885 values
 ('02','item-div','lote-div','admlog',15,'010040007','010050001','959990001','010060001','RFG001','RET001','REF001','APN001','SUC001','DE','PARA','APOS',NULL,'05','01/02/2015');

insert into parametros_885 values
 ('01','item-div','lote-div','admlog',15,'010060001','010040006','858500001','010060001','APN001',null,null,null,null,'DE','PARA','APOS',NULL,NULL,'01/02/2015');


drop table nf_solicit_885;
CREATE TABLE nf_solicit_885(
	cod_empresa        char(2) NOT NULL,
	num_romaneio       int NOT NULL,
	num_solicit        int NOT NULL,
	dat_refer          datetime,
	cod_via_transporte decimal(2, 0),
	cod_entrega        decimal(4, 0) NOT NULL,
	ies_tip_solicit    char(1) NOT NULL,
	ies_lotes_geral    char(1) NOT NULL,
	cod_tip_carteira   char(2),
	num_lote_om        decimal(6, 0),
	num_om             decimal(6, 0) NOT NULL,
	val_frete          decimal(15, 2) NOT NULL,
	val_seguro         decimal(15, 2) NOT NULL,
	val_frete_ex       decimal(15, 2) NOT NULL,
	val_seguro_ex      decimal(15, 2) NOT NULL,
	pes_tot_bruto      decimal(13, 4) NOT NULL,
	ies_situacao       char(1) NOT NULL,
	num_sequencia      smallint NOT NULL,
	nom_usuario        char(8) NOT NULL,
	cod_transpor       char(15),
	num_placa          char(7),
	num_volume         decimal(7, 0),
	cod_cnd_pgto       decimal(3, 0),
	pes_tot_liquido    decimal(13, 4) NOT NULL,
	cod_embal_1        char(3),
	qtd_embal_1        decimal(6, 0)
); 


create table ad_mestre_885
  (
    cod_empresa char(2) not null ,
    num_ad decimal(6,0) not null ,
    cod_tip_despesa decimal(4,0) not null ,
    ser_nf char(3),
    ssr_nf decimal(2,0),
    num_nf char(7) not null ,
    dat_emis_nf date,
    dat_rec_nf date,
    cod_empresa_estab char(2),
    mes_ano_compet decimal(4,0),
    num_ord_forn decimal(6,0),
    cnd_pgto decimal(3,0),
    dat_venc date,
    cod_fornecedor char(15) not null ,
    cod_portador decimal(3,0),
    val_tot_nf decimal(15,2) not null ,
    val_saldo_ad decimal(15,2) not null ,
    cod_moeda decimal(2,0) not null ,
    set_aplicacao decimal(4,0),
    cod_lote_pgto decimal(2,0) not null ,
    observ char(40),
    cod_tip_ad decimal(2,0) not null ,
    ies_ap_autom char(1) not null ,
    ies_sup_cap char(1) not null ,
    ies_fatura char(1) not null ,
    ies_ad_cont char(1) not null ,
    num_lote_transf decimal(3,0) not null ,
    ies_dep_cred char(1) not null ,
    num_lote_pat decimal(3,0),
    cod_empresa_orig char(2) not null ,
    ies_situacao char(01) not null,            
    primary key (cod_empresa,num_ad) 
  );
    

create table ad_ap_885
  (
    cod_empresa char(2) not null ,
    num_ad decimal(6,0) not null ,
    num_ap decimal(6,0) not null ,
    num_lote_transf decimal(3,0) not null 
  );


create table ap_885
  (
    cod_empresa char(2) not null ,
    num_ap decimal(6,0) not null ,
    num_versao decimal(2,0) not null ,
    ies_versao_atual char(1) not null ,
    num_parcela decimal(3,0) not null ,
    cod_portador decimal(3,0),
    cod_bco_pagador decimal(3,0),
    num_conta_banc char(15),
    cod_fornecedor char(15) not null ,
    cod_banco_for decimal(4,0),
    num_agencia_for char(6),
    num_conta_bco_for char(15),
    num_nf char(7) not null ,
    num_duplicata char(10),
    num_bl_awb char(30),
    compl_docum char(10),
    val_nom_ap decimal(15,2) not null ,
    val_ap_dat_pgto decimal(15,2) not null ,
    cod_moeda decimal(2,0) not null ,
    val_jur_dia decimal(15,2) not null ,
    taxa_juros decimal(12,8),
    cod_formula decimal(2,0),
    dat_emis date not null ,
    dat_vencto_s_desc date not null ,
    dat_vencto_c_desc date,
    val_desc decimal(15,2),
    dat_pgto date,
    dat_proposta date,
    cod_lote_pgto decimal(2,0) not null ,
    num_docum_pgto decimal(8,0),
    ies_lib_pgto_cap char(1) not null ,
    ies_lib_pgto_sup char(1) not null ,
    ies_baixada char(1) not null ,
    ies_docum_pgto char(1),
    ies_ap_impressa char(1) not null ,
    ies_ap_contab char(1) not null ,
    num_lote_transf decimal(3,0) not null ,
    ies_dep_cred char(1) not null ,
    data_receb date,
    num_lote_rem_escr integer not null ,
    num_lote_ret_escr integer not null ,
    dat_rem date,
    dat_ret date,
    status_rem smallint not null ,
    ies_form_pgto_escr char(3),
    primary key (cod_empresa,num_ap,num_versao)  
  );


create table ap_tip_desp_885 
  (
    cod_empresa char(2) not null ,
    num_ap decimal(6,0) not null ,
    conta_forn_trans char(23) not null ,
    cod_hist decimal(3,0),
    cod_tip_despesa decimal(4,0) not null ,
    val_tip_despesa decimal(15,2) not null ,
    primary key (cod_empresa,num_ap,cod_tip_despesa) 
  );


create table audit_cap_885 
  (
    cod_empresa char(2) not null ,
    ies_tabela char(2) not null ,
    nom_usuario char(8) not null ,
    num_ad_ap decimal(6,0) not null ,
    ies_ad_ap char(1) not null ,
    num_nf char(7) not null ,
    ser_nf char(3),
    ssr_nf decimal(2,0),
    cod_fornecedor char(15) not null ,
    ies_manut char(1) not null ,
    num_seq decimal(3,0) not null ,
    desc_manut char(200),
    data_manut date not null ,
    hora_manut char(8) not null ,
    num_lote_transf decimal(3,0) not null ,
    primary key (cod_empresa,num_ad_ap,ies_ad_ap,num_seq)  
  );



create table lanc_cont_cap_885 
  (
    cod_empresa char(2) not null ,
    num_ad_ap decimal(6,0) not null ,
    ies_ad_ap char(1) not null ,
    num_seq decimal(3,0) not null ,
    cod_tip_desp_val decimal(4,0),
    ies_desp_val char(1),
    ies_man_aut char(1) not null ,
    ies_tipo_lanc char(1) not null ,
    num_conta_cont char(23) not null ,
    val_lanc decimal(15,2) not null ,
    tex_hist_lanc char(50),
    ies_cnd_pgto char(1) not null ,
    num_lote_lanc decimal(3,0) not null ,
    ies_liberad_contab char(1) not null ,
    num_lote_transf decimal(3,0) not null ,
    dat_lanc date not null ,
    primary key (cod_empresa,num_ad_ap,ies_ad_ap,num_seq) 
  );


create table baixas_pendentes_885 (
 cod_empresa   CHAR(02),
 num_sequencia integer,
 num_ordem     INTEGER,
 dat_producao  datetime,
 cod_compon    CHAR(15),
 qtd_baixar    decimal(10,3),
 mensagem      char(20)
);   

create table trans_consu_885 (
  cod_empresa     char(02),
  num_seq_cons    INTEGER,
  num_transac     INTEGER,
  tip_operacao    char(01),
  tip_movto       char(01)
);

alter table roma_item_885 add itemorigem char(15);


create table baixa_aparas_885 (
  cod_empresa      char(02),
  dat_movto        datetime,
  cod_item         char(15),
  qtd_bx_trim      decimal(10,3),
  qtd_bx_logix     decimal(10,3),
  primary key(cod_empresa,dat_movto,cod_item)
);

alter table nfe_x_nff_885 add dat_atualiz  datetime;
 alter table nfe_x_nff_885 add	usuario      char(08);
 