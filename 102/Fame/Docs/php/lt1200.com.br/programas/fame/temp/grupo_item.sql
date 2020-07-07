{ TABLE "suporte".grupo_item row size = 57 number of columns = 6 index size = 8 }
create table "suporte".grupo_item 
  (
    cod_grupo_item char(3) not null constraint "informix".nn2240_14400,
    den_grupo_item char(25) not null constraint "informix".nn2240_14401,
    ultimo_pct_reajus decimal(5,2),
    sit_grupo_item char(1) not null ,
    compl_des_grp_item char(20),
    dat_atualiz date,
    primary key (cod_grupo_item)  constraint "informix".pk_grup_ite_1
  );
revoke all on "suporte".grupo_item from "public";






