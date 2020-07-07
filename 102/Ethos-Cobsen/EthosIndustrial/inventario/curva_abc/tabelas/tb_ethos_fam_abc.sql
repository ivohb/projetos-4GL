--- tabela de familias para classificacao da curva abc

drop table ethos_fam_abc;

create table "informix".ethos_fam_abc 
  (
    cod_empresa      char(02),
    cod_familia      char(03)
  );

revoke all on "informix".ethos_fam_abc from "public" as "informix";


create unique index "informix".ix_eth_fam_abc_1 on "informix".ethos_fam_abc 
    (cod_empresa,cod_familia) using btree ;

