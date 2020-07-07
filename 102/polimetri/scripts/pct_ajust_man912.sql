{ TABLE "admlog".pct_ajust_man912 row size = 58 number of columns = 5 index size 
              = 7 }
create table "admlog".pct_ajust_man912 
  (
    cod_empresa char(2) not null ,
    pct_ajus_insumo decimal(5,2) not null ,
    nom_caminho char(50),
    aponta_eqpto_recur char(1) not null ,
    aponta_ferramenta char(1) not null 
  );
revoke all on "admlog".pct_ajust_man912 from "public" as "admlog";


create unique index "admlog".ix_pct_man912 on "admlog".pct_ajust_man912 
    (cod_empresa) using btree ;


