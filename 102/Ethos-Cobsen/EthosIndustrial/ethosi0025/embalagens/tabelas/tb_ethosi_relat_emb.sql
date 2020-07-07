--- TABELA PARA O RELATÓRIO DAS EMBALAGENS
--- UTILIZADA NA APLICAÇÃO ETHOSI0025.

drop table ethosi_relat_emb;

create table "informix".ethosi_relat_emb
  (
    cod_empresa          char(02),
    usuario              char(50),
    sequencia_relat      decimal(09,0),
    cod_cliente          char(15),
    nom_cliente          char(53),
    pedido_cliente       char(25),
    pedido               decimal(09,0),
    seq                  decimal(04,0),
    item                 char(15),
    descricao            char(18),
    entrega              date,
    cod_produto          char(30),
    e_amostra            char(10),
    qtde_a_faturar       decimal(12,3),
    item_embalagem       char(15),
    den_embalagem        char(18),
    qtd_fat_ini          decimal(10,3),
    qtd_fat_fim          decimal(10,3),
    qtd_embal_estrut     decimal(14,7),
    qtd_necess_embal     decimal(17,7),
    peso_embalagem       decimal(17,7),
    embal_do_pedido      decimal(09,0),
    embal_da_seq         decimal(04,0),
    qtde_orig_item_ped   decimal(12,3),
    data_entrega_orig    date,
    item_ori             char(15),
    cod_cliente_ori      char(15),
    nova_qtde_a_faturar  decimal(12,3),
    item_embal_cli       char(30)
 );

revoke all on "informix".ethosi_relat_emb from "public";

create unique index "informix".ix_ethi_rel_emb_1 
       on "informix".ethosi_relat_emb
      (cod_empresa, usuario,
       sequencia_relat) using btree;

create index "informix".ix_ethi_rel_emb_2 
       on "informix".ethosi_relat_emb
      (cod_empresa, usuario,
       embal_do_pedido, 
       embal_da_seq) using btree;

alter table ethosi_relat_emb lock mode (row);
