create table pct_ajust_man912 
  (
    cod_empresa char(2) not null ,
    pct_ajus_insumo decimal(5,2) not null ,
    nom_caminho char(50),
    aponta_eqpto_recur char(1) not null ,
    aponta_ferramenta char(1) not null ,
    finaliza char(1) default 'S' not null ,
    ies_multipl_100 char(1) default 'N' not null 
  );

create unique index ix_pct_man912 on pct_ajust_man912 
    (cod_empresa) using btree ;


