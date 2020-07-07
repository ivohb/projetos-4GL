






{ TABLE "informix".rovapont_erro_man912 row size = 268 number of columns = 5 index 
              size = 0 }
create table "informix".rovapont_erro_man912 
  (
    empresa char(2) not null ,
    ordem_producao integer not null ,
    operacao char(9),
    sequencia_operacao decimal(3,0),
    texto_erro char(250),
    chav_seq   integer,
    ies_apont  char(01)
  );

revoke all on "informix".rovapont_erro_man912 from "public" as "informix";




