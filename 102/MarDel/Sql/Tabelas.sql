

create table simbolo_5054 
  (
    cod_empresa char(2) not null ,
    cod_simbolo char(2) not null ,
    den_simbolo char(30),
    cod_tip_oper decimal(1,0) not null 
  );


create unique index ix_simbol_5054 on 
  simbolo_5054 (cod_empresa, cod_simbolo);


create table item_ppap_970 
  (
    cod_empresa   char(2) not null ,
    cod_item      char(15) not null ,
    cod_revisao   char(2) not null ,
    dat_revisao   datetime not null ,
    cod_peca_ppap char(40) not null 
  );

create unique index ix_item_ppap_970 on 
    item_ppap_970 (cod_empresa,cod_item);


    


create table ciclo_peca_5054
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    qtd_ciclo_peca integer,
    qtd_peca_ciclo integer,
    num_seq decimal(3,0),
    num_sub_seq decimal(3,0),
    qtd_peca_emb integer not null ,
    qtd_peca_hor integer,
    fator_mo decimal(4,2),
    cod_item_cliente char(30),
    passo integer
  );


create unique index ciclo_peca_5054 on
    ciclo_peca_5054(cod_empresa,cod_item);


create table func_rm_5054 (
  cod_empresa        char(02) not null,
  num_matricula      decimal(8,0) not null,
  nom_funcionario    char(30)  not null,
  cod_uni_funcio     char(10) not null,
  cod_cargo          decimal(5,0)  not null,
  dat_admissao       datetime  not null,
  dat_demissao       datetime,
  cod_turno          decimal(4,0),
  cod_escala         decimal(4,0) not null,
  end_funcionario    char(30),
  end_complementar   char(20),
  cod_cep            char(09),
  nom_cidade         char(30),
  sigla_estado       char(02),
  nom_bairro         char(30),
  dat_nascimento     datetime,
  num_cpf            char(14),
  ies_processado     char(01) not null,     -- S=Sim N=N�o
  dat_hor_proces     datetime,
  cod_usuario        char(08),
  id_registro        int identity(1,1) primary key
);

create index func_rm_5054_1 on
 func_rm_5054(cod_empresa, num_matricula);

create unique index func_rm_5054_2 on
 func_rm_5054(cod_empresa, id_registro);

create table func_erro_5054 (
  cod_empresa        char(02),
  num_matricula      decimal(8,0),
  num_seq            integer,
  den_erro           char(75)
);

create unique index func_erro_5054_1 on
    func_erro_5054(cod_empresa,num_matricula, num_seq);

create index func_erro_5054_2 on
    func_erro_5054(cod_empresa,num_matricula);

create table finan_rm_5054 (
   cod_empresa    char(02) not null,
   num_tit_rm	    char(07) not null,
   tip_operacao   char(01) not null,         -- I=Incluir C=Cancelar
   cod_cent_custo	decimal(4,0), 
   cod_fornecedor	char(15) not null,
   dat_vencto     datetime not null,
   val_tot_titulo decimal(15,2) not null,
   cod_moeda	    decimal(2,0) not null,
   cod_tip_desp	  Decimal(4,0) not null,
   cod_lin_prod  	Decimal (2,0) default 0,
   cod_lin_recei  Decimal (2,0) default 0,
   cod_seg_merc   Decimal (2,0) default 0,
   cod_cla_uso    Decimal (2,0) default 0,
   val_cent_custo decimal(15,2) not null,
   ies_processado char(01) not null,         -- S=Sim N=N�o
   dat_hor_proces datetime,
   nom_usuario    char(08),
   num_tit_logix  decimal(6,0)
);
   
create unique index finan_rm_5054_1 on
finan_rm_5054(cod_empresa, num_tit_rm, tip_operacao);

create table tit_rm_logix_5054 (
   cod_empresa    char(02) not null,
   num_tit_rm	    char(07) not null,
   num_tit_logix  decimal(6,0) not null
);

create unique index tit_rm_logix_5054 on
tit_rm_logix_5054(cod_empresa, num_tit_rm);

create table finan_erro_5054 (
  cod_empresa        char(02),
  num_tit_rm         char(07),
  num_seq            integer,
  den_erro           char(75)
);

create unique index finan_erro_5054_1 on
    finan_erro_5054(cod_empresa, num_tit_rm, num_seq);

create index finan_erro_5054_2 on
    finan_erro_5054(cod_empresa, num_tit_rm);