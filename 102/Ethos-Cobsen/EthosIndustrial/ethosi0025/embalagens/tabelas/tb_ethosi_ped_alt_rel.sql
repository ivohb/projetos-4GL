--- PEDIDOS QUE FORAM ALTERADOS A QUANTIDADE A FATURAR PARA EMISSÃO DO 
--- RELATÓRIO  DAS  NECESSIDADES  DE  EMBALAGENS.  TABELA UTILIZADA NA 
--- APLICAÇÃO ETHOSI0025.

drop table ethosi_ped_alt_rel;

create table "informix".ethosi_ped_alt_rel
  (
    cod_empresa            char(02),
    usuario                char(50),
    pedido                 decimal(09,0),
    seq                    decimal(04,0),
    nova_qtde_a_faturar    decimal(14,3)
 );

revoke all on "informix".ethosi_ped_alt_rel from "public";


create unique index "informix".ix_ethi_ped_alt_rel_1 
       on "informix".ethosi_ped_alt_rel
      (cod_empresa, usuario,
       pedido, seq) using btree;

alter table ethosi_ped_alt_rel lock mode (row);
