--como o pol1159 (geração da grade de aprovação de AR)
--roda sem acompanhamento do usuário, essa tabela armazenará
--erros críticos ocorridos durante o processamento

create table erro_pol1159_265(
 cod_empresa     char(02),
 num_aviso_rec   integer,
 den_erro        char(76),
 dat_ini_process datetime year to day,
 hor_ini_process datetime hour to second
)

create index erro_pol1159_265_1 on erro_pol1159_265
 (cod_empresa, dat_ini_process, hor_ini_process)

create index erro_pol1159_265_2 on erro_pol1159_265
 (cod_empresa, num_aviso_rec)
 