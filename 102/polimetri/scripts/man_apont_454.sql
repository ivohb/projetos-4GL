{ TABLE "admlog".man_apont_454 row size = 186 number of columns = 29 index size = 
              11 }
create table "admlog".man_apont_454 
  (
    empresa char(2) not null ,
    dat_ini_producao char(10) not null ,
    dat_fim_producao char(10),
    item char(15) not null ,
    ordem_producao integer not null ,
    sequencia_operacao decimal(3,0) not null ,
    operacao char(5) not null ,
    centro_trabalho char(5) not null ,
    arranjo char(5) not null ,
    qtd_refugo decimal(10,3),
    qtd_boas decimal(10,3),
    tip_movto char(1) not null ,
    local char(10),
    qtd_hor decimal(11,7),
    matricula char(8) not null ,
    sit_apont char(1) not null ,
    turno char(1) not null ,
    hor_inicial char(10) not null ,
    hor_fim char(10),
    refugo integer,
    parada char(3),
    hor_ini_parada datetime hour to minute,
    hor_fim_parada datetime hour to minute,
    unid_funcional char(10),
    dat_atualiz char(10),
    terminado char(1),
    eqpto char(15),
    ferramenta char(15),
    integr_min char(1)
  );
revoke all on "admlog".man_apont_454 from "public" as "admlog";


create index "admlog".ix1_man_apont_454 on "admlog".man_apont_454 
    (empresa,ordem_producao) using btree ;


