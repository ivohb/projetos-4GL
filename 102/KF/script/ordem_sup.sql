






{ TABLE "suporte".ordem_sup row size = 190 number of columns = 44 index size = 381 }

create table "suporte".ordem_sup 
  (
    cod_empresa char(2) not null ,
    num_oc decimal(9,0) not null ,
    num_versao decimal(3,0) not null ,
    num_versao_pedido decimal(3,0) not null ,
    ies_versao_atual char(1) not null ,
    cod_item char(15) not null ,
    num_pedido decimal(6,0) not null ,
    ies_situa_oc char(1) not null ,
    ies_origem_oc char(1),
    ies_item_estoq char(1) not null ,
    ies_imobilizado char(1) not null ,
    cod_unid_med char(3) not null ,
    dat_emis date not null ,
    qtd_solic decimal(12,3) not null ,
    dat_entrega_prev date not null ,
    fat_conver_unid decimal(15,7) not null ,
    qtd_recebida decimal(12,3) not null ,
    pre_unit_oc decimal(17,6) not null ,
    dat_ref_cotacao date,
    ies_tip_cotacao char(1),
    pct_ipi decimal(6,3) not null ,
    cod_moeda decimal(2,0) not null ,
    cod_fornecedor char(15) not null ,
    num_cotacao decimal(6,0),
    cnd_pgto decimal(3,0) not null ,
    cod_mod_embar decimal(2,0) not null ,
    num_docum char(10),
    gru_ctr_desp decimal(4,0) not null ,
    cod_secao_receb char(10),
    cod_progr decimal(3,0) not null ,
    cod_comprador decimal(3,0) not null ,
    pct_aceite_dif decimal(6,3) not null ,
    ies_tip_entrega char(1) not null ,
    ies_liquida_oc char(1) not null ,
    dat_abertura_oc date,
    num_oc_origem decimal(9,0),
    qtd_origem decimal(12,3),
    dat_origem date,
    ies_tip_incid_ipi char(1),
    ies_tip_incid_icms char(1),
    cod_fiscal char(5),
    cod_tip_despesa decimal(4,0),
    ies_insp_recebto char(1),
    ies_tipo_inspecao char(1)
  );

revoke all on "suporte".ordem_sup from "public" as "suporte";


create index "informix".ix_ordem_sup_1 on "suporte".ordem_sup 
    (cod_empresa,cod_item,num_pedido,ies_situa_oc,ies_versao_atual) 
    using btree ;
create index "informix".ix_ordem_sup_2 on "suporte".ordem_sup 
    (cod_empresa,ies_versao_atual,ies_situa_oc,ies_origem_oc,
    cod_progr,cod_comprador) using btree ;
create index "informix".ix_ordem_sup_3 on "suporte".ordem_sup 
    (cod_empresa,cod_fornecedor,ies_versao_atual,ies_situa_oc,
    cod_comprador,cod_item) using btree ;
create index "informix".ix_ordem_sup_4 on "suporte".ordem_sup 
    (cod_empresa,num_oc,ies_versao_atual,ies_situa_oc,cod_item) 
    using btree ;
create index "informix".ix_ordem_sup_5 on "suporte".ordem_sup 
    (cod_empresa,cod_item,ies_versao_atual,num_oc,num_versao,
    num_pedido,cod_fornecedor) using btree ;
create index "informix".ix_ordem_sup_6 on "suporte".ordem_sup 
    (cod_empresa,cod_comprador,ies_versao_atual,ies_situa_oc,
    cod_item,cod_fornecedor) using btree ;
create index "informix".ix_ordem_sup_7 on "suporte".ordem_sup 
    (cod_empresa,ies_versao_atual,num_pedido,num_versao_pedido,
    cod_item) using btree ;
create unique index "informix".ix_ordem_sup_8 on "suporte".ordem_sup 
    (cod_empresa,num_oc,num_versao,ies_situa_oc) using btree 
    ;
create index "informix".ix_ordem_sup_9 on "suporte".ordem_sup 
    (cod_empresa,num_pedido,ies_versao_atual,ies_situa_oc) using 
    btree ;
create index "suporte".ix_ordem_sup_g3 on "suporte".ordem_sup 
    (cod_empresa,cod_fornecedor,cod_item,ies_versao_atual) using 
    btree ;
create index "suporte".ix_ordem_sup_g4 on "suporte".ordem_sup 
    (cod_empresa,cod_comprador,cod_item,cod_fornecedor,num_pedido,
    ies_situa_oc,num_cotacao,ies_versao_atual) using btree ;
create index "informix".ix_ordmrp on "suporte".ordem_sup (cod_empresa,
    cod_item,ies_situa_oc,ies_versao_atual) using btree ;


create trigger "informix".tr_tag_comp update on "suporte".ordem_sup 
    referencing new as new_rec
    for each row
        (
        execute procedure "informix".pr_tag_comp(new_rec.cod_empresa 
    ,new_rec.cod_item ,new_rec.num_pedido ,new_rec.ies_versao_atual ,
    new_rec.ies_situa_oc ,new_rec.num_oc ,new_rec.cod_fornecedor ,new_rec.cod_comprador 
    ,new_rec.pre_unit_oc ,new_rec.qtd_recebida ));

create trigger "root".tr_gapr_oc_sup update on "suporte".ordem_sup 
    referencing old as old_rec new as new_rec
    for each row
        (
        execute procedure "root".pr_gapr_oc_sup(new_rec.cod_empresa 
    ,new_rec.num_oc ,new_rec.num_versao ,new_rec.pre_unit_oc ,old_rec.pre_unit_oc 
    ));

