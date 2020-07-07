--armazena o AR marcado com X e sua respectiva
--situação antes da marcação (ies_incl_cap)
--creação do campo ies_ar_cs, p/ armazenar NOTA ou CONTRATO

create table nfe_aprov_265 (
 cod_empresa   char(02),
 num_aviso_rec integer,
 ies_incl_cap  char(01),
 ies_ar_cs     char(10)
)

create unique index nfe_aprov_265_1 on nfe_aprov_265
(cod_empresa, num_aviso_rec);

