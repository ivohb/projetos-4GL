{ TABLE "admlog".man_ordem_drummer row size = 136 number of columns = 12 index size 
              = 37 }
create table "admlog".man_ordem_drummer 
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
revoke all on "admlog".man_ordem_drummer from "public" as "admlog";


create unique index "admlog".ix_man_ord_drum_1 on "admlog".man_ordem_drummer 
    (empresa,ordem_mps) using btree ;


