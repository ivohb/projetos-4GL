






{ TABLE item_corresp row size = 42 number of columns = 4 index size = 
              20 }
create table item_corresp 
  (
    cod_item_ped char(15) not null ,
    cod_item_nf char(15) not null ,
    qtd_item_ped decimal(9,3) not null ,
    qtd_item_nf decimal(9,3) not null 
  );
revoke all on item_corresp from "public";


create index ix_itcorr_1 on item_corresp 
    (cod_item_ped) using btree ;


