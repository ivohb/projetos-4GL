
drop table pedido_erro_sical;
create table pedido_erro_sical (
  num_versao            integer,
  cnpj_empresa          char(19),
  pedido_sical          char(10),    
  mensagem              char(120)
);