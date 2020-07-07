
create table par_pw1_logix_912 
  (
    cod_empresa char(2) not null ,
    hist_auto_op_enc char(1) not null ,
    compati_op_lote char(1) not null ,
    ies_baixa_pc_rej char(1) not null ,
    cod_oper_bx_pc_rej char(4)
  );
revoke all on par_pw1_logix_912 from "public" as "admlog";


create unique index par_pw1_logix_912 on par_pw1_logix_912     (cod_empresa) ;


