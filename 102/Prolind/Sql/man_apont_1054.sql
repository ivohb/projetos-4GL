create table man_apont_1054 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null ,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15) not null ,
    num_lote char(15) not null ,
    dat_inicial datetime year to day not null ,
    dat_final datetime year to day not null ,
    cod_recur char(5),
    cod_operac char(5) ,
    num_seq_operac decimal(3,0)  ,
    oper_final char(1) not null ,
    cod_cent_trab char(5)  ,
    cod_cent_cust decimal(4,0),
    cod_arranjo char(5)  ,
    qtd_refugo decimal(10,3) not null ,
    qtd_sucata decimal(10,3) not null ,
    qtd_boas decimal(10,3) not null ,
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_movto char(1) not null ,
    cod_local char(10),
    qtd_hor decimal(11,7) not null ,
    matricula char(8),
    cod_turno char(1) not null ,
    hor_inicial datetime hour to second not null ,
    hor_final datetime hour to second not null ,
    unid_funcional char(10),
    dat_atualiz datetime year to second not null ,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8) not null ,
    nom_usuario char(8) not null ,
    cod_status char(1) not null ,
    num_seq_apont integer not null ,
    num_processo integer not null 
  ) 


create index man_apont_1054 on man_apont_1054 
    (cod_empresa,num_ordem) using btree  in prd;


