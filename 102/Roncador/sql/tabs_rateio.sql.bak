drop table rateio_mensal_orig912;
Create table rateio_mensal_orig912 (
   num_rateio        integer  not null,
   empresa_orig      char(02) not null,
   ano               char(04) not null,
   mes               char(02) not null,
   Primary key(num_rateio)
);

create unique index ix1_rat_mensal_orig on 
rateio_mensal_orig912(empresa_orig, ano, mes)

drop table rateio_mensal_dest912;
create table rateio_mensal_dest912(
   num_rateio        integer  not null,
   empresa_dest      char(02) not null,
   cod_cent_cust     dec(4,0) not null,
   cod_aen           char(08),
   pct_rateio        dec(5,2) not null
);

create unique index ix1_rat_mensal_dest on 
rateio_mensal_dest912(num_rateio,empresa_dest,cod_cent_cust)
   
create index ix2_rat_mensal_dest on 
rateio_mensal_dest912(num_rateio)

drop table rateio_tip_desp_orig912;
Create table rateio_tip_desp_orig912 (
  num_rateio          integer not null,
  empresa_orig        char(02) not null,
  versao              integer not null,
  cod_tip_desp        dec(4,0) not null,
  cod_fornecedor      char (15),
  timesheet           char(01) not null,
  situacao            char(01) not null,
  dat_liberac         char(10),
  cod_portador        decimal(4,0) not null default 0
  primary key(num_rateio)
);

create index ix1_rat_tip_desp on 
rateio_tip_desp_orig912(empresa_orig, cod_tip_desp)

drop table rateio_tip_desp_dest912;
Create table rateio_tip_desp_dest912 (
  num_rateio        integer not null,
  empresa_dest      char(02) not null,
  cod_cent_cust     dec(4,0) not null, 
  cod_aen           char(08),
  pct_rateio        dec(5,2) not null
);

create index ix1_rat_dest on 
rateio_tip_desp_dest912(num_rateio)

create unique index ix2_rat_dest on 
rateio_tip_desp_dest912(num_rateio,empresa_dest,cod_cent_cust)

drop table aprovador_912;
Create table aprovador_912 (
  cod_empresa  char(02) not null,
  cod_user     char(08) not null,
  primary key(cod_empresa, cod_user)
);

drop table rateio_aprovado_912;
Create table rateio_aprovado_912 (
  num_rateio          integer not null,
  empresa_orig        char(02) not null,
  cod_user            char(08) not null,
  dat_aprovac         char(10),
  primary key(num_rateio, cod_user)
);

drop table previsao_912;
CREATE TABLE previsao_912 (
      num_previsao     integer,
      cod_emp_orig     char(02),
      num_ad           integer,
      cod_cent_cust    decimal(5,0),
      cod_fornecedor   char(15),
      cod_tip_despesa  decimal(4,0),
      num_nf           char(12),
      dat_rec_nf       date,
      cnd_pgto         integer,
      val_tot_nf       decimal(12,2),
      dat_venc         date,
      cod_moeda        integer,
      cod_tip_ad       integer,
      ies_sup_cap      char(03),
      origem           char(03),
      rateado          char(01),
      cod_portador     decimal(4,0)
   primary key(num_previsao, num_ad)
);      
      
create unique index ix_previsao_912 on previsao_912
 (cod_emp_orig, num_ad);
 
drop table previsao_rateio_912;
CREATE TABLE previsao_rateio_912 (
      num_previsao     integer,
      num_ad           integer,
      num_seq          integer,
      empresa_dest     CHAR(02),
      cod_cent_cust    decimal(4,0),
      cod_aen          CHAR(08),
      pct_rateio       DECIMAL(5,2),
      val_rateio       DECIMAL(12,2),
      num_docum        INTEGER,
      num_titulo       CHAR(10)
);

create unique index ix_previsao_rat on previsao_rateio_912
 (num_previsao, num_ad, num_seq);

drop table previsao_periodo_912;
CREATE TABLE previsao_periodo_912 (
      num_previsao     integer, 
      dat_geracao      date,
      cod_emp_orig     char(02),
      dat_ini          date,
      dat_fim          date,
      primary key(num_previsao)
);

drop table nota_deb_orig_912;
CREATE TABLE nota_deb_orig_912 (  
  id_rateio           INTEGER,  --max+1 
  empresa_orig        char(02),
  num_nota_deb        char(14), --R+empresa_orig+id_rateio
  dat_emissao         date,
  dat_vencto          date,
  val_nota            decimal(12,2),
  num_previsao        INTEGER,
  primary key(num_nota_deb)
);

create unique index ix_nota_deb_orig on
nota_deb_orig_912(id_rateio);

drop table nota_deb_dest_912;
CREATE TABLE nota_deb_dest_912 (    
  num_nota_deb        char(14),
  empresa_dest        char(02),
  num_ad              INTEGER,
  val_ad              decimal(12,2),
  docum_orig          integer
);

create index ix_nota_deb_dest_912 on
nota_deb_dest_912(num_nota_deb);

drop table nota_imp_912;
create table nota_imp_912 (
  num_nota     char(14),
  cod_orig     char(02),
  raz_orig     char(36),
  end_orig     char(40),
  cid_orig     char(30),
  est_orig     char(02),
  cep_orig     char(09),
  cgc_orig     char(19),
  cod_dest     char(02),
  raz_dest     char(36),
  end_dest     char(40),
  cid_dest     char(30),
  est_dest     char(02),
  cep_dest     char(09),
  cgc_dest     char(19),
  dat_emis     char(10),
  dat_venc     char(10),
  nom_cont     char(40),
  crc_cont     char(15),
  val_nota     decimal(12,2),
  primary key(num_nota)
);

drop table ad_imp_912;
create table ad_imp_912 (
  num_ad     decimal(6,0),
  cod_desp   decimal(4,0),
  nom_des    char(30),
  val_ad     decimal(12,2),
  primary key(num_ad)
);

