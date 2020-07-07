   drop  TABLE pol1301_1054;
   CREATE  TABLE pol1301_1054(
       cod_empresa       char(02),  
       usuario           char(08),  
       ano               CHAR(04),
       mes               CHAR(02),
       semana            DECIMAL(2,0),       
       comp              CHAR (30),
       larg              CHAR (30),
       esp               CHAR (30),
       peso              CHAR (30),
       m2                CHAR (30),
	     num_pedido        CHAR (10),
	     num_orc           CHAR (13),
	     pos               CHAR (6),
       cod_item          CHAR(15),
       den_item          CHAR(18),
       num_ordem         DECIMAL(9,0),
       num_docum         CHAR(10),
       cod_local         CHAR(10),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       data              DATE
    );

create unique index pol1301_1054 on pol1301_1054 
    (cod_empresa, num_ordem);

   CREATE  TABLE lote_pol1301(
       cod_empresa       char(02),  
       usuario           char(08),  
       num_lote          integer,
	     dat_geracao       DATE,
	     hor_geracao       CHAR(08),
	     cod_status        CHAR(01),    -- P-Pendente A-Apontado E-Estornado
       primary key(num_lote)
   );

create unique index lote_pol1301 on lote_pol1301 
    (cod_empresa, num_lote);   

   CREATE  TABLE lote_item_pol1301(
       cod_empresa       char(02),  
       num_lote          integer,
       ano               CHAR(04),
       mes               CHAR(02),
       semana            DECIMAL(2,0),       
       comp              CHAR (30),
       larg              CHAR (30),
       esp               CHAR (30),
       peso              CHAR (30),
       m2                CHAR (30),
	     num_pedido        CHAR (10),
	     num_orc           CHAR (13),
	     pos               CHAR (6),
       cod_item          CHAR(15),
       den_item          CHAR(18),
       num_ordem         DECIMAL(9,0),
       num_docum         CHAR(10),
       cod_local         CHAR(10),
       qtd_planejada     DECIMAL(6,0),
       qtd_saldo         DECIMAL(6,0),
       data              DATE,
       dat_geracao       DATE
    );

create index lote_item_pol1301 on lote_item_pol1301 
    (cod_empresa, num_lote);
    
drop table processo_apont_pol1301;    
create table processo_apont_pol1301 (
 cod_empresa    char(02),
 num_processo   serial,
 num_lote       integer,
 usuario        char(08),
 dat_processo   DATE,
 hor_processo   CHAR(08),
 cod_status     char(01),  --A-Apontado E-Estornado
 primary key (num_processo)
);

create unique index processo_apont_pol1301 on processo_apont_pol1301 
    (cod_empresa, num_processo);


create table processo_item_pol1301 (
 cod_empresa    char(02),
 num_processo   integer,
 num_ordem      integer,
 cod_item       char(15),
 cod_cent_trab  char(10),
 cod_operac     char(05),
 num_seq_operac DECIMAL(3,0),
 qtd_boas       DECIMAL(10,3),
 qtd_refugo     DECIMAL(10,3),
 qtd_sucata     DECIMAL(10,3),
 ies_finaliza   char(01)
);

create index processo_item_pol1301 on processo_item_pol1301 
    (cod_empresa, num_processo);

drop table man_apont_pol1301;
create table man_apont_pol1301 (
    cod_empresa      char(2),
    num_seq_apont    serial,
    num_processo     integer,
    num_ordem        integer,
    num_pedido       integer,
    num_seq_pedido   integer,
    cod_item         char(15),
    num_lote         char(15),
    dat_inicial      date,
    dat_final        date,
    cod_recur        char(5),
    cod_operac       char(5) ,
    num_seq_operac   decimal(3,0)  ,
    oper_final       char(1),
    ies_finaliza     char(01),
    cod_cent_trab    char(5)  ,
    cod_cent_cust    decimal(4,0),
    cod_arranjo      char(5),
    qtd_refugo       decimal(10,3),                           
    qtd_sucata       decimal(10,3),                           
    qtd_boas         decimal(10,3),                           
    comprimento      integer,                                 
    largura          integer,                                
    altura           integer,                                 
    diametro         integer,                                 
    tip_movto        char(1),                                 
    cod_local        char(10),                                
    qtd_hor          decimal(11,7),                           
    matricula        char(15),                                 
    cod_turno        decimal(10,3),
    hor_inicial      char(05),
    hor_final        char(05),
    unid_funcional   char(10),
    dat_atualiz      date,
    ies_terminado    char(1),
    cod_eqpto        char(15),
    cod_ferramenta   char(15),
    integr_min       char(1),
    nom_prog         char(8),
    nom_usuario      char(8),
    cod_status       char(1), --A-Apontado E-Estonado
    cod_sucata       char(15),
    primary key (num_seq_apont)
); 

create index man_apont_pol1301 on man_apont_pol1301 
    (cod_empresa,num_processo);

drop table apont_erro_pol1301;
create table apont_erro_pol1301 (
   cod_empresa      char(02),
   num_seq_apont    integer,
   num_processo     integer,
   den_critica      char(120)  
);

create index apont_erro_pol1301 on apont_erro_pol1301 
    (cod_empresa, num_seq_apont);

drop  table trans_apont_pol1301;
create table trans_apont_pol1301 (
 cod_empresa    char(02),
 num_processo   integer,
 num_transac    integer,
 num_seq_apont  integer,
 cod_operacao   char(01)
);

create index trans_apont_pol1301 on trans_apont_pol1301
(cod_empresa, num_processo);

drop table estorno_erro_pol1301;
create table estorno_erro_pol1301
  (
    cod_empresa  char(02) not null ,
    usuario      char(08) not null,
    dat_processo char(20) not null ,
    num_processo integer not null ,
    den_critica  char(120)
  );


create index estorno_erro_pol1301 on estorno_erro_pol1301
(cod_empresa, num_processo);


drop table sequencia_apo_pol1301;
create table sequencia_apo_pol1301
  (
    cod_empresa      char(02),
    num_processo     integer,
    num_seq_apont    integer,
    seq_apo_oper     integer,
    seq_apo_mestre   integer
  );
   

create unique index sequencia_apo_pol1301 on 
sequencia_apo_pol1301(cod_empresa, num_processo, num_seq_apont);




