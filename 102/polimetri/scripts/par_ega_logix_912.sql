{ TABLE "admlog".par_ega_logix_912 row size = 9 number of columns = 5 index size 
              = 7 }
create table "admlog".par_ega_logix_912 
  (
    cod_empresa char(2) not null ,
    hist_auto_op_enc char(1) not null ,
    compati_op_lote char(1) not null ,
    ies_baixa_pc_rej char(1) not null ,
    cod_oper_bx_pc_rej char(4)
  );
revoke all on "admlog".par_ega_logix_912 from "public" as "admlog";


create unique index "admlog".par_ega_logix_912 on "admlog".par_ega_logix_912 
    (cod_empresa) using btree ;


