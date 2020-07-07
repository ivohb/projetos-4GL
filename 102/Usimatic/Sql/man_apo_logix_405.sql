
create table man_apo_logix_405 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null ,
    cod_item char(15) not null ,
    cod_compon char(15) not null ,
    num_lote char(15),
    dat_inicial date not null ,
    dat_final date not null ,
    cod_recur char(5),
    cod_operac char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    oper_final char(1) not null ,
    cod_cent_trab char(5) not null ,
    cod_cent_cust decimal(4,0),
    cod_arranjo char(5) not null ,
    qtd_refugo decimal(10,3) not null ,
    qtd_sucata decimal(10,3) not null ,
    qtd_boas decimal(10,3) not null ,
    qtd_baixar decimal(14,7),
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
    num_programa char(50) not null ,
    id_man_apont integer not null ,
    dat_inicio date,
    cod_roteiro char(15),
    num_altern_roteiro decimal(3,0),
    unid_produtiva char(5),
    dat_apontamento datetime year to second not null ,
    cod_defeito decimal(3,0),
    baixa_sucata decimal(14,7)
  );


create index man_apo_logix_405_i1 on 
    man_apo_logix_405 (cod_empresa,num_programa) 
create unique index man_apo_logix_405_i2 on 
    man_apo_logix_405 (cod_empresa,id_man_apont);

