drop table apont_balan_454;
create table apont_balan_454 
  (
    cod_empresa    char(2) not null ,
    id_registro    integer not null ,
    num_ordem      integer not null ,
    num_pedido     integer,
    num_seq_pedido integer,
    cod_item       char(15) not null ,
    cod_roteiro    char(15),
    num_rot_alt    decimal(2,0),
    num_lote       char(15),
    dat_inicial    datetime year to day not null ,
    dat_final      datetime year to day not null ,
    cod_recur      char(5),
    cod_operac     char(5) not null ,
    num_seq_operac decimal(3,0) not null ,
    oper_final     char(1) not null ,
    cod_cent_trab  char(5) not null ,
    cod_cent_cust  decimal(4,0),
    cod_unid_prod  char(5) not null ,
    cod_arranjo    char(5) not null ,
    qtd_refugo     decimal(10,3) not null ,
    qtd_sucata     decimal(10,3) not null ,
    qtd_boas       decimal(10,3) not null ,
    comprimento    integer,
    largura        integer,
    altura         integer,
    diametro       integer,
    tip_apon       char(1) not null ,
    tip_operacao   char(1) not null ,
    cod_local_prod char(10),
    cod_local_est  char(10),
    qtd_hor        decimal(11,7) not null ,
    matricula      char(8),
    cod_turno      char(1) not null ,
    hor_inicial    datetime hour to second not null ,
    hor_final      datetime hour to second not null ,
    unid_funcional char(10),
    dat_atualiz    datetime year to second,
    ies_terminado  char(1),
    cod_eqpto      char(15),
    cod_ferramenta char(15),
    integr_min     char(1),
    nom_prog       char(8) not null ,
    nom_usuario    char(8) not null ,
    cod_status     char(1) not null ,
    num_processo   integer not null ,
    num_proc_ant   integer not null ,
    num_proc_dep   integer not null ,
    num_transac    integer not null ,
    mensagem       char(210),
    dat_process    datetime year to second
  );

create unique index apont_balan_454_ix1 on apont_balan_454 
    (cod_empresa,id_registro);
create index apont_balan_454_ix2 on apont_balan_454 
    (cod_empresa,num_ordem);


