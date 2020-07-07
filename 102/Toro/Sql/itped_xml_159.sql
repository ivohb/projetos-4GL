create table itped_xml_159 
  (
    cod_empresa char(2) not null ,
    num_pedido decimal(6,0) not null ,
    num_pedido_cli char(25) not null 
  );

create index ix_itped_xml_159 on itped_xml_159 
    (cod_empresa,num_pedido) using btree ;


