{ TABLE "suporte".linha_prod row size = 216 number of columns = 15 index size = 13 
              }
create table "suporte".linha_prod 
  (
    cod_lin_prod decimal(2,0) not null constraint "informix".nn393_1406,
    cod_lin_recei decimal(2,0) not null constraint "informix".nn393_1407,
    cod_seg_merc decimal(2,0) not null constraint "informix".nn393_1408,
    cod_cla_uso decimal(2,0) not null constraint "informix".nn393_1409,
    den_estr_linprod char(20) not null constraint "informix".nn393_1410,
    cod_unid_med char(3) not null constraint "informix".nn393_1411,
    num_conta_nacional char(23),
    num_conta_export char(23),
    ies_emite_of char(1) not null constraint "informix".nn393_1412,
    num_conta_equip char(23),
    num_conta_deb_icms char(23),
    num_conta_estoque char(23),
    num_conta_est_nac char(23),
    num_conta_est_exp char(23),
    num_conta_est_equi char(23),
    primary key (cod_lin_prod,cod_lin_recei,cod_seg_merc,cod_cla_uso)  constraint 
              "informix".pk_linprod_1
  );
revoke all on "suporte".linha_prod from "public";






