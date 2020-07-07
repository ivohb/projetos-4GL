
drop index ix_analis_mest_915_1;
create unique index ix_analis_mest_915_1 on
    analise_mest_915 (cod_empresa,cod_item,lote_tanque,
    num_pa, identif_estoque) ;

drop index ix_analis_915_1;
create unique index ix_analis_915_1 on
    analise_915 (cod_empresa,cod_item,lote_tanque,
    tip_analise,num_pa, identif_estoque);


alter table analise_mest_915 drop column identif_estoque;
alter table analise_mest_915 add identif_estoque char(30) default '0';
alter table analise_915 add identif_estoque char(30)  default '0';
