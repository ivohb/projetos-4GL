create table ordens_export_912 (
   cod_empresa    char(02) not null,
   num_ordem      integer not null,
   qtd_planej     decimal(10,3) not null,
   dat_entrega    date not null,
   primary key(cod_empresa,num_ordem)
);
   
   

create table TBLInWOComplete (
IDInWOComplete                integer           IDENTITY(1,1),
WoCode                        varchar(41)        NOT NULL,              
ProductCode                   varchar(20)        NOT NULL,              
WOSituation                   varchar(10)        NOT NULL,              
ExtCode                       varchar(20),                          
Auxcode1                      varchar(20),                          
Auxcode2                      varchar(20),                          
WoTypeCode                    varchar(15)        NOT NULL,              
DtIssue                       datetime           NOT NULL,              
DtDue                         datetime           NOT NULL,              
DtPlanStart                   datetime,                             
DtPlanEnd                     datetime,                            
TotalQty                      decimal(19,4)      NOT NULL,              
Status                        smallint           NOT NULL,              
Comments                      varchar(500),                         
TechDoc                       varchar(2000),                        
ProcListCode                  varchar(20),                          
FlgPrinted                    smallint,                             
WODetCode                     varchar(10)        NOT NULL,              
WODetName                     varchar(40),                          
WODetExtCode                  varchar(20),                          
WODetAuxCode1                 varchar(20),                          
WODetAuxCode2                 varchar(20),                          
WODetTechDoc                  varchar(2000),                        
StdSpeed                      decimal(28,23)     NOT NULL,              
StdSpeedFormat                smallint           NOT NULL,              
ResourceCode                  varchar(15),                          
WODetStatus                   smallint           NOT NULL,              
WODetDtPlanStart              datetime,                             
WODetDtPlanEnd                datetime,                             
ManagerGrpCode                varchar(15)        NOT NULL,              
DefaultOrigin                 smallint           NOT NULL,              
DefaultType                   smallint           NOT NULL,              
SetUpTime                     integer            NOT NULL,              
SetUpTimeFormat               tinyint            NOT NULL,              
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
DtCreation                    datetime           NOT NULL,              
DtIntegration                 datetime,                             
ErrDescription                varchar(200),                                 
Selected                      smallint           NOT NULL,              
DataOrigin                    varchar(200),                                 
DtTimeStampImp                datetime,
primary key (IDInWOComplete)                       
);

create table TBLInProduct (
IDInProduct                  int            IDENTITY(1,1), 
PlantCode                    varchar(15)         NOT NULL,
ProductTypeCode              varchar(15)         NOT NULL,
Code                         varchar(20)         NOT NULL,
Name                         varchar(70)         NOT NULL,
Description                  varchar(500),            
Unit1Code                    varchar(5)          NOT NULL,
Unit2Code                    varchar(20),             
Unit2Factor                  decimal(8,4),            
Unit3Code                    varchar(5),              
Unit3Factor                  decimal(8,4),            
ExtCode                      varchar(50),             
ProductImage                 image,                   
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
ValiditPeriod                int,                     
ValPeriodUnit                tinyint,                 
ProductLabelCode             varchar(10),             
QualityLabelCode             varchar(10),             
BUnitCode                    varchar(20),             
Yield                        numeric(8,4),            
WOCriteria                   smallint,                
MinLot                       numeric(19,4),           
EconomicLot                  decimal(19,4),           
LogLeadTime                  int,                     
QueueLeadTime                int,                     
CostCenterCode               varchar(20),             
QtdBillMatCons               decimal(19,4),           
DefaultAddressCode           varchar(20),             
FlgBackFlush                 smallint            NOT NULL,
BackFlushType                tinyint,                 
LotBackFlushType             tinyint,                 
AddressBackFlushType         int,                     
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
Integrated                   tinyint             NOT NULL,
DtCreation                   datetime            NOT NULL,
DtIntegration                datetime,                
ErrDescription               varchar(200),                    
Selected                     smallint            NOT NULL,
DataOrigin                   varchar(200),                    
DtTimeStampImp               datetime,                
primary key(IDInProduct)
);


create table TBLInWOQueue (
IDInWOQueue                  int            IDENTITY(1,1),
ManagerGrpCode               varchar(15),          
ResourceCode                 varchar(15),          
Sequence                     int                 NOT NULL,
WOCode                       varchar(41),          
WODetCode                    varchar(10),          
WOEngCode                    varchar(41),          
Qty                          decimal(19,4),        
DtStart                      datetime,             
DtEnd                        datetime,             
Excluded                     tinyint             NOT NULL,
Integrated                   tinyint             NOT NULL,
DtCreation                   datetime            NOT NULL,
DtIntegration                datetime,
ErrDescription               varchar(200),
Selected                     smallint            NOT NULL,
DataOrigin                   varchar(200),                    
DtTimeStampImp               datetime,                
primary key(IDInWOQueue)
);


create table TBLOutInteg (
IDOutInteg                 int             IDENTITY(1,1),
TransacType                tinyint         not null,      -- 1=boa 2=refugada
DtTimeStamp                datetime        not null,      -- 
WOCode                     varchar(20),                   -- num ordem
ProductCode                varchar(20),                   -- cod produto
LotCode                    varchar(41),                   -- Lote do material que esta sendo movimentado
Qty                        decimal(19,9),                 -- quantidade do movimento
Integrated                 tinyint         not null,      -- 0/2/3=(Integrar/Integrado ok/integrado com erro)
DtCreation                 datetime default getdate() not null,      -- Data e hora da Grava��o do registro
DtIntegration              datetime,                      -- Data e hora da Leitura do registro
ErrDescription             varchar(200),                  -- descri��o do erro
WODetCode                  varchar(20),                   -- c�digo da opera��o que deu origem ao movimento.
Shift                      smallint,                      -- Turno no qual foi realizada a movimenta��o
DtProduction               datetime,                      -- data da produ��o
OriginalQty                decimal(19,4),                 -- quantidade original
CompanyCode                varchar(20),                   -- c�digo da empresa
TraceLotCode               varchar(41),                   -- lote para movimenta��o
Selected                   smallint        not null,      -- 0 
DtEv                       smalldatetime   default getdate() not null -- data da produ��o
primary key(IDOutInteg)
);


create table TBLOutProdEv (
IDOutProdEv                 int             IDENTITY(1,1),
ResourceCode                varchar(15),
DtEv                        smalldatetime,  --data da produ��o
Shift                       smallint,
DtTimeStamp                 datetime,       --data do lan�amento
UserCode_Start              varchar(30),
WOCode                      varchar(41),    --numero da odem
WODetCode                   varchar(20),    -- c�digo da opera��o
WOShiftProdT                int,            -- tempo produtivo
Integrated                  tinyint,        -- 0=Liberado 1=em processo 2=int c/ sucesso 3=int. com erro
DtCreation                  datetime,       -- data e hora da grava��o do registro
DtIntegration               datetime,       -- data e hora da leitura do registro
primary key(IDOutProdEv)
);

