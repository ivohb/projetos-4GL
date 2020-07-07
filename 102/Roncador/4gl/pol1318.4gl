#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1318                                                 #
# OBJETIVO: GERAÇÃO DE RATEIO DE DESPESAS                           #
# AUTOR...: IVO                                                     #
# DATA....: 06/12/16                                                #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_den_empresa   LIKE empresa.den_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_versao        CHAR(18),
           g_tipo_sgbd     CHAR(003)
           
END GLOBALS

DEFINE m_den_empresa     LIKE empresa.den_empresa,
       m_nom_cent_cust   LIKE cad_cc.nom_cent_cust,
       m_cod_empresa     LIKE empresa.cod_empresa

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_browse          VARCHAR(10),
       m_filtro          VARCHAR(10),
       m_brow_rat        VARCHAR(10)

DEFINE m_cod_emp_orig    VARCHAR(10),
       m_den_emp_orig    VARCHAR(10),
       m_previsao        VARCHAR(10),
       m_periodo         VARCHAR(10),
       m_emis_tit        VARCHAR(10),
       m_venc_tit        VARCHAR(10),
       m_cod_portador    VARCHAR(10),
       m_lupa_portador   VARCHAR(10),
       m_zoom_portador   VARCHAR(10),
       m_nom_portador    VARCHAR(10)

DEFINE m_ies_cons        SMALLINT,
       m_count           INTEGER,
       m_msg             VARCHAR(150),
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_opcao           CHAR(01),
       m_excluiu         SMALLINT,
       m_par_aen         CHAR(01),
       m_lin_pord        DECIMAL(2,0),
       m_lin_recei       DECIMAL(2,0),
       m_seg_merc        DECIMAL(2,0),
       m_cla_uso         DECIMAL(2,0),
       m_den_aen         CHAR(30),
       m_num_previsao    INTEGER,
       m_num_previsaoa   INTEGER,
       m_qtd_linha       INTEGER,
       m_index           INTEGER,
       m_carregando      SMALLINT,
       m_qtd_rateio      INTEGER,
       m_num_ad          INTEGER,
       m_empresa_dest    CHAR(02), 
       m_val_docum       DECIMAL(12,2),
       m_id_rateio       INTEGER,
       m_num_docum       CHAR(14),
       m_progres         SMALLINT,
       m_docum_orig      INTEGER,
       m_clik_exc        SMALLINT,
       m_clik_rat        SMALLINT,
       m_des_portador    CHAR(36)

DEFINE mr_cabec          RECORD
       num_previsao      CHAR(04),
       cod_emp_orig      CHAR(02),
       den_emp_orig      CHAR(36),
       periodo           CHAR(23),
       dat_emis_tit      DATE,
       dat_venc_tit      DATE,       
       cod_portador      DECIMAL(4,0),
       nom_portador      CHAR(36)
END RECORD

DEFINE mr_ad             RECORD
       emissao           DATE,
       valor             DECIMAL(12,2),
       cod_fornecedor    CHAR(15),
       cod_tip_despesa   DECIMAL(4,0),
       num_ad            INTEGER,
       num_nf            INTEGER,
       ser_nf            CHAR(3),
       ssr_nf            DECIMAL(2,0),
       dat_emis_nf       DATE,
       dat_rec_nf        DATE,
       cod_cent_cust     DECIMAL(5,0),
       dat_venc          DATE,
       cod_moeda         INTEGER,
       cod_tip_ad        INTEGER,
       ies_sup_cap       CHAR(03),
       cnd_pgto          INTEGER,
       cod_empresa       CHAR(02),
       cod_aen           CHAR(08),
       nom_programa      CHAR(08),
       tex_hist          CHAR(50)
END RECORD       

DEFINE ma_itens          ARRAY[300] OF RECORD
       excluir           CHAR(01),
       ratear            CHAR(01),
       docum             INTEGER,
       origem            CHAR(03),
       dat_rec           DATE,
       valor             DECIMAL(12,2),
       despesa           CHAR(30),
       fornecedor        CHAR(40),
       rateado           CHAR(01),
       cod_fornecedor    CHAR(15),
       cod_tip_despesa   DECIMAL(4,0),
       num_ad            INTEGER,
       num_nf            INTEGER,
       cod_cent_cust     DECIMAL(5,0),
       dat_venc          DATE,
       cod_moeda         INTEGER,
       cod_tip_ad        INTEGER,
       ies_sup_cap       CHAR(03),
       cnd_pgto          INTEGER
END RECORD

DEFINE ma_rateio         ARRAY[300] OF RECORD
       cod_emp_dest      CHAR(02),
       den_emp_dest      VARCHAR(40),
       cod_cent_cust     DECIMAL(4,0),
       pct_rateio        DECIMAL(5,2),
       val_rateio        DECIMAL(12,2),
       num_ad            INTEGER
END RECORD

DEFINE mr_docum          RECORD
       cod_empresa       CHAR(02),
       num_docum         CHAR(14),
       dat_emissao       DATE,
       dat_vencto        DATE,
       val_docum         DECIMAL(12,2),
       cod_cliente       CHAR(15),
       cod_cnd_pgto      DECIMAL(2,0),
       num_pedido        CHAR(16),
       num_nf            CHAR(14),
       ser_nf            CHAR(02),
       tip_nf            CHAR(02),
       empresa_dest      CHAR(02),
       cod_portador      DECIMAL(4,0)    
END RECORD

#-----------------#
FUNCTION pol1318()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 11
   DEFER INTERRUPT
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_versao = "pol1318-12.00.13  "
   CALL func002_versao_prg(p_versao)
   
   LET m_cod_empresa = p_cod_empresa
   CALL pol1318_menu()
    
END FUNCTION

#----------------------#
FUNCTION pol1318_menu()#
#----------------------#

    DEFINE l_menubar,
           l_panel,
           l_create,
           l_update,
           l_find,
           l_first,
           l_previous,
           l_next,
           l_last,
           l_delete,
           l_gerar, l_estorno  VARCHAR(10)
    
    LET m_carregando = TRUE
    CALL pol1318_limpa_campos()

    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE","GERAÇÃO DE RATEIO DE DESPESAS")
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)
        
    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","NO_CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1318_find")

    LET l_first = _ADVPL_create_component(NULL,"LFIRSTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_first,"EVENT","pol1318_first")

    LET l_previous = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_previous,"EVENT","pol1318_previous")

    LET l_next = _ADVPL_create_component(NULL,"LNEXTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_next,"EVENT","pol1318_next")

    LET l_last = _ADVPL_create_component(NULL,"LLASTBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_last,"EVENT","pol1318_last")

    LET l_delete = _ADVPL_create_component(NULL,"LDELETEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_delete,"EVENT","pol1318_delete")

   LET l_gerar = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_gerar,"IMAGE","GERAR_EX")
   CALL _ADVPL_set_property(l_gerar,"TYPE","CONFIRM")     
   CALL _ADVPL_set_property(l_gerar,"EVENT","pol1318_gerar")
   CALL _ADVPL_set_property(l_gerar,"CONFIRM_EVENT","pol1318_gerar_confirma")
   CALL _ADVPL_set_property(l_gerar,"CANCEL_EVENT","pol1318_gerar_cancela")

   LET l_estorno = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_estorno,"IMAGE","ESTORNO_EX")     
   CALL _ADVPL_set_property(l_estorno,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_estorno,"EVENT","pol1318_estornar")        

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1318_cria_campos(l_panel)
    CALL pol1318_cria_grade_orig(l_panel)
    CALL pol1318_cria_grade_dest(l_panel)
    
    CALL pol1318_ativa_desativa(FALSE)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#-----------------------------#
FUNCTION pol1318_limpa_campos()
#-----------------------------#

   INITIALIZE mr_cabec.* TO NULL
   INITIALIZE ma_itens TO NULL
    
END FUNCTION

#----------------------------------------#
FUNCTION pol1318_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT   
   
   CALL _ADVPL_set_property(m_venc_tit,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_emis_tit,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_browse,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",l_status)
   CALL _ADVPL_set_property(m_cod_portador,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_portador,"EDITABLE",l_status)      
   
END FUNCTION

#----------------------------------------#
FUNCTION pol1318_cria_campos(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","TOP")
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Número previsão:")    

    LET m_previsao = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_previsao,"POSITION",140,10)
    CALL _ADVPL_set_property(m_previsao,"LENGTH",4)
    CALL _ADVPL_set_property(m_previsao,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_previsao,"VARIABLE",mr_cabec,"num_previsao")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",230,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa origem:")    

    LET m_cod_emp_orig = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_cod_emp_orig,"POSITION",320,10)
    CALL _ADVPL_set_property(m_cod_emp_orig,"LENGTH",2)
    CALL _ADVPL_set_property(m_cod_emp_orig,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_cod_emp_orig,"VARIABLE",mr_cabec,"cod_emp_orig")
    
    LET m_den_emp_orig = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_den_emp_orig,"POSITION",360,10)
    CALL _ADVPL_set_property(m_den_emp_orig,"LENGTH",36) 
    CALL _ADVPL_set_property(m_den_emp_orig,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_den_emp_orig,"VARIABLE",mr_cabec,"den_emp_orig")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",700,10)
    CALL _ADVPL_set_property(l_label,"TEXT","Periodo:")    

    LET m_periodo = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_periodo,"POSITION",800,10)
    CALL _ADVPL_set_property(m_periodo,"LENGTH",23)
    CALL _ADVPL_set_property(m_periodo,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_periodo,"VARIABLE",mr_cabec,"Periodo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",30,35)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat emis titulos:")    

    LET m_emis_tit = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_emis_tit,"POSITION",140,35)
    CALL _ADVPL_set_property(m_emis_tit,"EDITABLE",TRUE) 
    CALL _ADVPL_set_property(m_emis_tit,"VARIABLE",mr_cabec,"dat_emis_tit")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",280,35)
    CALL _ADVPL_set_property(l_label,"TEXT","Vencimento:")    

    LET m_venc_tit = _ADVPL_create_component(NULL,"LDATEFIELD",l_panel)
    CALL _ADVPL_set_property(m_venc_tit,"POSITION",360,35)
    CALL _ADVPL_set_property(m_venc_tit,"VARIABLE",mr_cabec,"dat_venc_tit")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_panel)
    CALL _ADVPL_set_property(l_label,"POSITION",500,35)     
    CALL _ADVPL_set_property(l_label,"TEXT","  Cód portador:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,FALSE,FALSE)

    LET m_cod_portador = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel)
    CALL _ADVPL_set_property(m_cod_portador,"POSITION",590,35)     
    CALL _ADVPL_set_property(m_cod_portador,"VARIABLE",mr_cabec,"cod_portador")
    CALL _ADVPL_set_property(m_cod_portador,"LENGTH",4,0)
    CALL _ADVPL_set_property(m_cod_portador,"PICTURE","@E ####")
    CALL _ADVPL_set_property(m_cod_portador,"VALID","pol1318_valida_portador")

    LET m_lupa_portador = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel)
    CALL _ADVPL_set_property(m_lupa_portador,"POSITION",630,35)     
    CALL _ADVPL_set_property(m_lupa_portador,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_portador,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_portador,"CLICK_EVENT","pol1318_zoom_portador")
    
    LET m_nom_portador = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel)
    CALL _ADVPL_set_property(m_nom_portador,"POSITION",660,35)     
    CALL _ADVPL_set_property(m_nom_portador,"LENGTH",36) 
    CALL _ADVPL_set_property(m_nom_portador,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nom_portador,"VARIABLE",mr_cabec,"nom_portador")

END FUNCTION


#--------------------------------------------#
FUNCTION pol1318_cria_grade_orig(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",280)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE)
   
    LET m_browse = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_browse,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_browse,"BEFORE_ROW_EVENT","pol1318_before_linha")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CANCEL_EX")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","excluir")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1318_del_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1318_del_tudo")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_HEADER","CHECKED")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Ratear")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","ratear")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LCHECKBOX")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_CHECKED",'S')
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALUE_NCHECKED",'N')
    CALL _ADVPL_set_property(l_tabcolumn,"AFTER_EDIT_EVENT","pol1318_rat_linha")
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER_CLICK_EVENT","pol1318_rat_tudo")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Documento")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",70)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","docum")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Origem")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","origem")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Dat rec")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_rec")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Valor")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","valor")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.##")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Tipo de despesa")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","despesa")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",190)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","fornecedor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_browse)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Rateado")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","rateado")
    
    CALL _ADVPL_set_property(m_browse,"SET_ROWS",ma_itens,1)
    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)

    #CALL _ADVPL_set_property(m_browse,"CLEAR")

END FUNCTION

#--------------------------------------------#
FUNCTION pol1318_cria_grade_dest(l_container)#
#--------------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET l_panel= _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    #CALL _ADVPL_set_property(l_panel,"WIDTH",300)

    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brow_rat = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brow_rat,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emp")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",40)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Nome")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",190)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_emp_dest")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","C Cust")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_cent_cust")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","% Rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","pct_rateio")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Val rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","val_rateio")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@E ##,###,###.##")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brow_rat)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Num AD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",60)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ad")

    CALL _ADVPL_set_property(m_brow_rat,"SET_ROWS",ma_rateio,1)
    CALL _ADVPL_set_property(m_brow_rat,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_brow_rat,"EDITABLE",FALSE)
    #CALL _ADVPL_set_property(m_brow_rat,"CLEAR")

END FUNCTION

#---------------------------------#
FUNCTION pol1318_valida_portador()#
#---------------------------------#
    
    CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", '')
    
    IF  mr_cabec.cod_portador IS NULL THEN
        LET m_msg = 'Informe o portador.'
        CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
        RETURN FALSE
    END IF
      
   IF NOT pol1318_le_portador(mr_cabec.cod_portador) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
        
   LET mr_cabec.nom_portador = m_des_portador
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1318_le_portador(l_codigo)#
#---------------------------------------#

   DEFINE l_codigo LIKE portador.cod_portador
   
   LET m_msg = ''
   
   SELECT nom_portador
     INTO m_des_portador
     FROM portador
    WHERE cod_portador = l_codigo

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      LET m_des_portador = ''
      IF STATUS = 100 THEN
         LET m_msg = 'Portador inexistente.'    
      ELSE
         CALL log003_err_sql('SELECT','portador')
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------#
FUNCTION pol1318_zoom_portador()#
#-------------------------------#
    
   DEFINE l_codigo      LIKE portador.cod_portador,
          l_descricao   LIKE portador.nom_portador
          
   IF  m_zoom_portador IS NULL THEN
       LET m_zoom_portador = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_portador,"ZOOM","zoom_portador")
   END IF

   CALL _ADVPL_get_property(m_zoom_portador,"ACTIVATE")

   LET l_codigo    = _ADVPL_get_property(m_zoom_portador,"RETURN_BY_TABLE_COLUMN","portador","cod_portador")
   LET l_descricao = _ADVPL_get_property(m_zoom_portador,"RETURN_BY_TABLE_COLUMN","portador","nom_portador")

   IF l_codigo IS NOT NULL THEN
      LET mr_cabec.cod_portador = l_codigo
      LET mr_cabec.nom_portador = l_descricao
   END IF
    
END FUNCTION


#----------------------#
FUNCTION pol1318_find()#
#----------------------#

    DEFINE l_status SMALLINT

    DEFINE l_where_clause CHAR(800)
    DEFINE l_order_by     CHAR(200)

    LET m_num_previsaoa = m_num_previsao
    
    IF m_filtro IS NULL THEN
       LET m_filtro = _ADVPL_create_component(NULL,"LCONSTRUCT")
       CALL _ADVPL_set_property(m_filtro,"CONSTRUCT_NAME","SELEÇÃO DE PREVISÃO")
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_TABLE","previsao_periodo_912","Previsao")
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","num_previsao","Previsão",1 {INT},10,0)        	       
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","dat_ini","Dat inicial",1 {DATE},10,0)        	       
       CALL _ADVPL_set_property(m_filtro,"ADD_VIRTUAL_COLUMN","previsao_periodo_912","dat_fim","Dat Final",1 {DATE},10,0)        	       
    END IF

    LET l_status = _ADVPL_get_property(m_filtro,"INIT_CONSTRUCT")

    IF  l_status THEN
        LET l_where_clause = _ADVPL_get_property(m_filtro,"WHERE_CLAUSE")
        LET l_order_by = _ADVPL_get_property(m_filtro,"ORDER_BY")
        CALL pol1318_cria_cursor(l_where_clause,l_order_by)
    END IF

    LET m_num_previsao = m_num_previsaoa
        
END FUNCTION

#------------------------------------------------------#
FUNCTION pol1318_cria_cursor(l_where_clause,l_order_by)#
#------------------------------------------------------#
 
   DEFINE l_where_clause CHAR(800),
          l_order_by     CHAR(200),
          l_sql_stmt     CHAR(2000),
          l_ind          INTEGER

    IF  l_order_by IS NULL THEN
        LET l_order_by = " num_previsao "
    END IF

   LET l_sql_stmt = "SELECT num_previsao ",
                     " FROM previsao_periodo_912 ",
                    " WHERE ", l_where_clause CLIPPED,
                    " AND cod_emp_orig = '",m_cod_empresa,"' ",
                    " ORDER BY ", l_order_by

   PREPARE var_pesquisa FROM l_sql_stmt
    
   IF  STATUS <> 0 THEN
       CALL log003_err_sql("PREPARE","var_pesquisa")
       RETURN 
   END IF

   DECLARE cq_cons SCROLL CURSOR WITH HOLD FOR var_pesquisa

   IF  Status <> 0 THEN
       CALL log003_err_sql("DECLARE","cq_cons")
       RETURN 
   END IF

   FREE var_pesquisa

   OPEN cq_cons

   IF  STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_cons")
       RETURN 
   END IF
   
   LET m_ies_cons = FALSE
   
   FETCH cq_cons INTO m_num_previsao

   IF STATUS <> 0 THEN
      IF STATUS <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cq_cons")
      ELSE
         LET m_msg = 'Não a dados, para os argumentos informados.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      END IF
      RETURN 
   END IF

    IF NOT pol1318_exibe_dados() THEN
       LET m_msg = 'Operação cancelada'
       CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
       RETURN 
    END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
    
   LET m_ies_cons = TRUE
   
   LET m_num_previsaoa = m_num_previsao
         
END FUNCTION

#-----------------------------#
FUNCTION pol1318_exibe_dados()#
#-----------------------------#

   LET m_excluiu = FALSE
   CALL pol1318_limpa_campos()

   IF NOT pol1318_le_periodo() THEN
      RETURN FALSE
   END IF
   
   LET mr_cabec.num_previsao = m_num_previsao
   LET mr_cabec.den_emp_orig = pol1318_le_empresa(mr_cabec.cod_emp_orig)   
   
   LET m_carregando = TRUE
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",TRUE)
   LET p_status = pol1318_le_itens()
   CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
   LET m_carregando = FALSE
      
   RETURN p_status
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1318_le_periodo()#
#-----------------------------#

   DEFINE l_dat_ini       DATE,
          l_dat_fim       DATE
    

   SELECT cod_emp_orig,
          dat_ini,
          dat_fim
     INTO mr_cabec.cod_emp_orig,
          l_dat_ini,
          l_dat_fim
     FROM previsao_periodo_912
    WHERE cod_emp_orig = m_cod_empresa
      AND num_previsao = m_num_previsao
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','previsao_periodo_912')
      RETURN FALSE
   END IF
      
   LET mr_cabec.Periodo = l_dat_ini, ' a ', l_dat_fim
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1318_le_empresa(l_codigo)#
#------------------------------------#

   DEFINE l_codigo     LIKE empresa.cod_empresa,
          l_descricao  LIKE empresa.den_empresa
   
   LET m_msg = ''
   
   SELECT den_empresa
     INTO l_descricao
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
   END IF
   
   RETURN l_descricao

END FUNCTION

#--------------------------------------#
FUNCTION pol1318_le_emp_reduz(l_codigo)#
#--------------------------------------#

   DEFINE l_codigo     LIKE empresa.cod_empresa,
          l_descricao  LIKE empresa.den_reduz
   
   LET m_msg = ''
   
   SELECT den_reduz
     INTO l_descricao
     FROM empresa
    WHERE cod_empresa = l_codigo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
   END IF
   
   RETURN l_descricao

END FUNCTION

#--------------------------#
FUNCTION pol1318_le_itens()#
#--------------------------#

   DEFINE l_ind       SMALLINT
   
   INITIALIZE ma_itens TO NULL
   LET l_ind = 1
      
   DECLARE cq_itens CURSOR FOR
    SELECT a.num_ad,
           a.num_nf,
           a.dat_rec_nf,
           a.val_tot_nf,
           a.cod_fornecedor,
           a.cod_tip_despesa,
           a.origem,
           a.rateado,
           b.raz_social,
           c.nom_tip_despesa,
           a.cod_cent_cust,
           a.dat_venc,     
           a.cod_moeda,    
           a.cod_tip_ad,   
           a.ies_sup_cap  
      FROM previsao_912 a, fornecedor b, tipo_despesa c
     WHERE a.num_previsao = m_num_previsao
       AND a.cod_emp_orig = m_cod_empresa
       AND b.cod_fornecedor = a.cod_fornecedor
       AND c.cod_empresa = a.cod_emp_orig
       AND c.cod_tip_despesa = a.cod_tip_despesa       
      ORDER BY c.nom_tip_despesa

   FOREACH cq_itens INTO 
      ma_itens[l_ind].num_ad,
      ma_itens[l_ind].num_nf,
      ma_itens[l_ind].dat_rec,
      ma_itens[l_ind].valor,
      ma_itens[l_ind].cod_fornecedor,
      ma_itens[l_ind].cod_tip_despesa,
      ma_itens[l_ind].origem,
      ma_itens[l_ind].rateado,
      ma_itens[l_ind].fornecedor,
      ma_itens[l_ind].despesa
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF
      
      LET ma_itens[l_ind].excluir = 'N'
      LET ma_itens[l_ind].ratear = 'N'
      
      IF ma_itens[l_ind].origem = 'SUP' THEN
         LET ma_itens[l_ind].docum = ma_itens[l_ind].num_nf
      ELSE
         LET ma_itens[l_ind].docum = ma_itens[l_ind].num_ad
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade de titulos ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_itens
   
   LET m_qtd_linha = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)
   
   IF m_qtd_linha >= 1 THEN
      LET p_status = pol1318_le_rateio(ma_itens[1].num_ad)
   END IF
   
   RETURN p_status

END FUNCTION

#-----------------------------------#
FUNCTION pol1318_le_rateio(l_num_ad)#
#-----------------------------------#

   DEFINE l_num_ad    INTEGER,
          l_ind       INTEGER
   
   LET l_ind = 1
   
   DECLARE cq_rateio CURSOR FOR
    SELECT empresa_dest,
           cod_cent_cust,
           pct_rateio,
           val_rateio,
           num_titulo 
      FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao
       AND num_ad = l_num_ad
     ORDER BY empresa_dest, cod_cent_cust

   FOREACH cq_rateio INTO
      ma_rateio[l_ind].cod_emp_dest,
      ma_rateio[l_ind].cod_cent_cust,
      ma_rateio[l_ind].pct_rateio,
      ma_rateio[l_ind].val_rateio,
      ma_rateio[l_ind].num_ad

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_rateio')
         RETURN FALSE
      END IF

      LET ma_rateio[l_ind].den_emp_dest = pol1318_le_empresa(ma_rateio[l_ind].cod_emp_dest)  
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 300 THEN
         LET m_msg = 'Limite de linhas da grade de rateio ultrapassou'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_rateio
   
   LET l_ind = l_ind - 1

   CALL _ADVPL_set_property(m_brow_rat,"ITEM_COUNT", l_ind)
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1318_ies_cons()#
#--------------------------#

   IF NOT m_ies_cons THEN
      LET m_msg = 'Não há consulta ativa.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", m_msg)
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1318_paginacao(l_opcao)#
#----------------------------------#
   
   DEFINE l_opcao CHAR(01),
          l_achou SMALLINT

   IF NOT pol1318_ies_cons() THEN
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","")   
   
   LET l_achou = FALSE
   LET m_num_previsaoa = m_num_previsao

   WHILE TRUE
   
      CASE l_opcao
         WHEN 'F' 
            FETCH FIRST cq_cons INTO m_num_previsao
            LET l_opcao = 'N'
         WHEN 'L' 
            FETCH LAST cq_cons INTO m_num_previsao
            LET l_opcao = 'P'
         WHEN 'N' 
            FETCH NEXT cq_cons INTO m_num_previsao
         WHEN 'P' 
            FETCH PREVIOUS cq_cons INTO m_num_previsao
      END CASE

      IF STATUS <> 0 THEN
         IF STATUS <> 100 THEN
            CALL log003_err_sql("FETCH CURSOR","cq_cons")
         ELSE
            CALL _ADVPL_set_property(m_statusbar,
               "ERROR_TEXT","Não existem mais registros nesta direção.")
         END IF
         LET m_num_previsao = m_num_previsaoa
         EXIT WHILE
      ELSE
         SELECT 1
           FROM previsao_periodo_912
          WHERE num_previsao = m_num_previsao          
         IF STATUS = 100 THEN
         ELSE
            IF STATUS = 0 THEN
               CALL pol1318_exibe_dados()
               LET l_achou = TRUE
               EXIT WHILE
            ELSE 
               CALL log003_err_sql("FETCH CURSOR","cq_cons")
               EXIT WHILE
            END IF
         END IF
      END IF               
   
   END WHILE
   
   RETURN l_achou
   
END FUNCTION

#-----------------------#
FUNCTION pol1318_first()#
#-----------------------#

   IF NOT pol1318_paginacao('F') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION
    
#----------------------#
FUNCTION pol1318_next()#
#----------------------#

   IF NOT pol1318_paginacao('N') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1318_previous()#
#--------------------------#

   IF NOT pol1318_paginacao('P') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#----------------------#
FUNCTION pol1318_last()#
#----------------------#

   IF NOT pol1318_paginacao('L') THEN
      RETURN FALSE
   END IF

   RETURN TRUE
    
END FUNCTION

#------------------------------#
FUNCTION pol1318_before_linha()#
#------------------------------#

   DEFINE l_lin_atu       INTEGER
   
   IF m_carregando THEN
      RETURN TRUE
   END IF
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu <= 0 OR l_lin_atu IS NULL THEN
      RETURN TRUE
   END IF
   
   LET p_status = pol1318_le_rateio(ma_itens[l_lin_atu].num_ad)
  
   RETURN p_status

END FUNCTION   

#----------------------------------#
 FUNCTION pol1318_prende_registro()#
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM previsao_periodo_912
     WHERE num_previsao = m_num_previsao
     FOR UPDATE 
    
    OPEN cq_prende

    IF STATUS <> 0 THEN
       CALL log003_err_sql("OPEN CURSOR","cq_prende")
       CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF
    
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH CURSOR","cq_prende")
      CALL log085_transacao("ROLLBACK")
      CLOSE cq_prende
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol1318_gerar()#
#-----------------------#

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1318_ies_cons() THEN
      RETURN FALSE
   END IF

   IF NOT pol1318_prende_registro() THEN
      RETURN FALSE
   END IF
   
   CALL pol1318_ativa_desativa(TRUE)

   LET m_qtd_linha = _ADVPL_get_property(m_browse,"ITEM_COUNT")

   CALL _ADVPL_set_property(m_emis_tit,"GET_FOCUS")
   
   LET m_clik_exc = FALSE
   LET m_clik_rat = FALSE
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1318_gerar_confirma()#
#--------------------------------#
   
   DEFINE l_qtd_lin     INTEGER,
          l_ind         INTEGER,
          l_status      SMALLINT,
          l_qtd_exclui  INTEGER
   
   LET m_qtd_rateio = 0
   LET l_qtd_exclui = 0

   FOR l_ind = 1 TO m_qtd_linha
       IF ma_itens[l_ind].ratear = 'S' THEN
          LET m_qtd_rateio = m_qtd_rateio + 1
       END IF
       IF ma_itens[l_ind].excluir = 'S' THEN
          LET l_qtd_exclui = l_qtd_exclui + 1
       END IF
   END FOR

   IF m_qtd_rateio = 0 AND l_qtd_exclui = 0 THEN
      LET m_msg = 'Nelhuma modificação foi efetuada.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF  
   
   LET m_msg = 'Todos os registros marcados \n',
               'serão rateados ou excluídos. \n',
               'Confirma a operação?'

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
      RETURN FALSE
   END IF
   
   IF m_qtd_rateio > 0 THEN
      IF mr_cabec.dat_emis_tit IS NULL THEN
         LET m_msg = 'Dat emissão dos titulos invalída.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_emis_tit,"GET_FOCUS")
         RETURN FALSE
      END IF
      IF mr_cabec.dat_venc_tit IS NULL OR 
         mr_cabec.dat_venc_tit  < TODAY OR 
         mr_cabec.dat_venc_tit < mr_cabec.dat_emis_tit THEN
         LET m_msg = 'Dat vencto dos titulos invalída.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         CALL _ADVPL_set_property(m_venc_tit,"GET_FOCUS")
         RETURN FALSE
      END IF
   END IF

   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   IF l_qtd_exclui > 0 THEN
      FOR l_ind = 1 TO m_qtd_linha
          IF ma_itens[l_ind].excluir = 'S' THEN
             CALL _ADVPL_set_property(m_browse,"REMOVE_ROW",l_ind)
          END IF
      END FOR

      LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")

      IF NOT pol1318_atu_previsao(l_qtd_lin) THEN
         LET p_status = pol1318_gerar_cancela()
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
         RETURN TRUE
      END IF
   END IF
               
   IF m_qtd_rateio > 0 THEN
      CALL LOG_progresspopup_start("Gerando títulos...","pol1318_processa","PROCESS")
      IF NOT p_status THEN
         LET p_status = pol1318_gerar_cancela()
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
         RETURN TRUE
      END IF
   END IF
   
   CALL log085_transacao("COMMIT")
                
   CLOSE cq_prende

   CALL pol1318_exibe_dados() RETURNING l_status
   
   IF l_qtd_lin = 0 THEN
      CALL pol1318_limpa_campos()
      LET m_excluiu = TRUE
      CALL _ADVPL_set_property(m_browse,"CLEAR")
   END IF

   CALL pol1318_ativa_desativa(FALSE)
   
   LET m_msg = 'Operação efetuada com sucesso.'
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)

   RETURN TRUE   
   
END FUNCTION

#-------------------------------#
FUNCTION pol1318_gerar_cancela()#
#-------------------------------#

   DEFINE l_status     SMALLINT

   CALL log085_transacao("ROLLBACK")      
   CLOSE cq_prende
    
   LET m_num_previsao = m_num_previsaoa
   CALL pol1318_exibe_dados() RETURNING l_status
   CALL pol1318_ativa_desativa(FALSE)
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1318_atu_previsao(l_linha)#
#-------------------------------------#

   DEFINE l_linha    INTEGER
   
   IF NOT pol1318_del_previsao() THEN
      RETURN FALSE
   END IF
   
   IF l_linha = 0 THEN
      IF NOT pol1318_del_rateio() THEN
         RETURN FALSE
      END IF
      IF NOT pol1318_del_periodo() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   IF NOT pol1318_ins_previsao(l_linha) THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1318_atu_rateio() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#-------------------------------------#
FUNCTION pol1318_ins_previsao(l_linha)#
#-------------------------------------#

   DEFINE l_linha    INTEGER,
          l_ind      INTEGER
          
   FOR l_ind = 1 TO l_linha
       
       INSERT INTO previsao_912
        VALUES(mr_cabec.num_previsao,
               mr_cabec.cod_emp_orig,
               ma_itens[l_ind].num_ad,
               ma_itens[l_ind].cod_cent_cust,
               ma_itens[l_ind].cod_fornecedor,
               ma_itens[l_ind].cod_tip_despesa,
               ma_itens[l_ind].num_nf,
               ma_itens[l_ind].dat_rec,
               ma_itens[l_ind].cnd_pgto,
               ma_itens[l_ind].valor,
               ma_itens[l_ind].dat_venc,
               ma_itens[l_ind].cod_moeda,  
               ma_itens[l_ind].cod_tip_ad, 
               ma_itens[l_ind].ies_sup_cap,
               ma_itens[l_ind].origem,
               ma_itens[l_ind].rateado)
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('INSERT','previsao_912')
          RETURN FALSE
       END IF    
        
   END FOR
   
   RETURN TRUE

END FUNCTION             

#----------------------------#
FUNCTION pol1318_atu_rateio()#
#----------------------------#

   DELETE previsao_rateio_912
    WHERE num_previsao = m_num_previsao
      AND num_ad NOT IN
          (SELECT num_ad FROM previsao_912
            WHERE num_previsao = m_num_previsao
              AND cod_emp_orig = m_cod_empresa)
              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','previsao_rateio_912')
      RETURN FALSE
   END IF    
   
   RETURN TRUE

END FUNCTION
   
#------------------------#
FUNCTION pol1318_delete()#
#------------------------#
   
   DEFINE l_ret   SMALLINT

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem excluidos.")
      RETURN FALSE
   END IF
   
   IF NOT pol1318_ies_cons() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1318_checa_nota() THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   IF NOT LOG_question("Confirma a exclusão da previsão?") THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação cancelada.")
      RETURN FALSE
   END IF

   IF NOT pol1318_prende_registro() THEN
      RETURN FALSE
   END IF

   LET l_ret = FALSE

   IF pol1318_del_previsao() THEN
      IF pol1318_del_rateio() THEN
         IF pol1318_del_periodo() THEN
            LET l_ret = TRUE
         END IF
      END IF
   END IF

   IF l_ret THEN
      CALL log085_transacao("COMMIT")
      CALL pol1318_limpa_campos()
      LET m_excluiu = TRUE
      CALL _ADVPL_set_property(m_browse,"CLEAR")
      LET m_msg = 'Operação efetuada com sucesso.'
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET m_msg = 'Operação cancelada.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         
   CLOSE cq_prende
   
   RETURN l_ret
        
END FUNCTION

#----------------------------#
FUNCTION pol1318_checa_nota()#
#----------------------------#

   SELECT COUNT(*)
     INTO m_count
     FROM previsao_912
    WHERE num_previsao = m_num_previsao
      AND cod_emp_orig = m_cod_empresa
      AND rateado = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','previsao_912')
      LET m_msg = 'Erro ',STATUS, ' lendo tabela previsao_912.'
      RETURN FALSE
   END IF
   
   IF m_count > 0 THEN
      LET m_msg = 'Previsão que contém rateio não pode ser excluída.'
      RETURN FALSE
   END IF 
      
   RETURN TRUE
   
END FUNCTION        

#------------------------------#
FUNCTION pol1318_del_previsao()#
#------------------------------#

   DELETE FROM previsao_912
     WHERE num_previsao = m_num_previsao
       AND cod_emp_orig = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','previsao_912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1318_del_rateio()#
#----------------------------#
   
   DELETE FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','previsao_rateio_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1318_del_periodo()#
#-----------------------------#
   
   DELETE FROM previsao_periodo_912
     WHERE num_previsao = m_num_previsao
       AND cod_emp_orig = m_cod_empresa
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','previsao_periodo_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1318_rat_linha()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[l_lin_atu].ratear = 'S' THEN
      IF ma_itens[l_lin_atu].rateado = 'S' THEN
         LET m_msg = 'Esse título já foi rateado.'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         LET ma_itens[l_lin_atu].ratear = 'N'
         RETURN FALSE
      END IF
   END IF

   IF ma_itens[l_lin_atu].excluir = 'S' THEN
      LET m_msg = 'Escolha ratear ou excluir e não ambos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET ma_itens[l_lin_atu].ratear = 'N'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1318_rat_tudo()#
#--------------------------#

   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   LET m_clik_rat = NOT m_clik_rat
   
   IF m_clik_rat THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
      
   FOR l_ind = 1 TO m_qtd_linha
      IF ma_itens[l_ind].rateado <> 'S' THEN
         IF ma_itens[l_ind].excluir <> 'S' THEN
            CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","ratear",l_ind,l_sel)
         END IF
      END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1318_del_linha()#
#---------------------------#

   DEFINE l_lin_atu       INTEGER
   
   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_itens[l_lin_atu].rateado = 'S' THEN
      LET m_msg = 'Esse título já foi rateado e não pode ser excluído.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET ma_itens[l_lin_atu].excluir = 'N'
      RETURN FALSE
   END IF

   IF ma_itens[l_lin_atu].ratear = 'S' THEN
      LET m_msg = 'Escolha ratear ou excluir e não ambos.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      LET ma_itens[l_lin_atu].excluir = 'N'
      RETURN FALSE
   END IF
               
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1318_del_tudo()#
#--------------------------#

   DEFINE l_ind       INTEGER,
          l_sel       CHAR(01)
   
   LET m_clik_exc = NOT m_clik_exc
   
   IF m_clik_exc THEN
      LET l_sel = 'S'
   ELSE
      LET l_sel = 'N'
   END IF
      
   FOR l_ind = 1 TO m_qtd_linha
      IF ma_itens[l_ind].rateado <> 'S' THEN
         IF ma_itens[l_ind].ratear <> 'S' THEN
            CALL _ADVPL_set_property(m_browse,"COLUMN_VALUE","excluir",l_ind,l_sel)
         END IF
      END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1318_processa()#
#--------------------------#
   
   DEFINE l_qtd_lin   SMALLINT,
          l_progres   SMALLINT
   
   CALL LOG_progresspopup_set_total("PROCESS",m_qtd_rateio)
   
   INITIALIZE mr_ad.* TO NULL
   
   LET mr_ad.nom_programa = 'POL1318'
   LET p_status = pol1318_le_fornec()
   IF NOT p_status THEN
      RETURN
   END IF

   LET p_status = pol1318_cria_tab_temp()
   IF NOT p_status THEN
      RETURN
   END IF      
   
   LET l_qtd_lin = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   
   FOR m_ind = 1 TO l_qtd_lin
       IF ma_itens[m_ind].ratear = 'S' THEN
          LET p_status = pol1318_proces_rateio()
          LET l_progres = LOG_progresspopup_increment("PROCESS")
          IF NOT p_status THEN
             EXIT FOR
          END IF
       END IF
   END FOR
   
   IF p_status THEN     
      LET p_status = pol1318_gera_nota_deb() 
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1318_cria_tab_temp()#
#-------------------------------#

   DROP TABLE rateio_tmp_912

   CREATE TABLE rateio_tmp_912 (
     empresa_dest     CHAR(02),
     num_ad           INTEGER,
     val_ad           DECIMAL(12,2),
     docum_orig       INTEGER);

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','rateio_tmp_912')
      RETURN FALSE
   END IF

   DROP TABLE cent_cust_tmp_912

   CREATE TABLE cent_cust_tmp_912 (
     empresa_dest     CHAR(02),
     cod_cent_cust    DECIMAL(4,0),
     cod_aen          CHAR(08),
     valor            DECIMAL(12,2));

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','cent_cust_tmp_912')
      RETURN FALSE
   END IF

   DROP TABLE docum_aen_tmp_912

   CREATE TABLE docum_aen_tmp_912 (
     num_ad           INTEGER,
     cod_aen          CHAR(08),
     cod_emp_dest     CHAR(02),
     valor            DECIMAL(12,2));

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','docum_aen_tmp_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION

#---------------------------#
FUNCTION pol1318_le_fornec()#
#---------------------------#
   
   DEFINE l_cnpj     LIKE fornecedor.num_cgc_cpf
   
   SELECT num_cgc
     INTO l_cnpj
     FROM empresa
    WHERE cod_empresa = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE 
   END IF
   
   SELECT cod_fornecedor
     INTO mr_ad.cod_fornecedor
     FROM fornecedor
    WHERE num_cgc_cpf = l_cnpj

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','fornecedor')
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1318_proces_rateio()#
#-------------------------------#
   
   DEFINE l_cent_cust    DECIMAL(4,0),
          l_cod_aen      CHAR(08),
          l_valor        DECIMAL(12,2),
          l_val_aen      DECIMAL(12,2),
          l_pct_rateio   DECIMAL(5,2)
   
   DEFINE lr_aen         RECORD LIKE ad_aen_4.*
   
   LET mr_ad.num_ad = ma_itens[m_ind].num_ad
   LET mr_ad.tex_hist = 'RATEIO DA AD' , mr_ad.num_ad USING '<<<<<<'
   LET mr_ad.tex_hist = mr_ad.tex_hist CLIPPED, ' DA EMPRESA ',mr_cabec.cod_emp_orig
   LET m_docum_orig = ma_itens[m_ind].docum
   
   SELECT num_ad,
          ser_nf, 
          ssr_nf,
          dat_emis_nf,
          dat_rec_nf,
          cod_moeda,
          cod_tip_ad,
          ies_sup_cap,
          cnd_pgto
     INTO mr_ad.num_nf,
          mr_ad.ser_nf,
          mr_ad.ssr_nf,
          mr_ad.dat_emis_nf,
          mr_ad.dat_rec_nf,
          mr_ad.cod_moeda,
          mr_ad.cod_tip_ad,
          mr_ad.ies_sup_cap,
          mr_ad.cnd_pgto
     FROM ad_mestre
    WHERE cod_empresa =  mr_cabec.cod_emp_orig
      AND num_ad = mr_ad.num_ad
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ad_mestre')
      RETURN FALSE
   END IF
   
   LET mr_ad.emissao = mr_cabec.dat_emis_tit
   LET mr_ad.dat_venc = mr_cabec.dat_venc_tit
   LET mr_ad.cod_tip_despesa = ma_itens[m_ind].cod_tip_despesa

   DECLARE cq_emp_rat CURSOR FOR
    SELECT empresa_dest,
           SUM(val_rateio),
           SUM(pct_rateio)
      FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao
       AND num_ad = mr_ad.num_ad
     GROUP BY empresa_dest
     ORDER BY empresa_dest
           
   FOREACH cq_emp_rat INTO   
      mr_ad.cod_empresa,
      mr_ad.valor,
      l_pct_rateio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_emp_rat')
         RETURN FALSE
      END IF
      
      DECLARE cq_ad_aen CURSOR FOR
       SELECT *
         FROM ad_aen_4
        WHERE cod_empresa = p_cod_empresa
          AND num_ad = mr_ad.num_ad
      
      FOREACH cq_ad_aen INTO lr_aen.*
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_ad_aen')
            RETURN FALSE
         END IF
         
         LET l_val_aen = lr_aen.val_aen * l_pct_rateio / 100
         
         LET l_cod_aen = func002_strzero(lr_aen.cod_lin_prod,2),
                func002_strzero(lr_aen.cod_lin_recei,2),
                func002_strzero(lr_aen.cod_seg_merc,2),
                func002_strzero(lr_aen.cod_cla_uso,2)
         
         INSERT INTO docum_aen_tmp_912
          VALUES(mr_ad.num_ad, l_cod_aen, mr_ad.cod_empresa, l_val_aen)
                 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','docum_aen_tmp_912')
            RETURN FALSE
         END IF
      
      END FOREACH      
      
      DELETE FROM cent_cust_tmp_912
      
      DECLARE cq_aen CURSOR FOR
       SELECT cod_cent_cust,
              cod_aen,
              val_rateio
         FROM previsao_rateio_912
        WHERE num_previsao = m_num_previsao
          AND num_ad = mr_ad.num_ad
          AND empresa_dest = mr_ad.cod_empresa
         
      FOREACH cq_aen INTO   
         l_cent_cust,
         l_cod_aen,
         l_valor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_emp_rat')
            RETURN FALSE
         END IF
         
         INSERT INTO cent_cust_tmp_912
          VALUES(mr_ad.cod_empresa, l_cent_cust, l_cod_aen, l_valor)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','cent_cust_tmp_912')
            RETURN FALSE
         END IF
                  
      END FOREACH   
            
      LET m_num_ad = func009_gera_ad(mr_ad.*) 
      
      IF m_num_ad = -1 THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1318_gra_num_ad() THEN
         RETURN FALSE
      END IF
      
      INSERT INTO rateio_tmp_912
       VALUES(mr_ad.cod_empresa, m_num_ad, mr_ad.valor, m_docum_orig)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','rateio_tmp_912')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   IF NOT pol1318_gra_previsao() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
         
#----------------------------#         
FUNCTION pol1318_gra_num_ad()#
#----------------------------#
      
   UPDATE previsao_rateio_912
      SET num_titulo = m_num_ad
    WHERE num_previsao = m_num_previsao
      AND num_ad = mr_ad.num_ad
      AND empresa_dest = mr_ad.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','previsao_rateio_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#         
FUNCTION pol1318_gra_previsao()#
#------------------------------#
      
   UPDATE previsao_912
      SET rateado = 'S'
    WHERE num_previsao = m_num_previsao
      AND num_ad = mr_ad.num_ad
      AND cod_emp_orig = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','previsao_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
      
#-------------------------------#      
FUNCTION pol1318_gera_nota_deb()#
#-------------------------------#
      
   DECLARE cq_temp CURSOR FOR
    SELECT empresa_dest,
           SUM(val_ad)
      FROM rateio_tmp_912
     GROUP BY empresa_dest
   
   FOREACH cq_temp INTO m_empresa_dest, m_val_docum
        
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_temp')
         RETURN FALSE
      END IF
      
      SELECT MAX(id_rateio)
        INTO m_id_rateio
        FROM nota_deb_orig_912

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','nota_deb_orig_912:id')
         RETURN FALSE
      END IF
      
      IF m_id_rateio IS NULL THEN
         LET m_id_rateio = 0
      END IF
      
      LET m_id_rateio = m_id_rateio + 1      
      LET m_msg = func002_strzero(m_id_rateio,4)
      LET m_num_docum = 'R',m_cod_empresa,m_msg CLIPPED
      
      IF NOT pol1318_ins_deb_orig() THEN
         RETURN FALSE
       END IF
       
      IF NOT pol1318_ins_deb_dest() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1318_ins_docum() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION      

#------------------------------#
FUNCTION pol1318_ins_deb_orig()#
#------------------------------#

   INSERT INTO nota_deb_orig_912
    VALUES (m_id_rateio,
            m_cod_empresa,
            m_num_docum,
            mr_cabec.dat_emis_tit,
            mr_cabec.dat_venc_tit,
            m_val_docum,
            m_num_previsao)
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','nota_deb_orig_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1318_ins_deb_dest()#
#------------------------------# 
   
   DEFINE l_num_ad       INTEGER,
          l_val_ad       DECIMAL(12,2),
          l_docum        INTEGER
          
   DECLARE cq_dest CURSOR FOR
    SELECT num_ad,
           val_ad,
           docum_orig
      FROM rateio_tmp_912
     WHERE empresa_dest = m_empresa_dest
     ORDER BY num_ad
   
   FOREACH cq_dest INTO l_num_ad, l_val_ad, l_docum

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_dest')
         RETURN FALSE
      END IF
      
      INSERT INTO nota_deb_dest_912
       VALUES(m_num_docum,
              m_empresa_dest,
              l_num_ad,
              l_val_ad,
              l_docum)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','nota_deb_dest_912')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   
           
#---------------------------#
FUNCTION pol1318_ins_docum()#
#---------------------------#
 
   INITIALIZE mr_docum.* TO NULL
    
   LET mr_docum.cod_empresa = m_cod_empresa
   LET mr_docum.num_docum = m_num_docum
   LET mr_docum.dat_emissao = mr_cabec.dat_emis_tit
   LET mr_docum.dat_vencto = mr_cabec.dat_venc_tit
   LET mr_docum.val_docum = m_val_docum
   LET mr_docum.empresa_dest = m_empresa_dest
   LET mr_docum.cod_portador = mr_cabec.cod_portador
   
   IF NOT pol1318_le_cliente() THEN
      RETURN FALSE
   END IF
   
   IF NOT func010_gera_docum(mr_docum.*) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
    
#----------------------------#
FUNCTION pol1318_le_cliente()#
#----------------------------#
   
   DEFINE l_cnpj     LIKE empresa.num_cgc
   
   SELECT num_cgc
     INTO l_cnpj
     FROM empresa
    WHERE cod_empresa = m_empresa_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      RETURN FALSE 
   END IF
   
   SELECT cod_cliente
     INTO mr_docum.cod_cliente
     FROM clientes
    WHERE num_cgc_cpf = l_cnpj

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1318_estornar()#
#--------------------------#
   
   DEFINE l_num_ap      LIKE ap.num_ap,
          l_dat_pgto    LIKE ap.dat_pgto,
          l_txt         CHAR(10),
          l_status      SMALLINT,
          l_msg         CHAR(150)

   IF m_excluiu THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não há dados na tela a serem modificados.")
      RETURN FALSE
   END IF

   IF NOT pol1318_ies_cons() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(*)
     INTO m_count
     FROM previsao_912
    WHERE cod_emp_orig = m_cod_empresa
      AND num_previsao = m_num_previsao
      AND rateado = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','previsao_912')
      RETURN FALSE 
   END IF

   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Essa previsão não contem rateio para estornar.")
      RETURN FALSE
   END IF
          
   LET m_qtd_linha  = 0
          
   DECLARE cq_estorna CURSOR FOR
    SELECT empresa_dest,
           num_titulo
      FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao
       AND num_titulo IS NOT NULL
   
   FOREACH cq_estorna INTO m_empresa_dest, l_txt
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_estorna')
         RETURN FALSE 
      END IF
      
      LET m_qtd_linha = m_qtd_linha + 1
      
      LET m_num_ad = l_txt
      
      DECLARE cq_ad_ap CURSOR FOR
       SELECT num_ap
         FROM ad_ap
        WHERE cod_empresa = m_empresa_dest
          AND num_ad      = m_num_ad
      
      FOREACH cq_ad_ap INTO l_num_ap

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_ad_ap')
            RETURN FALSE
         END IF
      
      
         SELECT dat_pgto
           INTO l_dat_pgto
           FROM ap
          WHERE cod_empresa = m_empresa_dest
            AND num_ap = l_num_ap
            AND ies_versao_atual = 'S'

         IF STATUS <> 0 THEN
            LET l_msg = 'Erro: ', STATUS USING '<<<<<<', ' Empresa: ', m_empresa_dest,
             ' AP: ', l_num_ap USING '<<<<<<<<<'
            CALL log0030_mensagem(l_msg,'INFO')
            RETURN FALSE
         END IF
         
         IF l_dat_pgto IS NOT NULL THEN
            LET l_txt = l_num_ap
            LET m_msg = 'A AP ',l_txt CLIPPED, ' da empresa ',m_empresa_dest,'\n',
                        'já foi paga. Estorno não permitido.'
            CALL log0030_mensagem(m_msg,'info')
            RETURN FALSE
         END IF
      
      END FOREACH
   
   END FOREACH
   
   LET m_msg = 'Todos os títulos referentes a\n',
               'essa previsão serão excluídos. \n',
               'Confirma o estorno ?.'

   IF NOT LOG_question(m_msg) THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Operação cancelada.")
      RETURN FALSE
   END IF
   
   IF NOT pol1318_prende_registro() THEN
      RETURN FALSE
   END IF

   LET p_status = FALSE
   
   CALL LOG_progresspopup_start("Estornando títulos...","pol1318_executa","PROCESS")
   
   IF p_status THEN
      CALL log085_transacao("COMMIT")
      CALL pol1318_exibe_dados() RETURNING l_status
      LET m_msg = 'Operação efetuada com sucesso.'
   ELSE
      CALL log085_transacao("ROLLBACK")
      LET m_msg = 'Operação cancelada.'
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
   
   CLOSE cq_prende
   
   RETURN p_status

END FUNCTION

#-------------------------#
FUNCTION pol1318_executa()#
#-------------------------#
   
   SELECT COUNT(num_titulo)
     INTO m_count
      FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao
       AND num_titulo IS NOT NULL

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','previsao_rateio_912:COUNT')
      RETURN
   END IF
   
   LET m_count = m_count + 1
   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   IF pol1318_est_docum() THEN      
      IF pol1318_est_ad() THEN
         IF pol1318_limpa_previsao() THEN
            LET p_status = TRUE
         END IF
      END IF      
   END IF
   
END FUNCTION   

#---------------------------#
FUNCTION pol1318_est_docum()#
#---------------------------#

   DECLARE cq_docum CURSOR FOR
    SELECT num_nota_deb
      FROM nota_deb_orig_912
     WHERE empresa_orig = m_cod_empresa
       AND num_previsao = m_num_previsao

   FOREACH cq_docum INTO m_num_docum       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_docum')
         RETURN FALSE
      END IF
      
      LET m_msg = func011_estorna_cre(m_cod_empresa, m_num_docum, 'NS') 
      
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET m_progres = LOG_progresspopup_increment("PROCESS")
   
   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1318_est_ad()#
#------------------------#
   
   DEFINE l_txt      CHAR(10)
   
   DECLARE cq_est_ad CURSOR FOR
    SELECT DISTINCT empresa_dest,
           num_titulo
      FROM previsao_rateio_912
     WHERE num_previsao = m_num_previsao
       AND (num_titulo IS NOT NULL AND num_titulo <> ' ')
       
   FOREACH cq_est_ad INTO m_empresa_dest, l_txt
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_est_ad')
         RETURN FALSE 
      END IF
      
      LET m_num_ad = l_txt
  
      LET m_msg = func012_estorna_cap(m_empresa_dest, m_num_ad) 
      
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF

      LET m_progres = LOG_progresspopup_increment("PROCESS")
   
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1318_limpa_previsao()#
#--------------------------------#

   LET m_progres = LOG_progresspopup_increment("PROCESS")

   DELETE FROM nota_deb_dest_912
    WHERE num_nota_deb IN 
     (SELECT num_nota_deb FROM nota_deb_orig_912
       WHERE empresa_orig = m_cod_empresa
         AND num_previsao = m_num_previsao)
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','nota_deb_dest_912')
      RETURN FALSE 
   END IF

   DELETE FROM nota_deb_orig_912
    WHERE empresa_orig = m_cod_empresa
      AND num_previsao = m_num_previsao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','nota_deb_orig_912')
      RETURN FALSE 
   END IF

   UPDATE previsao_912
      SET rateado = ''
    WHERE num_previsao = m_num_previsao
      AND cod_emp_orig = m_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','previsao_912')
      RETURN FALSE
   END IF

   UPDATE previsao_rateio_912
      SET num_titulo = ''
    WHERE num_previsao = m_num_previsao

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','previsao_rateio_912')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#---FIM DO PROGRAMA---#
