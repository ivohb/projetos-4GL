{ TABLE "informix".item row size = 186 number of columns = 23 index size = 35 }
create table "informix".item 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    den_item char(76) not null ,
    den_item_reduz char(18),
    cod_unid_med char(3) not null ,
    pes_unit decimal(12,5) not null ,
    ies_tip_item char(1) not null ,
    dat_cadastro date,
    ies_ctr_estoque char(1) not null ,
    cod_local_estoq char(10),
    ies_tem_inspecao char(1) not null ,
    cod_local_insp char(10),
    ies_ctr_lote char(1) not null ,
    cod_familia char(3) not null ,
    gru_ctr_estoq decimal(2,0),
    cod_cla_fisc char(10) not null ,
    pct_ipi decimal(6,3) not null ,
    cod_lin_prod decimal(2,0) not null ,
    cod_lin_recei decimal(2,0) not null ,
    cod_seg_merc decimal(2,0) not null ,
    cod_cla_uso decimal(2,0) not null ,
    fat_conver decimal(11,6) not null ,
    ies_situacao char(1) not null 
  );
revoke all on "informix".item from "public";



create index "informix".fame_item_1 on "informix".item (cod_empresa,
    cod_item) using btree ;
create index "informix".ix_item_2 on "informix".item (cod_lin_prod,
    cod_lin_recei,cod_seg_merc,cod_cla_uso) using btree ;

create trigger "informix".ins_item insert on "informix".item referencing 
    new as new
    for each row
        (
        insert into "informix".vntrgprodutos (cdprod,operacao,
    dthrlog)  values (new.cod_item ,'I' ,CURRENT year to fraction(3) ));
    

create trigger "informix".upd_item update on "informix".item referencing 
    new as new
    for each row
        (
        insert into "informix".vntrgprodutos (cdprod,operacao,
    dthrlog)  values (new.cod_item ,'U' ,CURRENT year to fraction(3) ));
    



