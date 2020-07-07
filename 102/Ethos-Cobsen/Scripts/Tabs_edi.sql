drop table arquivo_edi_547;
create table arquivo_edi_547 (
    cod_empresa      char(02)      not null,
    id_arquivo       integer       not null,
    dat_carga        date          not null,
    hor_carga        char(8)       not null,
    nom_arquivo      char(40)      not null,
    cod_cliente      char(15)      not null,
    cod_usuario      char(08)      not null,
    processado       char(01)      not null, 
    primary key(cod_empresa,id_arquivo)
);    

create unique index ix_arquivo_edi_547 on
 arquivo_edi_547(cod_empresa,nom_arquivo);
 
drop table qfptran_547;
create table qfptran_547 (
 qfp_tran_txt    char(300),
 num_trans       serial,
 id_arquivo      integer,
 primary key(num_trans)
);

create table erro_edi_547(
    cod_empresa      char(02),
    id_arquivo       integer,
    id_pe1           integer,
    tip_reg          char(03),
    registro         char(128),
    mensagem         char(120)
);


create index ix_erro_edi_547 on
 erro_edi_547(cod_empresa,id_arquivo);

drop table edi_pe1_547;
create table edi_pe1_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,              
       cod_fabr_dest      CHAR(03), --não usado
       identif_prog_atual CHAR(09), --não usado
       dat_prog_atual     DATE,     --não usado
       identif_prog_ant   CHAR(09), --não usado
       dat_prog_anterior  DATE,     --não usado
       cod_item_cliente   CHAR(30),
       cod_item           CHAR(30),
       num_pedido_compra  CHAR(10), --só tem no txt
       cod_local_destino  CHAR(05), --não usado
       nom_contato        CHAR(11), --não usado
       cod_unid_med       CHAR(02),
       qtd_casas_decimais CHAR(01), --não usado
       cod_tip_fornec     CHAR(01), --não usado
       situacao           CHAR(01), --N/C
       mensagem           CHAR(120),--problema encontrado
       id_arquivo         integer,
       id_pe1             integer,
       primary key(cod_empresa,id_pe1)
);

create index ix_edi_pe1_547 on edi_pe1_547
(cod_empresa, num_pedido);

drop table edi_pe2_547;
create table edi_pe2_547(
       cod_empresa        CHAR(02),            
       num_pedido         INTEGER,              
       dat_ult_embar      DATE,       
       num_ult_nff        CHAR(06),
       ser_ult_nff        CHAR(04),
       dat_rec_ult_nff    DATE,
       qtd_recebida       DECIMAL(10,3),
       qtd_receb_acum     DECIMAL(17,3),
       qtd_lote_minimo    DECIMAL(10,3),
       cod_freq_fornec    CHAR(03),
       dat_lib_producao   CHAR(04),
       dat_lib_mat_prima  CHAR(04),
       cod_local_descarga CHAR(07),
       periodo_entrega    CHAR(04),
       cod_sit_item       CHAR(02),
       identif_tip_prog   CHAR(01),
       pedido_revenda     CHAR(03),
       qualif_progr       CHAR(01),
       id_pe1             integer
);

create index ix_edi_pe2_547 on edi_pe2_547
(cod_empresa, num_pedido);

drop table edi_pe3_547;
create table edi_pe3_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,       
       num_sequencia      INTEGER,                                                 
       dat_entrega_1      DATE,
       hor_entrega_1      CHAR(02),   
       qtd_entrega_1      DECIMAL(10,0),   
       dat_entrega_2      DATE,
       hor_entrega_2      CHAR(02),   
       qtd_entrega_2      DECIMAL(10,0),   
       dat_entrega_3      DATE,
       hor_entrega_3      CHAR(02),   
       qtd_entrega_3      DECIMAL(10,0),   
       dat_entrega_4      DATE,
       hor_entrega_4      CHAR(02),   
       qtd_entrega_4      DECIMAL(10,0),   
       dat_entrega_5      DATE,
       hor_entrega_5      CHAR(02),   
       qtd_entrega_5      DECIMAL(10,0),   
       dat_entrega_6      DATE,
       hor_entrega_6      CHAR(02),   
       qtd_entrega_6      DECIMAL(10,0),   
       dat_entrega_7      DATE,
       hor_entrega_7      CHAR(02),   
       qtd_entrega_7      DECIMAL(10,0),
       id_pe1             integer  
);

create index ix_edi_pe3_547 on edi_pe3_547
(cod_empresa, num_pedido);
             
create  index ix1_edi_pe3_547 on edi_pe3_547
(cod_empresa, num_pedido, num_sequencia);

drop table edi_pe5_547;
create table edi_pe5_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,       
       num_sequencia      INTEGER,                                                 
       dat_entrega_1      DATE,
       identif_programa_1 CHAR(01),
       ident_prog_atual_1 CHAR(09),
       dat_entrega_2      DATE,
       identif_programa_2 CHAR(01),
       ident_prog_atual_2 CHAR(09),
       dat_entrega_3      DATE,
       identif_programa_3 CHAR(01),
       ident_prog_atual_3 CHAR(09),
       dat_entrega_4      DATE,
       identif_programa_4 CHAR(01),
       ident_prog_atual_4 CHAR(09),
       dat_entrega_5      DATE,
       identif_programa_5 CHAR(01),
       ident_prog_atual_5 CHAR(09),
       dat_entrega_6      DATE,
       identif_programa_6 CHAR(01),
       ident_prog_atual_6 CHAR(09),
       dat_entrega_7      DATE,
       identif_programa_7 CHAR(01),
       ident_prog_atual_7 CHAR(09),
       id_pe1             integer
);

create index ix_edi_pe5_547 on edi_pe5_547
(cod_empresa, num_pedido);
             
create  index ix1_edi_pe5_547 on edi_pe5_547
(cod_empresa, num_pedido, num_sequencia);

drop table pedidos_edi_547;
create table pedidos_edi_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,   
       num_prog_atual     CHAR(10),
       dat_prog_atual     DATE,
       num_prog_ant       CHAR(10),
       dat_prog_ant       DATE,
       cod_frequencia     CHAR(03),
       cod_item_cliente   CHAR(30),
       num_nff_ult        INTEGER,
       id_pe1             integer
);

create index ix_pedidos_edi_547 on 
pedidos_edi_547(cod_empresa, num_pedido);

drop table ped_itens_edi_547;
create table ped_itens_edi_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,   
       num_sequencia      INTEGER,
       cod_item           CHAR(15),
       prz_entrega        DATE,
       qtd_solic          DECIMAL(10,3),
       qtd_atend          DECIMAL(10,3),
       qtd_saldo          DECIMAL(10,3),
       qtd_solic_nova     DECIMAL(10,3),
       qtd_solic_aceita   DECIMAL(10,3),
       id_pe1             integer,
       mensagem           CHAR(30)
);

create  index ix_ped_itens_edi_547 on 
ped_itens_edi_547(cod_empresa, num_pedido, num_sequencia);       


drop table ped_itens_edi_pe5_547;
create table ped_itens_edi_pe5_547(
       cod_empresa        CHAR(02),
       num_pedido         INTEGER,   
       cod_item           CHAR(15),
       num_sequencia      INTEGER,
       dat_abertura       DATE,
       ies_programacao    CHAR(01),
       id_pe1             integer
);       

create index ix_ped_itens_edi_pe5_547 on 
ped_itens_edi_pe5_547(cod_empresa, num_pedido, num_sequencia); 

drop table cliente_item_edi_547;
create table cliente_item_edi_547(
       id_registro        SERIAL,
       cod_empresa        CHAR(02),
       cod_cliente        CHAR(15),
       cod_it_cli         CHAR(30),
       cod_it_logix       CHAR(15),
       num_pedido         INTEGER,
       primary key (id_registro)
);       

create unique index ix_cliente_item_edi_547 on 
cliente_item_edi_547(cod_empresa, cod_cliente, cod_it_cli); 


drop table client_edi_547;
create table client_edi_547(
   cod_cliente        CHAR(15) not null,
   div_qtd_por        INTEGER not null,
   primary key(cod_cliente)
);

drop TABLE edi_audit_547;
CREATE TABLE edi_audit_547 (    
   id_registro   SERIAL,    
   cod_empresa   CHAR(02),
   num_pedido    INTEGER,
   cod_item      CHAR(15),
   prz_entrega   DATE,
   qtd_solic     DECIMAL(10,3),
   mensagem      CHAR(50),
   usuario       CHAR(08),
   dat_operacao  DATE,
   cod_cliente   CHAR(15),
   qtd_operacao  DECIMAL(10,3),
   item_cliente  CHAR(30),
   qtd_antes     DECIMAL(10,3),
   id_arquivo    INTEGER,
   id_pe1        integer,
   situacao      CHAR(01),
   programacao   CHAR(11),
   qtd_atual     DECIMAL(10,3),
   operacao      char(20),
   primary key(id_registro)
);

CREATE INDEX ix_edi_audit_547
 ON edi_audit_547(cod_empresa, dat_operacao, cod_cliente);
 
-- dividir quantidade por 100
    089674782000158
    089674782001049
    089674782001391
    089674782001472
    089674782001200
    2041
