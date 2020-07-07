{ TABLE "suporte".clientes row size = 336 number of columns = 32 index size = 54 
              }
create table "suporte".clientes 
  (
    cod_cliente char(15) not null constraint "informix".nn1089_5661,
    cod_class char(1) not null constraint "informix".nn1089_5662,
    nom_cliente char(36) not null constraint "informix".nn1089_5663,
    end_cliente char(36) not null constraint "informix".nn1089_5664,
    den_bairro char(19),
    cod_cidade char(5) not null constraint "informix".nn1089_5665,
    cod_cep char(9),
    num_caixa_postal char(5),
    num_telefone char(15),
    num_fax char(15),
    num_telex char(15),
    num_suframa decimal(9,0),
    cod_tip_cli char(2) not null constraint "informix".nn1089_5666,
    den_marca char(12),
    nom_reduzido char(15),
    den_frete_posto char(14),
    num_cgc_cpf char(19) not null constraint "informix".nn1089_5667,
    ins_estadual char(16),
    cod_portador decimal(4,0),
    ies_tip_portador char(1),
    cod_cliente_matriz char(15),
    cod_consig char(15),
    ies_cli_forn char(1) not null constraint "informix".nn1089_5668,
    ies_zona_franca char(1) not null constraint "informix".nn1089_5669,
    ies_situacao char(1) not null constraint "informix".nn1089_5670,
    cod_rota decimal(5,0) not null constraint "informix".nn1089_5671,
    cod_praca decimal(5,0),
    dat_cadastro date not null constraint "informix".nn1089_5672,
    dat_atualiz date not null constraint "informix".nn1089_5673,
    nom_contato char(20),
    dat_fundacao date,
    cod_local decimal(5,0) not null constraint "informix".nn1089_5674,
    primary key (cod_cliente)  constraint "informix".pk_clientes_1
  );
revoke all on "suporte".clientes from "public";



create index "suporte".ix_cliente3 on "suporte".clientes (cod_cidade) 
    using btree ;
create index "suporte".ix_clientes_2 on "suporte".clientes (num_cgc_cpf) 
    using btree ;



