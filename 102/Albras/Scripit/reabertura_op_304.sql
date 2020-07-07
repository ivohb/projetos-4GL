
create table reabertura_op_304 (
  cod_empresa       char(02),
  num_op            integer,
  usuario           char(08),
  data              date,
  motivo            char(150)
);

create index ix1_reabre_op on reabertura_op_304
 (cod_empresa, num_op);

  
