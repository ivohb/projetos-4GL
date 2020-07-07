create table lt1200_faixas_comis_tlmk (
faixa integer not null,
pct_ini decimal(16,2) not null,
pct_fin decimal(16,2) not null,
pct_sal decimal(16,2) not null
);

create index ix_lt1200_faixas_comis_tlmk on lt1200_faixas_comis_tlmk 
(pct_ini,pct_fin);