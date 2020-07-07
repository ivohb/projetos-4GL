DROP table fat_nf_item_fisc ;
CREATE table fat_nf_item_fisc 
  (
    empresa                  char(2) not null,
    trans_nota_fiscal        integer not null,
    seq_item_nf              integer not null,
    tributo_benef            char(20) not NULL,
    trans_config             integer not NULL,
    bc_trib_mercadoria       DECIMAL(17,2) not NULL,
    bc_tributo_frete         decimal(17,2) not NULL,
    bc_trib_calculado        decimal(17,2) not NULL,
    bc_tributo_tot           decimal(17,2) not NULL,
    val_trib_merc            decimal(17,2) not NULL,
    val_tributo_frete        decimal(17,2) not NULL,
    val_trib_calculado       decimal(17,2) not NULL,
    val_tributo_tot          decimal(17,2) not NULL,
    acresc_desc              char(1) not NULL,
    aplicacao_val            char(1),
    incide                   char(1) NOT NULL,
    origem_produto           smallint,
    tributacao               smallint,
    hist_fiscal              integer,
    sit_tributo              char(1),
    motivo_retencao          char(1),
    retencao_cre_vdp         CHAR(3),
    cod_fiscal               integer,
    inscricao_estadual       char(16),
    dipam_b                  CHAR(3),
    aliquota                 decimal(7,4),
    val_unit                 decimal(17,6),
    pre_uni_mercadoria       decimal(17,6),
    pct_aplicacao_base       decimal(7,4),
    pct_acre_bas_calc        decimal(7,4),
    pct_red_bas_calc         decimal(7,4),
    pct_diferido_base        decimal(7,4),
    pct_diferido_val         decimal(7,4),
    pct_acresc_val           decimal(7,4),
    pct_reducao_val          decimal(7,4),
    pct_margem_lucro         decimal(7,4),
    pct_acre_marg_lucr       decimal(7,4),
    pct_red_marg_lucro       decimal(7,4),
    taxa_reducao_pct         decimal(7,4),
    taxa_acresc_pct          decimal(7,4),
    cotacao_moeda_upf        decimal(7,2),
    simples_nacional         decimal(5,0),
    primary key (empresa,trans_nota_fiscal,seq_item_nf,tributo_benef)  
       constraint pk_fat_nf_item_fisc
  );


create index ix1_fat_nf_item_fisc on 
    fat_nf_item_fisc (empresa,trans_config);

