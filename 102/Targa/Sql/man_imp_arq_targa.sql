create table man_imp_arq_targa (

cod_empresa                  char(02)       ,  
nome_arquivo_import          varchar(50)    ,
check_plan                   char(02)       , 
posicao                      integer        ,
num_analise                  integer        ,
inspetor                     char(50)       ,
data_prod                    date           ,
hora_prod                    char(05)       ,
produto                      char (15)      ,
maquina                      char(05)       ,
lado                         char(02)       ,
tamanho                      char(05)       ,
turno                        char(03)       ,
num_lote                     char(15)       ,
cod_item                     char(15)       ,
den_item                     varchar(70)    ,
disposicao                   char(18)       ,
peso_grama                   decimal(15,3)  ,
qtd_sacos                    decimal(15,3)  ,
peso_tot_kg                  decimal(15,3)  ,
peso_medio                   decimal(15,3)  ,
qtd_lote_prod                decimal(15,3)  ,
marcacao                     decimal(15,3)  ,
fur_palm_pun_dedo            decimal(15,3)  ,
esbarrada                    decimal(15,3)  ,
rasgada                      decimal(15,3)  ,
mistura                      decimal(15,3)  ,
prega                        decimal(15,3)  ,
impureza                     decimal(15,3)  ,
cordao_defeito               decimal(15,3)  ,
acumulo                      decimal(15,3)  ,
ponto_fraco                  decimal(15,3)  ,
motivo_Reprova               varchar(50)    ,
obs_marcacao                 varchar(50)    ,
obs_palm_pun_dedo            varchar(50)    ,
obs_esbarrada                varchar(50)    ,
obs_rasgada                  varchar(50)    ,
obs_mistura                  varchar(50)    ,
obs_prega                    varchar(50)    ,
obs_impureza                 varchar(50)    ,
obs_cordao_defeito           varchar(50)    ,
obs_acumulo                  varchar(50)    ,
obs_ponto_fraco              varchar(50)    ,
obs_geral                    varchar(50)       
);

create index ix_man_imp_arq_targa on
 man_imp_arq_targa(cod_empresa, nome_arquivo_import);


create table man_tmp_arq_targa (              
                                              
check_plan                   char(02)       , 
posicao                      integer        , 
num_analise                  integer        , 
inspetor                     char(50)       , 
data_prod                    date           , 
hora_prod                    char(05)       , 
produto                      char (15)      , 
maquina                      char(05)       , 
lado                         char(02)       , 
tamanho                      char(05)       , 
turno                        char(03)       , 
num_lote                     char(15)       , 
cod_item                     char(15)       , 
den_item                     varchar(70)    , 
disposicao                   char(18)       , 
peso_grama                   decimal(15,3)  , 
qtd_sacos                    decimal(15,3)  , 
peso_tot_kg                  decimal(15,3)  , 
peso_medio                   decimal(15,3)  , 
qtd_lote_prod                decimal(15,3)  , 
marcacao                     decimal(15,3)  , 
fur_palm_pun_dedo            decimal(15,3)  , 
esbarrada                    decimal(15,3)  , 
rasgada                      decimal(15,3)  , 
mistura                      decimal(15,3)  , 
prega                        decimal(15,3)  , 
impureza                     decimal(15,3)  , 
cordao_defeito               decimal(15,3)  , 
acumulo                      decimal(15,3)  , 
ponto_fraco                  decimal(15,3)  , 
motivo_Reprova               varchar(50)    , 
obs_marcacao                 varchar(50)    , 
obs_palm_pun_dedo            varchar(50)    , 
obs_esbarrada                varchar(50)    , 
obs_rasgada                  varchar(50)    , 
obs_mistura                  varchar(50)    , 
obs_prega                    varchar(50)    , 
obs_impureza                 varchar(50)    , 
obs_cordao_defeito           varchar(50)    , 
obs_acumulo                  varchar(50)    , 
obs_ponto_fraco              varchar(50)    , 
obs_geral                    varchar(50)      
);                                            
                                              
create index ix_man_tmp_arq_targa on
 man_tmp_arq_targa(produto);


   CREATE TABLE erros_carga_pol1378 (
      cod_empresa          char(02),
      dat_proces           DATE,
      hor_proces           CHAR(08),
      nom_arquivo          VARCHAR(80),
      reg_proces           INTEGER,
      mensagem             VARCHAR(150)
   );

   CREATE INDEX ix_erros_carga_pol1378
    ON erros_carga_pol1378(cod_empresa, dat_proces);
