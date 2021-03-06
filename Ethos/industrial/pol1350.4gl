#-------------------------------------------------------------------#
# SISTEMA.: LOGIX      ETHOS INDUSTRIAL                             #
# PROGRAMA: pol1350                                                 #
# OBJETIVO: AN�LISE DE CUSTOS DO COMPONENTE DO ITEM                 #
# AUTOR...: IVO                                                     #
# DATA....: 15/09/2018                                              #
#-------------------------------------------------------------------#
# Altera��es                                                        #
# 16/03/2020 - Impotar itens de um csv (tela sele��o de produtos)   #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003),
           g_msg           CHAR(150),
           p_nom_arquivo   CHAR(100),
           p_caminho       CHAR(080)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_panel           VARCHAR(10),
       m_browse          VARCHAR(10),
       m_arquivo         VARCHAR(10)

DEFINE mr_cabec          RECORD
       cod_item          CHAR(15),
       den_item          CHAR(15),
       data_de           DATE,
       data_ate          DATE,
       nom_arquivo       CHAR(50)
END RECORD       

DEFINE m_item            VARCHAR(10),
       m_zoom_it         VARCHAR(10),
       m_dat_de          VARCHAR(10),
       m_dat_ate         VARCHAR(10)
       

DEFINE ma_compon        ARRAY[10000] OF RECORD
       cod_item         LIKE item.cod_item,
       den_item         LIKE item.den_item,
       cod_compon       LIKE item.cod_item,
       den_compon       LIKE item.den_item,
       qtd_neces        LIKE estrut_grade.qtd_necessaria,
       preco_min        LIKE aviso_rec.pre_unit_nf,
       dat_min          LIKE aviso_rec.dat_inclusao_seq,  
       fornec_min       LIKE fornecedor.raz_social,  
       preco_max        LIKE aviso_rec.pre_unit_nf,
       dat_max          LIKE aviso_rec.dat_inclusao_seq,
       fornec_max       LIKE fornecedor.raz_social,  
       preco_ult        LIKE aviso_rec.pre_unit_nf,
       dat_ult          LIKE aviso_rec.dat_inclusao_seq,
       fornec_ult       LIKE fornecedor.raz_social,  
       mensagem         CHAR(40)
END RECORD

DEFINE m_msg           CHAR(150),
       m_carregando    SMALLINT,
       m_ies_info      SMALLINT,
       m_count         INTEGER,
       m_registro      CHAR(100),
       m_pos_ini       INTEGER,
       m_pos_fim       INTEGER,
       m_num_lista     INTEGER,
       m_cod_cliente   CHAR(15),
       m_cod_item      CHAR(15),
       g_cod_item      CHAR(15),
       m_qtd_neces     DECIMAL(17,7),
       m_cod_comp      CHAR(15),
       m_den_compon    CHAR(50),
       m_neces_compon  DECIMAL(17,7),
       m_val_item      DECIMAL(12,5),
       m_nom_arquivo   CHAR(30),
       m_index         INTEGER,
       m_dat_atu       DATE,
       m_qtd_erro      INTEGER,
       m_num_transac   INTEGER,
       m_qtd_item      INTEGER,
       m_fat_conver    DECIMAL(7,3)
       
DEFINE m_den_item      LIKE item.den_item,
       g_den_item      LIKE item.den_item,
       m_preco_minimo  LIKE vdp_pre_it_audit.preco_minimo

DEFINE m_form_item         VARCHAR(10),
       m_bar_status_item   VARCHAR(10),
       m_brz_item          VARCHAR(10),
       m_familia           VARCHAR(10)

DEFINE mr_Item         RECORD
       cod_familia     LIKE familia.cod_familia,
       tip_item        LIKE item.ies_tip_item,
       den_item        LIKE item.den_item       
END RECORD

DEFINE ma_produto      ARRAY[10000] OF RECORD
       cod_item        CHAR(15),
       den_item        CHAR(50)
END RECORD

DEFINE m_posi_arq      INTEGER,
       m_qtd_arq       INTEGER,
       m_arq_arigem    VARCHAR(150),
       m_arq_dest      VARCHAR(150),
       m_ies_ambiente  CHAR(01),
       m_caminho       VARCHAR(120)
       
DEFINE ma_files ARRAY[150] OF CHAR(80)
       
       
#-----------------#
FUNCTION pol1350()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET p_versao = "pol1350-12.00.18  "
   CALL func002_versao_prg(p_versao)
   CALL pol1350_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1350_menu()#
#----------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_inform      VARCHAR(10),
           l_proces      VARCHAR(10), 
           l_auditoria   VARCHAR(10), 
           l_titulo      CHAR(80)
    
    LET l_titulo = "AN�LISE DE CUSTOS DO COMPONENTE DO ITEM - ",p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    
    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_inform = _ADVPL_create_component(NULL,"LINFORMBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_inform,"EVENT","pol1350_informar")
    CALL _ADVPL_set_property(l_inform,"TYPE","NO_CONFIRM")    

   CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

   LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
   CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

   CALL pol1350_cria_grade(l_panel)
   CALL pol1350_limpa_campos()   

   CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#---------------------------------------#
FUNCTION pol1350_cria_grade(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
  
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(m_browse,"AFTER_ROW_EVENT","alb001_limpa_status")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Componente")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_compon")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_compon")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Qtd.Nec")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")  
    CALL _ADVPL_set_property(l_tabcolumn,"PICTURE","@E ###,###.###")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","qtd_neces")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Menor pre�o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_min")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")  
    CALL _ADVPL_set_property(l_tabcolumn,"PICTURE","@E ####.##")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat compra")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_min")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fornec_min")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Maior pre�o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_max")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")  
    CALL _ADVPL_set_property(l_tabcolumn,"PICTURE","@E ####.##")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat compra")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_max")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fornec_max")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ult pre�o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","preco_ult")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LNUMERICFIELD")  
    CALL _ADVPL_set_property(l_tabcolumn,"PICTURE","@E ####.##")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dt ult pre")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",90)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_ult")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fornec_ult")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Observa��o")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","mensagem")

    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_compon,1)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)


END FUNCTION

#----------------------------#
FUNCTION pol1350_zoom_item()#
#----------------------------#

    DEFINE l_cod_item       LIKE item.cod_item,
           l_den_item       LIKE item.den_item,
           l_cod_ant        LIKE item.cod_item,
           l_lin_atu        INTEGER,
           l_where_clause   CHAR(300)
    
    IF m_zoom_it IS NULL THEN
       LET m_zoom_it = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_it,"ZOOM","zoom_item")
    END IF

    LET l_where_clause = " item.cod_empresa = '",p_cod_empresa CLIPPED,"' "
    CALL LOG_zoom_set_where_clause(l_where_clause CLIPPED)
    
    CALL _ADVPL_get_property(m_zoom_it,"ACTIVATE")
    
    LET l_cod_item = _ADVPL_get_property(m_zoom_it,"RETURN_BY_TABLE_COLUMN","item","cod_item")

    IF l_cod_item IS NOT NULL THEN
       LET l_lin_atu = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")
       LET ma_produto[l_lin_atu].cod_item = l_cod_item
       CALL pol1350_le_item(l_cod_item) RETURNING p_status
       LET ma_produto[l_lin_atu].den_item = m_den_item
    END IF        
    
END FUNCTION

#-----------------------------#
FUNCTION pol1350_checa_linha()#
#-----------------------------#

   DEFINE l_lin_atu        INTEGER,
          l_cod_item       CHAR(15)
          
   CALL _ADVPL_set_property(m_brz_item,"REMOVE_EMPTY_ROWS")
   
   LET m_count = _ADVPL_get_property(m_brz_item,"ITEM_COUNT")
   
   IF m_count < 1 THEN
      CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_produto,1)
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")
      
   LET l_cod_item = ma_produto[l_lin_atu].cod_item
   
   IF l_cod_item IS NULL THEN                 
      RETURN TRUE
   END IF
   
   IF NOT pol1350_valid_item(l_cod_item) THEN
      RETURN FALSE
   END IF
   
   LET ma_produto[l_lin_atu].den_item = m_den_item
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1350_limpa_linha()#
#-------------------------------#

   DEFINE l_lin_atu        INTEGER
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")
   LET m_msg = 'Linha ',l_lin_atu
   
   LET ma_produto[l_lin_atu].cod_item = NULL
   LET ma_produto[l_lin_atu].den_item = NULL
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1350_checa_item()#
#----------------------------#
   
   DEFINE l_lin_atu        INTEGER,
          l_cod_item       CHAR(15)
   
   LET l_lin_atu = _ADVPL_get_property(m_brz_item,"ROW_SELECTED")
      
   LET l_cod_item = ma_produto[l_lin_atu].cod_item
   
   IF l_cod_item IS NULL THEN                 
      RETURN TRUE
   END IF
   
   IF NOT pol1350_valid_item(l_cod_item) THEN
      RETURN FALSE
   END IF
   
   LET ma_produto[l_lin_atu].den_item = m_den_item
      
   RETURN TRUE

END FUNCTION   
   
#--------------------------------------#
FUNCTION pol1350_valid_item(l_cod_item)#
#--------------------------------------#
   
   DEFINE l_cod_item       CHAR(15)
   
   CALL _ADVPL_set_property(m_bar_status_item,"ERROR_TEXT",'')
   
   IF NOT pol1350_le_item(l_cod_item) THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1350_chek_estrut(l_cod_item) THEN
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'Produto sem estrutura.'
      CALL _ADVPL_set_property(m_bar_status_item,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1350_le_item(l_cod_item)#
#-----------------------------------#
   
   DEFINE l_cod_item     CHAR(15)
   
   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod_item
   
   IF STATUS = 100 THEN
      LET m_msg = 'Produto inexistente no Logix.'
      CALL _ADVPL_set_property(m_bar_status_item,"ERROR_TEXT",m_msg)
      LET m_den_item = NULL      
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item')
         LET m_den_item = NULL      
         RETURN FALSE            
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol1350_dialog_item()#
#-----------------------------#

    DEFINE l_menubar     VARCHAR(10),
           l_panel       VARCHAR(10),
           l_importa     VARCHAR(10),
           l_confirma    VARCHAR(10),
           l_cancela     VARCHAR(10),
           l_label       VARCHAR(10)

   LET m_form_item = _ADVPL_create_component(NULL,"LDIALOG")
   CALL _ADVPL_set_property(m_form_item,"SIZE",900,500) 
   CALL _ADVPL_set_property(m_form_item,"TITLE","SELE��O DE PRODUTOS")
   CALL _ADVPL_set_property(m_form_item,"ENABLE_ESC_CLOSE",FALSE)
   CALL _ADVPL_set_property(m_form_item,"INIT_EVENT","pol1350_posiciona")

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_item)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   {LET l_importa = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_importa,"IMAGE","IMPORTAR")     
   CALL _ADVPL_set_property(l_importa,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_importa,"EVENT","pol1350_importar")   }  

   LET l_confirma = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_confirma,"IMAGE","CONFIRM_EX")     
   CALL _ADVPL_set_property(l_confirma,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_confirma,"EVENT","pol1350_confirma")  

   LET l_cancela = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancela,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancela,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancela,"EVENT","pol1350_cancela")     

    LET m_bar_status_item = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_item)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_item)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1350_param_item(l_panel)
    CALL pol1350_grade_item(l_panel)

   CALL pol1350_carrega_lista() 

    CALL _ADVPL_set_property(m_form_item,"ACTIVATE",TRUE)
    
   
END FUNCTION

#---------------------------#
FUNCTION pol1350_posiciona()#
#---------------------------#

   CALL _ADVPL_set_property(m_arquivo,"GET_FOCUS")

END FUNCTION

#---------------------------------------#
FUNCTION pol1350_param_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_desc            VARCHAR(10),
           l_label           VARCHAR(10),
           l_arq             VARCHAR(10),
           l_lupa            VARCHAR(10)           

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",260,10) 
    CALL _ADVPL_set_property(l_label,"TEXT","Importr de arquivo:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_arquivo = _ADVPL_create_component(NULL,"LCOMBOBOX",l_panel)     
    CALL _ADVPL_set_property(m_arquivo,"POSITION",370,10)     
    CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM","0","Select    ")
    CALL _ADVPL_set_property(m_arquivo,"VARIABLE",mr_cabec,"nom_arquivo")
    CALL _ADVPL_set_property(m_arquivo,"VALID","pol1350_valid_arquivo")     

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",260,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","Per�odo de avalia��o:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_dat_de = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_de,"POSITION",370,40)     
    CALL _ADVPL_set_property(m_dat_de,"VARIABLE",mr_cabec,"data_de")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",500,40)     
    CALL _ADVPL_set_property(l_label,"TEXT","At�:")   
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE) 

    LET m_dat_ate = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_dat_ate,"POSITION",530,40)     
    CALL _ADVPL_set_property(m_dat_ate,"VARIABLE",mr_cabec,"data_ate")

END FUNCTION

#---------------------------------------#
FUNCTION pol1350_grade_item(l_container)#
#---------------------------------------#
   
   DEFINE l_container, l_panel, l_layout, l_tabcolumn           VARCHAR(20)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_item,"BEFORE_ADD_ROW_EVENT","pol1350_checa_linha")
    CALL _ADVPL_set_property(m_brz_item,"AFTER_ADD_ROW_EVENT","pol1350_limpa_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1350_checa_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1350_zoom_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descri��o")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")
    CALL _ADVPL_set_property(l_tabcolumn,"ORDER",TRUE)

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_produto,1)
    CALL _ADVPL_set_property(m_brz_item,"CAN_REMOVE_ROW",TRUE)
    CALL _ADVPL_set_property(m_brz_item,"EDITABLE",TRUE)

END FUNCTION   

#-------------------------------#
FUNCTION pol1350_carrega_lista()#
#-------------------------------#     

   DEFINE l_ind     INTEGER,
          t_ind     CHAR(03),
          l_caminho CHAR(150)
               
   LET m_posi_arq = LENGTH(m_caminho) + 1
   LET m_qtd_arq = LOG_file_getListCount(m_caminho,"*.csv",FALSE,FALSE,FALSE)
   LET m_msg = NULL
      
   IF m_qtd_arq = 0 THEN
      LET m_msg = 'Nenhum arquivo foi encontrado no caminho ', m_caminho
   ELSE
      IF m_qtd_arq > 150 THEN
         LET m_msg = 'Qtd arquivos enconrada encontrado no caminho ', m_caminho, ' > qtd prevista'
      END IF
   END IF
   
   IF m_msg IS NOT NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF
      
   INITIALIZE ma_files TO NULL
   
   FOR l_ind = 1 TO m_qtd_arq
       LET t_ind = l_ind
       LET ma_files[l_ind] = LOG_file_getFromList(l_ind)
       CALL _ADVPL_set_property(m_arquivo,"ADD_ITEM",t_ind,ma_files[l_ind])                    
   END FOR
   
   RETURN TRUE
   
END FUNCTION
   
#---------------------------------------#
FUNCTION pol1350_chek_estrut(l_item_pai)#
#---------------------------------------#
   
   DEFINE l_item_pai      CHAR(15)
    
   SELECT COUNT(cod_item_pai)
      INTO m_count
      FROM estrut_grade 
     WHERE cod_empresa = p_cod_empresa
       AND cod_item_pai = l_item_pai
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
        OR  (dat_validade_ini IS NULL AND dat_validade_fim >= m_dat_atu)
        OR  (dat_validade_fim IS NULL AND dat_validade_ini <= m_dat_atu)
        OR  (dat_validade_ini <= m_dat_atu AND dat_validade_fim IS NULL)
        OR  (m_dat_atu BETWEEN dat_validade_ini AND dat_validade_fim))
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estrut_grade')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1350_valid_periodo()#
#-------------------------------#
   
   
   IF mr_cabec.data_de IS NULL THEN
      LET m_msg = 'Informe per�odo inicial'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   IF mr_cabec.data_ate IS NULL THEN
      LET m_msg = 'Informe per�odo final'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_ate,"GET_FOCUS")
      RETURN FALSE
   END IF

   IF mr_cabec.data_ate <  mr_cabec.data_de THEN
      LET m_msg = 'Per�odo inv�lido'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS")
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1350_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_lista TO NULL
   INITIALIZE ma_produto TO NULL
   CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#----------------------------------------#
FUNCTION pol1350_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT

   
END FUNCTION

#----------------------------#
FUNCTION pol1350_le_caminho()#
#----------------------------#

   SELECT nom_caminho, ies_ambiente
     INTO m_caminho, m_ies_ambiente
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = "CSV"

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV n�o cadastrado na LOG1100.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("SELECT","path_logix_v2")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
 FUNCTION pol1350_dirExist()#
#---------------------------#

  DEFINE l_dir  CHAR(250),
         l_msg  CHAR(250)
 
  LET l_dir = m_caminho CLIPPED
 
  IF LOG_dir_exist(l_dir,0) THEN
  ELSE          
     IF LOG_dir_exist(l_dir,1) THEN
     ELSE
        CALL LOG_consoleMessage("FALHA. Motivo: "||log0030_mensagem_get_texto())
        LET l_msg = "Diret�rio : ",l_dir CLIPPED, ' n�o exite \n', log0030_mensagem_get_texto()
        CALL log0030_mensagem(l_msg,'info')
        RETURN FALSE
     END IF
     
  END IF
  
  RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1350_informar()#
#--------------------------#
   
   DEFINE l_cod_item    CHAR(15),
          l_ind         INTEGER

   IF NOT pol1350_le_caminho() THEN
      RETURN FALSE
   END IF

   IF NOT pol1350_dirExist() THEN
      RETURN FALSE
   END IF
   
   DROP TABLE item_sel_547
   
   CREATE TEMP TABLE item_sel_547(
      cod_item CHAR(15)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','item_sel_547')
      RETURN FALSE
   END IF   
      
   LET m_dat_atu = TODAY

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   CALL pol1350_limpa_campos()   
   
   LET mr_cabec.cod_item = ''
   DELETE FROM item_sel_547
   CALL pol1350_dialog_item()
   
   IF m_count > 0 THEN
   
      FOR l_ind = 1 TO m_count 
          
          LET l_cod_item = ma_produto[l_ind].cod_item
          
          SELECT cod_item FROM item_sel_547
           WHERE cod_item = l_cod_item
           
          IF STATUS = 100 THEN
          
             INSERT INTO item_sel_547 VALUES(l_cod_item)
             
             IF STATUS <> 0 THEN
                CALL log003_err_sql("INSERT","item_sel_547")
                RETURN FALSE
             END IF
             
          END IF
      END FOR
   
      LET m_carregando = TRUE

      LET p_status = LOG_progresspopup_start("Carregando...","pol1350_carrega_item","PROCESS") 
   
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1350_cancela()#
#-------------------------#

    LET m_count = 0
    CALL _ADVPL_set_property(m_form_item,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1350_valid_arquivo()#
#-------------------------------#

   LET m_carregando = TRUE
   INITIALIZE ma_produto TO NULL
   CALL _ADVPL_set_property(m_brz_item,"CLEAR")

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF mr_cabec.nom_arquivo = "0" THEN
      CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_produto,1)
      LET m_carregando = FALSE
      RETURN TRUE
   END IF
           
   LET m_count = mr_cabec.nom_arquivo
   LET m_arq_arigem = ma_files[m_count] CLIPPED
   
   LET m_nom_arquivo = m_arq_arigem[m_posi_arq, LENGTH(m_arq_arigem)]

   CALL LOG_consoleMessage("Arquivo: "||m_arq_arigem)
   
   LET p_status = LOG_progresspopup_start(
       "Carregando arquivo...","pol1350_load_arq","PROCESS")  
            
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1350_load_arq()#
#--------------------------#
      
   IF NOT pol1350_cria_temp() THEN
      RETURN 
   END IF
      
   CALL LOG_transaction_begin()
   
   LOAD FROM m_arq_arigem INSERT INTO item_temp
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('LOAD','item_temp:LOAD')
      CALL LOG_transaction_rollback()
      RETURN 
   END IF
   
   CALL LOG_transaction_commit()
   
   SELECT COUNT(*) INTO m_count
     FROM item_temp
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Select','tem_temp:count')
      RETURN 
   END IF
   
   IF m_count = 0 THEN
      LET m_msg = 'O arquivo selecionado est� vazio.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN 
   END IF

   IF NOT pol1350_le_item_temp() THEN
      RETURN
   END IF
   
   CALL pol1350_move_arquivo()
   
   CALL _ADVPL_set_property(m_brz_item,"EDITABLE", FALSE)
   
   CALL _ADVPL_set_property(m_dat_de,"GET_FOCUS") 

END FUNCTION

#------------------------------#
FUNCTION pol1350_le_item_temp()#
#------------------------------#

   DEFINE l_progres         SMALLINT
   
   LET m_index = 1

   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_temp CURSOR FOR
    SELECT DISTINCT cod_item FROM item_temp
   
   FOREACH cq_temp INTO m_cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item_temp:cq_temp')
         RETURN FALSE
      END IF
      
      LET g_den_item = func002_le_den_item(m_cod_item)            
      LET ma_produto[m_index].cod_item = m_cod_item
      LET ma_produto[m_index].den_item = g_den_item
      
      LET l_progres = LOG_progresspopup_increment("PROCESS")
      
      LET m_index = m_index + 1
      
      IF m_index > 10000 THEN
         LET m_msg = 'Limite de linhas da grade ultrapassou.'
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF m_index > 1 THEN
      LET m_qtd_item = m_index - 1      
      CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_item)
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1350_cria_temp()#
#---------------------------#
   
   DROP TABLE item_temp
   
   CREATE  TABLE item_temp (cod_item CHAR(15))
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','item_temp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1350_move_arquivo()#
#------------------------------#
   
   DEFINE l_arq_dest       CHAR(100),
          l_comando        CHAR(120),
          l_tamanho        integer
   
   LET m_arq_arigem = m_arq_arigem CLIPPED
   
   LET l_tamanho = LENGTH(m_arq_arigem)
   
   LET l_arq_dest = m_arq_arigem[1,(l_tamanho-4)],'.pro'

   IF m_ies_ambiente = 'W' THEN
      LET l_comando = 'move ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   ELSE
      LET l_comando = 'mv ', m_arq_arigem CLIPPED, ' ', l_arq_dest
   END IF
 
   RUN l_comando RETURNING p_status
   
   IF p_status = 1 THEN
      LET m_msg = 'N�o foi possivel renomear o arquivo de .txt para .txt-proces'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   END IF

END FUNCTION   

#--------------------------#
FUNCTION pol1350_confirma()#
#--------------------------#
   
   DEFINE l_ind     INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT pol1350_valid_periodo() THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_brz_item,"REMOVE_EMPTY_ROWS")
      
   LET m_count =  _ADVPL_get_property(m_brz_item,"ITEM_COUNT")
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhum item foi informado.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_form_item,"ACTIVATE",FALSE)
   
   RETURN TRUE
    
END FUNCTION

#------------------------------#
FUNCTION pol1350_carrega_item()#
#------------------------------#

   DEFINE l_progres         SMALLINT
   
   INITIALIZE ma_compon TO NULL
   LET m_index = 1

   CALL _ADVPL_set_property(m_browse,"CLEAR")
   CALL LOG_progresspopup_set_total("PROCESS",m_count)
   
   DECLARE cq_it_pai CURSOR FOR
    SELECT DISTINCT cod_item FROM item_sel_547
   
   FOREACH cq_it_pai INTO m_cod_item
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_it_pai')
         RETURN FALSE
      END IF
      
      LET g_den_item = func002_le_den_item(m_cod_item)            
      LET g_cod_item = m_cod_item
      LET m_qtd_neces = 1
      
      IF NOT pol1350_carrega_compon() THEN
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
         
   END FOREACH

   IF m_index = 1 THEN
      CALL log0030_mensagem('Nenhum componente comprado\n foi encontrado','info')
   ELSE
      LET m_index = m_index - 1      
      CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_index)
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol1350_carrega_compon()#
#--------------------------------#

   DEFINE l_progres         SMALLINT,
          l_ies_tipo        CHAR(01),
          l_qtd_neces       LIKE estrut_grade.qtd_necessaria
  
   IF NOT pol1350_explode_estrut() THEN
      RETURN FALSE
   END IF
         
   DECLARE cq_compon CURSOR FOR
   SELECT cod_item, SUM(qtd_neces)
      FROM item_compon_1350 
     GROUP BY cod_item
   
   FOREACH cq_compon INTO m_cod_comp, l_qtd_neces
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cq_compon')
         RETURN FALSE
      END IF

      LET ma_compon[m_index].cod_item = g_cod_item
      LET ma_compon[m_index].den_item = g_den_item
      LET ma_compon[m_index].cod_compon = m_cod_comp
      LET ma_compon[m_index].den_compon = func002_le_den_item(m_cod_comp) 
      LET ma_compon[m_index].qtd_neces = l_qtd_neces
      
      IF NOT pol1350_le_preco() THEN
         RETURN FALSE
      END IF
      
      LET m_index = m_index + 1
      
      IF m_index > 10000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou','info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1350_le_preco()#
#--------------------------#

   DEFINE l_preco    LIKE aviso_rec.pre_unit_nf,
          l_data     LIKE aviso_rec.dat_inclusao_seq,
          l_tem_nf   SMALLINT,
          l_num_ar   INTEGER,
          l_num_oc   INTEGER

   LET l_tem_nf = FALSE

   DECLARE cq_min CURSOR FOR
    SELECT dat_inclusao_seq, pre_unit_nf, num_aviso_rec, num_oc
     FROM aviso_rec 
    WHERE cod_empresa = p_cod_empresa
      AND dat_inclusao_seq BETWEEN mr_cabec.data_de AND mr_cabec.data_ate
      AND cod_item = m_cod_comp
    ORDER BY pre_unit_nf
   
   FOREACH cq_min INTO l_data, l_preco, l_num_ar, l_num_oc
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','aviso_rec:pre�o-minimo')
         RETURN FALSE
      END IF
      LET l_tem_nf = TRUE                  
      
      SELECT pre_unit_oc INTO l_preco
        FROM ordem_sup 
       WHERE cod_empresa = p_cod_empresa 
         AND num_oc = l_num_oc
             
      EXIT FOREACH
      
   END FOREACH
      
   IF l_tem_nf THEN
      LET ma_compon[m_index].fornec_min = pol1350_le_fornec(l_num_ar)
      LET ma_compon[m_index].preco_min = l_preco 
      LET ma_compon[m_index].dat_min = l_data
   ELSE
      LET ma_compon[m_index].mensagem = 'Item S/ NFE'
      RETURN TRUE
   END IF   

   LET l_tem_nf = FALSE
   
   DECLARE cq_max CURSOR FOR
    SELECT dat_inclusao_seq, pre_unit_nf, num_aviso_rec, num_oc
     FROM aviso_rec WHERE cod_empresa = p_cod_empresa
      AND dat_inclusao_seq BETWEEN mr_cabec.data_de AND mr_cabec.data_ate
      AND cod_item = m_cod_comp 
    ORDER BY 2 DESC
   
   FOREACH cq_max INTO l_data, l_preco, l_num_ar, l_num_oc
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','aviso_rec:pre�o-minimo')
         RETURN FALSE
      END IF
      LET l_tem_nf = TRUE

      SELECT pre_unit_oc INTO l_preco
        FROM ordem_sup 
       WHERE cod_empresa = p_cod_empresa 
         AND num_oc = l_num_oc
      
      EXIT FOREACH
      
   END FOREACH   
   
   IF l_tem_nf THEN
      LET ma_compon[m_index].fornec_max = pol1350_le_fornec(l_num_ar)
      LET ma_compon[m_index].preco_max = l_preco
      LET ma_compon[m_index].dat_max = l_data
   END IF   

   DECLARE cq_ult CURSOR FOR
    SELECT dat_inclusao_seq, pre_unit_nf, num_aviso_rec, num_oc 
     FROM aviso_rec WHERE cod_empresa = p_cod_empresa
      AND dat_inclusao_seq BETWEEN mr_cabec.data_de AND mr_cabec.data_ate
      AND cod_item = m_cod_comp 
    ORDER BY 1 DESC
   
   FOREACH cq_ult INTO l_data, l_preco, l_num_ar, l_num_oc
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','aviso_rec:pre�o-minimo')
         RETURN FALSE
      END IF
      LET l_tem_nf = TRUE

      SELECT pre_unit_oc INTO l_preco
        FROM ordem_sup 
       WHERE cod_empresa = p_cod_empresa 
         AND num_oc = l_num_oc
      
      EXIT FOREACH
      
   END FOREACH   
   
   IF l_tem_nf THEN
      LET ma_compon[m_index].fornec_ult = pol1350_le_fornec(l_num_ar)
      LET ma_compon[m_index].preco_ult = l_preco 
      LET ma_compon[m_index].dat_ult = l_data
   END IF   
   
   RETURN TRUE

END FUNCTION
 
#-----------------------------------#
FUNCTION pol1350_le_fornec(l_num_ar)#
#-----------------------------------#
   
   DEFINE l_raz_social     LIKE fornecedor.raz_social,
          l_cod_fornecedor LIKE fornecedor.cod_fornecedor,
          l_num_ar         INTEGER,
          l_erro           CHAR(10)
   
   LET m_fat_conver = 1
   
   SELECT f.raz_social, f.cod_fornecedor
     INTO l_raz_social,
          l_cod_fornecedor
     FROM fornecedor f, nf_sup n
    WHERE f.cod_fornecedor = n.cod_fornecedor
      AND n.cod_empresa = p_cod_empresa
      AND n.num_aviso_rec = l_num_ar

   IF STATUS <> 0 THEN
      LET l_erro = STATUS
      LET l_raz_social = 'ERRO ',l_erro CLIPPED, ' LENDO FORNECEDOR'
   ELSE
      IF STATUS = 0 THEN
         CALL pol1350_le_fat_conver(l_cod_fornecedor) RETURNING p_status
      END IF
   END IF
      
   RETURN l_raz_social

END FUNCTION

#------------------------------------#
FUNCTION pol1350_le_fat_conver(l_cod)#
#------------------------------------#
   
   DEFINE l_cod     CHAR(15)
   
   SELECT DISTINCT fat_conver_unid      
     INTO m_fat_conver
     FROM item_fornec
    WHERE cod_empresa = p_cod_empresa
      AND cod_fornecedor = l_cod
      AND cod_item = m_cod_comp

   IF STATUS = 100 THEN
      LET m_fat_conver = 1
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item_fornec')
         LET m_fat_conver = 1
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
       

#--------------------------------#
FUNCTION pol1350_explode_estrut()#
#--------------------------------#
   
   DEFINE l_count     INTEGER,
          l_progres   SMALLINT,
          l_ies_tipo  CHAR(01),
          l_qtd_neces DECIMAL(17,7)

   IF NOT pol1350_cria_tab_tmp() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1350_ins_it(m_cod_item) THEN
      RETURN FALSE
   END IF
   
   LET l_count = 1
      
   WHILE l_count > 0

      LET l_progres = LOG_progresspopup_increment("PROCESS")

      DECLARE cq_temp_it CURSOR FOR
       SELECT cod_item, qtd_neces 
         FROM item_estrut_1350
      
      FOREACH cq_temp_it INTO m_cod_item, l_qtd_neces
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','item_estrut_1350:cq_temp_it')  
            RETURN FALSE
         END IF

         IF NOT pol1350_del_item(m_cod_item) THEN
            RETURN FALSE
         END IF         
         
         DECLARE cq_estrut CURSOR FOR
          SELECT cod_item_compon, qtd_necessaria
            FROM estrut_grade 
           WHERE cod_empresa = p_cod_empresa
             AND cod_item_pai = m_cod_item
             AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
              OR  (dat_validade_ini IS NULL AND dat_validade_fim >= m_dat_atu)
              OR  (dat_validade_fim IS NULL AND dat_validade_ini <= m_dat_atu)
              OR  (dat_validade_ini <= m_dat_atu AND dat_validade_fim IS NULL)
              OR  (m_dat_atu BETWEEN dat_validade_ini AND dat_validade_fim))
   
         FOREACH cq_estrut INTO m_cod_comp, m_qtd_neces

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','estrut_grade:cq_estrut')  
               RETURN FALSE
            END IF
            
            LET m_qtd_neces = m_qtd_neces * l_qtd_neces

            SELECT den_item, ies_tip_item
              INTO m_den_compon, l_ies_tipo
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item = m_cod_comp

            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','item')
               RETURN FALSE
            END IF
      
            IF l_ies_tipo MATCHES '[BC]' THEN
               IF NOT pol1350_ins_compon() THEN
                  RETURN FALSE
               END IF
               IF l_ies_tipo = 'B' THEN
                  IF NOT pol1350_ins_it(m_cod_comp) THEN
                     RETURN FALSE
                  END IF
               END IF
            ELSE
               IF NOT pol1350_ins_it(m_cod_comp) THEN
                  RETURN FALSE
               END IF
            END IF            
         
         END FOREACH
                  
      END FOREACH
      
      SELECT COUNT(*) INTO l_count
        FROM item_estrut_1350
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','item_estrut_1350:count')
         RETURN FALSE
      END IF
      
      IF l_count IS NULL THEN
         LET l_count = 0
      END IF
      
   END WHILE
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1350_del_item(l_cod)#
#-------------------------------#
   
   DEFINE l_cod       CHAR(15)
   
   DELETE FROM item_estrut_1350 WHERE cod_item = l_cod
                  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','item_estrut_1350:item')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1350_ins_it(l_cod)#
#-----------------------------#
   
   DEFINE l_cod    CHAR(15)
   
   INSERT INTO item_estrut_1350 
    VALUES(l_cod, m_qtd_neces)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','item_estrut_1350')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1350_ins_compon()#
#----------------------------#

   INSERT INTO item_compon_1350 
    VALUES(m_cod_comp, m_den_compon, m_qtd_neces)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','item_estrut_1350')  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1350_cria_tab_tmp()
#------------------------------#
   
   DROP TABLE item_estrut_1350;
   CREATE TEMP TABLE item_estrut_1350 (
      cod_item    CHAR(15),
      qtd_neces   DECIMAL(17,7)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','item_estrut_1350')
      RETURN FALSE
   END IF

   DROP TABLE item_compon_1350;
   CREATE TEMP TABLE item_compon_1350 (
      cod_item    CHAR(15),
      den_item    CHAR(50),
      qtd_neces   DECIMAL(17,7)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','item_compon_1350')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   