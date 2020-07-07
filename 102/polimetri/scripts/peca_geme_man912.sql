{ TABLE "ana".peca_geme_man912 row size = 36 number of columns = 4 index size = 37 
              }
create table "ana".peca_geme_man912 
  (
    cod_empresa char(2) not null ,
    cod_peca_princ char(15) not null ,
    cod_peca_gemea char(15) not null ,
    qtd_peca_gemea integer not null 
  );
revoke all on "ana".peca_geme_man912 from "public" as "ana";


create unique index "ana".ix_peca_gem_pol on "ana".peca_geme_man912 
    (cod_empresa,cod_peca_princ,cod_peca_gemea) using btree ;
    


