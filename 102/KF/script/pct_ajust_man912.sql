






{ TABLE "informix".pct_ajust_man912 row size = 79 number of columns = 11 index size = 7 }

create table "informix".pct_ajust_man912 
  (
    cod_empresa char(2),
    pct_ajus_insumo decimal(5,2),
    nom_caminho char(50),
    aponta_eqpto_recur char(1),
    aponta_ferramenta char(1),
    finaliza char(1),
    aponta_refugo char(1),
    qtd_nivel_aen integer,
    aponta_parada char(1),
    prog_export_op char(7),
    prog_import_op char(7)
  );

revoke all on "informix".pct_ajust_man912 from "public" as "informix";


create unique index "informix".ix_pct_man912 on "informix".pct_ajust_man912 
    (cod_empresa) using btree ;


