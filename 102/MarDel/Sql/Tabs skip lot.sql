create table grupo_5054 
  (
    id_registro    int identity(1,1) primary key,
    cod_empresa    char(002) not null ,
    cod_grupo      char(003) not null ,
    descricao      char(350) not null ,
    quantidade     decimal(15,3) not null 
  );

create unique index ix1_grupo_5054 on 
    peca_gemea_5054 (cod_empresa, cod_grupo);
    

create table fornec_item_5054 
  (
    id_registro    int identity(1,1) primary key,
    cod_empresa    CHAR(02) not null ,
    cod_grupo      CHAR(03) not null ,
    cod_fornecedor CHAR(15) not null ,
    cod_item       CHAR(15) not null 
  );

create unique index ix1_fornec_item_5054 on 
 fornec_item_5054(cod_empresa, cod_fornecedor, cod_item);    
 

create table audit_skiplot_5054 
  (
    id_registro    int identity(1,1) primary key,
    cod_empresa    CHAR(02) not null ,
    cod_fornecedor CHAR(15) not null ,
    cod_item       CHAR(15) not null ,
    texto          CHAR(70) ,
    data_hora      DATETIME
  );

create INDEX ix1_audit_skip_5054 on 
 audit_skiplot_5054(cod_empresa, cod_fornecedor);    
 
create INDEX ix2_audit_skip_5054 on 
 audit_skiplot_5054(cod_empresa, cod_item);    


create TABLE movto_ar_5054 
  (
    id_registro    int identity(1,1) primary key,
    cod_empresa    CHAR(02) not null ,
    num_ar         CHAR(15) not null ,
    num_seq        CHAR(15) not NULL ,
    operacao       CHAR(01) not NULL 
    
  );

create INDEX ix1_movto_ar_5054 on 
 movto_ar_5054(cod_empresa, num_ar);    
 
create TABLE fornec_ar_5054 
  (
    id_registro    int identity(1,1) primary key,
    cod_empresa    CHAR(02) not null ,
    cod_fornecedor CHAR(15) not null ,
    cod_item       CHAR(15) not NULL 
    
  );

create INDEX ix1_fornec_ar_5054 on 
 fornec_ar_5054(cod_empresa, cod_fornecedor);    

create INDEX ix2_fornec_ar_5054 on 
 fornec_ar_5054(cod_empresa, cod_item);    
 
 
