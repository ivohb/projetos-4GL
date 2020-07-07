CREATE TABLE ar_aparas_885 (-- n�o copiar

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


CREATE TABLE umd_aparas_885(-- n�o copiar
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



CREATE TABLE cont_aparas_885(-- n�o copiar
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



CREATE TABLE etiq_aparas_885(-- n�o copiar
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


CREATE TABLE insp_trans_885(-- n�o copiar
	cod_empresa   char(2) NOT null,
	num_aviso_rec int NOT null,
	num_seq_ar    smallint NOT null,
	num_transac   int NOT null,
	cod_operacao  char(4),
	tip_movto     char(1),
	sequencia     int
) 


CREATE TABLE insumo_885(-- n�o copiar
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
    


create table cliente_885 -- n�o copiar
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


create table loc_entrega_885 -- n�o copiar
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
    nomprograma char(8),
    numpedido   integer
  );

create table cliente_msg_885 (
 dat_hor_proces      char(20),
 mensagem            char(100)
);


CREATE TABLE ordens_bob_885( -- n�o copiar
	numsequencia int ,
	codempresa char(2) ,
	numordem int ,
	codcliente char(15) ,
	nomcliente char(36) ,
	nomreduzido char(15) ,
	numpedido int ,
	numseqitem int ,
	tipopedido int ,
	coditem char(15) ,
	largura int ,
	diametro int ,
	tubete int ,
	tolentmenos decimal(10, 3) ,
	tolentmais decimal(10, 3) ,
	datentrega datetime ,
	qtdpedida decimal(10, 3) ,
	obspeditem char(80) ,
	numpedcli char(15) ,
	cancelada smallint ,
	statusregistro int,
	iesretrabalho  char(01)
) 

create index ix1_ordens_bob_885 on ordens_bob_885
 (codempresa, numordem)


create table oper_bob_885 ( -- n�o copiar
   codempresa    char(02),
   numordem      INTEGER,
   codoperac     char(10),
   numseqoperac  INTEGER,
   qtdhoras      decimal(12,5)
)

create index ix1_oper_bob_885 on oper_bob_885
 (codempresa, numordem)
 

create table apont_erro_885  -- n�o copiar
  (
    codempresa char(2),
    numsequencia integer,
    numordem integer,
    mensagem char(150)      --concatenar as mensagens
  );

create index ix_apont_erro_885 on apont_erro_885(codempresa);


CREATE TABLE man_apont_885(  -- n�o copiar
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
	
create index ix_man_apont_885 on man_apont_885(empresa);

CREATE TABLE apont_papel_885( -- n�o copiar
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

create unique index ix_apont_papel_885 on
 apont_papel_885(codempresa, numsequencia);

CREATE TABLE proces_apont_885(-- n�o copiar
  cod_empresa char(2) NOT null,
	ies_proces char(1) NOT null,
	primary key (cod_empresa)
);

create table apont_msg_885 ( -- n�o copiar
  cod_empresa      char(02),
  dat_hor_proces   datetime,
  mensagem         char(150),
  primary key(cod_empresa)
);

CREATE TABLE apont_trans_885( -- n�o copiar
	cod_empresa   char(2) NOT NULL,
	num_seq_apont int NOT NULL,
	num_transac   int NOT NULL,
	cod_tip_apon  char(1) NOT NULL, -- A=Apontamento B=Baixa do material
	cod_tip_movto char(1) NOT NULL,  -- N=Normal R=Revers�o
	ies_implant   char(01)
) ;

create index ix_apont_trans_885 on apont_trans_885(cod_empresa);

CREATE TABLE apont_sequencia_885( -- n�o copiar
	cod_empresa         char(2) NOT NULL,
	num_seq_apont       int NOT NULL,
	num_seq_apo_mestre  int NOT NULL,
	num_seq_apo_oper    int NOT NULL
);

create index ix_apont_sequencia_885 on apont_sequencia_885(cod_empresa); 

create table de_para_maq_885 (
cod_empresa       char(02),
cod_maq_trim      char(10),
ies_onduladeira   char(01),
cod_recur         char(05),
cod_compon        char(15),
cod_cent_trab     char(05),
cod_cent_cust     integer,
cod_arranjo       char(05),
cod_operac        char(05),
pct_refugo        decimal(5,2),
num_conta         char(15)
);

create unique index ix_de_para_maq_885
 on de_para_maq_885(cod_empresa, cod_maq_trim);

create table baixas_pendentes_885 ( -- n�o copiar
 cod_empresa   CHAR(02),
 num_sequencia integer,
 num_ordem     INTEGER,
 dat_producao  datetime,
 cod_compon    CHAR(15),
 qtd_baixar    decimal(10,3),
 mensagem      char(20),
 num_neces     INTEGER
);   

create index ix_bx_pendente on baixas_pendentes_885
(cod_empresa, num_sequencia, num_neces);

CREATE TABLE romaneio_885(-- n�o copiar
	numsequencia int ,
	codempresa char(6) ,
	identificador int ,
	tipooperacao int ,
	numromaneio int ,
	despachante char(30) ,
	coderpdesp char(30) ,
	tranportador char(30) ,
	coderptranspor char(15) ,
	codtipfrete char(1) ,
	codpercurso char(1) ,
	valfrete decimal(12, 2) ,
	codciddest char(5) ,
	codveiculo char(15) ,
	codtipcarga char(1) ,
	motorista char(30) ,
	coderpmotorista char(30) ,
	placaveiculo char(10) ,
	coderpveiculo char(30) ,
	horinicarreg datetime ,
	horfimcarreg datetime ,
	horexpedicao datetime ,
	pesobalanca decimal(10, 3) ,
	pesocarregado decimal(10, 3) ,
	statusproces int ,
	statusregistro char(1) ,
	usuario char(10) ,
	numlacre char(40) ,
	datageracao datetime ,
	ufveiculo char(2),
	pesoliquido decimal(10,3),
	qtdpalete   int default 0,
	pesopalete  decimal(10,3) default 0,
	pesoliqcarregado decimal(10,3),
	industrializacao char(01)
	
);

create index romaneio_885 on romaneio_885 (codempresa,
    numsequencia);


CREATE TABLE roma_item_885(-- n�o copiar
	numsequencia int ,
	codempresa char(2) ,
	identificador int ,
	tiporegistro int ,
	tipooperacao int ,
	numromaneio int ,
	numseqpai int ,
	coderpordem char(30) ,
	numpedido decimal(6, 0) ,
	numseqitem decimal(3, 0) ,
	coditem char(15) ,
	largura int ,
	diametro int ,
	tubete int ,
	comprimento int ,
	numlote char(15) ,
	pesoitem decimal(10, 3) ,
	reprogramacao int ,
	qtdvolumes int ,
	qtdpecas decimal(10, 3) ,
	tolmais decimal(10, 3) ,
	statusproces int ,
	statusregistro char(1) ,
	codciddest char(5) ,
	codseqentrega int ,
	pesobrutoitem decimal(10, 3) ,
	codcarteira char(2) ,
	qtdpacote decimal(10, 2) ,
	datageracao datetime  ,
	iespacote char(1),
	itemorigem  char(15),
	qtdpalete   int default 0,
	pesopalete  decimal(10,3) default 0,
	pesoliqcarregado decimal(10,3), 
	pesocarregado  decimal(10,3),
	pesoteoricoitem  decimal(10,3)
);


create index roma_item_885 on roma_item_885
    (codempresa,numsequencia);


create table roma_erro_885 -- n�o copiar
  (
    cod_empresa char(2) not null  ,
    num_sequencia integer,
    num_romaneio integer,
    den_erro char(50),
    dat_hor datetime 
  );

create index ix_roma_erro_885 on roma_erro_885(cod_empresa, num_sequencia)

CREATE TABLE solicit_fat_885(-- n�o copiar
	cod_empresa  char(2) NOT NULL,
	num_solicit  int NOT NULL,
	num_om       int NOT NULL,
	dat_atualiz  datetime NOT NULL,
	cod_status   char(1) NOT NULL,
	num_pedido   decimal(6, 0),
	val_frete    decimal(12, 2),
	num_lote_om  int,
	cod_cid_dest char(5),
	val_ger      decimal(12, 2)
);



create index ix_solicit_fat_885 on solicit_fat_885(cod_empresa, num_solicit)


CREATE TABLE nf_solicit_885(-- n�o copiar
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


create index ix_nf_solicit_885 on  nf_solicit_885(cod_empresa, num_romaneio)
 
create table audit_cotacao_885 (
 cod_empresa    CHAR (2),      
	cod_item       CHAR (15),     						
	cod_fornecedor CHAR (15),     						
	nom_usuario    CHAR (15),     						
	dat_proces     DATETIME ,     						
 den_texto      char (78)      							
);

create index ix_audit_cotacao_885 on audit_cotacao_885(cod_empresa, cod_item);


CREATE TABLE motivo_885(--  copiar
	cod_empresa char(2) NOT NULL,
	cod_motivo char(2) NOT NULL,
	den_motivo char(30) NOT NULL ,
	primary key(cod_empresa, cod_motivo)
) ;


create table apara_alternat_885 (
  cod_empresa    CHAR (2),      
	cod_item       CHAR (15),
	primary key (cod_empresa, cod_item)  						
);