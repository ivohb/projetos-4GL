create table apo_cairu
  (
    cod_item char(15) not null ,
    dat_referencia date,
    num_seq_operac decimal(3,0) not null ,
    cod_operac char(5) not null ,
    cod_cent_cust decimal(4,0),
    qtd_diferenca decimal(10,3) not null
  );

create unique index ix_pol0157_3 on apo_cairu (cod_item,
    dat_referencia,cod_operac,num_seq_operac,cod_cent_cust);
