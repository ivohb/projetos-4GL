create table transportador_placa_885 (
  cod_transpor   char(15) not null,
  num_placa      char(08) not null,
  tara_minima    decimal(10,2),
  primary key(cod_transpor, num_placa)
);
