{ TABLE "informix".item_vdp row size = 43 number of columns = 7 index size = 10 }
create table "informix".item_vdp 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    pre_unit_brut decimal(17,6) not null ,
    cod_grupo_item char(3) not null ,
    ies_lista_preco char(1) not null ,
    pre_unit_brut_exp decimal(17,6) not null ,
    cod_tip_carteira char(2) not null 
  );
revoke all on "informix".item_vdp from "public";



create index "informix".fame_item_vdp_1 on "informix".item_vdp 
    (cod_empresa,cod_grupo_item) using btree ;



