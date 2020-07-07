{ TABLE cc_agente_vetor row size = 43 number of columns = 4 index size = 8 
              }
create table cc_agente_vetor 
  (
    cod_agente decimal(4,0) not null constraint n74390_231566,
    den_agente char(36) not null constraint n74390_231567,
    cod_tip_despesa decimal(4,0),
    ies_cofre char(1) not null constraint n74390_233491
  );
revoke all on cc_agente_vetor from "public";


create unique index ix_ccvetor_1 on cc_agente_vetor 
    (cod_agente) using btree ;


