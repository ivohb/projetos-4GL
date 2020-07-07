






{ TABLE "logix".fat_solic_fatura row size = 154 number of columns = 33 index size 
              = 17 }
create table "logix".fat_solic_fatura 
  (
    trans_solic_fatura integer not null ,
    ord_montag integer not null ,
    lote_ord_montag integer not null ,
    seq_solic_fatura smallint not null ,
    controle smallint,
    cond_pagto integer,
    qtd_dia_acre_dupl smallint,
    texto_1 smallint,
    texto_2 smallint,
    texto_3 smallint,
    via_transporte smallint,
    cidade_dest_frete char(5),
    tabela_frete smallint,
    seq_tabela_frete smallint,
    sequencia_faixa smallint,
    transportadora char(15),
    placa_veiculo char(7),
    placa_carreta_1 char(7),
    placa_carreta_2 char(7),
    estado_placa_veic char(2),
    estado_plac_carr_1 char(2),
    estado_plac_carr_2 char(2),
    val_frete decimal(17,2) not null ,
    val_seguro decimal(17,2) not null ,
    peso_liquido decimal(17,6) not null ,
    peso_bruto decimal(17,6) not null ,
    primeiro_volume integer,
    volume_cubico decimal(17,6) not null ,
    mercado char(2),
    local_embarque decimal(3,0),
    modo_embarque decimal(2,0),
    dat_hor_embarque date,
    cidade_embarque varchar(5),
    primary key (trans_solic_fatura,ord_montag,lote_ord_montag)  constraint "logix".pk_fatsolfat
  );

revoke all on "logix".fat_solic_fatura from "public" as "logix";




