drop index ix_ordens_99;

create index "suporte".ix_ordens_99 on ordens (cod_empresa,
    ies_situa, num_docum, dat_entrega, cod_item) using btree ;
