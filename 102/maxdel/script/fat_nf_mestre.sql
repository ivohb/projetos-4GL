






{ TABLE "informix".fat_nf_mestre row size = 429 number of columns = 64 index size 
              = 117 }
create table "informix".fat_nf_mestre 
  (
    empresa char(2) not null ,
    trans_nota_fiscal serial not null ,
    tip_nota_fiscal char(8) not null ,
    serie_nota_fiscal char(3) not null ,
    subserie_nf smallint not null ,
    espc_nota_fiscal char(3) not null ,
    nota_fiscal integer not null ,
    status_nota_fiscal char(1) not null ,
    modelo_nota_fiscal char(2) not null ,
    origem_nota_fiscal char(1) not null ,
    tip_processamento char(1) not null ,
    sit_nota_fiscal char(1) not null ,
    cliente char(15) not null ,
    remetent char(15) not null ,
    zona_franca char(1) not null ,
    natureza_operacao integer not null ,
    finalidade char(1) not null ,
    cond_pagto integer not null ,
    tip_carteira char(2) not null ,
    ind_despesa_financ decimal(7,6) not null ,
    moeda smallint not null ,
    plano_venda char(1) not null ,
    transportadora char(15),
    tip_frete char(1) not null ,
    placa_veiculo char(10),
    estado_placa_veic char(2),
    placa_carreta_1 char(10),
    estado_plac_carr_1 char(2),
    placa_carreta_2 char(10),
    estado_plac_carr_2 char(2),
    tabela_frete smallint,
    seq_tabela_frete smallint,
    sequencia_faixa smallint,
    via_transporte smallint,
    peso_liquido decimal(17,6) not null ,
    peso_bruto decimal(17,6) not null ,
    peso_tara decimal(17,6) not null ,
    num_prim_volume integer not null ,
    volume_cubico decimal(17,6) not null ,
    usu_incl_nf char(8) not null ,
    dat_hor_emissao datetime year to second not null ,
    dat_hor_saida datetime year to second,
    dat_hor_entrega datetime year to second,
    contato_entrega char(40),
    dat_hor_cancel datetime year to second,
    motivo_cancel smallint,
    usu_canc_nf char(8),
    sit_impressao char(1) not null ,
    val_frete_rodov decimal(17,2) not null ,
    val_seguro_rodov decimal(17,2) not null ,
    val_fret_consig decimal(17,2) not null ,
    val_segr_consig decimal(17,2) not null ,
    val_frete_cliente decimal(17,2) not null ,
    val_seguro_cliente decimal(17,2) not null ,
    val_desc_merc decimal(17,2) not null ,
    val_desc_nf decimal(17,2) not null ,
    val_desc_duplicata decimal(17,2) not null ,
    val_acre_merc decimal(17,2) not null ,
    val_acre_nf decimal(17,2) not null ,
    val_acre_duplicata decimal(17,2) not null ,
    val_mercadoria decimal(17,2) not null ,
    val_duplicata decimal(17,2) not null ,
    val_nota_fiscal decimal(17,2) not null ,
    tip_venda decimal(2,0),
    primary key (empresa,trans_nota_fiscal)  constraint "informix".pk_fatmestre
  );

revoke all on "informix".fat_nf_mestre from "public" as "informix";


create unique index "informix".ix1_fatmestre on "informix".fat_nf_mestre 
    (empresa,tip_nota_fiscal,serie_nota_fiscal,subserie_nf,dat_hor_emissao,
    nota_fiscal) using btree ;
create index "informix".ix2_fatmestre on "informix".fat_nf_mestre 
    (empresa,status_nota_fiscal) using btree ;
create index "informix".ix3_fatmestre on "informix".fat_nf_mestre 
    (empresa,nota_fiscal,serie_nota_fiscal) using btree ;
create index "informix".ix4_fatmestre on "informix".fat_nf_mestre 
    (empresa,tip_nota_fiscal,dat_hor_emissao) using btree ;
create unique index "informix".ix5_fatmestre on "informix".fat_nf_mestre 
    (empresa,tip_nota_fiscal,serie_nota_fiscal,subserie_nf,nota_fiscal,
    status_nota_fiscal,trans_nota_fiscal) using btree ;


