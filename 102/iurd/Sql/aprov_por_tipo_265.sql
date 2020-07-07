create table aprov_por_tipo_265(
   usuario       char(08),
   ies_aprova    char(01),
   empresa       char(02),
   estado        char(02),
   tip_despesa   decimal(4,0),
   qtd_titulos   integer,
   val_titulos   decimal(12,2),
   dat_aprov     date,
   hor_aprov     char(08)
);

   
create index ix_aprov_por_tipo_265
 on aprov_por_tipo_265(usuario,empresa);
 