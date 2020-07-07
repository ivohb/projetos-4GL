
CREATE TABLE empresas_885(
	cod_emp_gerencial char(2) NOT ,
	cod_emp_oficial char(8) NOT ,
	tip_trim char(1) NOT 
) ;

CREATE TABLE parametros_885(
	cod_empresa        char(2) NOT null,
	cod_oper_ent_valor char(8) NOT null,
	cod_oper_ent_vrqtd char(8) NOT null,
	cod_faturista      char(8) NOT null,
	pct_umid_pad       decimal(5,2) NOT null,
	cod_item_refugo    char(15) NOT null,
	cod_item_sucata    char(15) NOT null,
	cod_item_retrab    char(15), 
	cod_apara_nobre    char(15), 
	num_lote_refugo    char(15), 
	num_lote_retrab    char(15), 
	num_lote_sucata    char(15), 
	num_Lote_nobre     char(15),
	num_lote_impurezas char(15),
	oper_sai_tp_refugo char(4), 
	oper_ent_tp_refugo char(4), 
	cod_pacote_bob     char(3),
	ies_versao_5       char(15),
	cod_item_sobras    char(15), 
	num_lote_sobras    char(15), 
	dat_corte          datetime,
  oper_entr_sucata   char(04),
  oper_sai_apto_refug char(04),
	primary key(cod_empresa)
);



create table par_item_885 (
cod_empresa char(2) not  ,
cod_clas_item integer not  ,
ies_tip_item char(1) not  ,
ies_ctr_estoque char(1) not  ,
ies_ctr_lote char(1) not  ,
ies_tem_inspecao char(1) not  ,
ies_mrp_apont char(1) not  ,
ies_sofre_baixa char(1) not  ,
num_casa_dec decimal(1,0) not  ,
plano_neces decimal(1,0) not  ,
cod_local_estoq char(10),
cod_local_insp char(10),
cod_local_receb char(10) not  ,
cod_local_prod char(10) not  ,
qtd_prog_minima decimal(10,3) not  ,
qtd_prog_maxima decimal(10,3) not  ,
qtd_prog_multipla decimal(10,3) not  ,
qtd_prog_fixa decimal(10,3) not  ,
qtd_estoq_seg decimal(10,3) not  ,
fat_conver decimal(11,6) not  ,
pct_ipi decimal(6,3) not  ,
pct_refug decimal(6,3) not  ,
cod_cla_fisc char(10) not  ,
tempo_ressup integer not  ,
cod_familia char(3) not  ,
cod_roteiro char(15),
gru_ctr_estoq decimal(2,0),
qtd_dias_min_ord decimal(3,0) not ,
cod_horizon decimal(2,0) not ,
num_altern_roteiro decimal(2,0),
cod_lin_prod decimal(2,0) not ,
cod_lin_recei decimal(2,0) not ,
cod_seg_merc decimal(2,0) not ,
cod_cla_uso decimal(2,0) not ,
ies_forca_apont char(1) not ,
ies_abert_liber char(1) not ,
ies_baixa_comp char(1) not ,
ies_lista_ordem char(1) not ,
ies_lista_roteiro char(1) not ,
ies_apontamento char(1) not ,
ies_tip_apont char(1) not ,
ies_apont_aut char(1) not 

);


create unique index par_item_885 on par_item_885 
    (cod_empresa,cod_clas_item);



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


CREATE TABLE ordens_885(
	numsequencia int ,
	codempresa char(2) ,
	numordem int ,
	statusordem char(1) ,
	numpedido int ,
	numseqitem int ,
	numpedidocli char(25) ,
	tipopedido int ,
	coditem char(15) ,
	codcliente char(15) ,
	datentrega datetime ,
	qtdpedida decimal(10, 3) ,
	obspeditem char(80) ,
	numloja char(15) ,
	numlocent char(15) ,
	datmaxent datetime ,
	tolentmenos decimal(10, 3) ,
	tolentmais decimal(10, 3) ,
	composicao char(15) ,
	largura int ,
	comprimento int ,
	resinainterna int ,
	resinaexterna int ,
	vinco1 int ,
	vinco2 int ,
	vinco3 int ,
	vinco4 int ,
	vinco5 int ,
	vinco6 int ,
	vinco7 int ,
	vinco8 int ,
	rfilado int ,
	pcporpacote int ,
	pcporpalete int ,
	palete char(30) ,
	exigelaudo char(1) ,
	gramatura int ,
	coluna decimal(10, 3) ,
	mullen decimal(10, 3) ,
	crush decimal(10, 3) ,
	cobbint decimal(10, 3) ,
	cobbext decimal(10, 3) ,
	espessura decimal(10, 3) ,
	tiporegistro char(1) ,
	statusregistro char(1) ,
	obspedido1 char(76) ,
	obspedido2 char(76) ,
	obspedido3 char(76) ,
	obspedido4 char(76) ,
	obspedido5 char(76) ,
	pre_unit decimal(17, 6) 
);


CREATE TABLE cli_tolerancia_885(
	cod_empresa char(2) NOT ,
	cod_cliente char(15) NOT ,
	pct_tolerancia_min decimal(6, 2) ,
	pct_tolerancia_max decimal(6, 2) 
) ;


create unique index ix_cli_tolera_885 on cli_tolerancia_885 
    (cod_empresa,cod_cliente);


create table carteira_cli_885 
  (
    cod_empresa char(2) not  ,
    cod_tip_carteira char(2) not  ,
    cod_cliente char(15),
    num_list_preco decimal(4,0)
  );

create unique index ix_carteira_cli_885 on carteira_cli_885 
    (cod_empresa,cod_tip_carteira,cod_cliente);



create table grupo_produto_885 
  (
    cod_empresa char(2) not  ,
    cod_grupo char(3) not  ,
    cod_tipo char(1) not  
  );

create unique index grupo_produto_885 on grupo_produto_885 
    (cod_empresa,cod_grupo);


create table largura_chapa_885 
  (
    cod_empresa char(2),
    cod_item char(15),
    largura integer
  );

create unique index ix_larg_ch_885 on largura_chapa_885 
    (cod_empresa,cod_item);
    

create table familia_insumo_885 
  (
    cod_empresa char(2) not  ,
    cod_familia char(3) not  ,
    ies_apara char(1) not  ,
    ies_bobina char(1)
  );

create unique index familia_insumo_885 on familia_insumo_885 
    (cod_empresa,cod_familia);



 create table cotacao_preco_885 
  (
    cod_empresa    char(2) not  ,
    cod_item       char(15) not  ,
    cod_fornecedor char(15) not  ,
    pre_unit_fob   decimal(17,6) not  ,
    pre_unit_cif   decimal(17,6),
    cnd_pgto       decimal(3,0) not ,
    dat_val_ini    datetime  not ,
    dat_val_fim    datetime  not ,
    id_registro    integer,         
    regiao_lagos   CHAR(01)      
    
  );

create index cotacao_preco_885_x1 on cotacao_preco_885 
    (cod_empresa,cod_item,cod_fornecedor);
    
create unique index cotacao_preco_ix on cotacao_preco_885 
    (cod_empresa,cod_fornecedor,cod_item);
    

create table disp_arranjo_885 
  (
    cod_empresa char(2) not  ,
    cod_arranjo char(5) not  ,
    data_disp datetime not  
  );

create unique index ix_disp_arranjo_885 on disp_arranjo_885 
    (cod_empresa,cod_arranjo);

create table de_para_turno_885
  (
    cod_empresa char(02) not ,
    turno_simula char(03) not ,
    turno_logix  decimal(3,0) not  
  );

create unique index ix_de_para_turno_885 on de_para_turno_885 (cod_empresa,
    turno_simula);


create table oper_entrada_885 
  (
    cod_empresa char(2) not  ,
    cod_operacao char(4) not  
  );


create table desc_nat_oper_912 
  (
    cod_empresa char(2) not  ,
    cod_cliente char(15) not  ,
    cod_nat_oper integer not  ,
    pct_desc_valor decimal(5,2) not  ,
    pct_desc_qtd decimal(5,2) not  ,
    pct_desc_oper decimal(5,2) not  
  );

create index ix_desc_nat_oper_912 on desc_nat_oper_912 
    (cod_empresa,cod_cliente,cod_nat_oper);



create index oper_ent_885_x1 on oper_entrada_885 
    (cod_empresa,cod_operacao);



create table ft_item_885 
  (
    num_sequencia integer,
    cod_empresa char(2),
    cod_item char(15),
    cod_cliente char(15),
    nom_item char(76),
    nom_reduzido char(18),
    medidas_internas char(15),
    estilo char(5),
    largura_chapa integer,
    compri_chapa integer,
    nom_composicao char(15),
    qtd_pcs_chapa integer,
    peso integer,
    resina char(1),
    tipo_fechamento char(10),
    cores char(70),
    cliche_ft char(10),
    faca_ft char(10),
    cod_tip_ipi integer,
    tol_ent_menos integer,
    tol_ent_mais integer,
    status_ft integer,
    classe_produto integer,
    unidade_medida char(3),
    familia char(3),
    agrupamento integer,
    onda char(3),
    qtd_chapas integer,
    dimensoes char(20),
    composicao char(50)
  );

create unique index ft_item_885 on ft_item_885 (cod_empresa,cod_item);



create table frete_rota_885 
  (
    cod_empresa      char(2) not null ,
    cod_transpor     char(15) not null ,
    cod_cid_orig     char(5) not  null,
    cod_cid_dest     char(5) not  null,
    cod_veiculo      char(15) not  null,
    cod_tip_carga    char(1) not  null,
    cod_tip_frete    char(1) not  null,
    cod_percurso     char(1) not  null,
    val_frete        decimal(12,2) not null ,
    num_versao       decimal(3,0) not  null,
    ies_versao_atual char(1) not  null,
    dat_atualiz      datetime not null
  );

create unique index frete_rota_885_1 on frete_rota_885 
    (cod_empresa,cod_transpor,cod_cid_orig,cod_cid_dest,cod_veiculo,
    cod_tip_carga,cod_tip_frete,cod_percurso,num_versao,ies_versao_atual);



create table desc_transp_885 
  (
    cod_empresa char(2) not  null ,
    cod_transpor char(15) not null ,
    pct_desc decimal(5,2) not null 
  );

create unique index desc_transp_885 on desc_transp_885 
    (cod_empresa,cod_transpor);



CREATE TABLE frete_solicit_885(
	cod_empresa    char(2) NOT NULL,
	num_solicit    int NOT NULL,
	cod_transpor   char(15) NOT NULL,
	num_chapa      char(7),
	cod_cid_orig   char(5),
	cod_cid_dest   char(5),
	cod_veiculo    char(15),
	cod_tip_carga  char(1) NOT NULL,
	cod_tip_frete  char(1) NOT NULL,
	cod_percurso   char(1) NOT NULL,
	num_conhec     int,
	num_nf_serv    decimal(6, 0),
	val_frete      decimal(12, 2) NOT NULL,
	val_frete_tab  decimal(12, 2) NOT NULL,
	val_frete_ofic decimal(12, 2) NOT NULL,
	val_frete_ger  decimal(12, 2) NOT NULL,
	num_versao_tab decimal(3, 0) NOT NULL,
	dat_cadastro   datetime NOT NULL,
	ies_validado   char(1) NOT NULL,
	num_sequencia  int,
	versao_atual   char(1),
	peso_carga     decimal(10, 3)
) ;

create table ger_com_885 
  (
    cod_gerente decimal(4,0) not  ,
    pct_com_ofi decimal(5,2) not  ,
    pct_com_ger decimal(5,2) not  ,
    val_gar_ofi decimal(15,2) not  ,
    val_gar_ger decimal(15,2) not  ,
    dat_exp_gar datetime,
    ies_exp char(1)
  );

create unique index ix_ger_885_1 on ger_com_885 
    (cod_gerente);
    


create table repres_885 
  (
    cod_repres decimal(4,0) not  ,
    cod_gerente decimal(4,0) not  ,
    pct_rep_ofi decimal(5,2) not  ,
    pct_rep_ger decimal(5,2) not  ,
    tip_perc char(1) not  ,
    tip_comis char(1) not  ,
    val_garantia decimal(15,2) not  ,
    dat_exp_gar date,
    ies_exp char(1),
    pct_ger_ofi decimal(5,2) not  ,
    pct_ger_ger decimal(5,2) not  
  );

create unique index ix_rep_885_1 on repres_885 (cod_repres);



create table veiculo_885 
  (
    cod_veiculo char(15) not  ,
    den_veiculo char(35) not  
  );

create unique index veiculo_885 on veiculo_885 
    (cod_veiculo);


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
	datiniproducao   datetime	
);	




create table frete_roma_885 
  (
    cod_empresa char(2) not null  ,
    num_solicit integer not null ,
    num_om      integer not null ,
    val_frete   decimal(12,2) not null ,
    val_ger     decimal(12,2),
    num_versao  decimal(2,0),
    versao_atual char(1)
  );

create unique index frete_roma_885 on frete_roma_885 
    (cod_empresa,num_solicit,num_om);
    

CREATE TABLE consumo_trimbox_885(
	codempresa   char(02),
	numsequencia integer,
	coditem      char(15),
	qtdconsumida decimal(10,3),
	numlote      char(15),
	comprimento  integer,
	largura      integer,
	altura       integer,
	diametro     integer,
	datageracao  datetime
);

create index num_sequencia_01 on consumo_trimbox_885 
    (codempresa, numsequencia);


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
	tipmovto char(1) ,
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
	datageracao datetime,
	tipoitem char(02)
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
	    ies_chapa                CHAR(01)                
);
	
CREATE TABLE man_apont_hist_885(
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
	    ies_chapa                CHAR(01)                
);

create table ar_proces_885 
  (
    cod_empresa char(2)   ,
    num_aviso_rec decimal(6,0)   ,
    pct_umid_pad decimal(5,2)   ,
    dat_movto datetime   ,
    num_nf integer,
    cod_fornecedor char(15)
  );

create unique index ar_proces_885 on ar_proces_885 
    (cod_empresa,num_aviso_rec);	 	    	    


CREATE TABLE romaneio_885(
	numsequencia int ,
	codempresa char(2) ,
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
	pesobalanca decimal(12, 2) ,
	pesocarregado decimal(12, 2) ,
	statusproces int ,
	statusregistro char(1) ,
	usuario char(10) ,
	numlacre char(40) ,
	datageracao datetime ,
	ufveiculo char(2) 
);

create index romaneio_885 on romaneio_885 (codempresa,
    numsequencia);


CREATE TABLE roma_item_885(
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
	pesoitem decimal(12, 5) ,
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
	iespacote char(1)
);


create index roma_item_885 on roma_item_885
    (codempresa,numsequencia);


create table roma_erro_885 
  (
    cod_empresa char(2) not  ,
    num_sequencia integer,
    num_romaneio integer,
    den_erro char(50),
    dat_hor datetime 
  );


CREATE TABLE solicit_fat_885(
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


CREATE TABLE nf_solicit_885(
	cod_empresa        char(2) NOT NULL,
	num_romaneio       int NOT NULL,
	num_solicit        decimal(4, 0) NOT NULL,
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

CREATE TABLE motivo_885(
	cod_empresa char(2) NOT ,
	cod_motivo char(2) NOT ,
	den_motivo char(30) NOT ,
	primary key(cod_empresa, cod_motivo)
) ;


CREATE TABLE repres_email_885(
	cod_repres decimal(4, 0) NOT ,
	sequencia smallint NOT ,
	email char(50) NOT ,
  PRIMARY KEY(cod_repres, sequencia)
);


CREATE TABLE familia_baixar_885(
	cod_empresa char(2) NOT null,
	cod_familia char(3) NOT null,
	primary key(cod_empresa, cod_familia)
);



CREATE TABLE proces_apont_885(
  cod_empresa char(2) NOT null,
	ies_proces char(1) NOT null
);

CREATE TABLE ar_aparas_885 (

cod_empresa    varchar(2) NOT ,
num_aviso_rec  integer  NOT ,
cod_status     varchar(1) NOT ,
ies_autorizado varchar(1) NOT ,
tip_frete      varchar(1),
reg_lagos      varchar(1),
val_pedagio    decimal(10,2),
ies_financeiro char(01)             -- A = gerou adiantamento  T = gerou titulos 
);


create unique index ar_aparas_885 on ar_aparas_885 
    (cod_empresa,num_aviso_rec);


CREATE TABLE umd_aparas_885(
	cod_empresa     char(2) NOT ,
	num_aviso_rec   int NOT ,
	num_seq_ar      smallint NOT ,
	pct_umd_med     decimal(4, 2) NOT ,
	ies_consid      char(1) NOT ,
	cod_motivo      char(2),
	fat_conversao   char(10) NOT ,
	cod_item_tr     char(15),
	pct_desc        decimal(4, 2),
	preco_cotacao   decimal(17, 6) NOT ,
	ies_troca_preco char(1) NOT ,
	preco_item_tr   decimal(17, 6)
);

create unique index umd_aparas_885 on umd_aparas_885 
    (cod_empresa,num_aviso_rec,num_seq_ar);



CREATE TABLE cont_aparas_885(
	cod_empresa     char(2) NOT ,
	num_aviso_rec   int NOT ,
	num_seq_ar      smallint NOT ,
	num_lote        char(15) NOT ,
	qtd_fardo       smallint NOT ,
	qtd_contagem    decimal(12, 3) NOT ,
	qtd_calculada   decimal(12, 3) NOT ,
	pre_calculado   decimal(17, 6) NOT ,
	qtd_liber       decimal(12, 3) NOT ,
	qtd_liber_excep decimal(12, 3) NOT ,
	qtd_rejeit      decimal(12, 3) NOT ,
	qtd_liber_calc  decimal(12, 3) NOT ,
	qtd_excep_calc  decimal(12, 3) NOT ,
	qtd_rejeit_calc decimal(12, 3) NOT ,
	dat_inspecao    datetime
) ;


create unique index cont_aparas_885 on cont_aparas_885 
    (cod_empresa,num_aviso_rec,num_seq_ar,num_lote);



CREATE TABLE etiq_aparas_885(
	cod_empresa    char(2) NOT ,
	num_registro   int NOT ,
	num_nf         int NOT ,
	num_aviso_rec  int NOT ,
	num_seq_ar     smallint NOT ,
	dat_entrada    datetime NOT ,
	cod_fornecedor char(15) NOT ,
	nom_fornecedor char(50) NOT ,
	cod_item       char(15) NOT ,
	num_lote       char(15) NOT ,
	qtd_fardo      smallint NOT ,
	tip_movto      char(1) NOT ,
	cod_status     smallint NOT 
);


CREATE TABLE user_liber_ar_885(
	cod_usuario char(8) NOT ,
	primary key(cod_usuario)
) 


CREATE TABLE insp_trans_885(
	cod_empresa   char(2) NOT ,
	num_aviso_rec int NOT ,
	num_seq_ar    smallint NOT ,
	num_transac   int NOT ,
	cod_operacao  char(4),
	tip_movto     char(1),
	sequencia     int
) 


CREATE TABLE insumo_885(
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
	dat_geracao    char(19)
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
    ies_situacao char(01) not null,            --N Nova  L Lida  P Paga
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


CREATE TABLE apara_alternat_885(
 cod_empresa char(2) NOT NULL,
 cod_item char(15)   NOT NULL,
 primary key(cod_empresa, cod_item)
) ;


CREATE TABLE apont_trans_885(
	cod_empresa   char(2) NOT NULL,
	num_seq_apont int NOT NULL,
	num_transac   int NOT NULL,
	cod_tip_apon  char(1) NOT NULL, -- A=Apontamento B=Baixa do material
	cod_tip_movto char(1) NOT NULL,  -- N=Normal R=Reversão
	ies_implant   char(01)
) ;

CREATE TABLE apont_sequencia_885(
	cod_empresa         char(2) NOT NULL,
	num_seq_apont       int NOT NULL,
	num_seq_apo_mestre  int NOT NULL,
	num_seq_apo_oper    int NOT NULL
);


CREATE TABLE frete_peso_885(
	cod_empresa      char(2) NOT NULL,
	cod_percurso     char(1) NOT NULL,
	val_tonelada     decimal(12, 2) NOT NULL,
	num_versao       decimal(3, 0) NOT NULL,
	ies_versao_atual char(1) NOT NULL,
	dat_atualiz      datetime NOT NULL
) 


CREATE TABLE nfe_x_nff_885(
	cod_empresa  char(2) NOT NULL,
	num_nfe      decimal(6, 0) NOT NULL,
	ser_nfe      char(2) NOT NULL,
	ssr_nfe      char(2) NOT NULL,
	cod_for      char(15) NOT NULL,
	num_nff      decimal(6, 0) NOT NULL,
	ser_nff      char(2) NOT NULL,
	val_frete    decimal(12, 2) NOT NULL,
	val_compl    decimal(12, 2) NOT NULL,
	ies_validado char(1)
);


CREATE TABLE frete_compl_885(
	cod_empresa char(2) NOT NULL,
	num_solicit int NOT NULL,
	preco_compl decimal(9, 2) NOT NULL,
	dat_atualiz datetime NOT NULL,
	nom_usuario char(8) NOT NULL
) ;



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


create table cons_erro_885 
  (
    codempresa   char(2),
    numsequencia integer,
    datconsumo   date,
    mensagem     char(70),
    dat_hor      datetime 
  );

create table trans_consu_885 (
  cod_empresa     char(02),
  num_seq_cons    INTEGER,
  num_transac     INTEGER,
  tip_operacao    char(01),
  tip_movto    char(01)
);
