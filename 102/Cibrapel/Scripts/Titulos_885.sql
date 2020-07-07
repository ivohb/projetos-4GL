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
