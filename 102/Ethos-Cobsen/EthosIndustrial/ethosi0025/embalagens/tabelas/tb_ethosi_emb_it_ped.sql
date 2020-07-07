--- PEDIDOS DAS EMBALAGENS POR CLIENTE/ITEM/DIA RELACIONADA COM A TABELA 'ethosi_emb_it_dia'
--- TABELA  UTILIZADA  NA APLICAÇÃO ETHOSI0025.

drop table ethosi_emb_it_ped;

create table "informix".ethosi_emb_it_ped
  (
    cod_empresa            char(02),
    usuario                char(50),
    reg_ethosi_emb_it_dia  decimal(15,0),
    pedido                 decimal(09,0),
    seq                    decimal(04,0),
    qtde_considerada_ped   decimal(14,7)
 );

revoke all on "informix".ethosi_emb_it_ped from "public";


create unique index "informix".ix_ethi_emb_it_ped_1 
       on "informix".ethosi_emb_it_ped
      (cod_empresa, usuario,
       reg_ethosi_emb_it_dia,
       pedido, seq) using btree;

alter table ethosi_emb_it_ped lock mode (row);
