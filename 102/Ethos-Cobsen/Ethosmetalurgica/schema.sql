






{ TABLE "informix".ordens row size = 164 number of columns = 29 index size = 288 }

create table "informix".ordens 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null ,
    num_neces integer not null ,
    num_versao decimal(2,0) not null ,
    cod_item char(15) not null ,
    cod_item_pai char(15) not null ,
    dat_ini date,
    dat_entrega date not null ,
    dat_abert date not null ,
    dat_liberac date not null ,
    qtd_planej decimal(10,3) not null ,
    pct_refug decimal(6,3) not null ,
    qtd_boas decimal(10,3) not null ,
    qtd_refug decimal(10,3) not null ,
    qtd_sucata decimal(10,3) not null ,
    cod_local_prod char(10) not null ,
    cod_local_estoq char(10) not null ,
    num_docum char(10),
    ies_lista_ordem char(1) not null ,
    ies_lista_roteiro char(1) not null ,
    ies_origem char(1) not null ,
    ies_situa char(1) not null ,
    ies_abert_liber char(1) not null ,
    ies_baixa_comp char(1) not null ,
    ies_apontamento char(1) not null ,
    dat_atualiz date,
    num_lote char(15),
    cod_roteiro char(15),
    num_altern_roteiro decimal(2,0),
    primary key (cod_empresa,num_ordem)  constraint "informix".pk_ordens
  );

revoke all on "informix".ordens from "public" as "informix";


create index "informix".ix4_ordens on "informix".ordens (num_lote) 
    using btree ;
create index "informix".ix_ordens_2 on "informix".ordens (cod_empresa,
    cod_item,ies_situa) using btree ;
create index "informix".ix_ordens_3 on "informix".ordens (cod_empresa,
    ies_situa) using btree ;
create index "informix".ix_ordens_5 on "informix".ordens (num_neces) 
    using btree ;
create index "informix".ix_ordens_92 on "informix".ordens (cod_empresa,
    num_docum,dat_entrega) using btree ;
create index "informix".ix_ordens_93 on "informix".ordens (cod_empresa,
    cod_item_pai,ies_situa,ies_origem) using btree ;
create index "informix".ix_ordens_94 on "informix".ordens (cod_empresa,
    cod_item,cod_item_pai,dat_entrega,num_docum) using btree 
    ;
create index "informix".ix_ordens_95 on "informix".ordens (cod_empresa,
    ies_situa,ies_apontamento,num_ordem,cod_item,dat_entrega) 
    using btree ;
create index "informix".ix_ordens_96 on "informix".ordens (cod_empresa,
    num_ordem,ies_situa) using btree ;
create index "informix".ix_ordens_97 on "informix".ordens (cod_empresa,
    ies_situa,dat_entrega) using btree ;
create index "informix".ix_ordens_98 on "informix".ordens (cod_empresa,
    cod_item,num_docum,ies_situa) using btree ;
create index "informix".ix_ordens_99 on "informix".ordens (cod_empresa,
    num_docum,cod_item) using btree ;


create trigger "Administrator".tr_ordens update on "informix".ordens 
    referencing new as new_rec
    for each row
        (
        execute procedure "fernandoruiz".pr_ordens(new_rec.cod_empresa 
    ,new_rec.num_ordem ,new_rec.ies_situa ));

create trigger "Administrator".tr_dt_ordens insert on "informix"
    .ordens referencing new as new_reg
    for each row
        (
        execute procedure "Administrator".pr_dt_ordens(new_reg.cod_empresa 
    ,new_reg.num_ordem ,new_reg.dat_atualiz ));

