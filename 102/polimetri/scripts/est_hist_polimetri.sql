{ TABLE "informix".est_hist_polimetri row size = 93 number of columns = 12 index 
              size = 0 }
create table "informix".est_hist_polimetri 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    mes_ref decimal(2,0) not null ,
    ano_ref decimal(4,0) not null ,
    ano_mes_ref decimal(6,0) not null ,
    qtd_entrada decimal(15,3) not null ,
    qtd_saida decimal(15,3) not null ,
    qtd_mes_ant decimal(15,3) not null ,
    cus_unit_medio decimal(17,6) not null ,
    cus_unit_forte decimal(17,6) not null ,
    cus_unit_medio_rep decimal(17,6) not null ,
    cus_unit_forte_rep decimal(17,6) not null 
  );
revoke all on "informix".est_hist_polimetri from "public" as "informix";




