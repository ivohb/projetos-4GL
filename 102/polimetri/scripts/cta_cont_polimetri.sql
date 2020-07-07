{ TABLE "toni".cta_cont_polimetri row size = 28 number of columns = 3 index size 
              = 43 }
create table "toni".cta_cont_polimetri 
  (
    cod_empresa char(2) not null constraint "toni".n5233_43687,
    num_conta char(23) not null constraint "toni".n5233_43688,
    cod_hist decimal(3,0) not null constraint "toni".n5233_43741
  );
revoke all on "toni".cta_cont_polimetri from "public";

create unique index "toni".ix_cta_polimetri on "toni".cta_cont_polimetri 
    (cod_empresa,num_conta);




