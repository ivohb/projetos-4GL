drop table man_apo_logix_405 
create table man_apo_logix_405 
  (
    cod_empresa char(2) not null ,
    num_ordem integer not null ,
    cod_item char(15) not null ,
    num_docum char(10), 
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
    qtd_baixar decimal(10,3) not null ,
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_movto char(1) not null ,
    cod_local_prod char(10),
    cod_local_estoq char(10),
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
    baixa_sucata decimal(10,3),
    id_nest      integer
  );

create index man_apo_logix_405_i1 on 
    man_apo_logix_405 (cod_empresa,num_programa) 
    
create unique index man_apo_logix_405_i2 on 
    man_apo_logix_405 (cod_empresa,id_man_apont) 


drop  table man_apo_nest_405 
create table man_apo_nest_405 
  (
    cod_empresa char(2) not null ,
    num_programa char(50) not null ,
    num_ordem integer not null ,
    cod_operac char(5),
    cod_item_compon char(15),
    qtd_produzida decimal(10,3),
    pes_unit decimal(14,7),
    tempo_unit char(8),
    tip_registro char(1) not null ,
    cod_item char(15),
    qtd_boas decimal(10,3),
    qtd_apontada decimal(10,3)       default 0.000,
    qtd_refugo  decimal(10,3)         default 0.000,
    cod_defeito decimal(3,0),
    pes_sucata  decimal(14,7)         default 0.0000000,
    dat_import  date                  default today,
    flag        varchar(1),
    id_registro serial,
    operador char(15),
    tempo_corte_prog decimal(10,4),
    metro_linear     decimal(17,4),
    dat_integracao   char(19),
    primary key (id_registro) 
  );


create index i2_man_apo_nest_405 on man_apo_nest_405
    (cod_empresa,num_programa) ;
create index ix_man_apo_nest_405 on man_apo_nest_405
   (cod_empresa,num_programa, num_ordem)  ;



drop table man_erro_405 
create table man_erro_405 
  (
    cod_empresa char(2) ,
    num_programa char(50),
    num_ordem integer  ,
    den_critica char(500),
    dat_proces   char(19)
  ) 

create index man_erro_405 on man_erro_405 
    (cod_empresa,num_programa);


create trigger trg_man_erro_405_ins insert on 
    man_erro_405 referencing new as new
    for each row
        (
        execute procedure proc_man_erro_nest_405(new.cod_empresa 
    ,new.num_ordem ,new.den_critica ,new.num_programa ));


drop table exec_proces_405
create table exec_proces_405(
 cod_empresa    char(02),
 cod_usuario    char(08),
 dat_exec       char(19),
 mensagem       char(150),
 id_registro    serial,
 primary key(id_registro)
);

create index ix_exec_proces_405 on exec_proces_405
 (cod_empresa, dat_exec);

drop TABLE proces_apont_405
CREATE TABLE proces_apont_405 (
 cod_empresa   char(02),
 dat_proces    char(19),
 ies_proces    char(01),
 cod_usuario   char(08)
 primary key(cod_empresa)
);

drop table item_sucata_405;
create table item_sucata_405 (
 cod_empresa  char(02) not null,
 cod_operac   char(05) not null,
 cod_item     char(15) not null,
 cod_defeito  decimal(3,0),
 primary key(cod_empresa, cod_operac)
);

drop table email_apont_405;
create table email_apont_405 (
 cod_empresa  char(02) not null,
 emitente     char(50) not null,
 receptor     char(150) not null,
 primary key(cod_empresa)
);
