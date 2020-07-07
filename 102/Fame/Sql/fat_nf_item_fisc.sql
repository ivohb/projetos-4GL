
create table fat_nf_item_fisc 
  (
    empresa char(2) not null ,
    trans_nota_fiscal integer not null ,
    seq_item_nf integer not null ,
    tributo_benef char(20) not null ,
    trans_config integer not null ,
    bc_trib_mercadoria decimal(17,2) not null ,
    bc_tributo_frete decimal(17,2) not null ,
    bc_trib_calculado decimal(17,2) not null ,
    bc_tributo_tot decimal(17,2) not null ,
    val_trib_merc decimal(17,2) not null ,
    val_tributo_frete decimal(17,2) not null ,
    val_trib_calculado decimal(17,2) not null ,
    val_tributo_tot decimal(17,2) not null ,
    acresc_desc char(1) not null ,
    aplicacao_val char(1),
    incide char(1) not null ,
    origem_produto smallint,
    tributacao smallint,
    hist_fiscal integer,
    hist_fiscal_2 integer,
    sit_tributo char(1),
    motivo_retencao char(1),
    retencao_cre_vdp char(3),
    cod_fiscal integer,
    inscricao_estadual char(16),
    dipam_b char(3),
    aliquota decimal(7,4),
    val_unit decimal(17,6),
    pre_uni_mercadoria decimal(17,6),
    pct_aplicacao_base decimal(7,4),
    pct_acre_bas_calc decimal(7,4),
    pct_red_bas_calc decimal(7,4),
    pct_diferido_base decimal(7,4),
    pct_diferido_val decimal(7,4),
    pct_acresc_val decimal(7,4),
    pct_reducao_val decimal(7,4),
    pct_margem_lucro decimal(7,4),
    pct_acre_marg_lucr decimal(7,4),
    pct_red_marg_lucro decimal(7,4),
    taxa_reducao_pct decimal(7,4),
    taxa_acresc_pct decimal(7,4),
    cotacao_moeda_upf decimal(7,2),
    simples_nacional decimal(5,0),
    iden_processo integer,
    qtd_base_calc decimal(17,6),
    primary key (empresa,trans_nota_fiscal,seq_item_nf,tributo_benef)
  );


create index ix1_fat_nf_item_fisc on fat_nf_item_fisc 
    (empresa,trans_config);


