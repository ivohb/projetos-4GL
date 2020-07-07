
create table man_erro_405 
  (
    cod_empresa char(2) not null ,
    num_programa char(50) not null ,
    num_ordem integer not null ,
    den_critica char(150) not null 
  ) extent size 132 next size 16 lock mode row;

create index man_erro_405 on man_erro_405 
    (cod_empresa,num_programa);


create trigger trg_man_erro_405_ins insert on 
    man_erro_405 referencing new as new
    for each row
        (
        execute procedure proc_man_erro_nest_405(new.cod_empresa 
    ,new.num_ordem ,new.den_critica ,new.num_programa ));

