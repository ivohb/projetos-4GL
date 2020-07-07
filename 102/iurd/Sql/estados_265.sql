create table estados_265 (
   sigla      char(02) not null,
   estado     char(30) not null
);

create unique index estados_265
on estados_265(sigla);