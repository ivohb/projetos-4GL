create table credito_analise_455 (
   cod_cliente	  Char(15) not null,
   num_processo	  integer not null,
   num_versao	    integer not null,          
   funcao         Char(01) not null,
   val_do_credito	Decimal(12,2) not null,
   dat_proces 	  date
);

create unique index credito_analise_455 on credito_analise_455
   (cod_cliente, num_processo, funcao);

