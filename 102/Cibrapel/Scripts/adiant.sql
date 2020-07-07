create table adiant_885
  (
    cod_empresa char(2) not null ,
    cod_fornecedor char(15) not null ,
    num_pedido decimal(7,0),
    num_ad_nf_orig decimal(7,0) not null ,
    ser_nf char(3) not null ,
    ssr_nf decimal(2,0) not null ,
    dat_ref date not null ,
    val_adiant decimal(17,2) not null ,
    val_saldo_adiant decimal(17,2) not null ,
    tex_observ_adiant char(50),
    ies_forn_div char(1) not null ,
    ies_adiant_transf char(1) not null ,
    ies_bx_automatica char(1) not null ,
    ies_situacao char(01) not null,            --N Novo  L Lida  C Compensado
    primary key (cod_empresa,cod_fornecedor,num_ad_nf_orig,ser_nf,ssr_nf) 
  );


create table mov_adiant_885 
  (
    cod_empresa char(2) not null ,
    dat_mov date not null ,
    ies_ent_bx char(1) not null ,
    cod_fornecedor char(15) not null ,
    num_ad_nf_orig decimal(6,0) not null ,
    ser_nf char(3),
    ssr_nf decimal(2,0),
    val_mov decimal(17,2) not null ,
    val_saldo_novo decimal(17,2) not null ,
    ies_ad_ap_mov char(1) not null ,
    num_ad_ap_mov decimal(6,0) not null ,
    cod_tip_val_mov decimal(3,0) not null ,
    hor_mov datetime hour to second not null 
  );


