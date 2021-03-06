#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1394                                                 #
# OBJETIVO: CONSULTA INTEGRA��O CONCUR X LOGIX                      #
# AUTOR...: IVO                                                     #
# DATA....: 10/06/2020     cap1040 e/ou cap9991 /cap2360            #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE     m_den_empresa   VARCHAR(36)

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_pnl_info        VARCHAR(10),
       m_browse          VARCHAR(10),
       m_brz_erro        VARCHAR(10),
       m_label           VARCHAR(10)
       
DEFINE m_arquivo         VARCHAR(10),
       m_de              VARCHAR(10),
       m_ate             VARCHAR(10),
       m_func            VARCHAR(10),
       m_relat           VARCHAR(10),
       m_ad              VARCHAR(10),
       m_ap              VARCHAR(10),
       m_user            VARCHAR(10)
       
DEFINE m_ies_carga       SMALLINT,
       m_ies_info        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_cod_empresa     CHAR(02),
       m_num_lista       INTEGER,
       m_ies_print       SMALLINT,
       m_index           INTEGER,
       m_page_length     INTEGER,
       m_despesa         DECIMAL(12,2)


DEFINE mr_cabec          RECORD
       nom_arquivo       VARCHAR(80),
       funcio_id         VARCHAR(15),
       relat_key         VARCHAR(15),    
       dat_de      	     DATE, 
       dat_ate     	     DATE, 
       num_ad            INTEGER,
       num_ap            INTEGER,
       usuario           VARCHAR(08)
END RECORD

DEFINE m_caminho         VARCHAR(120),
       m_caminho_pro     VARCHAR(120),
       m_caminho_pgi     VARCHAR(120),
       m_ies_ambiente    CHAR(01),
       m_carregando      SMALLINT,
       m_posi_arq        INTEGER,
       m_qtd_arq         INTEGER,
       m_nom_arquivo     VARCHAR(80),
       m_arq_origem      VARCHAR(100),
       m_progres         SMALLINT,
       m_qtd_item        INTEGER,
       m_qtd_ad          INTEGER,
       m_ind             INTEGER,
       m_linha           VARCHAR(250),
       m_id_arquivo      INTEGER,
       m_id_arquivoa     INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         VARCHAR(08),
       m_arq_convert     VARCHAR(200),
       m_arq_renomeado   VARCHAR(200),
       m_pos_ini         INTEGER,
       m_pos_fim         INTEGER,
       m_ies_erro        SMALLINT,
       m_ssr_nf          INTEGER,
       m_cent_cust       INTEGER,
       m_ctrl_aen        CHAR(01),
       m_query           VARCHAR(1000)


DEFINE ma_itens ARRAY[2000] OF RECORD
       cod_empresa       char(02),
       id_arquivo        integer,
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
       num_ap            INTEGER,
       cod_tip_despesa   INTEGER
END RECORD

DEFINE mr_relat          RECORD
       cod_empresa       char(02),
       id_arquivo        integer,
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
       num_ap            INTEGER,
       cod_tip_despesa   INTEGER 
END RECORD

      
#-----------------#
FUNCTION pol1394()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1394-12.00.03  "
   CALL func002_versao_prg(p_versao)

   CALL pol1394_menu()
    
END FUNCTION
       
#----------------------#
FUNCTION pol1394_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_proces      VARCHAR(10),
           l_carga       VARCHAR(10),
           l_find        VARCHAR(10),
           l_fechar      VARCHAR(10),
           l_titulo      VARCHAR(100),
           l_erro        VARCHAR(100),
           l_first       VARCHAR(10),
           l_previous    VARCHAR(10),
           l_next        VARCHAR(10),
           l_last        VARCHAR(10),
           l_print       VARCHAR(10)

    LET l_titulo = "CONSULTA INTEGRA��O CONCUR X LOGIX - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1394_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1394_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1394_find_canc")
    
    {
    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1394_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1394_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1394_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1394_last")
    }
    
    LET l_print = _ADVPL_create_component(NULL,"LPRINTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_print,"EVENT","pol1394_tela_print")

    LET l_fechar = _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)
    #CALL _ADVPL_set_property(l_fechar,"EVENT","pol1394_fechar")

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1394_cria_campos(l_panel)
   CALL pol1394_ativa_campo(FALSE)
   CALL pol1394_cria_grade(l_panel)

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1394_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10)

    LET m_pnl_info = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_info,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_info,"HEIGHT",65)
    #CALL _ADVPL_set_property(m_pnl_info,"ENABLE",FALSE)
    CALL _ADVPL_set_property(m_pnl_info,"BACKGROUND_COLOR",231,237,237)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Arquivo:")    

    LET m_arquivo = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",70,10)     
    CALL _ADVPL_set_property(m_arquivo,"LENGTH",50) 
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"nom_arquivo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",530,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Dat carga de:")    

    LET m_de = _ADVPL_create_component(NULL,"LDATEFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_de,"POSITION",610,10)     
    CALL _ADVPL_set_property(m_de,"VARIABLE",mr_cabec,"dat_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",730,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","At�:")    

    LET m_ate = _ADVPL_create_component(NULL,"LDATEFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_ate,"POSITION",765,10)     
    CALL _ADVPL_set_property(m_ate,"VARIABLE",mr_cabec,"dat_ate")        

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",10,35) 
    CALL _ADVPL_set_property(l_label,"TEXT","Funcion�rio:")    

    LET m_func = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_func,"POSITION",90,35)     
    CALL _ADVPL_set_property(m_func,"LENGTH",15) 
    CALL _ADVPL_set_property(m_func,"VARIABLE",mr_cabec,"funcio_id")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",240,35) 
    CALL _ADVPL_set_property(l_label,"TEXT","Relat�rio:")    

    LET m_relat = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_relat,"POSITION",290,35)     
    CALL _ADVPL_set_property(m_relat,"LENGTH",15) 
    CALL _ADVPL_set_property(m_relat,"VARIABLE",mr_cabec,"relat_key")
        
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",490,35) 
    CALL _ADVPL_set_property(l_label,"TEXT","Num AD:")    

    LET m_ad = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_ad,"POSITION",540,35)     
    CALL _ADVPL_set_property(m_ad,"LENGTH",6) 
    CALL _ADVPL_set_property(m_ad,"VARIABLE",mr_cabec,"num_ad")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",615,35) 
    CALL _ADVPL_set_property(l_label,"TEXT","Num AP:")    

    LET m_ap = _ADVPL_create_component(NULL,"LNUMERICFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_ap,"POSITION",665,35)     
    CALL _ADVPL_set_property(m_ap,"LENGTH",6) 
    CALL _ADVPL_set_property(m_ap,"VARIABLE",mr_cabec,"num_ap")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(l_label,"POSITION",735,35) 
    CALL _ADVPL_set_property(l_label,"TEXT","Usu�rio:")    

    LET m_user = _ADVPL_create_component(NULL,"LTEXTFIELD",m_pnl_info)     
    CALL _ADVPL_set_property(m_user,"POSITION",790,35)     
    CALL _ADVPL_set_property(m_user,"LENGTH",8) 
    CALL _ADVPL_set_property(m_user,"VARIABLE",mr_cabec,"usuario")

    LET m_label = _ADVPL_create_component(NULL,"LLABEL",m_pnl_info)
    CALL _ADVPL_set_property(m_label,"POSITION",1200,10) 
    CALL _ADVPL_set_property(m_label,"FOREGROUND_COLOR",237,28,36)
    CALL _ADVPL_set_property(m_label,"TEXT","")    
    CALL _ADVPL_set_property(m_label,"FONT",NULL,NULL,TRUE,FALSE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1394_cria_grade(l_container)#
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
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Pessoal")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pessoal")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Funcion�rio")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcionario")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Identif")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","funcio_id")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Relatorio")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","relat_key")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Empresa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","empresa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Despesa")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","despesa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Moeda")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","moeda")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tp Desp")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",140)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_desp")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Cent cust")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Status")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","situacao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt emis")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_emissao")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt pgto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_pagto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tip pgto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","tip_pgto")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AD")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ad")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ap")

    {LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Arquivo")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","nom_arquivo")}

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

END FUNCTION

#-------------------------------------#
FUNCTION pol1394_ativa_campo(l_status)#
#-------------------------------------#
   
   DEFINE l_status       SMALLINT
    
    CALL _ADVPL_set_property(m_arquivo,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_func,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_relat,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_de,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_ate,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_ad,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_ap,"ENABLE",l_status) 
    CALL _ADVPL_set_property(m_user,"ENABLE",l_status) 

END FUNCTION

#------------------------------#
FUNCTION pol1394_limpa_campos()#
#------------------------------#
   
   LET m_carregando = TRUE
   INITIALIZE mr_cabec.*, ma_itens TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")
   LET m_ies_print = FALSE
   
END FUNCTION
  
#----------------------#
FUNCTION pol1394_find()#
#----------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1394_limpa_campos()
   LET m_ies_info = FALSE
   
   CALL pol1394_ativa_campo(TRUE)
   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1394_find_canc()#
#---------------------------#

   CALL pol1394_limpa_campos()
   CALL pol1394_ativa_campo(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1394_find_conf()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   CALL pol1394_monta_select()
   LET m_msg = NULL
   
   IF NOT pol1394_exec_select() THEN
      IF m_msg IS NOT NULL THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF

   LET m_ies_info = TRUE

   LET p_status = LOG_progresspopup_start(
       "Integra��o com PGI...","pol1394_exibe_dados","PROCESS")  


   CALL pol1394_ativa_campo(FALSE)
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1394_monta_select()#
#------------------------------#
   
   IF mr_cabec.nom_arquivo IS NULL THEN
      LET mr_cabec.nom_arquivo = ''
   END IF
   
   LET m_query =
    " select DISTINCT i.* from itens_concur i, arquivo_concur a  ",           
    " where a.cod_empresa = i.cod_empresa ",
    " and a.cod_empresa = '",p_cod_empresa,"' ",
    " and i.id_arquivo = a.id_arquivo ",
    " and a.nom_arquivo LIKE '","%",mr_cabec.nom_arquivo CLIPPED,"%","' "
                            
    IF mr_cabec.funcio_id IS NOT NULL THEN
       LET m_query = m_query, " AND i.funcio_id = ",mr_cabec.funcio_id
    END IF

    IF mr_cabec.relat_key IS NOT NULL THEN
       LET m_query = m_query, " AND i.relat_key = ",mr_cabec.relat_key
    END IF

    IF mr_cabec.dat_de IS NOT NULL THEN
       LET m_query = m_query, " AND a.dat_carga >= '",mr_cabec.dat_de,"' "
    END IF

    IF mr_cabec.dat_ate IS NOT NULL THEN
       LET m_query = m_query, " AND a.dat_carga <= '",mr_cabec.dat_ate,"' "
    END IF

    IF mr_cabec.num_ad IS NOT NULL THEN
       LET m_query = m_query, " AND i.num_ad = ",mr_cabec.num_ad 
    END IF

    IF mr_cabec.num_ap IS NOT NULL THEN
       LET m_query = m_query, " AND i.num_ap = ",mr_cabec.num_ap 
    END IF

    IF mr_cabec.usuario IS NOT NULL THEN
       LET m_query = m_query, " AND a.usuario = '",mr_cabec.usuario,"' "
    END IF

    LET m_query = m_query, " order by funcio_id, num_ad   "                            
    
    
END FUNCTION
       
#-----------------------------#
FUNCTION pol1394_exec_select()#
#-----------------------------#

   PREPARE var_pesquisa FROM m_query
    
   IF  Status <> 0 THEN
       CALL log003_err_sql("PREPARE SQL","prepare:var_pesquisa")
       RETURN FALSE
   END IF   

   DECLARE cq_cons CURSOR FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE CURSOR","cq_cons")
       RETURN FALSE
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN FALSE
   END IF

   FETCH cq_cons INTO ma_itens[1].*

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'N�o a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1394_exibe_dados()#
#-----------------------------#

   DEFINE l_progres   SMALLINT

   CALL LOG_progresspopup_set_total("PROCESS",1000)

   CALL _ADVPL_set_property(m_browse,"CLEAR")
   INITIALIZE ma_itens TO NULL
   
   LET m_ind = 1
      
   FOREACH cq_cons INTO ma_itens[m_ind].*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','itens_concur:cq_exib')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET m_qtd_item = m_ind - 1 
   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_item)
   LET m_msg = 'Qtd reg: ', m_qtd_item USING '<<<<<<'
   CALL _ADVPL_set_property(m_label,"TEXT",m_msg)
   
   RETURN TRUE

END FUNCTION

      
#--------------------------#
FUNCTION pol1394_ies_cons()#
#--------------------------#

   IF NOT m_ies_info THEN
      LET m_msg = 'N�o h� consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1394_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1394_ies_cons() THEN
      RETURN FALSE
   END IF
   
   LET l_achou = FALSE
   LET m_id_arquivoa = m_id_arquivo

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_id_arquivo
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_id_arquivo
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_id_arquivo
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_id_arquivo
      END CASE
       
      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","N�o existem mais dados nesta dire��o.")
         END IF
         LET m_id_arquivo = m_id_arquivoa
      ELSE
         CALL pol1394_exibe_dados()
         LET l_achou = TRUE
     END IF               
 
     EXIT WHILE
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1394_first()#
#-----------------------#

   IF NOT pol1394_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1394_next()#
#----------------------#

   IF NOT pol1394_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1394_previous()#
#--------------------------#

   IF NOT pol1394_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1394_last()#
#----------------------#

   IF NOT pol1394_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------------#
FUNCTION pol1394_tela_print()#
#----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_ies_info THEN
      LET m_msg = 'Efetue a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_msg = NULL
   
   LET p_status = LOG_progresspopup_start(
       "Imprimindo...","pol1394_imprime","PROCESS")  

   IF NOT p_status THEN
      LET m_msg = "Impress�o cancelada."
   ELSE
   
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1394_imprime()#
#-------------------------#
   
   DEFINE l_status   SMALLINT
   
   LET l_status = StartReport(
       "pol1394_relatorio","pol1394","REGISTROS DE DESPESAS ENVIADOS PELO CONCUR",114,TRUE,TRUE)

   
   RETURN l_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1394_relatorio(l_report)#
#-----------------------------------#
   
   DEFINE l_report    CHAR(300),
          l_progres   SMALLINT,
          l_status    SMALLINT
   
   LET l_status = TRUE   
   LET m_page_length = ReportPageLength("pol1394")
       
   START REPORT pol1394_relat TO l_report

   CALL pol1394_le_den_empresa() RETURNING l_status
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_item)

   FOREACH cq_cons INTO mr_relat.*
   
      LET l_progres = LOG_progresspopup_increment("PROCESS") 

      OUTPUT TO REPORT pol1394_relat(mr_relat.num_ad)
   
   END FOREACH

   FINISH REPORT pol1394_relat

   CALL FinishReport("pol1394")
   
   RETURN l_status
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1394_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#--------------------------------#
REPORT pol1394_relat(l_num_ad)#
#--------------------------------#

   DEFINE l_num_ad     VARCHAR(15),
          l_val_ad     DECIMAL(12,2)

    OUTPUT
        TOP    MARGIN 0
        LEFT   MARGIN 0
        RIGHT  MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH m_page_length
   
       ORDER EXTERNAL BY l_num_ad

    FORMAT

    FIRST PAGE HEADER

      CALL ReportPageHeader("pol1394")

      PRINT COLUMN 001, 'PESSOAL FUNCIONARIO          FUNCIO ID RELAT KEY EMPRESA DESPESA  MOEDA TIP_DESP DEN DESP        CENT CUST SITUACAO DAT EMISS  DAT PAGTO  TIP_PGTO NUM AD NUM AP'
      PRINT COLUMN 001, '------- -------------------- --------- --------- ------- -------- ----- -------- --------------- --------- -------- ---------- ---------- -------- ------ ------'

    PAGE HEADER
           
      PRINT COLUMN 001, 'PESSOAL FUNCIONARIO          FUNCIO ID RELAT KEY EMPRESA DESPESA  MOEDA TIP_DESP DEN DESP        CENT CUST SITUACAO DAT EMISS  DAT PAGTO  TIP_PGTO NUM AD NUM AP'
      PRINT COLUMN 001, '------- -------------------- --------- --------- ------- -------- ----- -------- --------------- --------- -------- ---------- ---------- -------- ------ ------'

    ON EVERY ROW 
        LET m_despesa = mr_relat.despesa[1,7]
        
        PRINT COLUMN 001, mr_relat.pessoal,    
              COLUMN 009, mr_relat.funcionario[1,20],
              COLUMN 030, mr_relat.funcio_id[1,9],
              COLUMN 040, mr_relat.relat_key[1,9],  
              COLUMN 050, mr_relat.empresa[1,7],    
              COLUMN 058, m_despesa USING '####&.&&',        
              COLUMN 067, mr_relat.moeda[1,5],                    
              COLUMN 073, mr_relat.tip_desp[1,8],                 
              COLUMN 082, mr_relat.den_desp[1,15],                 
              COLUMN 098, mr_relat.cent_cust[1,9],      
              COLUMN 108, mr_relat.situacao[1,8],           
              COLUMN 117, mr_relat.dat_emissao[1,10],
              COLUMN 128, mr_relat.dat_pagto[1,10],  
              COLUMN 139, mr_relat.tip_pgto[1,8],   
              COLUMN 148, mr_relat.num_ad USING '#####&',  
              COLUMN 155, mr_relat.num_ap USING '#####&'      

   AFTER GROUP OF l_num_ad
      
      IF l_num_ad IS NULL THEN
         LET l_val_ad = NULL
      ELSE
         SELECT val_tot_nf 
           INTO l_val_ad
           FROM ad_mestre 
          WHERE cod_empresa = p_cod_empresa 
            AND num_ad = l_num_ad
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ad_mestre')
            LET l_val_ad = NULL
         END IF
      END IF
      
      SKIP 1 LINE
      PRINT COLUMN 030, 'VALOR TOTAL DO TITULO:',
            COLUMN 054, l_val_ad USING '#,###,##&.&&'
      SKIP 1 LINE

END REPORT


#LOG1700             
#-------------------------------#
 FUNCTION pol1394_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1394.4gl $|$Revision: 3 $|$Date: 17/09/2020 13:23 $|$Modtime: 26/06/2020 07:40 $" 

 END FUNCTION
       