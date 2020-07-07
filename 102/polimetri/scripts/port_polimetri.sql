{ TABLE "toni".port_polimetri row size = 32 number of columns = 4 index size = 15 
              }
create table "toni".port_polimetri 
  (
    cod_empresa char(2) not null constraint "toni".n5237_43699,
    cod_portador decimal(4) not null constraint "toni".n5237_43700,
    num_conta char(23) not null constraint "toni".n5237_43701,
    cod_hist decimal(3) not null constraint "toni".n5237_43702
  );
revoke all on "toni".port_polimetri from "public";

create unique index "toni".ix_port_polimetri on "toni".port_polimetri 
    (cod_empresa,cod_portador);




