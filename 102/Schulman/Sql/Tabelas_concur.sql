--tabela onde ficarão os registros 
--importados do Concur (mestre)

create table arquivo_concur(
 cod_empresa      char(02),
 id_arquivo       integer,
 nom_arquivo      varchar(80),
 dat_carga        date,
 hor_carga        char(08),
 usuario          char(08),
 primary key(id_arquivo)
);

--tabela onde ficarão os registros 
--importados do Concur (detalhes)
 
create table itens_concur(
 cod_empresa       char(02),
 id_arquivo        integer,
 pessoal           CHAR(01),        
 funcionario       VARCHAR(60),        
 funcio_id         VARCHAR(15),      
 relat_key         VARCHAR(15),          
 empresa           VARCHAR(15),            
 despesa           decimal(12,2),            
 moeda             VARCHAR(15),              
 tip_desp          VARCHAR(15),              
 den_desp          VARCHAR(50),           
 cent_cust         VARCHAR(15),          
 situacao          VARCHAR(40),           
 dat_emissao       VARCHAR(25),        
 dat_pagto         VARCHAR(25),          
 tip_pgto          VARCHAR(30),      
 num_ad            INTEGER,          
 num_ap            INTEGER,
 cod_tip_despesa   INTEGER
);

create index ix1_itens_concur on itens_concur
 (cod_empresa, id_arquivo);

--armazena os erros de integrção
create table erro_concur (
 cod_empresa       char(02),
 funcio_id         VARCHAR(15),      
 relat_key         VARCHAR(15),          
 tip_desp          VARCHAR(15),              
 cent_cust         VARCHAR(15),          
 erro              VARCHAR(120)
);

create index ix_erro_concur on  erro_concur
 (cod_empresa, funcio_id);


--de para funcionário x fornecedor
create table func_fornec_concur (
 cod_empresa       char(02),
 funcio_id         VARCHAR(15),
 cod_fornecedor    VARCHAR(15),
 primary key(cod_empresa, funcio_id)
);

--de para centro de custos concur x logix
create table cent_cust_concur (
 cod_empresa       CHAR(02),
 cod_cc_concor     INTEGER,
 cod_cc_logix      INTEGER,
 cod_lin_prod      decimal(2,0),
 cod_lin_recei     decimal(2,0),
 cod_seg_merc      decimal(2,0),
 cod_cla_uso       decimal(2,0),
 primary key(cod_empresa, cod_cc_concor)
);

--de-para tipo de despesa concur x logix
create table tip_desp_concur (
 cod_empresa       char(02),
 tip_desp_concur   INTEGER,
 tip_desp_logix    INTEGER,
 primary key(cod_empresa, tip_desp_concur)
);






