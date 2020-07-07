
create table rovpct_ajust_man912 
  (
    cod_empresa char(2) not null ,
    pct_ajus_insumo decimal(5,2) not null ,
    nom_caminho char(50),
    aponta_eqpto_recur char(1) not null ,
    aponta_ferramenta char(1) not null 
  );


create unique index rovix_pct_man912 on rovpct_ajust_man912 
    (cod_empresa);


