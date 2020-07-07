   drop TABLE limite_proces_547;
   CREATE TABLE limite_proces_547 (
     cod_empresa     char(02),
     num_ordem       INTEGER,
     dat_proces      char(19),
     primary key(cod_empresa, num_ordem)
   );

   drop TABLE limite_erro_547;
   CREATE TABLE limite_erro_547 (
     cod_empresa     char(02),
     num_pedido      decimal(6,0),
     seq_pedido      decimal(3,0),
     num_ordem       INTEGER,
     dat_proces      char(19),
     den_erro        char(120)
   );

   create index ix_limite_erro_547  on
   limite_erro_547(cod_empresa, num_pedido, seq_pedido);
   

drop table estrut_ordem_547;
create table estrut_ordem_547 (
 id_registro          serial,
 cod_empresa          char(02),
 num_pedido           decimal(6,0),
 seq_pedido           decimal(3,0),
 num_ordem            integer,
 cod_item             char(15),
 item_pai             char(15),
 cod_operac           char(05),
 seq_operac           decimal(3,0),
 num_processo         INTEGER,
 qtd_dias             decimal(3,0),
 dat_limite           date,
 ord_processo         decimal(3,0),
 primary key(id_registro)
);

create index ix_estrut_ordem_547  on
 estrut_ordem_547(cod_empresa, num_pedido, seq_pedido);

drop table sequenc_calc_547 ;
create table sequenc_calc_547 (
 id_registro          serial,
 cod_empresa          char(02),
 num_pedido           decimal(6,0),
 seq_pedido           decimal(3,0),
 num_ordem            INTEGER,
 cod_operac           char(05),
 seq_calculo          decimal(3,0),
 qtd_dias             decimal(3,0),
 dat_limite           date,
 dias_subtrair        decimal(3,0),
 primary key(id_registro)
);

create unique index ix_sequenc_calc_547  on
 sequenc_calc_547(cod_empresa, num_pedido, seq_pedido, cod_operac);



drop TABLE local_proces_547;
   CREATE TABLE local_proces_547 (
     id_local        serial,
     cod_empresa     char(02),
     num_ordem       INTEGER,
     dat_proces      char(19),
     primary key(cod_empresa, num_ordem)
   );

drop TABLE local_erro_547;
   CREATE TABLE local_erro_547 (
     id_local        INTEGER,
     cod_empresa     char(02),
     num_ordem       INTEGER,
     dat_proces      char(19),
     den_erro        char(120)
   );

   create index ix_local_erro_547  on
   local_erro_547(id_local);

drop TABLE op_local_547;
   CREATE TABLE op_local_547(
    id_local        INTEGER,
    cod_empresa     char(02),
    num_neces       INTEGER,
    num_ordem       INTEGER,
    num_docum       CHAR(15),
    cod_item        CHAR(15),
    cod_item_pai    CHAR(15),
    cod_local_prod  CHAR(10),
    cod_local_estoq CHAR(10),
    dat_entrega     DATE,
    primary key(cod_empresa, num_ordem)
   );
   
            
   create index ix_op_local_547  on
   op_local_547(id_local);

drop TABLE op_liber_pol1347;
   CREATE TABLE op_liber_pol1347 (
     id_liber        serial,
     cod_empresa     char(02),
     num_ordem       INTEGER,
     dat_proces      char(19),
     cod_usuario     char(08),
     primary key(id_liber)
   );

create table porc_pol1346_547(
 id              serial,
 dat_proces      char(19),
 processo        char(20),
 cod_empresa     char(02),
 cod_usuario     char(08),
 primary key(id)
)


 create table loc_baixa_547 (
   cod_empresa      char(02),
   num_ordem        integer,
   cod_item_pai     char(15),
   cod_local_baixa  char(10),
   cod_item_compon  char(15),
   ies_tip_item     char(01)
)

create index ix_loc_baixa_547 on 
 loc_baixa_547(cod_empresa, num_ordem);