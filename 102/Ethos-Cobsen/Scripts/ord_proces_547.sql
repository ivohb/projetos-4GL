   CREATE TABLE ord_proces_547 (
     cod_empresa     char(02),
     num_ordem       INTEGER,
     operacao        char(05),          
     dat_proces      char(19),
     primary key(cod_empresa, num_ordem, operacao)
   );


   CREATE TABLE ord_erro_547 (
     cod_empresa     char(02),
     num_ordem       INTEGER,
     dat_proces      char(19),
     operacao        char(05),          
     den_erro        char(120)
   );

   create index ix_ord_erro_547  on
   ord_erro_547(cod_empresa);
   
   
