create table apont_pw1_man912 
  (
    dat_producao char(8),
    cod_item char(14),
    num_op char(9),
    cod_operac char(9),
    cod_maquina char(3),
    qtd_refugo char(8),
    qtd_boas char(8),
    tip_mov char(1),
    mat_operador char(8),
    cod_turno char(1),
    hor_ini char(6),
    hor_fim char(6),
    cod_mov char(5),
    num_seq_operac char(3),
    den_erro char(75),
    chav_seq integer,
    arq_orig char(50),
    num_versao decimal(5,0),
    cod_empresa char(2),
    status_operacao char(1)
  );
revoke all on apont_pw1_man912 from "public" as "admlog";

create  index ix_apo_pw1_man912_1 on apont_pw1_man912
    (dat_producao,cod_item,num_op, cod_operac)  ;



