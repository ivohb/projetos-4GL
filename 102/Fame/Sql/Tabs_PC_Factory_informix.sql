drop table ordens_export_912;
create table ordens_export_912 (
   cod_empresa    char(02) not null,
   num_ordem      integer not null,
   qtd_planej     decimal(10,3) not null,
   dat_entrega    date not null,
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
DtIssue                       date           NOT NULL,              
DtDue                         date           NOT NULL,              
DtPlanStart                   date,                             
DtPlanEnd                     date,                            
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
SetUpTimeFormat               smallint            NOT NULL,              
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
ies_exportar                  char(01)
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
ies_exportar                 char(01),           
primary key(IDInProduct)
);


create table TBLInWOQueue (
IDInWOQueue                  serial         not null
ManagerGrpCode               varchar(15),          
ResourceCode                 varchar(15),          
Sequence                     integer                 NOT NULL,
WOCode                       varchar(41),          
WODetCode                    varchar(10),          
WOEngCode                    varchar(41),          
Qty                          decimal(19,4),        
DtStart                      date,             
DtEnd                        date,             
Excluded                     smallint             NOT NULL,
Integrated                   smallint             NOT NULL,
DtCreation                   DATETIME YEAR TO SECOND,
DtIntegration                date,
ErrDescription               varchar(200),
Selected                     smallint            NOT NULL,
DataOrigin                   varchar(200),                    
DtTimeStampImp               date,  
ies_exportar                 char(01),              
primary key(IDInWOQueue)
);
