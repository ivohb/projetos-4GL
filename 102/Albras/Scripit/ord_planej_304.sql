
CREATE TABLE ord_planej_304 (
 empresa              CHAR(02), 
 ordem                INTEGER, 
 operacao             CHAR(05), 
 sequencia            INTEGER, 
 dat_ini_planej       DATETIME YEAR TO SECOND, 
 dat_fim_planej       DATETIME YEAR TO SECOND,
 primary KEY(empresa, ordem, sequencia)
);
