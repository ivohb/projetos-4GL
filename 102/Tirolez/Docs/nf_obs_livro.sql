

create table nf_obs_livro
 (
   cod_empresa char(2) not null ,
   num_nff     decimal(6,0) not null ,
   ser_nff     char(2) not null ,
   texto       char(120),
   dat_emissao date
 );


create unique index ix1_nf_obs_livro on nf_obs_livro
   (cod_empresa,num_nff,ser_nff,dat_emissao);
   
create unique index ix_nfobsliv_1 on nf_obs_livro
   (cod_empresa,num_nff,ser_nff);
