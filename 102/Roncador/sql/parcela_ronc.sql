
create table parcela_ronc (
 cod_empresa     char(02),
 num_reserva     integer,
 num_invent      char(15),
 usuario         char(08),
 data            date,
 hora            char(08)
 primary key (cod_empresa, num_reserva)
);

