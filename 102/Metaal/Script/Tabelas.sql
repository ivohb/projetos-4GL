
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


create table proc_apont_man912 
  (
    processando char(1) not null ,
    hor_ini     datetime hour to second,
    cod_empresa char(2)
  );


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



create table man_log_apo_prod912 
  (
    empresa char(2) not null ,
    transacao decimal(12,0),
    seq_mensagem serial not null ,
    seq_reg_mestre decimal(10,0),
    item char(15),
    ordem_producao decimal(10,0),
    num_seq_operac decimal(3,0) not null ,
    num_operador char(15),
    tip_apontamento char(1),
    tip_movimentacao char(1),
    apo_operacao char(1),
    sit_apontamento char(1),
    operacao char(5),
    tip_mensagem char(1) not null ,
    erro decimal(10,0) not null ,
    texto_resumo char(70) not null ,
    texto_detalhado char(500),
    programa char(10) not null ,
    dat_processamento date,
    hor_processamento datetime hour to second not null ,
    usuario char(8) not null ,
    num_seq_registro integer
  );


create unique index ix1_man_log_apo_pr912 on 
    man_log_apo_prod912 (empresa,transacao,seq_mensagem) using 
    btree ;

create index ix2_man_log_apo_pr912 on man_log_apo_prod912 
    (empresa,transacao,seq_reg_mestre) using btree ;
    
create index ix3_man_log_apo_pr912 on man_log_apo_prod912 
    (empresa,item,ordem_producao,tip_mensagem) using btree ;

create index ix4_man_log_apo_pr912 on man_log_apo_prod912 
    (empresa,usuario,dat_processamento,hor_processamento);


create table op_coluna_912
  (
    cod_empresa char(2) not null ,
    cod_coluna decimal(9,0) not null ,
    coluna varchar(18),
    tamanho decimal(3,0) not null ,
    primary key (cod_empresa,cod_coluna)
  );
  
  
create table op_coluna_item_912
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_operac char(5) not null ,
    cod_roteiro char(15) not null ,
    seq_oper decimal(2,0) not null ,
    cod_coluna decimal(9,0) not null ,
    primary key (cod_empresa,cod_item,cod_operac,cod_roteiro,seq_oper)
    
create table op_col_dados_912
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_operac char(5) not null ,
    cod_roteiro char(15) not null ,
    seq_oper decimal(2,0) not null ,
    linha decimal(1,0) not null ,
    conteudo varchar(100),
    primary key (cod_empresa,cod_item,cod_operac,cod_roteiro,seq_oper,linha)
    