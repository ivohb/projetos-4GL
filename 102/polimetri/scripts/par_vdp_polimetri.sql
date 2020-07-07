{ TABLE "informix".par_vdp_polimetri row size = 10 number of columns = 3 index size 
              = 7 }
create table "informix".par_vdp_polimetri 
  (
    cod_empresa char(2),
    pct_margem decimal(5,2),
    pct_outras_desp decimal(5,2),
    primary key (cod_empresa)  constraint "informix".pk_par_vdp_poli
  );
revoke all on "informix".par_vdp_polimetri from "public" as "informix";




