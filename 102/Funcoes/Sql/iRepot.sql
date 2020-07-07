create table relat_ireport_912 (
 id_relat       integer  not null,
 cod_empresa    char(02) not null,
 relatorio      char(15) not null,
 descricao      char(60) not null,
 primary key (id_relat)
);

create table tabela_relat_912 (
 id_tabela      integer  not null,
 id_relat       integer  not null,
 tabela         char(25) not null,
 primary key (id_tabela)
);

create unique index tabela_relat_912 on
tabela_relat_912(id_relat, tabela);

create table filtro_tabela_912 (
 id_filtro      integer  not null,
 id_relat       integer  not null,
 filtro         char(300) not null,
 primary key (id_filtro)
);

create unique index filtro_tabela_912 on
filtro_tabela_912(id_relat, filtro);

