{ TABLE "admlog".lt1200_faixas_comis row size = 31 number of columns = 4 index size 
              = 37 }
create table "admlog".lt1200_faixas_comis_geral 
  (
    faixa integer not null ,
    pct_ini decimal(16,2) not null ,
    pct_fin decimal(16,2) not null ,
    pct_sal decimal(16,2) not null 
  );
revoke all on "admlog".lt1200_faixas_comis_geral from "public" as "admlog";


create index "admlog".ix118_11 on "admlog".lt1200_faixas_comis_geral 
    (faixa) using btree ;
create index "admlog".ix118_21 on "admlog".lt1200_faixas_comis_geral 
    (pct_ini) using btree ;
create index "admlog".ix118_31 on "admlog".lt1200_faixas_comis_geral 
    (pct_fin) using btree ;


