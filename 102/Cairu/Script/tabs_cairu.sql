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

create table saldo_cairu
  (
    cod_item char(15) not null ,
    dat_saldo      date,
    num_seq_operac decimal(3,0) not null ,
    cod_operac char(5) not null ,
    cod_cent_cust decimal(4,0),
    qtd_saldo  decimal(10,3) not null ,
    ies_oper_final CHAR(01)  not null

  );

create unique index ix_pol0157_4 on saldo_cairu (cod_item,
    dat_saldo,cod_operac,num_seq_operac,cod_cent_cust);



create table aviso_rec_cairu 
  (
    cod_empresa char(2) not null ,
    num_aviso_rec decimal(6,0) not null,
    cod_item_benef char(15)
  );

create unique index ix_cairu on aviso_rec_cairu (cod_empresa,
    num_aviso_rec,cod_item_benef);



create table nf_retorno_cairu 
  (
    cod_empresa char(2) not null,
    num_aviso_rec decimal(6,0) not null,
    num_nff1 decimal(6),
    num_nff2 decimal(6),
    num_nff3 decimal(6),
    num_nff4 decimal(6),
    num_nff5 decimal(6)
  );

create unique index ix_nfcairu_1 on nf_retorno_cairu (cod_empresa,
    num_aviso_rec);




