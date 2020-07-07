-- Inventários realizados

drop table invent_547;
create table invent_547 (       
   cod_empresa             char(02),
   num_invent              integer,
   dat_invent              char(10),    
   hor_invent              CHAR(08),    
   cod_usuario             CHAR(08),    
   sit_invent              CHAR(15),    
   qtd_carga               integer,
   nom_caminho             CHAR(80),
   tip_invent              CHAR(01)
);

create unique index ix1_invent_547 
 on invent_547(cod_empresa, num_invent);
 
create unique index ix2_invent_547 
 on invent_547(cod_empresa, dat_invent);
 

--- usuarios participantes do Inventario.

drop table invent_user_547;
create table invent_user_547
  (
    cod_empresa      char(02),
    cod_usuario      char(08)
  );

create unique index ix1_invent_user_547 on invent_user_547
    (cod_empresa, cod_usuario);


--temporária
create  table invent_carga_547
  (
    contagem         char(50)
  );

drop table arquivo_coletor_547;
create table arquivo_coletor_547 (
    cod_empresa      char(02)      not null,
    id_arquivo       integer       not null,
    num_invent       integer       not null,
    dat_carga        char(10)      not null,
    hor_carga        char(08)      not null,
    arquivo          char(40)      not null,
    tip_coletor      CHAR(01)      not null,
    contagem         char(01)      not null,
    cod_usuario      char(08)      not null,
    primary key(cod_empresa,id_arquivo)
);    

create unique index ix_arquivo_coletor_547 on arquivo_coletor_547
 (cod_empresa, num_invent, arquivo);


drop table carga_coletor_547;
create table carga_coletor_547
  (
    cod_empresa      char(02),
    id_arquivo       integer,
    cod_item         char(15),
    cod_local        char(10),
    num_lote         char(15),
    controle         char(10),
    qtde             decimal(12,3),
    ies_ativo        char(01),       -- S=Sim  N=Não
    ies_situa        char(01),       -- C=Carregado P=Processado D=Divergente
    tex_diverg       char(200),
    reg_pai          decimal(12,0),
    registro         decimal(12,0),
    totaliza         char(01),
    cod_usuario      CHAR(08),
    origem           CHAR(01),
    contagem         char(03),
    num_invent       integer,
    ies_situa_qtd    CHAR(01),
    primary key(cod_empresa, registro)
  );


create index ix_carga_coletor_547 on 
 carga_coletor_547(cod_empresa, id_arquivo);

drop table itens_invent_547;
create table itens_invent_547
  (
    cod_empresa          char(02),      --amarração com a
    cod_item             char(15),
    cod_local            char(10),
    num_lote             char(15),
    qtd_pri_cont         decimal(12,3),
    qtd_seg_cont         decimal(12,3),
    qtd_ter_cont         decimal(12,3),    
    num_invent           integer,
    id_registro          integer,
    ies_situa_qtd        CHAR(01)
  );

create unique index ix_itens_invent_547_1 on itens_invent_547
    (cod_empresa, num_invent, cod_item, cod_local, num_lote, ies_situa_qtd);

create unique index ix1_itens_invent_547 on itens_invent_547
    (cod_empresa, id_registro);

create index ix2_itens_invent_547 on itens_invent_547
    (cod_empresa, num_invent);

       