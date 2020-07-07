{ TABLE "admlog".movto_ega_drummer row size = 24 number of columns = 6 index size 
              = 0 }
create table "admlog".movto_ega_drummer 
  (
    cod_empresa char(2) not null ,
    num_ordem char(9),
    cod_operac char(5),
    cod_maquina char(3),
    ies_situacao char(1),
    dat_atualiz date
  );
revoke all on "admlog".movto_ega_drummer from "public" as "admlog";




