drop table cliente_komatsu;
create table cliente_komatsu (
 loc_geograf         varchar(03),
 cod_cliente         varchar(15),
 primary key(loc_geograf)
);

drop table periodo_firme_komatsu;
create table periodo_firme_komatsu (
 cod_empresa         varchar(02),
 per_firme           decimal(3,0),
 primary key(cod_empresa)
);

drop table arquivo_komatsu;
create table arquivo_komatsu (
    id_arquivo       integer ,
    cod_empresa      char(02),
    cod_cliente      varchar(15),    
    nom_arquivo      char(40),
    dat_carga        date,
    hor_carga        char(08),
    cod_usuario      char(08),
    processado       char(01), 
    primary key(id_arquivo)
);    

create index ix1_arquivo_komatsu on
 arquivo_komatsu(cod_cliente, nom_arquivo);

drop table programacao_komatsu;
create table programacao_komatsu (
   id_arquivo        integer,
   cod_empresa       varchar(02),
   cod_cliente       varchar(15),
   fornecedor        varchar(30), 
   item_cliente      varchar(30), 
   und               varchar(03), 
   revisao	         varchar(10),
   data	             varchar(10),  
   prazo	           varchar(10),
   alm	             varchar(30),
   ordem	           varchar(15),
   pos	             varchar(10),
   op	               varchar(30),  
   valor_unit	       varchar(12),  
   valor_total	     varchar(14),
   ordenado	         varchar(10),  
   entregue	         varchar(10),  
   pendente	         varchar(10),  
   data_2	           varchar(10),  
   nf	               varchar(10),  
   rese	             varchar(30),  
   rcf               varchar(05),  
   local_geogr       varchar(30)
   );                             

create index ix1_programacao_komatsu
 on programacao_komatsu(id_arquivo, item_cliente);

drop table pedidos_komatsu;
create table pedidos_komatsu (
   id_arquivo        INTEGER,    
   id_pedido         INTEGER,    
   cod_empresa       varchar(02),
   cod_cliente       varchar(15),
   item_cliente      CHAR(15),       
   num_pedido        DECIMAL(6,0),        
   cod_item          CHAR(15),       
   mensagem          CHAR(120),      
   situacao          CHAR(01),
   primary key(id_pedido)
);       

create index ix1_pedidos_komatsu
 on pedidos_komatsu(id_arquivo, num_pedido);

drop table itens_komatsu;
create table itens_komatsu (   
   id_arquivo        INTEGER,
   id_pedido         INTEGER,    
   id_item           INTEGER,    
   cod_empresa       VARCHAR(02),
   num_pc            VARCHAR(15),
   seq_pc            DECIMAL(6,0),
   prz_entrega       date,             
   qtd_solic         DECIMAL(10,3),    
   qtd_atual         DECIMAL(10,3),    
   operacao          VARCHAR(10),
   mensagem          VARCHAR(60),
   situacao          VARCHAR(01)
   primary key(id_item)
);

create index ix1_itens_komatsu
 on itens_komatsu(id_arquivo, id_pedido);

drop table erro_komatsu;         
create table erro_komatsu(
    id_arquivo       integer,
    id_pedido        INTEGER,   
    cod_empresa      char(02),
    mensagem         char(120)
);

create index ix1_erro_komatsu
 on erro_komatsu(id_arquivo, id_pedido);

drop TABLE audit_komatsu;
CREATE TABLE audit_komatsu (    
   id_audit      INTEGER,    
   id_arquivo    INTEGER,
   id_pedido     INTEGER,
   id_item       INTEGER,
   cod_empresa   VARCHAR(02),
   cod_cliente   VARCHAR(15),
   item_cliente  CHAR(30),
   num_pc        VARCHAR(15),
   seq_pc        INTEGER,
   num_pedido    INTEGER,
   cod_item      VARCHAR(15),
   prz_entrega   DATE,
   qtd_solic     DECIMAL(10,3),
   qtd_atual     DECIMAL(10,3),
   qtd_operacao  DECIMAL(10,3),
   mensagem      VARCHAR(20),
   usuario       VARCHAR(08),
   dat_operacao  DATE,
   hor_operacao  VARCHAR(08),
   primary key(id_audit)
);

CREATE INDEX ix_audit_komatsu
 ON audit_komatsu(cod_empresa, cod_cliente);


drop table forecast_komatsu;
create table forecast_komatsu (
    id_arquivo       integer ,
    cod_empresa      char(02),
    nom_arquivo      char(40),
    dat_carga        date,
    hor_carga        char(08),
    cod_usuario      char(08),
    processado       char(01), 
    primary key(id_arquivo)
);    

create index ix1_forecast_komatsu on
 forecast_komatsu(nom_arquivo);

drop table plano_komatsu;
create table plano_komatsu (
   id_arquivo            INTEGER,
   id_item               INTEGER,
   linha_plano           INTEGER,       
   forec                 VARCHAR(15),
   fornec                VARCHAR(15),
   cliente               VARCHAR(15),
   item                  VARCHAR(15),
   item_logix            VARCHAR(15),
   descricao             VARCHAR(76),
   revisao               VARCHAR(04),
   preco                 VARCHAR(12),
   vigencia              VARCHAR(10),
   unidade               VARCHAR(03),
   ipi                   VARCHAR(12),
   nf                    VARCHAR(10),
   clf                   VARCHAR(15),
   almox                 VARCHAR(15),
   local_almox           VARCHAR(15),
   ent_ac                VARCHAR(15),
   de_para               VARCHAR(15),
   atras                 VARCHAR(15),
   quatro_sem_1          VARCHAR(15),
   quatro_sem_2          VARCHAR(15),
   cod_it_fornec         VARCHAR(15),
   rese                  VARCHAR(15),
   recof                 VARCHAR(15),
   local_geogr           VARCHAR(15),
   ano_plano             DECIMAL(4,0),
   mes_plano             DECIMAL(2,0),
   qtd_firme             DECIMAL(10,3),
   qtd_preve             DECIMAL(10,3),
   mensagem              VARCHAR(80),
   situacao              VARCHAR(01)
   primary key(id_item)
);


drop table prog_komatsu;
create table prog_komatsu (
   id_arquivo            INTEGER,
   id_item               INTEGER,
   item_logix            VARCHAR(15),
   dat_prog              VARCHAR(10),
   qtd_prog              VARCHAR(12),
   tip_prog              VARCHAR(08),
   mensagem              VARCHAR(40),
   ano_plano             DECIMAL(4,0),
   mes_plano             DECIMAL(2,0),
   qtd_plano             DECIMAL(10,3)
);

create index ix1_prog_komatsu on
 prog_komatsu(id_arquivo, id_item);

create index ix2_prog_komatsu on
 prog_komatsu(id_arquivo, item_logix);
