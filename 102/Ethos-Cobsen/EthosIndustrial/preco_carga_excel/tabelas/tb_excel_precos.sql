
--- tabela das planilhas excel de precos carregadas

drop table ethos_excel_prec;

create table "informix".ethos_excel_prec
  (
    cod_empresa              char(02),
    planilha                 char(50),
    data_carga               date,
    cod_usuario              char(18)
  );

revoke all on "informix".ethos_excel_prec from "public" as "informix";

create unique index "informix".ix_eth_exc_pre_1 on "informix".ethos_excel_prec
    (cod_empresa, planilha) using btree ;

alter table ethos_excel_prec lock mode (row);
