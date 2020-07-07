create table tip_estoque_915 (
cod_empresa             char(2) not null,
tip_estoq_insp          char(6) not null,
restricao_insp          char(6) not null,
status_liberado         char(1) not null,
tip_estoq_liber         char(6) not null,
restricao_liber         char(6) not null,
status_rejeitado        char(1) not null,
tip_estoque_rejei       char(6) not null,
restricao_rejei         char(6) not null,
primary key (cod_empresa, tip_estoq_insp, restricao_insp)
);


