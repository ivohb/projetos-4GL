--Armazena um resumo do processamento,
--quando o usu�rio aprova um documento

create table resumo_aprov_265 (
 cod_empresa char(02),
 num_docum   char(10),
 tip_docum   char(02),
 mensagem    char(60),
 nivel_aprov char(02),
 user_aprov  char(08),
 dat_aprov   datetime,
 hor_aprov   char(08)
);

create index resu1_aprov_265 on
 resumo_aprov_265(user_aprov, nivel_aprov);
 
 
--armazena o AR marcado com X e sua respectiva
--situa��o antes da marca��o (ies_incl_cap)
--crea��o do campo ies_ar_cs, p/ armazenar NOTA ou CONTRATO

create table nfe_aprov_265 (
 cod_empresa   char(02),
 num_aviso_rec integer,
 ies_incl_cap  char(01),
 ies_ar_cs     char(10)
)

create unique index nfe_aprov_265_1 on nfe_aprov_265
(cod_empresa, num_aviso_rec);

--como o pol1159 (gera��o da grade de aprova��o de AR)
--roda sem acompanhamento do usu�rio, essa tabela armazenar�
--erros cr�ticos ocorridos durante o processamento

create table erro_pol1159_265(
 cod_empresa     char(02),
 num_aviso_rec   integer,
 den_erro        char(76),
 dat_ini_process datetime,
 hor_ini_process char(08)
)

create index erro_pol1159_265_1 on erro_pol1159_265
 (cod_empresa, dat_ini_process, hor_ini_process)

create index erro_pol1159_265_2 on erro_pol1159_265
 (cod_empresa, num_aviso_rec)
 
--armazena informa��es dos documentos processados
--os quais ser�o enviados por email, para o usu�-
--rio solicitante ou para o pr�ximo aprovador
 
   CREATE  TABLE email_env_265(
      id_registro    int IDENTITY(1,1) primary key,                             
	    num_docum      CHAR(10),
	    num_versao     CHAR(02),
	    tip_docum      CHAR(02),
	    cod_empresa    CHAR(02),
	    cod_usuario    CHAR(10),
	    email_usuario  CHAR(50),
	    nom_usuario    CHAR(50),
	    cod_emitente   CHAR(10),
	    email_emitente CHAR(50),
	    nom_emitente   CHAR(50)
	 );

create unique index email_env_265_ix1 on
email_env_265(id_registro);
 
create index email_env_265_ix2 on
email_env_265(cod_usuario);

--Estapas que o solicitante selecionou para serem aprovadas
--por um dos aprovantes

create table aprov_etapa_265 
  (
    cod_empresa     char(02) not null,
    unid_funcional  char(10) not null,  
    num_contrato    integer  not null,
    versao_contrato integer  not null,
    num_etapa       integer  not null,
    cod_aprovador   char(02),
    usuario_aprov   char(08),
    dat_aprov       datetime,
    hor_aprova      char(08),
    usuario_solic   char(08),
    dat_solic       datetime,
    hor_solic       char(08)
  );

create index aprov_etapa_265_1 on aprov_etapa_265 
    (cod_empresa, cod_aprovador);
    
create unique index aprov_etapa_265_2 on aprov_etapa_265 
    (cod_empresa,cod_aprovador,num_contrato,num_etapa);

create unique index aprov_etapa_265_3 on aprov_etapa_265 
    (cod_empresa,num_contrato,versao_contrato,num_etapa);

--grade de aprova��o do AR

create table aprov_ar_265 
  (
    cod_empresa       char(2) not null,
    num_aviso_rec     integer not null,
    hierarquia        integer not null,
    cod_nivel_autorid char(2) not null,
    nom_usuario_aprov char(8),
    dat_aprovacao     datetime,
    hor_aprovacao     char(8),
    usuario_inclusao  char(8),
    dat_inclusao      datetime,
    hor_inclusao      char(8)
  );

create unique index aprov_ar_265_1 on aprov_ar_265 
    (cod_empresa, num_aviso_rec, hierarquia);

create unique index aprov_ar_265_2 on aprov_ar_265 
    (cod_empresa, num_aviso_rec, cod_nivel_autorid);

create index aprov_ar_265_3 on aprov_ar_265 
    (cod_empresa, cod_nivel_autorid);

--asrmazenar� as ADs cujo texto teve jun��o com
--texto do contrato de servi�o

create table ad_contrato_265 
  (
    cod_empresa       char(2) not null,
    num_ad            integer not null);
    
create unique index ad_contrato_265_1 on ad_contrato_265 
    (cod_empresa, num_ad);
    

--nivel de autoridade p/ AR/CS
create table nivel_autorid_265
  (
    cod_empresa       char(2) not null,
    cod_nivel_autorid char(2) not null,
    den_nivel_autorid char(30) not null,
    cod_nivel_subst   char(2),
    primary key (cod_empresa,cod_nivel_autorid)
  );

--hierarquia de aprova��o p/ AR/CS
create table nivel_hierarq_265
  (
    empresa          char(2) not null ,
    nivel_autoridade char(2) not null ,
    hierarquia       decimal(2,0) not null ,
    primary key (empresa,nivel_autoridade,hierarquia)
  );

--nivel de autoridade do usu�rio p/ AR/CS
create table nivel_usuario_265
  (
    cod_empresa        char(2) not null ,
    nom_usuario        char(8) not null ,
    cod_nivel_autorid  char(2) not null ,
    num_versao         decimal(3,0) not null ,
    ies_versao_atual   char(10) not null ,
    nom_usuario_cad    char(8) not null ,
    dat_cadast         datetime not null ,
    hor_cadast         char(8) not null ,
    ies_tip_autoridade char(1),
    primary key (cod_empresa,nom_usuario,cod_nivel_autorid,num_versao,ies_versao_atual) 
  );
 
--unidade funcional para AR/CS 

create table unid_aprov_265
  (
    cod_empresa    char(2) not null ,
    nom_usuario    char(8) not null ,
    cod_uni_funcio char(10) not null ,
    primary key (cod_empresa,nom_usuario,cod_uni_funcio)  
  );

create index unid_aprov_265 on 
unid_aprov_265(cod_empresa,nom_usuario);

--unidade funcional isenta de aprova��o
create table unid_isenta_265
  (
    empresa        char(2) not null,
    cod_uni_funcio char(10) not null,
    primary key (empresa,cod_uni_funcio)
  );


--empresas que ser�o processadas pelo pol1159
create table empresa_proces_265
  (
    cod_empresa    char(2) not null,
    dat_corte      datetime not null,
    primary key (cod_empresa)
  );

--armazenar� os usu�rios com autoridade de administrador
-- da grade de aprova��o
create table usuario_adim_265
  (
    nom_usuario    char(08) not null,
    primary key (nom_usuario)
  );



create table usuario_subs_265
  (
    cod_empresa      char(2)      not null,
    cod_usuario      char(8)      not null,
    num_versao       decimal(3,0) not null,
    ies_versao_atual char(1)      not null,
    cod_usuario_subs char(8)      not null,
    dat_ini_validade datetime     not null,
    dat_fim_validade datetime     not null,
    cod_usuario_incl char(8)      not null,
    dat_inclusao     date         not null,
    hor_inclusao     char(8)      not null,
    motivo_subs      char(50)     not null
  );

create unique index usuario_subs_265_1 on usuario_subs_265 
    (cod_empresa,cod_usuario,cod_usuario_subs,dat_ini_validade,
    ies_versao_atual,num_versao) using btree ;
    
create index usuario_subs_265_2 on usuario_subs_265 
    (cod_empresa,cod_usuario_subs,ies_versao_atual,num_versao) 
    using btree ;
