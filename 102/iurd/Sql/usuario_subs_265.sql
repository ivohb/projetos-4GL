
create table usuario_subs_265
  (
    cod_empresa      char(2)      not null,
    cod_usuario      char(8)      not null,
    num_versao       decimal(3,0) not null,
    ies_versao_atual char(1)      not null,
    cod_usuario_subs char(8)      not null,
    dat_ini_validade date         not null,
    dat_fim_validade date         not null,
    cod_usuario_incl char(8)      not null,
    dat_inclusao     date         not null,
    hor_inclusao     char(8)      not null,
    motivo_subs      char(50)     not null
  );

create unique index usuario_subs_265_1 on usuario_subs_265 
    (cod_empresa,cod_usuario,cod_usuario_subs,dat_ini_validade,
    ies_versao_atual,num_versao) using btree ;
    
create index usuario_subs_265_2 on usuario_subs_265 
    (cod_empresa,cod_usuario_subs,ies_versao_atual,num_versao) 
    using btree ;


