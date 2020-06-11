#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1393                                                 #
# OBJETIVO: GERAÇÃO DE TÍTULOS - INTEGRAÇÃO CONCUR                  #
# AUTOR...: IVO                                                     #
# DATA....: 10/06/2020                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_browse          VARCHAR(10)

DEFINE m_arquivo         VARCHAR(10),
       m_carga           VARCHAR(10),
       m_funcio          VARCHAR(10),
       m_relat           VARCHAR(10),
       m_ad              VARCHAR(10),
       m_ap              VARCHAR(10)
       
DEFINE m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_empresa     CHAR(02),
       m_num_lista       INTEGER

DEFINE mr_cabec          RECORD
       cod_empresa       CHAR(02),
       nom_arquivo       VARCHAR(80),
       dat_carga  	     DATE, 
       funcio_id         VARCHAR(15),
       relat_key         VARCHAR(15),     
       num_ad            INTEGER,
       num_ap            INTEGER
END RECORD

DEFINE m_caminho         VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_carregando      SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     CHAR(40),
       m_arq_arigem      CHAR(100),
       m_progres         SMALLINT,
       m_qtd_item        INTEGER,
       m_ind             INTEGER

DEFINE ma_files ARRAY[50] OF CHAR(100)

DEFINE ma_itens ARRAY[5000] OF RECORD
       pessoal           CHAR(01),        
       funcionario       VARCHAR(60),  
       funcio_id         VARCHAR(15),
       relat_key         VARCHAR(15),    
       empresa           VARCHAR(15),      
       despesa           VARCHAR(15),      
       moeda             VARCHAR(15),        
       tip_desp          VARCHAR(15),        
       den_desp          VARCHAR(50),     
       cent_cust         VARCHAR(15),    
       situacao          VARCHAR(40),     
       dat_emissao       VARCHAR(25),  
       dat_pagto         VARCHAR(25),    
       tip_pgto          VARCHAR(30),
       num_ad            INTEGER,
       num_ap            INTEGER
END RECORD

#-----------------#
FUNCTION pol1393()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1393-12.00.00  "
   CALL func002_versao_prg(p_versao)
    
   CALL pol1393_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1393_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_find        VARCHAR(10),
           l_fechar      VARCHAR(10),
           l_titulo      VARCHAR(100)
    
    LET l_titulo = "GERAÇÃO DE TÍTULOS - INTEGRAÇÃO CONCUR - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_carga = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
    CALL _ADVPL_set_property(l_carga,"IMAGE","IMPORTAR_ARQUIVO")     
    CALL _ADVPL_set_property(l_carga,"TYPE","CONFIRM")     
    CALL _ADVPL_set_property(l_carga,"TOOLTIP","Selecionar um arquivo para carga")
    CALL _ADVPL_set_property(l_carga,"EVENT","pol1393_carga_informar")
    CALL _ADVPL_set_property(l_carga,"CONFIRM_EVENT","pol1393_carga_info_conf")
    CALL _ADVPL_set_property(l_carga,"CANCEL_EVENT","pol1393_carga_info_canc")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"TOOLTIP","Proessa a carga do arquivo")
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1393_processar")

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1393_find")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_fechar,"EVENT","pol1391_fechar")

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1393_cria_campos(l_panel)
   #CALL pol1393_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1393_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LTITLEDPANELEX",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",60)
    CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)
    
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",m_pnl_info)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"nom_arquivo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",510,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Dt import:")    

    LET m_carga = _ADVPL_create_component(NULL,"LDATEFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_carga,"POSITION",560,10)     
    CALL _ADVPL_set_property(m_carga,"VARIABLE",mr_cabec,"dat_carga")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",680,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Func ID:")    

    LET m_funcio = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_funcio,"POSITION",730,10)     
    CALL _ADVPL_set_property(m_funcio,"LENGTH",10) 
    CALL _ADVPL_set_property(m_funcio,"VARIABLE",mr_cabec,"funcio_id")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",840,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Relat key:")    

    LET m_relat = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_relat,"POSITION",890,10)     
    CALL _ADVPL_set_property(m_relat,"LENGTH",10) 
    CALL _ADVPL_set_property(m_relat,"VARIABLE",mr_cabec,"relat_key")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",1000,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Num AD:")    

    LET m_ad = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_ad,"POSITION",1050,10)     
    CALL _ADVPL_set_property(m_ad,"LENGTH",10) 
    CALL _ADVPL_set_property(m_ad,"VARIABLE",mr_cabec,"num_ad")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",1150,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Num AP:")    

    LET m_ap = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_ap,"POSITION",1200,10)     
    CALL _ADVPL_set_property(m_ap,"LENGTH",10) 
    CALL _ADVPL_set_property(m_ap,"VARIABLE",mr_cabec,"num_ap")

END FUNCTION

{
#---------------------------------------#
FUNCTION pol1393_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Lista")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_Lista")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_Lista")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valid ini")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_val_ini")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valid fim")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_val_fim")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","B. ped")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","bloqueia_pedido")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","B. fat")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","bloqueia_faturamento")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Moeda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_moeda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","U Med")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","unid_medida")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cliente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cliente")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","AEN")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","area_e_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre Unit")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_unit")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pre mínimo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",120)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_minimo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Mensagem")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#-------------------------------------#
FUNCTION pol1393_ativa_campo(l_status)#
#-------------------------------------#
   
   DEFINE l_status       SMALLINT
   
    CALL _ADVPL_set_property(m_carga,"ENABLE",FALSE) 
