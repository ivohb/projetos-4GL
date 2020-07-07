{ TABLE "informix".doc_desc_polimetri row size = 18 number of columns = 4 index size 
              = 19 }
create table "informix".doc_desc_polimetri 
  (
    cod_empresa char(2) not null constraint "informix".n5854_44419,
    num_docum char(10) not null constraint "informix".n5854_44420,
    ies_tip_docum char(2) not null constraint "informix".n5854_44421,
    dat_desc date not null constraint "informix".n5854_44422
  );
revoke all on "informix".doc_desc_polimetri from "public" as "informix";


create unique index "informix".ix_doc_desc_1 on "informix".doc_desc_polimetri 
    (cod_empresa,num_docum,ies_tip_docum) using btree ;


