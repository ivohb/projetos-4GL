drop table pedido_sical;
create table pedido_sical (
  num_versao            integer,
  versao_atual          char(01),
  cnpj_empresa          char(19),   
  cod_empresa           char(02),  
  pedido_sical          char(10),      
  tipo_pedido           char(01),      
  cnpj_cpf_cliente      char(20),     
  dt_emissao            char(30),         
  entrega_futura        char(01),      
  cod_portador          char(05),      
  cod_cond_pagto        char(03),      
  cnpj_cpf_vendedor     char(20),     
  pedido_logix          integer,      
  situacao              char(01),
  pedido_bloqueado      char(01),
  tipo_frete            char(01),
  insc_estad            char(15)
);

create unique index ix1_pedido_sical on
 pedido_sical(cnpj_empresa, pedido_sical, num_versao);
 
drop table pedido_compl_sical;
create table pedido_compl_sical (
  num_versao            integer,
  cnpj_empresa          char(19),     
  pedido_sical          char(10),      
  obs                   char(120),    
  obs_nota_fiscal       char(120),
);  

create index ix1_pedido_compl_sical on
 pedido_compl_sical(cnpj_empresa, pedido_sical, num_versao);

drop table ped_item_sical;
create table ped_item_sical (
  num_versao            integer,
  cnpj_empresa          char(19),
  pedido_sical          char(10),    
  cod_produto           char(15),
  qtd_prod_tonelada     char(12),
  qtd_canc_tonelada     char(12),
  dat_cancelamento      char(10),
  preco_tabela          char(12),
  pct_desc              char(12),
  preco_unit_liquido    char(12),
  total_bruto           char(12),
  total_liquido         char(12)
);

create unique index ix1_ped_item_sical on
 ped_item_sical(num_versao, cnpj_empresa, pedido_sical, cod_produto);

 
drop table pedido_erro_sical;
create table pedido_erro_sical (
  num_versao            integer,
  cnpj_empresa          char(19),
  pedido_sical          char(10),    
  mensagem              char(120)
);

create index ix_pedido_erro_sical on
 pedido_erro_sical(num_versao, cnpj_empresa, pedido_sical);
