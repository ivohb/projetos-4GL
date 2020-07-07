drop table ordens_export_912;
create table ordens_export_912 (
   cod_empresa    char(02) not null,
   num_ordem      integer not null,
   qtd_planej     decimal(10,3) not null,
   dat_entrega    date not null,
   ies_situa      char(01),
   primary key(cod_empresa,num_ordem)
);
   
   
drop table TBLInWOComplete;
create table TBLInWOComplete (
IDInWOComplete                serial             not null,           
WoCode                        varchar(41)        NOT NULL,              
ProductCode                   varchar(20)        NOT NULL,              
WOSituation                   varchar(10)        NOT NULL,              
ExtCode                       varchar(20),                          
Auxcode1                      varchar(20),                          
Auxcode2                      varchar(20),                          
WoTypeCode                    varchar(15)        NOT NULL,              
DtIssue                       date               NOT NULL,              
DtDue                         date               NOT NULL,              
DtPlanStart                   datetime year to second,                             
DtPlanEnd                     datetime year to second,                            
TotalQty                      decimal(19,4)      NOT NULL,              
Status                        smallint           NOT NULL,              
Comments                      varchar(200),                         
TechDoc                       varchar(200),                        
ProcListCode                  varchar(20),                          
FlgPrinted                    smallint,                             
WODetCode                     varchar(10)        NOT NULL,              
WODetName                     varchar(40),                          
WODetExtCode                  varchar(20),                          
WODetAuxCode1                 varchar(20),                          
WODetAuxCode2                 varchar(20),                          
WODetTechDoc                  varchar(200),                        
StdSpeed                      decimal(28,23)     NOT NULL,              
StdSpeedFormat                smallint           NOT NULL,              
ResourceCode                  varchar(15),                          
WODetStatus                   smallint           NOT NULL,              
WODetDtPlanStart              date,                             
WODetDtPlanEnd                date,                             
ManagerGrpCode                varchar(15)        NOT NULL,              
DefaultOrigin                 smallint           NOT NULL,              
DefaultType                   smallint           NOT NULL,              
SetUpTime                     integer            NOT NULL,              
SetUpTimeFormat               smallint           NOT NULL,              
StdCrew                       decimal(9,4),                         
PlanType                      smallint           NOT NULL,              
Unit1Factor                   decimal(8,4),                         
ReportTrigger                 smallint           NOT NULL,              
DisablePrint                  smallint           NOT NULL,              
BaseQty                       decimal(9,2)       NOT NULL,              
MatListCode                   varchar(20),                          
Qty                           decimal(19,4)      NOT NULL,              
Unit1Code                     varchar(5)         NOT NULL,              
Unit2Factor                   decimal(8,4),                         
Unit2Code                     varchar(5),                           
Unit3Factor                   decimal(8,4),                         
Unit3Code                     varchar(5),                           
LabelCode                     varchar(20),                          
FlgQCInspection               smallint           NOT NULL,              
DefaultAddressCode            varchar(15),                          
ConsAddressCode               varchar(15),                          
ProdAddressCode               varchar(15),                          
ScrapAddressCode              varchar(15),                          
ReWorkAddressCode             varchar(15),                          
Yield                         decimal(8,4),                         
Unit1FactorScrap              decimal(8,4),                         
Unit1FactorReWork             decimal(8,4),                         
MPSPlanHDCode                 varchar(20),                          
WOCodeOrigin                  varchar(41),                          
BackFlushType                 smallint,                             
LotCodeBackFlushType          varchar(41),                          
DefaultFactorOrigin           smallint,                             
DefaultFactorScrapOrigin      smallint,                             
DefaultFactorReWorkOrigin     smallint,                             
StdCycleTime                  decimal(28,23),                       
StdCycleTimeOrigin            smallint,                             
DefaultCycleTimeOrigin        smallint,                             
CommittedStdSpeed             decimal(28,23),                       
FlgEng                        smallint,                             
ToolingTypeCode               varchar(15),                          
Excluded                      smallint           NOT NULL,              
Integrated                    smallint           NOT NULL,              
DtCreation                    DATETIME YEAR TO SECOND,
DtIntegration                 date,                             
ErrDescription                varchar(200),                                 
Selected                      smallint           NOT NULL,              
DataOrigin                    varchar(200),                                 
DtTimeStampImp                date,
ies_exportado                 char(01),
primary key (IDInWOComplete)                       
);

drop table TBLInProduct;
create table TBLInProduct (
IDInProduct                  serial              not null, 
PlantCode                    varchar(15)         NOT NULL,
ProductTypeCode              varchar(15)         NOT NULL,
Code                         varchar(20)         NOT NULL,
Name                         varchar(70)         NOT NULL,
Description                  varchar(200),            
Unit1Code                    varchar(5)          NOT NULL,
Unit2Code                    varchar(20),             
Unit2Factor                  decimal(8,4),            
Unit3Code                    varchar(5),              
Unit3Factor                  decimal(8,4),            
ExtCode                      varchar(50),             
FlgEnable                    smallint            NOT NULL,
FlgPrintP00                  smallint            NOT NULL,
FlgPrintP01                  smallint            NOT NULL,
FlgPrintP02                  smallint            NOT NULL,
FlgPrintP03                  smallint            NOT NULL,
FlgPrintP04                  smallint            NOT NULL,
FlgPrintP05                  smallint            NOT NULL,
FlgPrintP06                  smallint            NOT NULL,
FlgPrintP07                  smallint            NOT NULL,
FlgPrintP08                  smallint            NOT NULL,
FlgPrintP09                  smallint            NOT NULL,
FlgPrintP10                  smallint            NOT NULL,
FlgPrintP11                  smallint            NOT NULL,
FlgprintP12                  smallint            NOT NULL,
QtyPackage                   decimal(19,4),           
QtyProdReport                decimal(19,4),           
QtyCEP                       decimal(19,4),           
QtyQC                        decimal(19,4),           
ValiditPeriod                integer,                     
ValPeriodUnit                smallint,                 
ProductLabelCode             varchar(10),             
QualityLabelCode             varchar(10),             
BUnitCode                    varchar(20),             
Yield                        numeric(8,4),            
WOCriteria                   smallint,                
MinLot                       numeric(19,4),           
EconomicLot                  decimal(19,4),           
LogLeadTime                  integer,                     
QueueLeadTime                integer,                     
CostCenterCode               varchar(20),             
QtdBillMatCons               decimal(19,4),           
DefaultAddressCode           varchar(20),             
FlgBackFlush                 smallint            NOT NULL,
BackFlushType                smallint,                 
LotBackFlushType             smallint,                 
AddressBackFlushType         integer,                     
SecondName                   varchar(30),             
FamilyProductCode            varchar(15),             
FamilyProductName            varchar(30),             
ValueScrap                   decimal(6,3),            
Label_ItemCode               varchar(10),             
ReportByLot                  smallint,                
BackFlushTypeOrigin          smallint,                
ScrapBFlush                  smallint,                
FlgTooling                   smallint,             
Excluded                     smallint            NOT NULL,
Integrated                   smallint             NOT NULL,
DtCreation                   DATETIME YEAR TO SECOND,
DtIntegration                date,                
ErrDescription               varchar(200),                    
Selected                     smallint            NOT NULL,
DataOrigin                   varchar(200),                    
DtTimeStampImp               date,     
ies_exportado                char(01),           
primary key(IDInProduct)
);

drop  table TBLInWOQueue;
create table TBLInWOQueue (
IDInWOQueue                  serial         not null,
ManagerGrpCode               varchar(15),          
ResourceCode                 varchar(15),          
Sequence                     integer                 NOT NULL,
WOCode                       varchar(41),          
WODetCode                    varchar(10),          
WOEngCode                    varchar(41),          
Qty                          decimal(19,4),        
DtStart                      datetime year to second,             
DtEnd                        datetime year to second,             
Excluded                     smallint             NOT NULL,
Integrated                   smallint             NOT NULL,
DtCreation                   DATETIME YEAR TO SECOND,
DtIntegration                date,
ErrDescription               varchar(200),
Selected                     smallint            NOT NULL,
DataOrigin                   varchar(200),                    
DtTimeStampImp               date,  
ies_exportado                char(01),              
primary key(IDInWOQueue)
);

drop table proces_export_factory;
create table proces_export_factory (
  id_proces         integer,
  cod_empresa       char(02),
  proces_export     char(01),
  proces_import     char(01),
  proces_apont      char(01),
  primary key(cod_empresa)
);
  

drop table item_sucata_304;
create table item_sucata_304 (
 cod_empresa  char(02) not null,
 cod_operac   char(05) not null,
 cod_item     char(15) not null,
 primary key(cod_empresa, cod_operac)
);



drop TABLE erro_pol1305_912;
CREATE TABLE erro_pol1305_912 (
    cod_empresa       char(02),
    num_ordem         INTEGER,
    erro              char(100)
);
   
CREATE INDEX erro_pol1305_912 ON
   erro_pol1305_912(cod_empresa, num_ordem);

drop table man_apont_304 ;
create table man_apont_304 
  (
    cod_empresa char(2),
    id_registro serial not null ,
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    cod_roteiro char(15),
    num_rot_alt decimal(2,0),
    num_lote char(15),
    dat_inicial datetime year to day,
    dat_final datetime year to day,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_unid_prod char(5),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_apon char(1),
    tip_operacao char(1),
    cod_local_prod char(10),
    cod_local_est char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial char(5),
    hor_final char(5),
    unid_funcional char(10),
    dat_atualiz datetime year to second,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_processo integer,
    num_proc_ant integer,
    num_proc_dep integer,
    num_transac integer,
    mensagem char(210),
    dat_process datetime year to second,
    id_apont integer,
    id_tempo integer,
    integrado integer,
    den_erro char(500),
    dat_integra char(20),
    usuario char(8),
    tip_integra char(1),
    concluido char(1),
    num_docum char(15),
    qtd_movto decimal(10,3),
    tip_movto char(1),
    qtd_tempo integer,
    dat_criacao datetime year to second,
    primary key(id_registro)
  );

create index ix1_man_apont_304 on man_apont_304 
    (cod_empresa,num_ordem);




create table man_parada_912 (
   IDOutRSEv           integer,
   cod_empresa         char(02),
   num_ordem           integer,
   cod_operac          char(05),
   cod_parada          char(20),
   dat_ini_parada      datetime YEAR to minute,
   dat_fim_parada      datetime YEAR to minute,
   tempo_parada        integer,
   primary key(IDOutRSEv)
);

create index ix_man_parada_912 on man_parada_912
 (cod_empresa, num_ordem,  cod_operac);
 

CREATE TABLE erros_pol1305 (
 cod_empresa char(02),
 num_ordem   INTEGER,
 mensagem    char(150)
);

create index ix_erros_pol1305 
 on erros_pol1305(cod_empresa,num_ordem);

create table erro_import_304 (
 id_apont_ppi    integer,
 id_tempo_ppi    integer,
 den_erro        char(800),
 den_operacao    char(50),
 dat_integra     char(20)
);

create index ix_erro_import_304 on erro_import_304(id_apont_ppi);


 

create table calendar_apont_304 (
  dia_semana          char(01) not null,
  hora_ini            char(08) not null,
  hora_fim            char(08) not null
);

create index ix_calendar_304 
 on calendar_apont_304(dia_semana);
