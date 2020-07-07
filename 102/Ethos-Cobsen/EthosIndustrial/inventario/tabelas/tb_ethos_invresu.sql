drop table ethos_invresu;

--- Resultado da Contagem dos Itens dados gerados a partir
--- da Opcao "Processar Cargas" da pasta Carga das Contagens

create table "informix".ethos_invresu
  (
    cod_empresa          char(02),
    dat_selecao          date,
    hor_selecao          char(8),
    num_cartao           decimal(8,0),
    cod_item             char(15),
    cod_local            char(10),
    num_lote             char(15),
    qtd_estoque_sist     decimal(12,3),
    qtd_contagem_1       decimal(12,3),
    qtd_contagem_2       decimal(12,3),
    qtd_contagem_3       decimal(12,3),
    diferenca            char(01),
    qtde_difer           decimal(12,3),
    vtot_difer           decimal(17,2),
    gru_ctr_estoq        decimal(2,0),
    den_gru_ctr_estoq    char(30),
    linha                char(20),
    receita              char(20),
    den_item             char(76),
    ies_tip_item         char(1),
    cod_unid_med         char(3),
    cus_unit_medio       decimal(17,6)
  );

revoke all on "informix".ethos_invresu from "public";

create unique index "informix".ix_eth_invresu_1 on "informix".ethos_invresu
    (cod_empresa, dat_selecao, hor_selecao, cod_item,
     cod_local, num_lote) using btree;
