CREATE  TABLE tempo_proces912(
 operacao     char(120),
 hor_ini      datetime hour to second,
 hor_fim      datetime hour to second
 
);

create index ix_tempo912 on 
 tempo_proces912(operacao);