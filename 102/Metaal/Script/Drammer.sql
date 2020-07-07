create table man_ordem_drummer 
  (
    empresa char(2) not null ,
    ordem_producao char(30),
    item char(30) not null ,
    dat_recebto date not null ,
    qtd_ordem decimal(12,2) not null ,
    ordem_mps char(30) not null ,
    status_ordem char(1) not null ,
    status_import char(1),
    dat_liberacao date not null ,
    qtd_pecas_boas decimal(12,2) not null ,
    docum char(10),
    num_projeto char(10)
  );

create unique index ix_man_ord_drum_1 on man_ordem_drummer 
    (empresa,ordem_mps) ;
    

create table man_oper_drummer 
  (
    empresa char(2) not null ,
    ordem_mps char(30) not null ,
    item char(30) not null ,
    operacao char(5) not null ,
    des_operacao char(40),
    sequencia_operacao decimal(3,0) not null ,
    centro_trabalho char(10),
    arranjo char(5),
    tmp_maquina_prepar decimal(8,2) not null ,
    tmp_maq_execucao decimal(14,6) not null ,
    tmp_mdo_prepar decimal(8,2) not null ,
    tmp_mdo_execucao decimal(14,6) not null ,
    relacao_ferramenta char(150),
    dat_ini_planejada datetime year to second not null ,
    dat_trmn_planejada datetime year to second not null ,
    qtd_planejada decimal(12,2) not null ,
    qtd_real decimal(12,2) not null ,
    qtd_sucata decimal(12,2) not null 
  );

create unique index ix_man_oper_drum_1 on man_oper_drummer 
    (empresa,ordem_mps,operacao,sequencia_operacao);



create table man_necd_drummer 
  (
    empresa char(2) not null ,
    ordem_mps char(30) not null ,
    necessidad_ordem integer not null ,
    item char(30) not null ,
    qtd_necess decimal(12,2) not null ,
    qtd_requis decimal(12,2) not null 
  );

create unique index ix_man_necd_drum_1 on man_necd_drummer 
    (empresa,ordem_mps,necessidad_ordem) using btree ;

    