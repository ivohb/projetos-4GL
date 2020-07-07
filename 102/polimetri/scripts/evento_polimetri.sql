{ TABLE "toni".evento_polimetri row size = 81 number of columns = 5 index size = 
              13 }
create table "toni".evento_polimetri 
  (
    cod_empresa char(2) not null constraint "toni".n5611_43960,
    cod_evento decimal(3,0) not null constraint "toni".n5611_43961,
    den_evento char(50) not null constraint "toni".n5611_43962,
    cta_debito char(23) not null constraint "toni".n5612_43965,
    cod_hist_deb decimal(3,0) not null constraint "toni".n5611_43964,
    primary key (cod_empresa,cod_evento) constraint "toni".pk_evento
  );
revoke all on "toni".evento_polimetri from "public";





