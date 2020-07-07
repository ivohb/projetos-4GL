{ TABLE "toni".desc_nat_oper row size = 31 number of columns = 5 index size = 34 
              }
create table "toni".desc_nat_oper 
  (
    cod_cliente char(15) not null constraint "toni".n3612_34724,
    cod_nat_oper integer not null constraint "toni".n3957_37576,
    pct_desc_valor decimal(5,2) not null constraint "toni".n3612_34726,
    pct_desc_qtd decimal(5,2) not null constraint "toni".n3612_34727,
    pct_desc_oper decimal(5,2) not null constraint "toni".n3612_34728
  );
revoke all on "toni".desc_nat_oper from "public";

create index "toni".ix_descno_1 on "toni".desc_nat_oper (cod_cliente,cod_nat_oper);
    




