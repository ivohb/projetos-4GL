






{ TABLE "informix".man_apo_nest_405 row size = 157 number of columns = 17 index size = 126 }

create table "informix".man_apo_nest_405 
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
    qtd_apontada decimal(10,3) 
        default 0.000,
    qtd_refugo decimal(10,3) 
        default 0.000,
    cod_defeito decimal(3,0),
    pes_sucata decimal(14,7) 
        default 0.0000000,
    dat_import date 
        default today,
    id_registro integer 
        default 0
  ) extent size 9132 next size 912 lock mode row;

revoke all on "informix".man_apo_nest_405 from "public" as "informix";


create index "informix".i2_man_apo_nest_405 on "informix".man_apo_nest_405 
    (cod_empresa,num_programa) using btree  in tst;
create index "informix".i3_man_apo_nest_405 on "informix".man_apo_nest_405 
    (cod_empresa,num_programa,num_ordem) using btree  in tst;
    
create index "informix".ix_man_apo_nest_405 on "informix".man_apo_nest_405 
    (cod_empresa,tip_registro) using btree  in tst;


