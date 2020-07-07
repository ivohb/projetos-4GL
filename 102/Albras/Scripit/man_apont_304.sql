create table man_apont_304 
  (
    cod_empresa char(2),
    id_registro serial not null ,
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    cod_roteiro char(15),
    num_rot_alt decimal(2,0),
    num_lote char(15),
    dat_inicial datetime year to day,
    dat_final datetime year to day,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_unid_prod char(5),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_apon char(1),
    tip_operacao char(1),
    cod_local_prod char(10),
    cod_local_est char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial char(5),
    hor_final char(5),
    unid_funcional char(10),
    dat_atualiz datetime year to second,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_processo integer,
    num_proc_ant integer,
    num_proc_dep integer,
    num_transac integer,
    mensagem char(210),
    dat_process datetime year to second,
    id_apont integer,
    id_tempo integer,
    integrado integer,
    den_erro char(500),
    dat_integra char(20),
    usuario char(8),
    tip_integra char(1),
    concluido char(1),
    num_docum char(15),
    qtd_movto decimal(10,3),
    tip_movto char(1),
    qtd_tempo integer,
    dat_criacao datetime year to second,
    motivo_retrab char(15),
    motivo_refugo char(15)
  );





