{ TABLE "suporte".pedidos row size = 167 number of columns = 35 index size = 135 
              }
create table "suporte".pedidos 
  (
    cod_empresa char(2) not null constraint "informix".nn2126_13628,
    num_pedido decimal(6,0) not null constraint "informix".nn2126_13629,
    cod_cliente char(15) not null constraint "informix".nn2126_13630,
    pct_comissao decimal(4,2) not null constraint "informix".nn2126_13631,
    num_pedido_repres char(10),
    dat_emis_repres date,
    cod_nat_oper integer not null ,
    cod_transpor char(15),
    cod_consig char(15),
    ies_finalidade decimal(1,0) not null constraint "informix".nn2126_13633,
    ies_frete decimal(1,0) not null constraint "informix".nn2126_13634,
    ies_preco char(1) not null constraint "informix".nn2126_13635,
    cod_cnd_pgto decimal(3,0) not null constraint "informix".nn2126_13636,
    pct_desc_financ decimal(4,2) not null constraint "informix".nn2126_13637,
    ies_embal_padrao char(1) not null constraint "informix".nn2126_13638,
    ies_tip_entrega decimal(1,0) not null constraint "informix".nn2126_13639,
    ies_aceite char(1) not null constraint "informix".nn2126_13640,
    ies_sit_pedido char(1) not null constraint "informix".nn2126_13641,
    dat_pedido date not null constraint "informix".nn2126_13642,
    num_pedido_cli char(25),
    pct_desc_adic decimal(4,2) not null constraint "informix".nn2126_13643,
    num_list_preco decimal(4,0),
    cod_repres decimal(4,0),
    cod_repres_adic decimal(4,0),
    dat_alt_sit date,
    dat_cancel date,
    cod_tip_venda decimal(2,0),
    cod_motivo_can decimal(2,0),
    dat_ult_fatur date,
    cod_moeda decimal(3,0) not null constraint "informix".nn2126_13644,
    ies_comissao char(1),
    pct_frete decimal(4,2) not null constraint "informix".nn2126_13645,
    cod_tip_carteira char(2) not null constraint "informix".nn2126_13646,
    num_versao_lista decimal(3,0) not null constraint "informix".nn2126_13647,
    cod_local_estoq char(10),
    primary key (cod_empresa,num_pedido)  constraint "informix".pk_pedidos
  );
revoke all on "suporte".pedidos from "public";



create index "informix".fame_pedidos_1 on "suporte".pedidos (cod_empresa,
    num_pedido,cod_cliente,ies_sit_pedido) using btree ;
create index "admlog".ix_pedidos_2 on "suporte".pedidos (cod_nat_oper,
    cod_empresa) using btree ;
create index "admlog".ix_pedidos_3 on "suporte".pedidos (cod_empresa,
    num_pedido_cli) using btree ;
create index "admlog".ix_pedidos_4 on "suporte".pedidos (cod_empresa,
    cod_cliente) using btree ;
create index "admlog".ix_pedidos_5 on "suporte".pedidos (cod_empresa,
    num_pedido_repres) using btree ;
create index "admlog".ix_pedidos_6 on "suporte".pedidos (cod_empresa,
    dat_pedido,ies_sit_pedido,cod_cnd_pgto) using btree ;



