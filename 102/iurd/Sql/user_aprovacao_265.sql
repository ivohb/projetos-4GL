create table user_aprov_265 (
 cod_usuario     char(08) not null,
 senha           char(24),
 primary key(cod_usuario)
 );
 
create table senha_cript_265 (
 cod_usuario     char(08) not null,
 senha_normal    char(10),
 senha_cript     char(24),
 primary key(cod_usuario)
 );
 
 