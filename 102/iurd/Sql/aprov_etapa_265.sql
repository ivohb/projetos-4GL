--Estapas que o solicitante selecionou para serem aprovadas
--por um dos aprovantes

create table aprov_etapa_265 
  (
    cod_empresa     char(02) not null,
    unid_funcional  char(10) not null,  
    num_contrato    integer  not null,
    versao_contrato integer  not null,
    num_etapa       integer  not null,
    cod_aprovador   char(02),
    usuario_aprov   char(08),
    dat_aprov       date,
    hor_aprova      char(08),
    usuario_solic   char(08),
    dat_solic       date,
    hor_solic       char(08)
  );

create index aprov_etapa_265_1 on aprov_etapa_265 
    (cod_empresa, cod_aprovador);
    
create unique index aprov_etapa_265_2 on aprov_etapa_265 
    (cod_empresa,cod_aprovador,num_contrato,num_etapa);

create unique index aprov_etapa_265_3 on aprov_etapa_265 
    (cod_empresa,num_contrato,versao_contrato,num_etapa);

