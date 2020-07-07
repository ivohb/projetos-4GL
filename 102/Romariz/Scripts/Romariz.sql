drop table laudo_mest_915;
create table laudo_mest_915 
  (
    cod_empresa      char(2) not null ,
    num_laudo        decimal(6,0) not null,
    num_versao       decimal(2,0) not null,
    versao_atual     char(01),
    num_om           decimal(6,0),
    num_nf           decimal(6,0),
    ser_nf           char(03),
    cod_item         char(15),
    seq_item_nf      integer,
    cod_item_analise char(15),
    dat_emissao      date not null ,
    cod_cliente      char(15),
    lote_tanque      char(10) not null ,
    qtd_laudo        decimal(12,3) not null ,
    tipo             char(2),
    ies_impresso     char(1) not null ,
    laudo_bloqueado  char(1) not null ,
    texto_1          char(70),
    texto_2          char(70),
    usuario_desbl    char(8),
    dat_desbloq      date,
    cod_transport    char(15),
    num_pa           decimal(6,0),
    dat_emis_nf      date,
    dat_fabricacao   date,
    dat_validade     date,
    identif_estoque  char(30)
  );

create unique index ix_laudo_me_915_1 on laudo_mest_915
    (cod_empresa,num_laudo, num_versao);


drop  table laudo_audit_915;
create table laudo_audit_915 
  (
    id_registro integer,
    cod_empresa char(2),
    num_laudo decimal(6,0) not null,
    num_versao decimal(2,0) not null,
    data date,
    hora char(08),
    usuario char(08),
    operacao char(20)
  );

create unique index laudo_audit_915 on laudo_audit_915 
    (cod_empresa, id_registro);

drop  table laudo_item_915;
create table laudo_item_915
  (
    cod_empresa       char(2) not null,
    num_laudo         decimal(6,0) not null,
    num_versao        decimal(2,0) not null,
    tip_analise       decimal(6,0) not null,
    metodo            char(20),
    especificacao_de  decimal(10,4),
    especificacao_ate decimal(10,4),
    val_resultado     char(250),
    tipo_valor        char(2),
    analise_bloq      char(1),
    observacao        char(20),
    dat_analise       date,
    hor_analise       char(08)
  );

create unique index ix_laudo_it_915_1 on laudo_item_915 
    (cod_empresa,num_laudo,num_versao,tip_analise);

--tabelas alteradas
drop  table analise_mest_915;
create table analise_mest_915 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    dat_analise date not null ,
    lote_tanque char(10) not null ,
    num_pa decimal(6,0),
    qtd_lote decimal(15,3) not null ,
    qtd_pa decimal(15,3) not null ,
    ies_liberado char(1) not null ,
    nom_usuario char(8),
    identif_estoque char(30)
  );

create unique index ix_analis_mest_915_1 on 
    analise_mest_915 (cod_empresa,cod_item,lote_tanque,
    num_pa, identif_estoque) ;
    
--tabelas alteradas
drop  table analise_915;
create table analise_915 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    dat_analise date not null ,
    lote_tanque char(10) not null ,
    tip_analise decimal(6,0) not null ,
    num_pa decimal(6,0),
    metodo char(20),
    val_especif_de decimal(10,4),
    val_especif_ate decimal(10,4),
    em_analise char(1) not null ,
    val_analise decimal(10,4),
    usuario char(8) not null ,
    dat_fabricacao date,
    dat_validade date,
    unidade char(15),
    ies_conforme char(1),
    ies_obrigatoria char(1),
    identif_estoque  char(30)
 );

create unique index ix_analis_915_1 on 
    analise_915 (cod_empresa,cod_item,lote_tanque,
    tip_analise,num_pa, identif_estoque);




drop  table analise_audit_915;
create table analise_audit_915 
  (
    id_registro integer,
    cod_empresa char(2),
    cod_item char(15),
    lote_tanque char(10),
    cod_familia char(5),
    data date,
    num_pa decimal(6,0),
    usuario char(8),
    operacao char(10),
    resultado char(300)
  );


create unique index analise_audit_915 on 
    analise_audit_915 (cod_empresa,id_registro) ;


drop  table analise_vali_915;
create table analise_vali_915 
  (
    cod_empresa char(2) not null,
    tip_analise decimal(6,0) not null,
    metodo char(20),
    cod_familia char(5),
    cod_item char(15),
    dat_vali_ini date not null,
    dat_vali_fim date not null,
    dat_analise date not null,
    hor_analise datetime hour to second not null,
    em_analise  char(01) not null,
    resultado   varchar(250),
    usuario     char(08) not null
  );

create index ix_an_vali_915_1 on analise_vali_915 
    (cod_empresa,tip_analise,cod_familia);
create index ix_an_vali_915_2 on analise_vali_915 
    (cod_empresa,tip_analise,cod_item);


drop  table especific_915;
create table especific_915 
  (
    cod_empresa char(2) not null ,
    cod_item char(15) not null ,
    cod_cliente char(15),
    tip_analise decimal(6,0) not null ,
    metodo char(20), 
    unidade char(15),
    val_especif_de decimal(10,4) not null ,
    val_especif_ate decimal(10,4) not null ,
    variacao decimal(10,4) not null ,
    tipo_valor char(2),
    calcula_media char(1),
    ies_tanque char(1) not null ,
    qtd_casas_dec integer,
    ies_texto char(1),
    texto_especific char(14)
  );

create unique index ix_espec_915_1 on 
   especific_915 (cod_empresa,cod_item,cod_cliente,tip_analise);


drop  table est_corresp_915;
create table est_corresp_915 
  (
    cod_empresa char(2) not null ,
    cod_operac_ent char(4) not null ,
    cod_operac_sai char(4) not null ,
    cod_prefixo char(5) not null 
  );

create unique index ix_est_corr_915_1 on 
    est_corresp_915(cod_empresa,cod_operac_ent);


drop  table it_analise_915; --tipo de análises
create table it_analise_915 
  (
    cod_empresa      char(2) not null ,
    tip_analise      decimal(6,0) not null ,
    den_analise_port varchar(30) not null ,
    den_analise_ing  varchar(30),
    den_analise_esp  varchar(30),
    ies_validade     varchar(01) not null,
    ies_texto        char(01) not null,
    ies_obrigatoria  char(01) not null
  );

create unique index ix_itana_915 on it_analise_915 
    (cod_empresa,tip_analise);

drop  table item_915;
create table item_915 
  (
    cod_empresa char(2) not null ,
    cod_item_analise char(15) not null ,
    den_item_portugues char(76) not null ,
    den_item_ingles char(76),
    den_item_espanhol char(76),
    qtd_dia_validade integer,
    ies_indeterminada char(1)
  );

create unique index ix_item_915_1 on item_915 
    (cod_empresa,cod_item_analise);

drop  table item_refer_915;
create table item_refer_915 
  (
    cod_empresa char(2) not null ,
    cod_item_analise char(15) not null ,
    cod_item char(15) not null 
  );

create unique index ix_item_ref_915_1 on item_refer_915 
    (cod_empresa,cod_item_analise,cod_item);

drop  table laudo_usu_915;
create table laudo_usu_915
  (
    cod_empresa char(2) not null,
    cod_usuario char(8) not null
  );

create unique index ix_lau_usu_915_1 
   on laudo_usu_915(cod_empresa,cod_usuario);

drop  table pa_laudo_915;
create table pa_laudo_915 
  (
    cod_empresa char(2) not null ,
    num_laudo decimal(6,0) not null ,
    num_versao decimal(3,0) not null,
    num_pa decimal(6,0) not null 
  );

drop  table par_laudo_915;
create table par_laudo_915 
  (
    cod_empresa char(2) not null,
    cod_item char(15) not null,
    cod_cliente char(15),
    tip_analise decimal(6,0) not null,
    pa_fora_especif char(1),
    tipo_venda char(11),
    bloqueia_laudo char(1),
    texto char(100)
  );

create unique index ix_par_ld_915_1 on par_laudo_915 
    (cod_empresa,cod_item,cod_cliente,tip_analise);

drop  table tipo_caract_915;
create table tipo_caract_915 
  (
    cod_empresa char(2) not null, 
    tip_analise decimal(6,0) not null,
    val_caracter decimal(3,0) not null,
    den_caracter char(45) not null
  );

create unique index ix_tip_car_915_1 on tipo_caract_915
    (cod_empresa,tip_analise,val_caracter);

drop  table validade_lote_915;
create table validade_lote_915(
   cod_empresa      char(02) not null,
   cod_item         char(15) not null,
   lote_tanque      char(10) not null,
   dat_fabricacao   date     not null
);

create unique index ix_vali_lote_915
   on validade_lote_915(cod_empresa, cod_item, lote_tanque);




create table espec_carac_915 
  (
    cod_empresa char(2),
    cod_item char(15),
    tip_analise decimal(6,0),
    cod_cliente char(15),
    val_caracter decimal(3,0)
  );

create unique index ix_espec_ca_915_1 on 
    espec_carac_915 (cod_empresa,cod_item,tip_analise,cod_cliente,
    val_caracter) ;

create table tip_estoque_915 (
cod_empresa             char(2) not null,
tip_estoq_insp          char(6) not null,
restricao_insp          char(6) not null,
status_liberado         char(1) not null,
tip_estoq_liber         char(6) not null,
restricao_liber         char(6) not null,
status_rejeitado        char(1) not null,
tip_estoque_rejei       char(6) not null,
restricao_rejei         char(6) not null,
primary key (cod_empresa, tip_estoq_insp, restricao_insp)
);


                                           