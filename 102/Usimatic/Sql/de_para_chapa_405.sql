create table de_para_chapa_405 (
 cod_empresa   char(02) not null,
 cod_chapa     char(15) not null,    --c�digo de (c�digo original: MCA0001A)
 cod_no_ar     char(15) not null,    --c�digo para (c�digo beneficiado: BAA0787A)
 primary key (cod_empresa, cod_chapa));
 