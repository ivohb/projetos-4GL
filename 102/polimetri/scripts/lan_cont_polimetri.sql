create table lan_cont_polimetri 
  (
    cod_empresa char(2) not null,
    num_docum char(10) not null,
    ies_tip_docum char(2) not null,
    cod_evento decimal(3,0) not null,
    valor_evento decimal(10,2) not null,
    primary key (cod_empresa,num_docum,ies_tip_docum,cod_evento) 
            constraint pk_lan_pol
  );
revoke all on lan_cont_polimetri from "public";





