CREATE TABLE  consiste_ped5029
                (
                cod_empresa      CHAR (2) not null,
                num_pedido       decimal(6,0) not null,
                data_consist      date  not null,
                ies_processado   CHAR (1) not null,
                ies_robo         CHAR (1) not null
                );

CREATE INDEX ix1_consiste_ped5029
                ON consiste_ped5029 (cod_empresa, num_pedido);
