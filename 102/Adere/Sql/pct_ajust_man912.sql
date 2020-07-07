drop table pct_ajust_man912;
create table pct_ajust_man912
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
    prog_import_op char(7),
    cod_operac char(05),
    cod_maquina char(15)
  );


create unique index ix_pct_man912 on pct_ajust_man912
    (cod_empresa) ;

alter table pct_ajust_man912 add cod_maquina char(15)