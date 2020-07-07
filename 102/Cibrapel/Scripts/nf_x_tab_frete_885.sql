create table nf_x_tab_frete_885 (
  num_aviso_rec      integer not null,
  tip_frete          char(01) not null, --C=CIF F=FOB
  cod_transpor       char(15) not null,
  num_placa          char(08) not null,
  tabela             int not null,      --popup da tabela tab_frete_885
  versao             decimal(2,0) not null,
  val_tonelada       decimal(12,2) not null,
  peso_balanca       decimal(10,3) not null,
  peso_pagar         decimal(10,3) not null,
  val_frete          decimal(12,2) not null
);