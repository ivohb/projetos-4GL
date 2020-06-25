drop table pedido_sical;
create table pedido_sical (
  num_versao            integer,
  versao_atual          varchar(01),
  cnpj_empresa          varchar(19),   
  cod_empresa           varchar(02),  
  pedido_sical          varchar(10),      
  tipo_pedido           varchar(01),      
  cnpj_cpf_cliente      varchar(20),     
  dt_emissao            varchar(30),         
  entrega_futura        varchar(01),      
  cod_portador          varchar(05),      
  cod_cond_pagto        varchar(03),      
  cnpj_cpf_vendedor     varchar(20),     
  pedido_logix          integer,      
  situacao              varchar(01),
  pedido_bloqueado      varchar(01),
  tipo_frete            varchar(01),
  insc_estad            varchar(15)
);

create unique index ix1_pedido_sical on
 pedido_sical(cnpj_empresa, pedido_sical, num_versao);
 
drop table pedido_compl_sical;
create table pedido_compl_sical (
  num_versao            integer,
  cnpj_empresa          varchar(19),     
  pedido_sical          varchar(10),      
  obs                   varchar(120),    
  obs_nota_fiscal       varchar(120),
);  

create index ix1_pedido_compl_sical on
 pedido_compl_sical(cnpj_empresa, pedido_sical, num_versao);

drop table ped_item_sical;
create table ped_item_sical (
  num_versao            integer,
  cnpj_empresa          varchar(19),
  pedido_sical          varchar(10),    
  cod_produto           varchar(15),
  qtd_prod_tonelada     varchar(12),
  qtd_canc_tonelada     varchar(12),
  dat_cancelamento      varchar(10),
  preco_tabela          varchar(12),
  pct_desc              varchar(12),
  preco_unit_liquido    varchar(12),
  total_bruto           varchar(12),
  total_liquido         varchar(12)
);

create unique index ix1_ped_item_sical on
 ped_item_sical(num_versao, cnpj_empresa, pedido_sical, cod_produto);

 
drop table pedido_erro_sical; 
create table pedido_erro_sical (
  num_versao            integer,
  cnpj_empresa          varchar(19),
  pedido_sical          varchar(10),    
  mensagem              varchar(120)
);

create index ix_pedido_erro_sical on
 pedido_erro_sical(num_versao, cnpj_empresa, pedido_sical);

drop table nota_sical;
create table nota_sical (
  cod_empresa           varchar(02),
  num_transac           integer,
  num_nota              integer,            
  serie                 varchar(05),
  pedido_sical          varchar(10),
  sit_nota              varchar(01)
);

create unique index ix_nota_sical on
 nota_sical(cod_empresa, num_transac, sit_nota);

drop table de_para_produto;
create table de_para_produto (
   cod_empresa           varchar(02),
   cod_sical             varchar(15),
   cod_logix             varchar(15),
   primary key(cod_empresa, cod_sical)
);


drop table nat_oper_sical;
create table nat_oper_sical (
   tip_pedido            varchar(01),
   entrega_furura        varchar(01),
   cod_nat_venda         integer,
   cod_nat_remessa       integer,
   primary key(tip_pedido, entrega_furura)
);

drop table cnpj_empresa;
create table cnpj_empresa (
  num_cnpj          varchar(19),
  cod_empresa       varchar(02),
  dat_corte         varchar(10)
);

create unique index ix_cnpj_empresa on
 cnpj_empresa(num_cnpj);
 
 -- FAVOR CONFERIR OS DADOS ABAIXO
 
 insert into cnpj_empresa(num_cnpj, cod_empresa, dat_corte) 
    values ('005.872.541/0001-23','21','2020-05-01')
 insert into cnpj_empresa(num_cnpj, cod_empresa, dat_corte) 
    values ('005.872.541/0004-76','24','2020-05-01')
 
 