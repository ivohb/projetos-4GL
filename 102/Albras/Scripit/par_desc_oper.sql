{ TABLE "toni".par_desc_oper row size = 22 number of columns = 8 index size = 7 }
create table "toni".par_desc_oper 
  (
    cod_emp_ofic char(2) not null ,
    cod_emp_oper char(2) not null ,
    max_desc_oper decimal(5,2) not null ,
    per_jur_dia decimal(5,4) not null 
    
  );
revoke all on "toni".par_desc_oper from "public";



create index "toni".ix_pardes_1 on "toni".par_desc_oper (cod_emp_ofic) 
    using btree ;



