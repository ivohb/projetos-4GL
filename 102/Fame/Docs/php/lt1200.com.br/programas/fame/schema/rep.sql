create table "admlog".lt1200_hist_comis
  (
    mes_ref integer not null ,
    ano_ref integer not null ,
    cod_repres decimal(4,0) not null ,
    tipo char(1),
    cod_empresa char(2),
    num_matricula decimal(8,0),
    pct_nff decimal(16),
    pct_dp decimal(16),
    fixo decimal(16),
    cota decimal(16)
    val_merc_nff decimal(15),
    val_merc_dp decimal(15),
    cod_supervisor decimal(4),
    pct_alcancado decimal(16),
    valor_comissao decimal(16),
    outros decimal(16)
)

