{ TABLE "admlog".man_apont_erro_454 row size = 264 number of columns = 5 index size 
              = 11 }
create table "admlog".man_apont_erro_454 
  (
    empresa char(2) not null ,
    ordem_producao integer not null ,
    operacao char(5),
    sequencia_operacao decimal(3,0),
    texto_erro char(250)
  );
revoke all on "admlog".man_apont_erro_454 from "public" as "admlog";


create index "admlog".ix1_apont_erro_454 on "admlog".man_apont_erro_454 
    (empresa,ordem_producao) using btree ;


