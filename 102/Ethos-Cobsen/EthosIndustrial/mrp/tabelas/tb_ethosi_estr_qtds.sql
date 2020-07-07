--- TABELA DA ESTRUTURA DOS ITENS E SUAS QUANTIDADES PARA GERAR AS OP´S(tab: ordens)
--- E SUAS NECESSIDADES(tab: necessidades) UTILIZADA NA APLICAÇÃO ETHOSI0030

drop table ethosi_estr_qtds;

create table "informix".ethosi_estr_qtds
  (
    cod_empresa             char(02),
    seq_gerada              decimal(10,0),
    pai_princip             char(15),
    nivel                   decimal(5,0),
    cod_item                char(15),
    tipo_item               char(01),
    cod_item_pai            char(15),
    qtd_necess_estrut       decimal(14,7),
    qtd_necess_ordem        decimal(14,7),
    gerar_op                char(01),
    num_docum               char(10),
    dat_entrega             date,
    ctrl_lote               char(01),
    cod_local_estoq         char(10),
    cod_local_prod          char(10),
    cod_roteiro             char(15),
    num_altern_roteiro      decimal(2,0),
    ies_abert_liber         char(1),
    ies_baixa_comp          char(1),
    ies_apontamento         char(1),
    reg_log_pai             decimal(10,0),
    num_ordem               decimal(10,0),
    data_inclus            date,
    hora_inclus            char(08)
 );

revoke all on "informix".ethosi_estr_qtds from "public";

create index "informix".ix_ethi_estr_qtds_1 
       on "informix".ethosi_estr_qtds
      (cod_empresa, pai_princip,
       nivel, cod_item,
       data_inclus, hora_inclus) using btree;

create index "informix".ix_ethi_estr_qtds_2
       on "informix".ethosi_estr_qtds
      (cod_empresa, seq_gerada, pai_princip,
       data_inclus, hora_inclus) using btree;

create index "informix".ix_ethi_estr_qtds_3
       on "informix".ethosi_estr_qtds
      (cod_empresa, pai_princip,
       data_inclus, hora_inclus,
       seq_gerada) using btree;

alter table ethosi_estr_qtds lock mode (row);
