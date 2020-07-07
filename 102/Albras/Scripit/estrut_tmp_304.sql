{ TABLE "admlog".estrut_tmp_304 row size = 47 number of columns = 7 index size = 
              0 }
create table "admlog".estrut_tmp_304 
  (
    num_seq integer,
    cod_item_pai char(15),
    cod_item char(15),
    tip_item char(1),
    qtd_prodcomp decimal(14,7),
    gerar char(2),
    explodiu char(1)
  );
revoke all on "admlog".estrut_tmp_304 from "public" as "admlog";




