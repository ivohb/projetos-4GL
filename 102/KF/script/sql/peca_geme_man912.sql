
create table peca_geme_man912 
  (
    cod_empresa char(2) not null ,
    cod_peca_princ char(15) not null ,
    cod_peca_gemea char(15) not null ,
    qtd_peca_gemea integer not null 
  );

create unique index ix_peca_gem_pol on peca_geme_man912 
    (cod_empresa,cod_peca_princ,cod_peca_gemea)  ;
    


