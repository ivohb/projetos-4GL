--- TABELA PARA PRE GERAÇÃO DOS DADOS PARA RELATÓRIO DAS EMBALAGENS
--- POR PEDIDO/SEQUENCIA - UTILIZADA NA APLICAÇÃO ETHOSI0025.

drop table ethosi_rel_pre_emb;

create table "informix".ethosi_rel_pre_emb
  (
    cod_empresa          char(02),
    usuario              char(50),
    cliente              char(15),
    nom_cliente          char(53),
    pedido_cliente       char(25),
    pedido               decimal(09,0),
    seq                  decimal(04,0),
    item                 char(15),
    descricao            char(18),
    entrega              date,
    cod_produto          char(30),
    amostra              char(10),
    qtde_a_faturar       decimal(12,3),
    item_embalagem       char(15),
    den_embalagem        char(18),
    pes_unit             decimal(17,7),
    qtd_embal_estrut     decimal(14,7),
    qtd_fat_ini          decimal(10,3),
    qtd_fat_fim          decimal(10,3),
    qtd_necess_embal     decimal(17,7),
    item_embal_cli       char(30),
    sal_ori_ped          decimal(12,3)

 );

revoke all on "informix".ethosi_rel_pre_emb from "public";

create index "informix".ix_ethi_rel_pre_emb_1 
       on "informix".ethosi_rel_pre_emb
      (cod_empresa, usuario) using btree;

alter table ethosi_rel_pre_emb lock mode (row);
