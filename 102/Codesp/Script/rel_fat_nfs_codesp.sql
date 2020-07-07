
CREATE TABLE rel_fat_nfs_codesp 
  (
    cod_empresa     char(1) not null ,
    num_docum       decimal(6,0) not null ,
    especie         char(2) not null ,
    data_emissao_fa date not null ,
    data_emissao_nf date not null ,
    num_nff         decimal(6,0),
    num_transac     integer not null 
  );
  		