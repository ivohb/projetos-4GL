drop table  man_necd_drummer;
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
    (empresa,ordem_mps,necessidad_ordem) ;


