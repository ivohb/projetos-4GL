

create table item_prog_kf_1099 
  (
    cod_empresa char(2),
    cod_item char(15),
    pct_refugo decimal(5,2),
    num_ped_wv char(12),
    cod_item_wv char(30),
    contato char(11),
    cod_uni_med char(2)
  );

create unique index ix_itpg1099_1 on item_prog_kf_1099 
    (cod_empresa,cod_item) using btree ;


