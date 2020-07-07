drop table trans_col;

create table "informix".trans_col 
  (
    cod_empresa          char(2),
    cod_item             char(15),
    den_item             char(76),
    ies_tip_item         char(1),
    num_ordem            integer,
    num_docum            char(10),
    qtd_necessaria       decimal(14,7),
    qtd_transferida      decimal(14,7),
    saldo_transferir     decimal(14,7),
    saldo_estoque        decimal(14,7),
    qtd_coletada         decimal(14,7),
    cod_local_baixa      char(10),
    cod_local_padr       char(10),
    situacao_reg         char(60)
);

revoke all on "informix".trans_col from "public" as "informix";

create unique index "informix".ix_trans_col_1 on "informix".trans_col
    (cod_empresa, cod_item, num_ordem);



situações:

ITEM NÃO PERTENCE A ORDEM;
ITEM SEM ESTOQUE PARA TRANSFERENCIA;
QUANTIDADE COLETADA MAIOR QUE A NECESSIDADE DA ORDEM;
QTDE COLETADA MAIOR QUE NECESSÁRIO PARA TRANSFERÊNCIA