drop table pedido_erro_sical; -- banco integrador
create table pedido_erro_sical (
  num_versao            integer,
  cnpj_empresa          varchar(19),
  pedido_sical          varchar(10),   
  cod_produto           varchar(15), 
  mensagem              varchar(120)
);

create index ix_pedido_erro_sical on
 pedido_erro_sical(num_versao, cnpj_empresa, pedido_sical);
 