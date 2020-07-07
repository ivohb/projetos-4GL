create table audit_cre_912 (
   cod_empresa         char(02),
   pedido              integer,
   limpeza             char(20),
   usuario             char(08),
   dias_atr_duplicata  integer,
   dias_atr_medio      integer,
   motivo              char(90)
);

create index audit_cre_912 on
 audit_cre_912(cod_empresa, pedido);
 