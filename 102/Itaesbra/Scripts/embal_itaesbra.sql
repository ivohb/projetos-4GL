create table embal_itaesbra 
  (
    cod_empresa char(2) not null ,
    cod_cliente char(15) not null ,
    cod_item char(15) not null ,
    cod_tip_venda decimal(2,0) not null ,
    cod_embal char(3),
    ies_tip_embal char(1) not null ,
    qtd_padr_embal decimal(12,3) not null ,
    vol_padr_embal decimal(9,3) not null ,
    contner char(15),
    dloc char(12),
    doc char(3),
    stck char(5)
  );

create unique index ix_embal_ita1 on embal_itaesbra 
(cod_empresa,cod_cliente,cod_item,cod_tip_venda,
    cod_embal,ies_tip_embal);
    
create index ix_embal_ita2 on embal_itaesbra 
    (cod_empresa,cod_cliente,cod_item,cod_tip_venda,ies_tip_embal);


