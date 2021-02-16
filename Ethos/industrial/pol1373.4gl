#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1373                                                 #
# OBJETIVO: ALTERAÇÃO DO FORNECEDOR DO CAP                          #
# DATA....: 20/01/2021                                              #
#-------------------------------------------------------------------#

{

select first 100 * from audit_cap
select * from ad_mestre where cod_empresa = '06' and num_ad = 100    -- 045467636000267
select * from ad_ap where cod_empresa = '06' and num_ad = 100
select * from ap where cod_empresa = '06' and num_ap = 90
select * from nf_sup where cod_empresa = '06' and num_nf = 418448    -- 045467636000267
select * from fornecedor

   LET m_query = 
   "select cod_cliente ",
   "  from [10.10.0.5].[logixprd].[logix].[pedidos] ",
   " where cod_empresa = '02' and num_pedido = 4 "
   
   PREPARE var_query FROM m_query 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query:PREPARE')
   ELSE
      DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DECLARE','cq_padrao:DECLARE')
      ELSE
         OPEN cq_padrao
         FETCH cq_padrao INTO p_msg
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FETCH','cq_padrao:FETCH')
         ELSE
            CALL log0030_mensagem(p_msg,'info')
         END IF
      END IF
   END IF   
      
}

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_dialog          VARCHAR(10),
       m_statusbar       VARCHAR(10),
       m_construct       VARCHAR(10),
       m_brz_item        VARCHAR(10),
       m_pnl_cabec       VARCHAR(10),
       m_pnl_item        VARCHAR(10),
       m_dlg_nf          VARCHAR(10),
       m_bar_nf          VARCHAR(10),
       m_brz_nf          VARCHAR(10),
       m_new_fornec      VARCHAR(10),
       m_zoom_fornecedor VARCHAR(10)


DEFINE m_titulo          VARCHAR(10),
       m_fornec          VARCHAR(10),
       m_nota            VARCHAR(10)
              
DEFINE mr_cabec          RECORD
       cod_empresa       LIKE nf_sup.cod_empresa,
       num_ad            LIKE ad_mestre.num_ad,
       fornec_ad         LIKE ad_mestre.cod_fornecedor,
       num_nf            LIKE ad_mestre.num_nf,
       ser_nf            LIKE ad_mestre.ser_nf,
       ssr_nf            LIKE ad_mestre.ssr_nf,
       fornec_nf         LIKE nf_sup.cod_fornecedor,
       raz_social        LIKE fornecedor.raz_social
END RECORD
       
DEFINE ma_item           ARRAY[50] OF RECORD
       num_ap            LIKE ap.num_ap,
       num_versao        LIKE ap.num_versao,
       cod_fornecedor    LIKE ap.cod_fornecedor,
       raz_social        LIKE fornecedor.raz_social,
       dat_emis          LIKE ap.dat_emis,
       dat_vencto_s_desc LIKE ap.dat_vencto_s_desc,
       filler            CHAR(01)
END RECORD

DEFINE ma_nf             ARRAY[50] OF RECORD
       num_nf            LIKE nf_sup.num_nf,
       cod_fornecedor    LIKE nf_sup.cod_fornecedor,
       raz_social        LIKE fornecedor.raz_social,
       filler            CHAR(01)
END RECORD

DEFINE m_ies_cons        SMALLINT,
       m_qtd_item        INTEGER,
       m_msg             CHAR(120),
       m_ies_info        SMALLINT,
       m_ind             INTEGER,
       m_dat_atu         DATE,
       m_hor_atu         VARCHAR(08),
       m_num_seq         INTEGER,
       m_ies_ad_ap       CHAR(01),
       m_ies_oper        CHAR(01),
       m_num_tit         INTEGER,
       m_car_nf          SMALLINT,
       m_cod_fornecedor  VARCHAR(15)

DEFINE m_manut       LIKE audit_cap.desc_manut,
       m_num_lote    LIKE audit_cap.num_lote_transf
       
#-----------------#
FUNCTION pol1373()#
#-----------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "pol1373-12.00.03  "   
   CALL pol1373_menu()

END FUNCTION

#----------------------#
FUNCTION pol1373_menu()#
#----------------------#

    DEFINE l_menubar,
           l_create,
           l_update,
           l_find,
           l_panel,
           l_titulo  VARCHAR(80)

    LET l_titulo = 'ALTERAÇÃO DO FORNECEDOR DO CAP - ',p_versao
    
    LET m_dialog = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dialog,"SIZE",640,480)
    CALL _ADVPL_set_property(m_dialog,"TITLE",l_titulo)
    CALL _ADVPL_set_property(m_dialog,"FORM_NAME",p_versao)
    CALL _ADVPL_set_property(m_dialog,"ENABLE_ESC_CLOSE",FALSE)

    LET m_statusbar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dialog)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_dialog)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_find = _ADVPL_create_component(NULL,"LFINDBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_find,"TYPE","CONFIRM")
    CALL _ADVPL_set_property(l_find,"EVENT","pol1373_find")
    CALL _ADVPL_set_property(l_find,"CONFIRM_EVENT","pol1373_find_conf")
    CALL _ADVPL_set_property(l_find,"CANCEL_EVENT","pol1373_find_canc")

    LET l_update = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_update,"EVENT","pol1373_update")
    CALL _ADVPL_set_property(l_update,"TYPE","NO_CONFIRM")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")

    CALL pol1373_monta_cabec(l_panel)
    CALL pol1373_monta_item(l_panel)

    CALL _ADVPL_set_property(m_dialog,"ACTIVATE",TRUE)

END FUNCTION

#----------------------------------------#
FUNCTION pol1373_monta_cabec(l_container)#
#----------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_caixa           VARCHAR(10),
           l_lupa            VARCHAR(10)

    LET m_pnl_cabec = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_cabec,"ALIGN","TOP")
    CALL _ADVPL_set_property(m_pnl_cabec,"HEIGHT",40)
    CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",FALSE) 
    #CALL _ADVPL_set_property(m_panel,"BACKGROUND_COLOR",231,237,237)
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_cabec)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",18)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Empresa:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"cod_empresa")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",2)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Num AD:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_titulo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_titulo,"VARIABLE",mr_cabec,"num_ad")
    CALL _ADVPL_set_property(m_titulo,"LENGTH",10)
    CALL _ADVPL_set_property(m_titulo,"VAlid","pol1373_valid_titulo")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Fornecedor AD:")    

    LET m_fornec = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_fornec,"VARIABLE",mr_cabec,"fornec_ad")
    CALL _ADVPL_set_property(m_fornec,"LENGTH",15)
    CALL _ADVPL_set_property(m_fornec,"EDITABLE",FALSE) 

    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN") 
    #CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN") 

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Num nf:")    

    LET m_nota = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_nota,"VARIABLE",mr_cabec,"num_nf")
    CALL _ADVPL_set_property(m_nota,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(m_nota,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Série:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"ser_nf")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",3)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Sub série:")    

    LET l_caixa = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"ssr_nf")
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","   Novo fornec:")    

    LET m_new_fornec = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_new_fornec,"VARIABLE",mr_cabec,"fornec_nf")
    CALL _ADVPL_set_property(m_new_fornec,"LENGTH",15)
    CALL _ADVPL_set_property(m_new_fornec,"VAlid","pol1373_valid_new_fornec")

    LET l_lupa = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(l_lupa,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(l_lupa,"SIZE",24,20)
    CALL _ADVPL_set_property(l_lupa,"CLICK_EVENT","pol1373_zoom_fornecedor")

    LET l_caixa = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_caixa,"VARIABLE",mr_cabec,"raz_social")
    CALL _ADVPL_set_property(l_caixa,"LENGTH",20)
    CALL _ADVPL_set_property(l_caixa,"EDITABLE",FALSE) 
    CALL _ADVPL_set_property(l_caixa,"CAN_GOT_FOCUS",FALSE)


END FUNCTION

#---------------------------------------#
FUNCTION pol1373_monta_item(l_container)#
#---------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10)

    LET m_pnl_item = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(m_pnl_item,"ALIGN","CENTER")
          
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",m_pnl_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_item,"ALIGN","CENTER")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","AP")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_ap")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Versão")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",80)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_versao")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_fornecedor")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",200)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","raz_social")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Emissão")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_emis")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Vencto")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","dat_vencto_s_desc")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)

END FUNCTION

#------------------------------#
FUNCTION pol1373_valid_titulo()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.num_ad IS NULL OR mr_cabec.num_ad = 0 THEN
      LET m_msg = 'Informe o número da AD.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT num_nf, 
          ser_nf, 
          ssr_nf, 
          cod_fornecedor,
          num_lote_transf
     INTO mr_cabec.num_nf,       
          mr_cabec.ser_nf,       
          mr_cabec.ssr_nf,       
          mr_cabec.fornec_ad,
          m_num_lote
     FROM ad_mestre
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ad = mr_cabec.num_ad

   IF STATUS = 100 THEN
      LET m_msg = 'Título inexistente no CAP'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ad_mestre')
         RETURN FALSE
      END IF
   END IF
   
   {SELECT cod_fornecedor
     INTO mr_cabec.fornec_nf
     FROM nf_sup
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_nf = mr_cabec.num_nf
      AND ser_nf = mr_cabec.ser_nf
      AND ssr_nf = mr_cabec.ssr_nf

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET m_msg = 'Nota fiscal inexistente no SUP'
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
         RETURN FALSE
      ELSE
         IF STATUS <> -284 THEN
            CALL log003_err_sql('SELECT','nf_sup')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   LET m_car_nf = TRUE
   CALL pol1373_sel_fornec()
   
   IF m_cod_fornecedor IS NULL THEN
      RETURN FALSE
   END IF
   
   LET mr_cabec.fornec_nf = m_cod_fornecedor}
   
   CALL _ADVPL_set_property(m_new_fornec,"GET_FOCUS")
   
   RETURN TRUE

END FUNCTION   

#----------------------------------#
FUNCTION pol1373_valid_new_fornec()#
#----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')
   
   IF mr_cabec.fornec_nf IS NULL THEN
      LET m_msg = 'Informe o novo fornecedor.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   SELECT raz_social INTO mr_cabec.raz_social
     FROM fornecedor where cod_fornecedor = mr_cabec.fornec_nf

   IF STATUS = 100 THEN
      LET m_msg = 'Fornecedor não existe.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fornecedor')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION

#---------------------------------#
FUNCTION pol1373_zoom_fornecedor()#
#---------------------------------#

    DEFINE l_codigo         LIKE fornecedor.cod_fornecedor,
           l_descri         LIKE fornecedor.raz_social
    
    IF m_zoom_fornecedor IS NULL THEN
       LET m_zoom_fornecedor = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_fornecedor,"ZOOM","zoom_fornecedor")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_fornecedor,"ACTIVATE")
    
    LET l_codigo = _ADVPL_get_property(m_zoom_fornecedor,"RETURN_BY_TABLE_COLUMN","fornecedor","cod_fornecedor")
    LET l_descri = _ADVPL_get_property(m_zoom_fornecedor,"RETURN_BY_TABLE_COLUMN","fornecedor","raz_social")
    
    IF l_codigo IS NOT NULL THEN
       LET mr_cabec.fornec_nf = l_codigo
       LET mr_cabec.raz_social = l_descri
    END IF        

    CALL _ADVPL_set_property(m_new_fornec,"GET_FOCUS")
    
END FUNCTION
               
#------------------------------------#
FUNCTION pol1373_set_compon(l_status)#
#------------------------------------#
  
   DEFINE l_status     SMALLINT
   
   CALL _ADVPL_set_property(m_pnl_cabec,"ENABLE",l_status)

END FUNCTION

#------------------------------#
FUNCTION pol1373_clear_campon()#
#------------------------------#

   INITIALIZE mr_cabec.*, ma_item TO NULL   
   CALL _ADVPL_set_property(m_brz_item,"SET_ROWS",ma_item,1)

END FUNCTION

#----------------------#
FUNCTION pol1373_find()#
#----------------------#
   
   CALL pol1373_clear_campon()
   CALL pol1373_set_compon(TRUE)
   LET m_ies_info = FALSE
   LET mr_cabec.cod_empresa = p_cod_empresa
   CALL _ADVPL_set_property(m_titulo,"GET_FOCUS")
    
END FUNCTION

#---------------------------#
FUNCTION pol1373_find_canc()#
#---------------------------#
   
   CALL pol1373_clear_campon()
   CALL pol1373_set_compon(FALSE)
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1373_find_conf()#
#---------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')


   LET m_ies_info = LOG_progresspopup_start(
       "Lendo ordens... ","pol1373_exibe_dados","PROCESS")  

   CALL pol1373_set_compon(FALSE)
   
   RETURN m_ies_info
   
END FUNCTION

#-----------------------------#
FUNCTION pol1373_exibe_dados()#
#-----------------------------#

   DEFINE l_progres   SMALLINT,
          l_em_prog   SMALLINT,
          l_descri    VARCHAR(30)

   CALL LOG_progresspopup_set_total("PROCESS",2)
   
   LET m_ind = 1
   
   DECLARE cq_ad_ap CURSOR FOR
    SELECT num_ap FROM ad_ap
     WHERE cod_empresa = mr_cabec.cod_empresa
       AND num_ad = mr_cabec.num_ad
       
   FOREACH cq_ad_ap INTO 
      ma_item[m_ind].num_ap
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ad_ap:cq_ad_ap')
         RETURN FALSE
      END IF
      
      SELECT num_versao,
             cod_fornecedor,
             dat_emis,
             dat_vencto_s_desc
        INTO ma_item[m_ind].num_versao,
             ma_item[m_ind].cod_fornecedor,  
             ma_item[m_ind].dat_emis,        
             ma_item[m_ind].dat_vencto_s_desc
        FROM ap
       WHERE cod_empresa = mr_cabec.cod_empresa
         AND num_ap = ma_item[m_ind].num_ap
         AND ies_versao_atual = 'S'
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ap:cq_ad_ap')
         RETURN FALSE
      END IF
      
      SELECT raz_social INTO ma_item[m_ind].raz_social
        FROM fornecedor
       WHERE cod_fornecedor = ma_item[m_ind].cod_fornecedor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','fornecedor:cq_ad_ap')
         RETURN FALSE
      END IF

      LET l_progres = LOG_progresspopup_increment("PROCESS")
            
      LET m_ind = m_ind + 1
      
      IF m_ind > 50 THEN
         LET m_msg = 'Limite previsto de itens ultrapassou\n',
                     'Serão exibidos somente 50 itens.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET l_progres = LOG_progresspopup_increment("PROCESS")
   
   IF m_ind = 1 THEN
      LET m_msg = 'AD sem APs'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
   
   LET m_qtd_item = m_ind - 1 
   CALL _ADVPL_set_property(m_brz_item,"ITEM_COUNT", m_qtd_item)
   
END FUNCTION

#-------------------------#
 FUNCTION pol1373_prende()#
#-------------------------#
   
   DEFINE l_codigo     CHAR(02)
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT 1
      FROM ad_mestre
     WHERE cod_empresa =  mr_cabec.cod_empresa
       AND num_ad = mr_cabec.num_ad
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

#------------------------#
FUNCTION pol1373_update()#
#------------------------#

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",'')

   IF NOT m_ies_info THEN
      LET m_msg = 'Efetue a consulta previamente.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   IF mr_cabec.fornec_ad = mr_cabec.fornec_nf THEN
      LET m_msg = 'Fornecedor do TÍTULO já está igual ao fornecedor da NOTA.'
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF
      
   #IF NOT pol1373_prende() THEN
   #   RETURN FALSE
   #END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol1373_atu_adiant() THEN
      CALL log085_transacao("ROLLBACK")   
      RETURN FALSE
   END IF

   IF NOT pol1373_atu_titulo() THEN
      CALL log085_transacao("ROLLBACK")   
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   CALL log0030_mensagem('Operação efetuada com sucesso','info')
   
   LET mr_cabec.fornec_ad = mr_cabec.fornec_nf
   
   LET m_ies_info = LOG_progresspopup_start(
       "Lendo ordens... ","pol1373_exibe_dados","PROCESS")  
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1373_atu_adiant()#
#----------------------------#
   
   DEFINE l_count INTEGER
   
   SELECT COUNT(*) INTO l_count
     FROM adiant
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ad_nf_orig = mr_cabec.num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','adiant')
      RETURN FALSE
   END IF
   
   IF l_count = 0 THEN
      RETURN TRUE
   END IF
   
   UPDATE adiant SET cod_fornecedor = mr_cabec.fornec_nf
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ad_nf_orig = mr_cabec.num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','adiant')
      RETURN FALSE
   END IF

   UPDATE mov_adiant SET cod_fornecedor = mr_cabec.fornec_nf
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ad_nf_orig = mr_cabec.num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','mov_adiant')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1373_atu_titulo()#
#----------------------------#
      
   UPDATE ad_mestre 
      SET cod_fornecedor = mr_cabec.fornec_nf
    WHERE cod_empresa =  mr_cabec.cod_empresa
      AND num_ad = mr_cabec.num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ad_mestre')
      RETURN FALSE
   END IF

   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME

   LET m_manut = 'POL1373 - AUTEROU FRONECEDOR DA AD No. ', mr_cabec.num_ad USING '<<<<<<<'
   LET m_ies_ad_ap = '1'
   LET m_ies_oper = 'M'
   LET m_num_tit = mr_cabec.num_ad
   LET m_num_seq = pol1373_le_audit()
   
   IF NOT pol1373_ins_audit() THEN
      RETURN FALSE
   END IF
   
   FOR m_ind = 1 to m_qtd_item
       IF NOT pol1373_atu_ap(ma_item[m_ind].num_ap) THEN
          RETURN FALSE
       END IF   
   END FOR   

   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1373_atu_ap(l_num_ap)#
#--------------------------------#

   DEFINE l_num_ap      LIKE ap.num_ap
   DEFINE lr_ap         RECORD LIKE ap.*
   
   SELECT * INTO lr_ap.* FROM ap
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ap = l_num_ap
      AND ies_versao_atual = 'S'
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ap:sel_ap')
      RETURN FALSE
   END IF
   
   UPDATE ap SET ies_versao_atual = 'N'
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ap = l_num_ap
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ap:upd_ap')
      RETURN FALSE
   END IF
   
   LET lr_ap.num_versao = lr_ap.num_versao + 1
   LET lr_ap.cod_fornecedor = mr_cabec.fornec_nf
   
   INSERT INTO ap VALUES(lr_ap.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ap:ins_ap')
      RETURN FALSE
   END IF

   LET m_manut = 'POL1373 - AUTEROU FRONECEDOR DA AP No. ', l_num_ap USING '<<<<<<<'
   LET m_ies_ad_ap = '2'
   LET m_ies_oper = 'M'
   LET m_num_tit = l_num_ap
   LET m_num_seq = pol1373_le_audit()
   
   IF NOT pol1373_ins_audit() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1373_le_audit()#
#--------------------------#
   
   DEFINE l_sequen     LIKE audit_cap.num_seq
   
   SELECT MAX(num_seq)
     INTO l_sequen
     FROM audit_cap
    WHERE cod_empresa = mr_cabec.cod_empresa
      AND num_ad_ap = m_num_tit
      AND ies_ad_ap = m_ies_ad_ap
      
   IF STATUS <> 0 THEN
      LET l_sequen = 0
   END IF
   
   LET l_sequen = l_sequen + 1
      
   RETURN l_sequen

END FUNCTION

#---------------------------#
FUNCTION pol1373_ins_audit()#
#---------------------------#
   

   RETURN TRUE
      
   INSERT INTO audit_cap
      VALUES(mr_cabec.cod_empresa,
             m_ies_ad_ap,
             p_user,
             m_num_tit,
             m_ies_ad_ap,
             mr_cabec.num_nf,
             mr_cabec.ser_nf,
             mr_cabec.ssr_nf,
             mr_cabec.fornec_nf,
             m_ies_oper,
             m_num_seq,
             m_manut,
             m_dat_atu,
             m_hor_atu,
             m_num_lote)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_cap')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1373_sel_fornec()#
#----------------------------#

   DEFINE l_menubar     VARCHAR(10),
          l_panel       VARCHAR(10),
          l_select      VARCHAR(10),
          l_cancel      VARCHAR(10)

    LET m_dlg_nf = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_dlg_nf,"SIZE",600,400)
    CALL _ADVPL_set_property(m_dlg_nf,"TITLE","SELECÇÃO DO FORNECEDOR")
    CALL _ADVPL_set_property(m_dlg_nf,"INIT_EVENT","pol1373_inicia_form")

    LET m_bar_nf = _ADVPL_create_component(NULL,"LSTATUSBAR",m_dlg_nf)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_nf)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    
    CALL pol1373_grade_nf(l_panel)
    CALL pol1373_careega_nf(l_panel)
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_dlg_nf)
    CALL _ADVPL_set_property(l_panel,"ALIGN","BOTTOM")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232)
    CALL _ADVPL_set_property(l_panel,"HEIGHT",60)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",l_panel)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

   LET l_select = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_select,"IMAGE","CONFIRM_EX")
   CALL _ADVPL_set_property(l_select,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_select,"EVENT","pol1373_conf_nf")     

   LET l_cancel = _ADVPL_create_component(NULL,"LMENUBUTTON",l_menubar)     
   CALL _ADVPL_set_property(l_cancel,"IMAGE","CANCEL_EX")     
   CALL _ADVPL_set_property(l_cancel,"TYPE","NO_CONFIRM")     
   CALL _ADVPL_set_property(l_cancel,"EVENT","pol1373_canc_nf")     

   CALL _ADVPL_set_property(m_dlg_nf,"ACTIVATE",TRUE)


END FUNCTION

#-----------------------------#
FUNCTION pol1373_inicia_form()#
#-----------------------------#
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1373_grade_nf(l_container)#
#-------------------------------------#

    DEFINE l_container       VARCHAR(10),
           l_layout          VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_panel           VARCHAR(10)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_container)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
          
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",1) 
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
   
    LET m_brz_nf = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_brz_nf,"ALIGN","CENTER")
    CALL _ADVPL_set_property(m_brz_nf,"BEFORE_ROW_EVENT","pol1373_before_row")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_nf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","NOTA")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","num_nf")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_nf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Fornecedor")
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",150)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_fornecedor")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_nf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",300)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","raz_social")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_brz_nf)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","filler")

    CALL _ADVPL_set_property(m_brz_nf,"SET_ROWS",ma_nf,1)

END FUNCTION

#----------------------------#
FUNCTION pol1373_careega_nf()#
#----------------------------#
   
   DEFINE l_ind       INTEGER
   
   LET m_car_nf = TRUE
   LET l_ind = 1
   
   DECLARE cq_car_nf CURSOR FOR
   SELECT nf_sup.num_nf, nf_sup.cod_fornecedor, fornecedor.raz_social
     FROM nf_sup 
          LEFT JOIN fornecedor
             ON fornecedor.cod_fornecedor = nf_sup.cod_fornecedor     
    WHERE nf_sup.cod_empresa = mr_cabec.cod_empresa
      AND nf_sup.num_nf = mr_cabec.num_nf
      AND nf_sup.ser_nf = mr_cabec.ser_nf
      AND nf_sup.ssr_nf = mr_cabec.ssr_nf
   
   FOREACH cq_car_nf INTO 
      ma_nf[l_ind].num_nf,
      ma_nf[l_ind].cod_fornecedor,
      ma_nf[l_ind].raz_social
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_car_nf')
         EXIT FOREACH
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 50 THEN
         LET m_msg = 'Limite previsto de notas ultrapassou\n',
                     'Serão exibidos somente 50 notas.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF
   
   END FOREACH

   LET l_ind = l_ind - 1
   
   CALL _ADVPL_set_property(m_brz_nf,"ITEM_COUNT", l_ind)
   LET m_cod_fornecedor = ma_nf[1].cod_fornecedor

   LET m_car_nf = FALSE

END FUNCTION   

#----------------------------#
FUNCTION pol1373_before_row()#
#----------------------------#
   
   DEFINE l_linha      INTEGER
   
   IF m_car_nf THEN
      RETURN TRUE
   END IF
   
   LET l_linha = _ADVPL_get_property(m_brz_nf,"ROW_SELECTED")
   
   LET m_cod_fornecedor = ma_nf[l_linha].cod_fornecedor
          
   RETURN TRUE

END FUNCTION   

#-------------------------#
FUNCTION pol1373_conf_nf()#
#-------------------------#

   CALL _ADVPL_set_property(m_bar_nf,"ERROR_TEXT", '')

   IF m_cod_fornecedor IS NULL THEN
      LET m_msg = 'Selecione a nota'
      CALL _ADVPL_set_property(m_bar_nf,"ERROR_TEXT",m_msg)
      RETURN FALSE
   END IF

   
   CALL _ADVPL_set_property(m_dlg_nf,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION
   
#-------------------------#
FUNCTION pol1373_canc_nf()#
#-------------------------#
   
   LET m_cod_fornecedor = NULL
   CALL _ADVPL_set_property(m_dlg_nf,"ACTIVATE",FALSE)

   RETURN TRUE

END FUNCTION

   