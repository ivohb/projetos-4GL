
create table simbolo_itaesbra 
  (
    cod_empresa char(2) not null ,
    cod_simbolo char(2) not null ,
    den_simbolo char(30),
    cod_tip_oper decimal(1,0) not null 
  );


create unique index ix_simbol_itaesbra on simbolo_itaesbra 
    (cod_empresa,cod_simbolo) using btree ;



create table item_ppap_970 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_revisao char(2) not null ,
    dat_revisao date not null ,
    cod_peca_ppap char(40) not null 
  );


create unique index ix_item_ppap_970 on item_ppap_970 
    (cod_empresa,cod_item) using btree ;



create table compon_ppap_970 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_compon char(15) not null ,
    cod_oper_logix char(5) not null ,
    cod_oper_siga char(6) not null ,
    cod_simbolo char(2) not null 
  );

create unique index ix_compon_ppap_970 on compon_ppap_970 
    (cod_empresa,cod_item,cod_compon,cod_oper_logix) using btree 
    ;



create table ciclo_peca_970 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    qtd_ciclo_peca integer not null ,
    qtd_peca_ciclo integer not null ,
    num_seq decimal(3,0) not null ,
    num_sub_seq decimal(3,0) not null ,
    qtd_peca_emb integer not null ,
    qtd_peca_hor integer not null ,
    fator_mo decimal(4,2) not null 
  );

create unique index ciclo_peca_970 on ciclo_peca_970 
    (cod_empresa,cod_item) using btree ;


