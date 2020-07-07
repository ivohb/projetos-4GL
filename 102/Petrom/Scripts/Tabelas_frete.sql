--drop table par_frete_455;
create table par_frete_455 (
   cod_empresa        char(02) not null,
   dat_corte          date not null,
   pct_tolerancia     decimal(5,2),  --toler�ncia para valores divergentes
   pct_seguro         decimal(6,2),  --pct seguro para gera��o do relat�rio
   primary key (cod_empresa)
);

--drop table transportador_455 ;
create table transportador_455 
  (
    cod_transpor   char(15) not null,
    cod_cnd_pgto   integer  not null,
    pct_frete_peso decimal(5,2) not null ,  --acrescentar ao valor calculado
    pct_ad_valorem decimal(5,2) not null ,  --seguro sobre o valor da mercadoria
    pct_gris       decimal(5,2) not null ,  --sobre o valor da mercadoria
    val_despacho   decimal(12,2) not null ,  --acrescentar ao valor calculado
    val_tas        decimal(12,2) not null ,  --acrescentar ao valor calculado
    val_trt        decimal(12,2) not null ,  --acrescentar ao valor calculado
    ies_ddr        char(01) not null,
    dat_vencto_ddr date,
    primary key (cod_transpor) 
  );


--drop table carreta_455;
create table carreta_455 (
   cod_transpor        char(15) not null,
   chapa               char(10) not null,
   cod_tip_veiculo     char(04) not null,  --do cadastro de tipo de veiculo
   tip_carga           char(01) not null,   --S-Seca, G-Granel
   peso_minimo         decimal(10,3) not null,
   qtd_eixo            integer not null,
   ies_dif_preco       char(01) not null,
   primary key (cod_transpor, chapa)
);

--drop table rota_frete_455;
create table rota_frete_455 (
   cod_rota           integer  not null,   --auto incremento
   des_rota           char(76) not null,
   cod_cidade         char(05) not null,
   primary key (cod_rota)
);

--drop table cli_fornec_455;
create table cli_fornec_455 (
   ies_cli_fornec     char(01) not null,  --C = Cliente F = Fornecedor
   cod_cli_fornec     char(15) not null,
   cod_rota           integer not null,
   primary key (ies_cli_fornec, cod_cli_fornec )
);

--drop table preco_frete_455;
create table preco_frete_455 (
    id_registro      integer not null ,
    cod_transpor     char(15) not null ,
    cod_tip_veiculo  char(04) not null,            --do cadastro de tipo de veiculo
    tip_carga        char(1) not null ,            --S-Seca, G-Granel
    cod_cidade_orig  char(5) not null ,
    cod_rota_orig    integer not null,            -- pode ser zero             
    cod_cidade_dest  char(5) not null,
    cod_rota_dest    integer not null,            -- pode ser zero     
    val_pri_viagem   decimal(12,2) not null ,
    val_demais_viag  decimal(12,2) not null ,
    tip_valor        char(1) not null ,           -- T-Tonelada  V-Viagem
    tip_cobranca     char(1) not null ,           -- N-Peso da nota  C-Peso minimo da carreta
    val_pedagio      decimal(12,2) not null ,
    val_adicional    decimal(12,2) not null ,
    dat_ini_vigencia date not null ,
    dat_fim_vigencia date not null ,
    num_versao       integer not null ,
    dat_atualiz      date not null ,
    cod_usuario      char(8) not null ,
    operacao         char(60),
    primary key (id_registro) 
);

--drop table conhec_proces_455 ;
create table conhec_proces_455  (
    id_registro   integer,
    cod_empresa   char(2),
    cod_transpor  char(19),
    num_conhec    decimal(7,0),
    ser_conhec    char(3),
    ssr_conhec    decimal(2,0),
    placa_veiculo char(10),
    dat_conhec    date,
    val_frete     decimal(12,2),
    val_calculado decimal(12,2),
    cidade_orig   char(5),
    cidade_dest   char(5),
    motivo        char(210),
    divergencia   char(78),
    tip_frete     char(01),
    val_tolerancia decimal(12,2), --alterar no cliente
    primary key (id_registro) 
);

create unique index conhec_proces_455 on  conhec_proces_455
 (cod_empresa, cod_transpor, num_conhec, ser_conhec, ssr_conhec);

--drop table erro_conhec_455;
create table erro_conhec_455 (
  cod_empresa        char(02),
  cod_transpor       char(19),
  num_conhec         integer,
  ser_conhec         char(3),
  ssr_conhec         decimal(2,0),
  den_erro           char(500),
  dat_ini_proces     date,
  hor_ini_proces     char(08)
);

--drop table audit_conhec_455;
CREATE TABLE audit_conhec_455(
      cod_empresa  CHAR(02),	
      id_tabela    integer,	  
      id_cf_proces integer,
      dat_confer   date,	
      hor_confer   char(08),	
      erro_confer  char(80),
      dat_liberac  date,
      hor_liberac  char(08),
      cod_usuario  char(08)
);
 
--drop table tip_despesa_455;
create table tip_despesa_455  (
    cod_empresa      char(2),
    cod_tip_despesa  decimal(4,0),
    primary key (cod_empresa, cod_tip_despesa) 
);

--drop table tip_despesa_455;
create table grupo_frete_455  (
    cod_empresa      char(2),
    cod_grupo        decimal(4,0),
    primary key (cod_empresa, cod_grupo) 
);

--drop table tip_veiculo_455;
create table tip_veiculo_455  (
    cod_empresa          char(02) not null,
    cod_tip_veiculo      char(04) not null,
    des_tip_veiculo      char(20) not null,
    primary key (cod_empresa, cod_tip_veiculo) 
);

create table placa_veic_455 (
 cod_empresa   char(02) not null,
 cod_transpor  char(15) not null,
 num_conhec    decimal(7,0) not null,
 ser_conhec    char(03) not null,
 ssr_conhec    decimal(2,0) not null,
 placa_veic    char(07) not null,
 cidade_orig   char(05), 
 cidade_dest   char(05)
 primary key (cod_empresa,cod_transpor,num_conhec,ser_conhec,ssr_conhec)
);


CREATE TABLE calculo_conhec_455(
  cod_empresa    CHAR(02),	
  id_cf_proces   integer,
  id_tabela      integer,	  
  val_tabela     decimal(12,2),
  val_pedagio    decimal(12,2),
  tip_cobranca   char(01),        --C=Peso m�nimo N=Normal
  peso_minimo    decimal(10,3),
  peso_nf        decimal(10,3),
  qtd_eixo       integer,
  val_ad_valorem decimal(12,2),
  val_gris       decimal(12,2),
  val_despacho   decimal(12,2),
  val_tas        decimal(12,2),
  val_trt        decimal(12,2),
  primary key (cod_empresa, id_cf_proces)    
);

      