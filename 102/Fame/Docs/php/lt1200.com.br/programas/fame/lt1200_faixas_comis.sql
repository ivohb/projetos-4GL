{ TABLE "admlog".lt1200_faixas_comis row size = 31 number of columns = 4 index size 
              = 37 }
create table "admlog".lt1200_faixas_comis 
  (
    faixa integer not null ,
    pct_ini decimal(16,2) not null ,
    pct_fin decimal(16,2) not null ,
    pct_sal decimal(16,2) not null 
  );
revoke all on "admlog".lt1200_faixas_comis from "public" as "admlog";


create index "admlog".ix118_1 on "admlog".lt1200_faixas_comis 
    (faixa) using btree ;
create index "admlog".ix118_2 on "admlog".lt1200_faixas_comis 
    (pct_ini) using btree ;
create index "admlog".ix118_3 on "admlog".lt1200_faixas_comis 
    (pct_fin) using btree ;


