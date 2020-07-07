






{ TABLE "informix".rovapont_hist_man912 row size = 132 number of columns = 19 index 
              size = 13 }
create table "informix".rovapont_hist_man912 
  (
    chav_seq integer not null ,
    num_versao decimal(5,0),
    dat_producao char(8),
    cod_item char(15),
    num_op char(9),
    cod_operac char(9),
    cod_maquina char(3),
    qtd_refugo char(8),
    qtd_boas char(8),
    tip_mov char(1),
    mat_operador char(8),
    cod_turno char(1),
    hor_ini char(6),
    hor_fim char(6),
    cod_mov char(5),
    arq_orig char(20),
    situacao char(1),
    usuario char(8),
    programa char(8)
  );

revoke all on "informix".rovapont_hist_man912 from "public" as "informix";


create unique index "informix".rovapont_hist_man912 on "informix"
    .rovapont_hist_man912 (chav_seq,num_versao) using btree ;
    

