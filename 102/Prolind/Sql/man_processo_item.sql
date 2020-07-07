
create table man_processo_item 
  (
    empresa                char(2) not null ,
    item                   char(15) not null ,
    conteudo_grade_1       char(15),
    conteudo_grade_2       char(15),
    conteudo_grade_3       char(15),
    conteudo_grade_4       char(15),
    conteudo_grade_5       char(15),
    roteiro                char(15) not null ,
    roteiro_alternativo    decimal(2,0) not null ,
    seq_operacao           integer not null ,
    prioridade             integer not null ,
    operacao               char(5) not null ,
    centro_trabalho        char(5) not null ,
    arranjo                char(5),
    centro_custo           decimal(4,0),
    qtd_tempo              decimal(11,7) not null ,
    qtd_pecas_ciclo        decimal(12,7) not null ,
    qtd_tempo_setup        decimal(11,7) not null ,
    apontar_operacao       char(1) not null ,
    imprimir_operacao      char(1) not null ,
    operacao_final         char(1) not null ,
    pct_retrabalho         decimal(6,3) not null ,
    validade_inicial       date,
    validade_final         date,
    seq_operacao_grade     integer not null ,
    seq_processo           integer not null ,
    seq_processo_prototipo integer,
    texto_operacao         varchar(255),
    tip_tempo              char(1),
    planeja_operacao       char(1),
    considera_local_docum  char(1),
    primary key (empresa, item, seq_processo)  
  );

create index ix1_man_processo_item on 
    man_processo_item (empresa,seq_processo) ;


