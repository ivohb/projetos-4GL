create table usuario_funcao_455 (
   cod_usuario char(08) not null,
   funcao      char(01) not null
);

create unique index usuario_funcao_455
on usuario_funcao_455(cod_usuario, funcao);



create table indicadores_455 (
   cod_indicador char(08) not null,
   descricao     char(30) not null
);

create unique index indicadores_455
on indicadores_455(cod_indicador);


create table validade_indicador_455 (
   cod_cliente	    Char(15) not null,
   cod_indicador	  Char(05) not null,
   valor	          Decimal(12,2)	not null,
   dat_ini_vigencia	date	not null,
   dat_fim_vigencia	date	not null
);

create unique index val_indicador_455_1
on validade_indicador_455(
   cod_cliente, cod_indicador, dat_ini_vigencia);

create unique index val_indicador_455_2
on validade_indicador_455(
   cod_cliente, cod_indicador, dat_fim_vigencia);


create table perguntas_455 (
   cod_pergunta	    Char(05) not null,
   descricao	      Char(40) not null,
   tipo	            Char(01) not null,
   pct_peso	        Decimal(4,2) not null,
   val_comparativo	Decimal(12,2) not null,
   codicao_debitar  Char(02) not null
);

create unique index perguntas_455 
on perguntas_455 (cod_pergunta);

create table formulas_455 (
   cod_pergunta	  Char(05) not null,
   num_sequencia	integer	not null,
   operando	      Char(05) not null,
   tipo	          Char(01) not null
);

create unique index formulas_455
on formulas_455(cod_pergunta, num_sequencia);


create table analise_455 (
   cod_cliente	      Char(15) not null, 
   num_processo	      integer not null,        
   num_versao	        integer not null,          
   val_credito	      Decimal(12,2) not null,  
   val_referencia	    Decimal(12,2) not null,
   val_analista 	    Decimal(12,2) not null,
   val_gerente  	    Decimal(12,2) not null,
   val_vendedor 	    Decimal(12,2) not null,
   val_aprovador 	    Decimal(12,2) not null,
   prz_validade	      date not null,           
   dat_inclusao	      date not null,           
   dat_alteracao	    date,
   cod_status	        Char(01) not null,         
   usuario_inclusao	  Char(08) not null,   
   usuario_alteracao	Char(08),
   dat_refer_vigen	  date not null,
   observacao         Char(70)   
);

create unique index analise_455 on analise_455
 (cod_cliente, num_processo, num_versao)

create table analise_pergunta_455 (
   cod_cliente	      Char(15) not null,       
   num_processo	      integer	not null,
   num_versao	        integer	not null,
   cod_pergunta	      Char(05) not null,
   peso_cadastrado	  Decimal(4,2)	not null,
   peso_informado	    Decimal(4,2)	not null,
   formula	          Char(200),
   val_formula     	  Decimal(12,2),
   val_comparativo	  Decimal(12,2)	not null,
   ies_debitar  	    Char(01)	not null,
   observacao         Char(600)
);

create index analise_pergunta_455 on
analise_pergunta_455(cod_cliente, num_processo, num_versao);   


create table analise_indicador_455 (
   cod_cliente	  Char(15) not null,
   num_processo	  integer not null,
   num_versao	    integer not null,
   cod_indicador	Char(05) not null,
   val_indicador	Decimal(12,2) not null
);


create table analise_usuario_455 (
   cod_cliente	  Char(15) not null,
   num_processo	  integer not null,
   num_versao	    integer not null,
   cod_usuario    char(08) not null,
   funcao         char(01) not null
);

create unique index analise_usuario_455 on
analise_usuario_455(cod_cliente, num_processo, funcao);   


create table pct_faturamento_455 (
   valor_de	     Decimal(12,2) not null,
   valor_ate  	 Decimal(12,2) not null,
   pct_aplicado	 Decimal(4,2) not null,
   cod_indicador char(08) not null
);

create table pct_lucro_455 (
   valor_de	     Decimal(12,2) not null,
   valor_ate  	 Decimal(12,2) not null,
   pct_aplicado  Decimal(4,2) not null,
   cod_indicador char(08) not null
);


