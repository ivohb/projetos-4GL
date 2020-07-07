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
