{ TABLE "admlog".man_necd_drummer row size = 80 number of columns = 6 index size 
              = 41 }
create table "admlog".man_necd_drummer 
  (
    empresa char(2) not null ,
    ordem_mps char(30) not null ,
    necessidad_ordem integer not null ,
    item char(30) not null ,
    qtd_necess decimal(12,2) not null ,
    qtd_requis decimal(12,2) not null 
  );
revoke all on "admlog".man_necd_drummer from "public" as "admlog";


create unique index "admlog".ix_man_necd_drum_1 on "admlog".man_necd_drummer 
    (empresa,ordem_mps,necessidad_ordem) using btree ;


