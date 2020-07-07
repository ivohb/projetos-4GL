{ TABLE "informix".ped_itens row size = 112 number of columns = 16 index size = 103 
              }
create table "informix".ped_itens 
  (
    cod_empresa char(2) not null constraint "informix".nn3220_21526,
    num_pedido decimal(6,0) not null constraint "informix".nn3220_21527,
    num_sequencia decimal(5,0) not null constraint "informix".nn3220_21528,
    cod_item char(15) not null constraint "informix".nn3220_21529,
    pct_desc_adic decimal(4,2) not null constraint "informix".nn3220_21530,
    pre_unit decimal(17,6) not null constraint "informix".nn3220_21531,
    qtd_pecas_solic decimal(10,3) not null constraint "informix".nn3220_21532,
    qtd_pecas_atend decimal(10,3) not null constraint "informix".nn3220_21533,
    qtd_pecas_cancel decimal(10,3) not null constraint "informix".nn3220_21534,
    qtd_pecas_reserv decimal(10,3) not null constraint "informix".nn3220_21535,
    prz_entrega date not null constraint "informix".nn3220_21536,
    val_desc_com_unit decimal(15,2) not null constraint "informix".nn3220_21537,
    val_frete_unit decimal(17,6) not null constraint "informix".nn3220_21538,
    val_seguro_unit decimal(17,6) not null constraint "informix".nn3220_21539,
    qtd_pecas_romaneio decimal(10,3) not null constraint "informix".nn3220_21540,
    pct_desc_bruto decimal(9,6) not null constraint "informix".nn3220_21541,
    primary key (cod_empresa,num_pedido,num_sequencia)  constraint "informix".pk_peditens_3
  );
revoke all on "informix".ped_itens from "public";



create index "admlog".ix_peditens_1 on "informix".ped_itens (cod_empresa,
    num_pedido) using btree ;
create index "admlog".ix_peditens_2 on "informix".ped_itens (cod_empresa,
    cod_item) using btree ;
create unique index "admlog".ix_peditens_4 on "informix".ped_itens 
    (cod_empresa,num_pedido,num_sequencia,cod_item) using btree 
    ;
create index "admlog".ix_peditens_5 on "informix".ped_itens (cod_empresa,
    num_pedido,qtd_pecas_solic,qtd_pecas_cancel) using btree 
    ;



