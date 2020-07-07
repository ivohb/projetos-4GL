drop table pol1301_1054;
create table pol1301_1054 
  (
    cod_empresa char(2),
    usuario char(8),
    ano char(4),
    mes char(2),
    semana decimal(2,0),
    comp char(30),
    larg char(30),
    esp char(30),
    peso char(30),
    m2 char(30),
    num_pedido char(10),
    num_orc char(13),
    pos char(6),
    cod_item char(15),
    den_item char(18),
    num_ordem decimal(9,0),
    num_docum char(10),
    cod_local char(10),
    qtd_planejada decimal(6,0),
    qtd_saldo decimal(6,0),
    data date
  );

create unique index pol1301_1054 on pol1301_1054 
    (cod_empresa,num_ordem);


