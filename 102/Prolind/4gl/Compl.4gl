    #-------------------------------------------------------------------#
    
    # criação de painel para entrada dos itens e familias
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
 
    LET l_panel_item = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(l_panel_item,"ALIGN","TOP")
 
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    CALL _ADVPL_set_property(l_layout,"MIN_SIZE",300,400)
    
    LET m_bz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_bz_item,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_bz_item,"AFTER_ROW_EVENT","pol1301_row_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_item")

    #descrição do item
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição do item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    CALL _ADVPL_set_property(m_bz_item,"SET_ROWS",ma_item,1)
 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN",20)
    
    # criação do painel para entrada das familias
    
    LET m_bz_familia = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_bz_familia,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_bz_familia,"AFTER_ROW_EVENT","pol1301_row_familia")
    
    # código da familia

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_familia")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_familia")

    # zoom da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_familia")

    #descrição da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição da familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",185)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_familia")

    CALL _ADVPL_set_property(m_bz_familia,"SET_ROWS",ma_familia,1)





    #criação do campo para entrada do código do profissional
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operador:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_profis,"VARIABLE",mr_parametro,"cod_profis")
    CALL _ADVPL_set_property(m_cod_profis,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_profis,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_profis,"VALID","pol1301_checa_profis")

    #criação/definição do icone do zoom
    LET m_lupa_profis = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_profis,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_profis,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_profis,"CLICK_EVENT","pol1301_zoom_profis")

    #criação/definição do campos para exibir o nome d profissional
    LET l_nom_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_profis,"LENGTH",30) 
    CALL _ADVPL_set_property(l_nom_profis,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_nom_profis,"VARIABLE",mr_parametro,"nom_profis")











#-------------------------------------#
FUNCTION pol1301_cria_campos(l_dialog)#
#-------------------------------------#

    DEFINE l_dialog          VARCHAR(10),
           l_panel           VARCHAR(10),
           l_layout          VARCHAR(10),
           l_label           VARCHAR(10),
           l_den_cent_trab   VARCHAR(10),
           l_den_operac      VARCHAR(10),           
           l_panel_item      VARCHAR(10),
           l_panel_familia   VARCHAR(10),
           l_tabcolumn       VARCHAR(10),
           l_nom_profis      VARCHAR(10)


    #criação de painel da esquerda utilizado como margem esquerda
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","LEFT")
    CALL _ADVPL_set_property(l_panel,"WIDTH",600)
    
    #criação um LLAYOUT c/ 4 colunas, para distribuiçao dos campos com popup 
    
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",4)

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do centro de trabalho
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Centro de trabalho:")    

    LET m_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cent_trab,"LENGTH",5)
    CALL _ADVPL_set_property(m_cent_trab,"VARIABLE",mr_parametro,"cod_cent_trab")
    CALL _ADVPL_set_property(m_cent_trab,"PICTURE","@!")
    #FUNCTION para validação da entrada. Se retornar TRUE, a entrada será válida. Se 
    #retornar FALSE, o usuário terá que re-digitar a informação
    CALL _ADVPL_set_property(m_cent_trab,"VALID","pol1301_checa_cent_traba")

    #criação/definição do icone do zoom do centro de trabalho
    LET m_lupa_cent_trab = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_cent_trab,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_cent_trab,"CLICK_EVENT","pol1301_zoom_cent_trab")

    #criação/definição do campos para exibir o nome do centro de tabalho
    LET l_den_cent_trab = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_cent_trab,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_cent_trab,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_cent_trab,"VARIABLE",mr_parametro,"den_cent_trab")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada da operação
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operação:")    

    LET m_cod_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_operac,"VARIABLE",mr_parametro,"cod_operac")
    CALL _ADVPL_set_property(m_cod_operac,"LENGTH",5)
    CALL _ADVPL_set_property(m_cod_operac,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_operac,"VALID","pol1301_checa_operacao")

    #criação/definição do icone do zoom
    LET m_lupa_operac = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_operac,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_operac,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_operac,"CLICK_EVENT","pol1301_zoom_operacao")

    #criação/definição do campos para exibir o nome da operação
    LET l_den_operac = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_den_operac,"LENGTH",30) 
    CALL _ADVPL_set_property(l_den_operac,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_den_operac,"VARIABLE",mr_parametro,"den_operac")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do numero do documento
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Documento:")    
    
    LET m_docum = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_docum,"VARIABLE",mr_parametro,"num_docum")
    CALL _ADVPL_set_property(m_docum,"LENGTH",10)
    CALL _ADVPL_set_property(m_docum,"PICTURE","@!")
    CALL _ADVPL_set_property(m_docum,"VALID","pol1301_checa_docum")

    #criação do campo para entrada do numero da ordem
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Ordem:")    
    
    LET m_ordem = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_ordem,"VARIABLE",mr_parametro,"num_ordem")
    CALL _ADVPL_set_property(m_ordem,"LENGTH",9,0)
    CALL _ADVPL_set_property(m_ordem,"PICTURE","@E #########")
    CALL _ADVPL_set_property(m_ordem,"VALID","pol1301_checa_ordem")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")
    
    #criação do campo para entrada do periodo p/ pesquisa
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Data de:")
    
    LET m_datini = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datini,"VARIABLE",mr_parametro,"dat_ini")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","  Até:")
    
    LET m_datfim = _ADVPL_create_component(NULL,"LDATEFIELD",l_layout)
    CALL _ADVPL_set_property(m_datfim,"VARIABLE",mr_parametro,"dat_fim")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Dat p/ pesquisa:")
    
    LET m_dat_pesquisa = _ADVPL_create_component(NULL,"LCOMBOBOX",l_layout)    
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","A","Abertura")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","E","Entrega")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"ADD_ITEM","L","Liberação")     
    CALL _ADVPL_set_property(m_dat_pesquisa,"VARIABLE",mr_parametro,"dat_pesquisa")


    #criação do campo para entrada do numero da semana
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Semana:")
    
    LET m_semana = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_layout)
    CALL _ADVPL_set_property(m_semana,"VARIABLE",mr_parametro,"num_semana")
    CALL _ADVPL_set_property(m_semana,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_semana,"LENGTH",2,0)
    CALL _ADVPL_set_property(m_semana,"PICTURE","@E ##")

    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_ROW")

    #criação do campo para entrada do código do profissional
    LET l_label = _ADVPL_create_component(NULL,"LLABEL",l_layout)
    CALL _ADVPL_set_property(l_label,"TEXT","Operador:")    
    CALL _ADVPL_set_property(l_label,"FONT",NULL,NULL,TRUE,FALSE)

    LET m_cod_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(m_cod_profis,"VARIABLE",mr_parametro,"cod_profis")
    CALL _ADVPL_set_property(m_cod_profis,"LENGTH",15)
    CALL _ADVPL_set_property(m_cod_profis,"PICTURE","@!")
    CALL _ADVPL_set_property(m_cod_profis,"VALID","pol1301_checa_profis")

    #criação/definição do icone do zoom
    LET m_lupa_profis = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_layout)
    CALL _ADVPL_set_property(m_lupa_profis,"IMAGE","BTPESQ")
    CALL _ADVPL_set_property(m_lupa_profis,"SIZE",24,20)
    CALL _ADVPL_set_property(m_lupa_profis,"CLICK_EVENT","pol1301_zoom_profis")

    #criação/definição do campos para exibir o nome d profissional
    LET l_nom_profis = _ADVPL_create_component(NULL,"LTEXTFIELD",l_layout)
    CALL _ADVPL_set_property(l_nom_profis,"LENGTH",30) 
    CALL _ADVPL_set_property(l_nom_profis,"EDITABLE",FALSE) #não permite edição do conteúdo
    CALL _ADVPL_set_property(l_nom_profis,"VARIABLE",mr_parametro,"nom_profis")

    #-------------------------------------------------------------------#
    
    # criação de painel para entrada dos itens e familias
    
    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",l_dialog)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
 
    LET l_panel_item = _ADVPL_create_component(NULL,"LPANEL",l_panel)
    CALL _ADVPL_set_property(l_panel_item,"ALIGN","TOP")
 
    LET l_layout = _ADVPL_create_component(NULL,"LLAYOUTMANAGER",l_panel_item)
    CALL _ADVPL_set_property(l_layout,"COLUMNS_COUNT",3) #número de colunas
    CALL _ADVPL_set_property(l_layout,"EXPANSIBLE",TRUE) 
    CALL _ADVPL_set_property(l_layout,"MIN_SIZE",300,400)
    
    LET m_bz_item = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_bz_item,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_bz_item,"AFTER_ROW_EVENT","pol1301_row_item")
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",100)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",15)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_item")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_item")

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_item")

    #descrição do item
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_item)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição do item")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",250)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_item")

    CALL _ADVPL_set_property(m_bz_item,"SET_ROWS",ma_item,1)
 
    CALL _ADVPL_set_property(l_layout,"ADD_EMPTY_COLUMN",20)
    
    # criação do painel para entrada das familias
    
    LET m_bz_familia = _ADVPL_create_component(NULL,"LBROWSEEX",l_layout)
    CALL _ADVPL_set_property(m_bz_familia,"ALIGN","CENTER")
    
    CALL _ADVPL_set_property(m_bz_familia,"AFTER_ROW_EVENT","pol1301_row_familia")
    
    # código da familia

    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",50)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_COMPONENT","LTEXTFIELD")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","LENGTH",5)
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","PICTURE","@!")
    CALL _ADVPL_set_property(l_tabcolumn,"EDIT_PROPERTY","VALID","pol1301_checa_familia")
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","cod_familia")

    # zoom da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER"," ")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",TRUE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",20)
    CALL _ADVPL_set_property(l_tabcolumn,"NO_VARIABLE")
    CALL _ADVPL_set_property(l_tabcolumn,"IMAGE_RENDERER","BTPESQ")
    CALL _ADVPL_set_property(l_tabcolumn,"BEFORE_EDIT_EVENT","pol1301_zoom_br_familia")

    #descrição da familia
    
    LET l_tabcolumn = _ADVPL_create_component(NULL,"LTABLECOLUMNEX",m_bz_familia)
    CALL _ADVPL_set_property(l_tabcolumn,"HEADER","Descrição da familia")
    CALL _ADVPL_set_property(l_tabcolumn,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(l_tabcolumn,"COLUMN_WIDTH",185)
    CALL _ADVPL_set_property(l_tabcolumn,"VARIABLE","den_familia")

    CALL _ADVPL_set_property(m_bz_familia,"SET_ROWS",ma_familia,1)



END FUNCTION


#habilita/desabilita os campos de tela

#----------------------------------------#
FUNCTION pol1301_ativa_desativa(l_status)#
#----------------------------------------#

   DEFINE l_status SMALLINT
    
   CALL _ADVPL_set_property(m_cent_trab,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_cent_trab,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cod_operac,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_lupa_operac,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_docum,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_ordem,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datini,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_datfim,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_dat_pesquisa,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_semana,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_cod_profis,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_bz_item,"EDITABLE",l_status)
   CALL _ADVPL_set_property(m_bz_familia,"EDITABLE",l_status)
   #CALL _ADVPL_set_property(m_processo,"EDITABLE",FALSE)

END FUNCTION


#----------------------------------#
FUNCTION pol1301_checa_cent_traba()#
#----------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_cent_trab TO NULL
   
   IF mr_parametro.cod_cent_trab IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT den_cent_trab
     INTO mr_parametro.den_cent_trab
     FROM cent_trabalho
    WHERE cod_empresa = p_cod_empresa
      AND cod_cent_trab = mr_parametro.cod_cent_trab
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Centro de trabalho inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cent_trabalho')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_zoom_cent_trab()#
#--------------------------------#

    DEFINE l_cod_cent_trab       LIKE cent_trabalho.cod_cent_trab,
           l_den_cent_trab       LIKE cent_trabalho.den_cent_trab
    
    IF  m_zoom_cent_trab IS NULL THEN
        LET m_zoom_cent_trab = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_cent_trab,"ZOOM","zoom_cent_trabalho")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_cent_trab,"ACTIVATE")
    
    #obtém o código e nome do ct da linha atual da grade de zoom
    LET l_cod_cent_trab = _ADVPL_get_property(m_zoom_cent_trab,"RETURN_BY_TABLE_COLUMN","cent_trabalho","cod_cent_trab")
    LET l_den_cent_trab = _ADVPL_get_property(m_zoom_cent_trab,"RETURN_BY_TABLE_COLUMN","cent_trabalho","den_cent_trab")

    IF  l_cod_cent_trab IS NOT NULL THEN
        LET mr_parametro.cod_cent_trab = l_cod_cent_trab
        LET mr_parametro.den_cent_trab = l_den_cent_trab
    END IF

END FUNCTION
      
#--------------------------------#
FUNCTION pol1301_checa_operacao()#
#--------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.den_operac TO NULL

   IF mr_parametro.cod_operac IS NULL THEN
      RETURN TRUE
   END IF

   SELECT den_operac
     INTO mr_parametro.den_operac
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = mr_parametro.cod_operac
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação inexistente.")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','operacao')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_zoom_operacao()#
#-------------------------------#

    DEFINE l_cod_operac       LIKE operacao.cod_operac,
           l_den_operac       LIKE operacao.den_operac
    
    IF  m_zoom_operac IS NULL THEN
        LET m_zoom_operac = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_operac,"ZOOM","zoom_operacao")
    END IF
    
    CALL _ADVPL_get_property(m_zoom_operac,"ACTIVATE")
    
    LET l_cod_operac = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","cod_operac")
    LET l_den_operac = _ADVPL_get_property(m_zoom_operac,"RETURN_BY_TABLE_COLUMN","operacao","den_operac")

    IF  l_cod_operac IS NOT NULL THEN
        LET mr_parametro.cod_operac = l_cod_operac
        LET mr_parametro.den_operac = l_den_operac
    END IF

END FUNCTION      

#-----------------------------#
FUNCTION pol1301_checa_docum()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   IF mr_parametro.num_docum IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT COUNT(num_docum)   
     INTO m_count
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_docum = mr_parametro.num_docum
      AND ies_situa = '4'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Não existem ordens liberadas p/ o documento informado")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_checa_ordem()#
#-----------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   IF mr_parametro.num_ordem IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT COUNT(num_docum)   
     INTO m_count
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = mr_parametro.num_ordem
      AND ies_situa = '4'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordens')
      RETURN FALSE
   END IF
   
   IF m_count = 0 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "A ordem infromada não existe ou não está liberada")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_checa_profis()#
#------------------------------#

   CALL _ADVPL_set_property(m_statusbar,"CLEAR_TEXT")
   
   INITIALIZE mr_parametro.nom_profis TO NULL

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe o operador.")
      RETURN FALSE
   END IF

   SELECT nom_profis
     INTO mr_parametro.nom_profis
     FROM tx_profissional
    WHERE cod_empresa = p_cod_empresa
      AND cod_profis = mr_parametro.cod_profis
      AND cod_tip_profis = 'F'
   
   IF STATUS = 100 THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operador inexistente ou não é um funcionário")
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tx_profissional')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_zoom_profis()#
#-----------------------------#

    DEFINE l_codigo       LIKE tx_profissional.cod_profis,
           l_descricao    LIKE tx_profissional.nom_profis
    
    IF  m_zoom_profis IS NULL THEN
        LET m_zoom_profis = _ADVPL_create_component(NULL,"LZOOMMETADATA")
        CALL _ADVPL_set_property(m_zoom_profis,"ZOOM","zoom_tx_profissional")
    END IF
    
    #exibe a janela do zoom
    CALL _ADVPL_get_property(m_zoom_profis,"ACTIVATE")
    
    #obtém o código e nome do profissional
    LET l_codigo    = _ADVPL_get_property(m_zoom_profis,"RETURN_BY_TABLE_COLUMN","tx_profissional","cod_profis")
    LET l_descricao = _ADVPL_get_property(m_zoom_profis,"RETURN_BY_TABLE_COLUMN","tx_profissional","nom_profis")

    IF  l_codigo IS NOT NULL THEN
        LET mr_parametro.cod_profis = l_codigo
        LET mr_parametro.nom_profis = l_descricao
    END IF

END FUNCTION


#--------------------------#
FUNCTION pol1301_row_item()#
#--------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_bz_item,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      IF ma_item[l_lin_atu].cod_item IS NULL OR 
         ma_item[l_lin_atu].cod_item = ' ' THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_checa_item()#
#----------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_bz_item,"ROW_SELECTED")
      
   LET ma_item[l_lin_atu].den_item = ''
   
   IF ma_item[l_lin_atu].cod_item IS NULL THEN
      RETURN TRUE
   END IF

   IF NOT pol1301_le_item(ma_item[l_lin_atu].cod_item) THEN
      LET m_msg = 'Item não existe.'
      CALL log0030_mensagem(m_msg,'excl')
      RETURN FALSE
   END IF
   
   LET ma_item[l_lin_atu].den_item = m_den_item
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_row_familia()#
#-----------------------------#

   DEFINE l_lin_atu       SMALLINT
      
   LET l_lin_atu = _ADVPL_get_property(m_bz_familia,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN
      IF ma_familia[l_lin_atu].cod_familia IS NULL OR 
         ma_familia[l_lin_atu].cod_familia = ' ' THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_checa_familia()#
#-------------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_bz_familia,"ROW_SELECTED")
      
   LET ma_familia[l_lin_atu].den_familia = ''
   
   IF ma_familia[l_lin_atu].cod_familia IS NULL THEN
      RETURN TRUE
   END IF
       
   IF NOT pol1301_le_familia(ma_familia[l_lin_atu].cod_familia) THEN
      LET m_msg = 'Familia não existe.'
      CALL log0030_mensagem(m_msg,'excl')
      RETURN FALSE
   END IF
   
   LET ma_familia[l_lin_atu].den_familia = m_den_familia
      
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1301_le_familia(l_familia)#
#-------------------------------------#

   DEFINE l_familia     LIKE familia.cod_familia
   
   SELECT den_familia
     INTO m_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = l_familia
      
   IF STATUS <> 0 THEN
      LET m_den_familia = ''
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1301_zoom_br_familia()#
#---------------------------------#
    
   DEFINE l_codigo      LIKE Familia.cod_familia,
          l_lin_atu     INTEGER
          
   IF  m_zoom_familia IS NULL THEN
       LET m_zoom_familia = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_familia,"ZOOM","zoom_familia")
   END IF

   CALL _ADVPL_get_property(m_zoom_familia,"ACTIVATE")

   LET l_codigo = _ADVPL_get_property(m_zoom_familia,"RETURN_BY_TABLE_COLUMN","familia","cod_familia")

   IF l_codigo IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_bz_familia,"ROW_SELECTED")
      LET ma_familia[l_lin_atu].cod_familia = l_codigo
      CALL pol1301_le_familia(l_codigo) RETURNING p_status
      LET ma_familia[l_lin_atu].den_familia = m_den_familia   
   END IF
    
END FUNCTION

#--------------------------#
FUNCTION pol1301_cancelar()#
#--------------------------#

    CALL pol1301_limpa_campos()
    CALL pol1301_ativa_desativa(FALSE)
    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_confirmar()#
#---------------------------#
   
   IF mr_parametro.dat_fim IS NOT NULL AND
        mr_parametro.dat_ini IS NOT NULL THEN
      IF mr_parametro.dat_fim < mr_parametro.dat_ini THEN
         CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT","Período inválido!")
         CALL _ADVPL_set_property(m_datini,"GET_FOCUS")
         RETURN FALSE      
      END IF
   END IF

   IF mr_parametro.cod_profis IS NULL THEN
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Informe o operador p/ apontamento")
      CALL _ADVPL_set_property(m_cod_profis,"GET_FOCUS")
      RETURN FALSE
   END IF

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", "Aguarde! Coletando dados...")           
   
   LET p_status = pol1280_le_ordens()
     
   IF NOT p_status THEN 
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
                "Operação cancelada")           
   ELSE
      CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT",
             "Operação efetuada com sucesso.")
   END IF

   CALL pol1301_ativa_desativa(FALSE)
   
   LET m_ies_info = TRUE
   LET m_ies_mod = FALSE
                  
   RETURN TRUE
   
END FUNCTION
            
#---------------------------#
FUNCTION pol1280_le_ordens()#
#---------------------------#
   
   DEFINE sql_stmt        VARCHAR(5000),
          l_progres       SMALLINT,
          l_dat_abert     DATE,
          l_dat_entrega   DATE, 
          l_dat_liberac   DATE,
          l_ind           INTEGER,
          l_item          SMALLINT,
          l_familia       SMALLINT,
          l_cod_familia   CHAR(05)
   
   LET l_item = FALSE
   LET l_familia = FALSE
   
   DELETE FROM item_pol1301
   DELETE FROM familia_pol1301
   
   FOR l_ind = 1 TO 50

       IF ma_item[l_ind].cod_item IS NOT NULL THEN
          INSERT INTO item_pol1301 VALUES(ma_item[l_ind].cod_item)
          LET l_item = TRUE
       END IF

       IF ma_familia[l_ind].cod_familia IS NOT NULL THEN
          INSERT INTO familia_pol1301 VALUES(ma_familia[l_ind].cod_familia)
          LET l_familia = TRUE
       END IF
       
   END FOR
   
   LET sql_stmt =
       " SELECT num_ordem, cod_item, num_docum, dat_abert, dat_entrega, dat_liberac, ",
       "   cod_item_pai FROM ordens  ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_situa  = '4' ",
       "    AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata) "

   IF l_item THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND cod_item IN (SELECT cod_item FROM item_pol1301) "
   END IF

   IF mr_parametro.num_ordem IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_ordem = ", mr_parametro.num_ordem
   END IF

   IF mr_parametro.num_docum IS NOT NULL THEN
      LET sql_stmt = sql_stmt CLIPPED, " AND num_docum = '",mr_parametro.num_docum,"' "
   END IF

   IF mr_parametro.dat_ini IS NOT NULL THEN
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_abert >= '",mr_parametro.dat_ini,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_entrega >= '",mr_parametro.dat_ini,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_liberac >= '",mr_parametro.dat_ini,"' "
      END IF      
   END IF

   IF mr_parametro.dat_fim IS NOT NULL THEN
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_abert <= '",mr_parametro.dat_fim,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_entrega <= '",mr_parametro.dat_fim,"' "
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND dat_liberac <= '",mr_parametro.dat_fim,"' "
      END IF      
   END IF
  
   PREPARE var_ordem FROM sql_stmt   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","var_ordem")  
      RETURN FALSE          
   END IF 
   
   LET m_count = 0
   
   DECLARE cq_ordem CURSOR FOR var_ordem

   FOREACH cq_ordem INTO 
      mr_dados.num_ordem, 
      mr_dados.cod_item, 
      mr_dados.num_docum,  
      l_dat_abert,  
      l_dat_entrega,
      l_dat_liberac,
      m_cod_item_pai     
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ORDENS:CQ_ORDEM')
         RETURN FALSE
      END IF
      
      IF l_familia THEN
      
         SELECT cod_familia
           INTO l_cod_familia
           FROM Item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = mr_dados.cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Item')
            RETURN FALSE
         END IF
         
         SELECT COUNT(cod_familia)
           INTO m_count
           FROM familia_pol1301
          WHERE cod_familia = l_cod_familia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','Familia')
            RETURN FALSE
         END IF
         
         IF m_count = 0 THEN
            CONTINUE FOREACH
         END IF
         
      END IF
      
      IF NOT pol1301_le_cotas() THEN
         RETURN FALSE
      END IF
            
      IF mr_parametro.dat_pesquisa = 'A' THEN
         LET mr_dados.data = l_dat_abert
      END IF
      IF mr_parametro.dat_pesquisa = 'E' THEN
         LET mr_dados.data = l_dat_entrega
      END IF
      IF mr_parametro.dat_pesquisa = 'L' THEN
         LET mr_dados.data = l_dat_liberac
      END IF                  

      LET mr_dados.cod_empresa = p_cod_empresa
      LET mr_dados.ano = YEAR(mr_dados.data)
      LET mr_dados.mes = MONTH(mr_dados.data)
      #LET mr_dados.Semana = week_of_year(mr_dados.data)

      SELECT den_item_reduz
        INTO mr_dados.den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = mr_dados.cod_item
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ITEM')
         RETURN FALSE
      END IF      
      
      LET sql_stmt =
       " SELECT cod_operac, num_seq_operac, cod_cent_trab, ies_oper_final, ",
       " qtd_planejada, qtd_boas, qtd_refugo, qtd_sucata FROM ord_oper    ",
       "  WHERE cod_empresa = '",p_cod_empresa,"' ",
       "    AND ies_apontamento = 'S' ",
       "    AND num_ordem = ",mr_dados.num_ordem,
       "    AND qtd_planejada > (qtd_boas + qtd_refugo + qtd_sucata) "
      
      IF mr_parametro.cod_cent_trab IS NOT NULL THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND cod_cent_trab = '",mr_parametro.cod_cent_trab,"' "
      END IF
      
      IF mr_parametro.cod_operac IS NOT NULL THEN
         LET sql_stmt = sql_stmt CLIPPED, " AND cod_operac = '",mr_parametro.cod_operac,"' "
      END IF
      
      PREPARE var_oper FROM sql_stmt   

      IF STATUS <> 0 THEN
         CALL log003_err_sql("PREPARE","var_oper")  
         RETURN FALSE          
      END IF 
      
      DECLARE cq_oper CURSOR FOR var_oper

      FOREACH cq_oper INTO 
         mr_dados.cod_operac, 
         mr_dados.num_seq_operac, 
         mr_dados.cod_cent_trab, 
         mr_dados.ies_oper_final,
         mr_dados.qtd_planejada,
         mr_dados.qtd_boas, 
         mr_dados.qtd_refugo, 
         mr_dados.qtd_sucata
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','ORDENS:CQ_OPER')
            RETURN FALSE
         END IF      
                     
         LET mr_dados.qtd_saldo = mr_dados.qtd_planejada -
              (mr_dados.qtd_boas + mr_dados.qtd_refugo + mr_dados.qtd_sucata)
         LET mr_dados.qtd_boas = mr_dados.qtd_saldo
         LET mr_dados.qtd_refugo = 0
         LET mr_dados.qtd_sucata = 0
         LET mr_dados.usuario = p_user
         LET mr_dados.cod_status = 'P'

         INSERT INTO pol1301_1054 VALUES(mr_dados.*)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('INSERT','pol1301_1054')
            RETURN FALSE
         END IF      

         LET m_count = m_count + 1         
         
      END FOREACH
            
   END FOREACH
   
   IF m_count = 0 THEN
      LET m_msg = 'Nenhum registro foi encontrado,\n',
                  'para os parâmetros informados.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE 
   END IF 
   
   LET m_checa_linha = FALSE

   CALL _ADVPL_set_property(m_statusbar,"ERROR_TEXT", "")   

   IF NOT pol1301_sel_operacao() THEN
      RETURN FALSE
   END IF      
   
   RETURN TRUE   

END FUNCTION

#--------------------------#
FUNCTION pol1301_le_cotas()#
#--------------------------#
   
   DECLARE cq_cotas CURSOR FOR
    SELECT num_pedido, num_orc, pos
      FROM cfg_val_cotas912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = mr_dados.cod_item
       AND cod_pai = m_cod_item_pai
   FOREACH cq_cotas INTO
       mr_dados.num_pedido, 
       mr_dados.num_orc, 
       mr_dados.pos
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cfg_val_cotas912')
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_sel_operacao()#
#------------------------------#

    DEFINE l_menubar       VARCHAR(10),
           l_panel         VARCHAR(10),
           l_modifica      VARCHAR(10),
           l_print         VARCHAR(10),
           l_proces        VARCHAR(10)

    LET m_form_aponta = _ADVPL_create_component(NULL,"LDIALOG")
    CALL _ADVPL_set_property(m_form_aponta,"SIZE",1300,500)
    CALL _ADVPL_set_property(m_form_aponta,"TITLE","SELEÇÃO DE OPERAÇÕES")

    LET m_bar_aponta = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form_aponta)

    LET l_menubar = _ADVPL_create_component(NULL,"LMENUBAR",m_form_aponta)
    CALL _ADVPL_set_property(l_menubar,"HELP_VISIBLE",FALSE)

    LET l_modifica = _ADVPL_create_component(NULL,"LUPDATEBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_modifica,"EVENT","pol1301_modifica")
    CALL _ADVPL_set_property(l_modifica,"CONFIRM_EVENT","pol1301_conf_mod")
    CALL _ADVPL_set_property(l_modifica,"CANCEL_EVENT","pol1301_canc_mod")

    LET l_proces = _ADVPL_create_component(NULL,"LPROCESSBUTTON",l_menubar)
    CALL _ADVPL_set_property(l_proces,"EVENT","pol1301_processar")

    CALL _ADVPL_create_component(NULL,"LQUITBUTTON",l_menubar)

    LET l_panel = _ADVPL_create_component(NULL,"LPANEL",m_form_aponta)
    CALL _ADVPL_set_property(l_panel,"ALIGN","CENTER")
    CALL _ADVPL_set_property(l_panel,"BACKGROUND_COLOR",225,232,232) #vermelho,verde,azul

    CALL pol1301_cria_grade(l_panel)

    IF NOT pol1301_le_operacao() THEN
       RETURN FALSE
    END IF

    CALL _ADVPL_set_property(m_browse,"CAN_ADD_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"CAN_REMOVE_ROW",FALSE)
    CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)
    CALL _ADVPL_set_property(m_form_aponta,"ACTIVATE",TRUE)

   RETURN TRUE
  
END FUNCTION








#----------------------------------#
FUNCTION pol1301_zoom_item_sucata()#
#----------------------------------#
    
   DEFINE l_item     LIKE item.cod_item,
          l_lin_atu  INTEGER

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF ma_ordem[l_lin_atu].qtd_sucata = 0 THEN
      LET ma_ordem[l_lin_atu].item_sucata = ''
      RETURN
   END IF
           
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_item IS NOT NULL THEN
      LET ma_ordem[l_lin_atu].item_sucata = l_item
   END IF
    
END FUNCTION

#------------------------------#
FUNCTION pol1301_zoom_br_item()#
#------------------------------#
    
   DEFINE l_item        LIKE item.cod_item,
          l_lin_atu     INTEGER
          
   IF  m_zoom_item IS NULL THEN
       LET m_zoom_item = _ADVPL_create_component(NULL,"LZOOMMETADATA")
       CALL _ADVPL_set_property(m_zoom_item,"ZOOM","zoom_item")
   END IF

   CALL _ADVPL_get_property(m_zoom_item,"ACTIVATE")

   LET l_item      = _ADVPL_get_property(m_zoom_item,"RETURN_BY_TABLE_COLUMN","item","cod_item")

   IF l_item IS NOT NULL THEN
      LET l_lin_atu = _ADVPL_get_property(m_bz_item,"ROW_SELECTED")
      LET ma_item[l_lin_atu].cod_item = l_item
      CALL pol1301_le_item(l_item) RETURNING p_status
      LET ma_item[l_lin_atu].den_item = m_den_item   
   END IF
    
END FUNCTION

#-----------------------------#
FUNCTION pol1301_le_operacao()#
#-----------------------------#
   
   DEFINE l_ind     INTEGER
   
   INITIALIZE ma_ordem TO NULL
   
   LET l_ind = 1
   
   DECLARE cq_le_oper CURSOR FOR
    SELECT *
      FROM pol1301_1054
     WHERE cod_empresa = p_cod_empresa
       AND usuario = p_user
       AND cod_status = 'P'
     ORDER BY num_ordem DESC, num_seq_operac ASC
   
   FOREACH cq_le_oper INTO ma_ordem[l_ind].*      
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_le_oper')
         RETURN FALSE
      END IF
            
      LET l_ind = l_ind + 1
      
      IF l_ind > 5000 THEN
         CALL log0030_mensagem("Limite de linhas da grade ultrapassou!","excl")
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   FREE cq_le_oper
   
   LET m_qtd_linha = l_ind - 1

   CALL _ADVPL_set_property(m_browse,"ITEM_COUNT", m_qtd_linha)

END FUNCTION

#--------------------------#
FUNCTION pol1301_modifica()#
#--------------------------#
   
   LET m_checa_linha = TRUE

   IF m_ies_proces THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Lote já processado!")
      RETURN FALSE
   END IF
   
   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", 
          "Informe a qtd a apontar, refugar e sucaterar.")   
          
   CALL _ADVPL_set_property(m_browse,"EDITABLE",TRUE)
   CALL _ADVPL_set_property(m_browse,"SELECT_ITEM",1,14)

END FUNCTION

#----------------------------#
FUNCTION pol1301_boas_valid()#
#----------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_ordem[l_lin_atu].qtd_boas IS NULL OR
           ma_ordem[l_lin_atu].qtd_boas < 0 THEN
         LET ma_ordem[l_lin_atu].qtd_boas = 0
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_refugo_valid()#
#------------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_ordem[l_lin_atu].qtd_refugo IS NULL OR
           ma_ordem[l_lin_atu].qtd_refugo < 0 THEN
         LET ma_ordem[l_lin_atu].qtd_refugo = 0
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_sucata_valid()#
#------------------------------#
   
   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_ordem[l_lin_atu].qtd_sucata IS NULL OR
           ma_ordem[l_lin_atu].qtd_sucata < 0 THEN
         LET ma_ordem[l_lin_atu].qtd_sucata = 0
      END IF
      IF ma_ordem[l_lin_atu].qtd_sucata = 0 THEN
         LET ma_ordem[l_lin_atu].item_sucata = ''
         LET ma_ordem[l_lin_atu].motivo = ''
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_item_valid()#
#----------------------------#

   DEFINE l_lin_atu       SMALLINT
   
   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")

   IF l_lin_atu > 0 THEN
      IF ma_ordem[l_lin_atu].qtd_sucata = 0 THEN
         LET ma_ordem[l_lin_atu].item_sucata = ''
      ELSE
         IF ma_ordem[l_lin_atu].item_sucata IS NULL OR
               ma_ordem[l_lin_atu].item_sucata = ' ' THEN
            LET m_msg = 'Informe o item sucata.'
            CALL log0030_mensagem(m_msg,'excl')
            RETURN FALSE
         ELSE
            IF NOT pol1301_le_item(ma_ordem[l_lin_atu].item_sucata) THEN
               LET m_msg = 'Item sucata não existe.'
               CALL log0030_mensagem(m_msg,'excl')
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1301_le_item(l_cod_item)#
#-----------------------------------#
   
   DEFINE l_cod_item       LIKE item.cod_item

   SELECT den_item
     INTO m_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_cod_item
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
            
#-----------------------------#
FUNCTION pol1301_checa_linha()#
#-----------------------------#
   
   DEFINE l_lin_atu       SMALLINT,
          l_tot_apo       DECIMAL(10,3)
   
   IF NOT m_checa_linha THEN
      RETURN TRUE
   END IF       

   LET l_lin_atu = _ADVPL_get_property(m_browse,"ROW_SELECTED")
   
   IF l_lin_atu > 0 THEN

      IF ma_ordem[l_lin_atu].qtd_sucata = 0 THEN
         LET ma_ordem[l_lin_atu].item_sucata = ''
         LET ma_ordem[l_lin_atu].motivo = ''
      ELSE
         IF ma_ordem[l_lin_atu].item_sucata IS NULL OR
             ma_ordem[l_lin_atu].item_sucata = ' ' THEN
            LET m_msg = 'Informe o item sucata.'
            CALL log0030_mensagem(m_msg,'excl')
            RETURN FALSE
         END IF
      END IF
   
      LET l_tot_apo = ma_ordem[l_lin_atu].qtd_boas +
            ma_ordem[l_lin_atu].qtd_refugo + ma_ordem[l_lin_atu].qtd_sucata
            
      IF l_tot_apo > ma_ordem[l_lin_atu].qtd_saldo THEN
         LET m_msg = ' Quantidade total informada\n',
                     'supera o saldo da operação.'
         CALL log0030_mensagem(m_msg,'excl')
         RETURN FALSE
      END IF      

   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_canc_mod()#
#--------------------------#

   CALL pol1301_le_operacao() RETURNING p_status
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", 
          "Operação cancelada.")   
   
   LET m_checa_linha = FALSE
   LET m_ies_mod = FALSE
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_conf_mod()#
#--------------------------#
    
   LET m_count = _ADVPL_get_property(m_browse,"ITEM_COUNT")
   LET m_msg = NULL
   
   IF NOT pol1301_checa_linha() THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
    
   FOR m_ind = 1 TO m_count
       IF NOT pol1301_gra_modifi() THEN
          CALL log085_transacao("ROLLBACK")
          LET m_msg = 'Modificação cancelada.'
          EXIT FOR
       END IF
   END FOR
    
   IF m_msg IS NULL THEN
      CALL log085_transacao("COMMIT")
      LET m_msg = 'Sua modificação foi salva em um lote\n',
                  'e poderá ser utilizada no futuro.'
      CALL log0030_mensagem(m_msg,'info')
   END IF
    
   CALL _ADVPL_set_property(m_browse,"EDITABLE",FALSE)

   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg)
   
   LET m_checa_linha = FALSE
   LET m_ies_mod = TRUE
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1301_gra_modifi()#
#----------------------------#
   
   IF ma_ordem[m_ind].qtd_sucata = 0 THEN
      LET ma_ordem[m_ind].item_sucata = ''
      LET ma_ordem[m_ind].motivo = ''
   END IF
   
   UPDATE pol1301_1054
      SET qtd_boas = ma_ordem[m_ind].qtd_boas,
          qtd_refugo = ma_ordem[m_ind].qtd_refugo,
          qtd_sucata = ma_ordem[m_ind].qtd_sucata,
          item_sucata = ma_ordem[m_ind].item_sucata,
          motivo = ma_ordem[m_ind].motivo
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
      AND cod_status = 'P'
      AND num_ordem = ma_ordem[m_ind].num_ordem
      AND cod_operac = ma_ordem[m_ind].cod_operac
      AND num_seq_operac = ma_ordem[m_ind].num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','pol1301_1054')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1301_processar()#
#---------------------------#

   DEFINE l_qtd_info       LIKE ord_oper.qtd_boas
      
   IF m_ies_proces THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",
             "Lote já processado!")
      RETURN FALSE
   END IF
   
   LET l_qtd_info = 0
   
   FOR m_ind = 1 TO m_qtd_linha
       SELECT (qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata)
         INTO m_saldo
         FROM ord_oper
        WHERE cod_empresa = p_cod_empresa
          AND num_ordem = ma_ordem[m_ind].num_ordem
          AND cod_operac = ma_ordem[m_ind].cod_operac
          AND num_seq_operac =  ma_ordem[m_ind].num_seq_operac
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('SELECT','ord_oper')
          RETURN FALSE
       END IF
       
       LET m_qtd_apont = ma_ordem[m_ind].qtd_boas + 
              ma_ordem[m_ind].qtd_refugo + ma_ordem[m_ind].qtd_sucata
       
       IF m_qtd_apont > m_saldo THEN
          LET m_msg = 'Ordem: ', ma_ordem[m_ind].num_ordem,'\n',
                      'Operação: ', ma_ordem[m_ind].cod_operac,'\n',
                      'Sequência: ', ma_ordem[m_ind].num_seq_operac,'\n\n',
                      'SEM SALDO PARA APONTAR\n AS QUANTIDADES INFORMADAS.\n\n',
                      'Deseja manter e modificar o lote ?'
          
          IF LOG_question(m_msg) THEN
             LET m_msg = 'Clique em Modificar e altere a ordem ', ma_ordem[m_ind].num_ordem
             CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg)
             RETURN FALSE
          END IF

       END IF

       LET l_qtd_info = l_qtd_info + m_qtd_apont
       
   END FOR
   
   IF l_qtd_info = 0 THEN
      LET m_msg = 'Você precisa informar as quantidades\n',
                  'de pelomenos uma ordem/operação.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF

   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   LET m_dat_processo = CURRENT

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO m_dat_fecha_ult_man,
          m_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_estoque')
      RETURN FALSE
   END IF

   IF m_dat_fecha_ult_man IS NOT NULL THEN
      IF m_dat_atu <= m_dat_fecha_ult_man THEN
         LET m_msg = 'A MANUFATURA JA ESTA FECHADA'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   END IF

   IF m_dat_fecha_ult_sup IS NOT NULL THEN
      IF m_dat_atu < m_dat_fecha_ult_sup THEN
         LET m_msg = 'O ESTOQUE JA ESTA FECHADO'
         CALL log0030_mensagem(m_msg,'info')
         RETURN FALSE
      END IF
   END IF

   IF NOT LOG_question("Confirma o apontamento das\n quantidades informadas?") THEN
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT","Operação cancelada.")
      RETURN FALSE
   END IF
   
   LET p_status = TRUE
   
   CALL LOG_progresspopup_start("Apontando ordens...","pol1301_apontar","PROCESS")

   IF NOT p_status THEN 
      LET m_msg = 'Operação cancelada.'
   ELSE
      LET m_ies_proces = TRUE
      LET m_msg = 'Operação efetuada com sucesso.'
   END IF

   CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT",m_msg)

   RETURN p_status

END FUNCTION

#-------------------------#
FUNCTION pol1301_apontar()#
#-------------------------#
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1301_prepara_apo() THEN
      CALL log085_transacao("ROLLBACK")
      LET p_status = FALSE
      RETURN
   END IF   
   
   IF NOT pol1301_processa_apo() THEN
      #CALL pol1301_carrega_erros()
      CALL log085_transacao("ROLLBACK")
      LET p_status = FALSE
      #IF m_index > 1 THEN
      #   CALL pol1301_exibe_erros()
      #END IF
   ELSE
      CALL log085_transacao("COMMIT")
      LET p_status = TRUE
   END IF
            
END FUNCTION

#-----------------------------#
FUNCTION pol1301_prepara_apo()#
#-----------------------------#

   INITIALIZE p_man TO NULL

   IF NOT pol1301_le_operacoes() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_del_erro() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_ins_processo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_ins_tab_apo() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#------------------------------#
FUNCTION pol1301_le_operacoes()#
#------------------------------#

   SELECT cod_estoque_sp,
          cod_estoque_rp,
          cod_estoque_rn
     INTO p_cod_oper_sp,
          p_cod_oper_rp,
          p_cod_oper_sucata
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_del_erro()#
#--------------------------#

   DELETE FROM apont_erro_pol1301

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','apont_erro_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_ins_processo()#
#------------------------------#

   DEFINE l_processo   RECORD LIKE processo_apont_pol1301.*

   LET l_processo.cod_empresa    = p_cod_empresa
   LET l_processo.num_processo   = 0
   LET l_processo.usuario        = p_user
   LET l_processo.dat_processo   = TODAY
   LET l_processo.hor_processo   = TIME
   LET l_processo.cod_status     = 'A'   
      
   INSERT INTO processo_apont_pol1301(
      cod_empresa,  
      #num_processo,
      usuario,      
      dat_processo, 
      cod_status)
     VALUES(
      l_processo.cod_empresa,  
      #l_processo.num_processo,
      l_processo.usuario,      
      l_processo.dat_processo, 
      l_processo.cod_status)
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','processo_apont_pol1301')
      RETURN FALSE
   END IF       
   
   LET m_num_processo = SQLCA.SQLERRD[2]
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_ins_tab_apo()#
#-----------------------------#
                           
   DECLARE cq_aponta CURSOR WITH HOLD FOR
    SELECT num_ordem,
           cod_item,           
           cod_operac,    
           cod_cent_trab, 
           ies_oper_final,
           num_seq_operac,
           qtd_planejada, 
           qtd_boas,      
           qtd_refugo,    
           qtd_sucata,    
           num_pedido,
           item_sucata               
      FROM pol1301_1054
     WHERE cod_empresa = p_cod_empresa
       AND usuario = p_user
       AND cod_status = 'P'
       AND (qtd_boas + qtd_refugo + qtd_sucata) > 0
     ORDER BY num_ordem DESC, num_seq_operac ASC

   FOREACH cq_aponta INTO 
           p_man.num_ordem,
           p_man.cod_item,
           p_man.cod_operac,    
           p_man.cod_cent_trab, 
           p_man.oper_final,
           p_man.num_seq_operac,
           m_qtd_planejada, 
           p_man.qtd_boas,
           p_man.qtd_refugo,
           p_man.qtd_sucata,
           p_man.num_pedido,
           p_man.cod_sucata
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pol1301_1054')
         RETURN FALSE
      END IF                                           
           
      LET m_msg = 'Preparando para apontar a OP ', p_man.num_ordem 
      CALL _ADVPL_set_property(m_bar_aponta,"ERROR_TEXT", m_msg) 

      IF NOT pol1301_coleta_dados() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_man_apont() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION
                                       
#-------------------------------#
FUNCTION pol1301_coleta_dados()
#-------------------------------#

   DEFINE l_ies_recur      SMALLINT,
          l_tem_oper_final SMALLINT,
          l_ctr_lote       CHAR(01),
          l_hor_ini        CHAR(08),
          l_ies_apont      CHAR(01)

   LET p_man.cod_empresa = p_cod_empresa
   LET p_man.tip_movto = 'N'
   LET p_man.num_processo = m_num_processo
   
   SELECT cod_local_prod,
          num_lote
     INTO p_man.cod_local,
          p_man.num_lote
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordens')
      RETURN FALSE
   END IF
   
   SELECT ies_apontamento
     INTO l_ies_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man')
      RETURN FALSE
   END IF

   IF l_ies_apont = '2' THEN
      LET p_man.cod_operac = '     '
      LET p_man.num_seq_operac = NULL
      LET p_man.cod_cent_trab = '     '
      LET p_man.cod_arranjo = '     '
      LET p_man.cod_cent_cust = 0
      LET p_man.qtd_hor = 0
      LET p_man.oper_final = 'S'
      LET p_man.cod_recur = '     '
      LET p_man.dat_inicial = TODAY
      LET p_man.hor_inicial = TIME
      LET p_man.dat_final = p_man.dat_inicial
      LET p_man.hor_final = p_man.hor_inicial

      CALL pol1301_calcula_turno(p_man.hor_inicial[1,2])
      
      RETURN TRUE
   END IF

   SELECT cod_arranjo,
          cod_cent_cust,
          qtd_horas
     INTO p_man.cod_arranjo,
          p_man.cod_cent_cust,
          p_man.qtd_hor
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
      AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper')
      RETURN FALSE
   END IF
            
   LET l_ies_recur = FALSE
      
   DECLARE cq_recurso CURSOR FOR
    SELECT a.cod_recur
      FROM rec_arranjo a,
           recurso b
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.cod_arranjo   = p_man.cod_arranjo
       AND b.cod_empresa   = a.cod_empresa
       AND b.cod_recur     = a.cod_recur
       AND b.ies_tip_recur = '2'
       
   FOREACH cq_recurso INTO p_man.cod_recur

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_recurso')
         RETURN FALSE
      END IF
         
      LET l_ies_recur = TRUE
         
   END FOREACH

   IF NOT l_ies_recur THEN
      LET p_man.cod_recur = ' '
   END IF
   
   LET m_tot_apont = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata   
   LET p_man.qtd_hor = p_man.qtd_hor * m_tot_apont

   IF NOT pol1301_calc_data_hora() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE   

END FUNCTION

#-------------------------------#
FUNCTION pol1301_calc_data_hora()
#-------------------------------#

   DEFINE p_hi             CHAR(02),
          p_mi             CHAR(02),
          p_si             CHAR(02),
          p_hf             INTEGER,
          p_mf             INTEGER,
          p_sf             INTEGER,
          p_dat_ini        CHAR(10),
          p_hor_ini        CHAR(8),
          p_hor_fim        CHAR(8),
          p_segundo_ini    INTEGER,
          p_segundo_fim    INTEGER,
          p_tmp_producao   INTEGER,
          p_dat_fim        DATE,
          p_dat_hor        CHAR(19),
          p_num_seq_ant    SMALLINT
          
   LET p_tmp_producao = p_man.qtd_hor * 3600
   
      LET p_dat_ini = TODAY
      LET p_hor_ini = TIME
      LET p_dat_fim = TODAY
   
   LET p_man.dat_inicial = p_dat_ini
   LET p_man.hor_inicial = p_hor_ini
   
   LET p_hi = p_hor_ini[1,2]
   
   CALL pol1301_calcula_turno(p_hi)
   
   LET p_mi = p_hor_ini[4,5]
   LET p_si = p_hor_ini[7,8]
   LET p_segundo_ini = (p_hi * 3600)+(p_mi * 60)+(p_si)
   LET p_segundo_fim = p_segundo_ini + p_tmp_producao

   LET p_hf = p_segundo_fim / 3600
   LET p_segundo_fim = p_segundo_fim - p_hf * 3600
   LET p_mf = p_segundo_fim / 60
   LET p_sf = p_segundo_fim - p_mf * 60


   WHILE p_hf > 23
      LET p_hf = p_hf - 24
      LET p_dat_fim = p_dat_fim + 1
   END WHILE   
      
   LET p_hi = p_hf USING '&&'
   LET p_mi = p_mf USING '&&'
   LET p_si = p_sf USING '&&'
   LET p_hor_fim = p_hi,':',p_mi,':',p_si

   LET p_man.dat_final = p_dat_fim
   LET p_man.hor_final = p_hor_fim

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1301_calcula_turno(p_hi)
#-----------------------------------#

   DEFINE p_hi SMALLINT
   
   IF p_hi >= 6 AND p_hi < 14 THEN
      LET p_man.cod_turno = 1
   ELSE
      IF p_hi >= 14 AND p_hi < 22 THEN
         LET p_man.cod_turno = 2
      ELSE
         LET p_man.cod_turno = 3
      END IF
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol1301_ins_man_apont()#
#-------------------------------#
                 
   LET p_man.nom_prog = 'POL1301'
   LET p_man.nom_usuario = p_user
   LET p_man.cod_status = 'I'
   LET p_man.dat_atualiz = TODAY
   LET p_man.num_seq_apont = 0
   LET p_man.integr_min = 'N'
   LET p_man.matricula = mr_parametro.cod_profis CLIPPED
   LET p_man.num_processo = m_num_processo
   LET p_man.comprimento = 0   
   LET p_man.largura = 0    
   LET p_man.altura = 0    
   LET p_man.diametro = 0     

   INSERT INTO man_apont_pol1301 (
      cod_empresa,   
      #num_seq_apont, 
      num_processo,  
      num_ordem,     
      num_pedido,    
      num_seq_pedido,
      cod_item,      
      num_lote,      
      dat_inicial,   
      dat_final,     
      cod_recur,     
      cod_operac,    
      num_seq_operac,
      oper_final,    
      cod_cent_trab, 
      cod_cent_cust, 
      cod_arranjo,   
      qtd_refugo,    
      qtd_sucata,    
      qtd_boas,      
      comprimento,   
      largura,       
      altura,        
      diametro,      
      tip_movto,     
      cod_local,     
      qtd_hor,       
      matricula,     
      cod_turno,     
      hor_inicial,   
      hor_final,     
      unid_funcional,
      dat_atualiz,   
      ies_terminado, 
      cod_eqpto,     
      cod_ferramenta,
      integr_min,    
      nom_prog,      
      nom_usuario,   
      cod_status,
      cod_sucata)    
    VALUES(
       p_man.cod_empresa,   
       #p_man.num_seq_apont, 
       p_man.num_processo,  
       p_man.num_ordem,     
       p_man.num_pedido,    
       p_man.num_seq_pedido,
       p_man.cod_item,      
       p_man.num_lote,      
       p_man.dat_inicial,   
       p_man.dat_final,     
       p_man.cod_recur,     
       p_man.cod_operac,    
       p_man.num_seq_operac,
       p_man.oper_final,    
       p_man.cod_cent_trab, 
       p_man.cod_cent_cust, 
       p_man.cod_arranjo,   
       p_man.qtd_refugo,    
       p_man.qtd_sucata,    
       p_man.qtd_boas,      
       p_man.comprimento,   
       p_man.largura,       
       p_man.altura,        
       p_man.diametro,      
       p_man.tip_movto,     
       p_man.cod_local,     
       p_man.qtd_hor,       
       p_man.matricula,     
       p_man.cod_turno,     
       p_man.hor_inicial,   
       p_man.hor_final,     
       p_man.unid_funcional,
       p_man.dat_atualiz,   
       p_man.ies_terminado, 
       p_man.cod_eqpto,     
       p_man.cod_ferramenta,
       p_man.integr_min,    
       p_man.nom_prog,      
       p_man.nom_usuario,   
       p_man.cod_status,
       p_man.cod_sucata)
          
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','man_apont_pol1301')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#------------------------------#   
FUNCTION pol1301_processa_apo()#
#------------------------------#
   
   IF NOT pol1301_grava_apont() THEN
      RETURN FALSE
   END IF
   
   IF p_criticou THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1301_grava_man() THEN
      RETURN FALSE
   END IF

   IF NOT pol1301_atu_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      

#---------------------------#
FUNCTION pol1301_grava_man()#
#---------------------------#

   UPDATE man_apont_pol1301
      SET cod_status = 'A'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = m_num_processo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizado','man_apont_pol1301')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1301_atu_lote()#
#--------------------------#

   UPDATE pol1301_1054 
      SET cod_status = 'A', 
          num_processo = m_num_processo
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_user
      AND cod_status = 'P'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','pol1301_1054')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION
   
#-----------------------------#
FUNCTION pol1301_grava_apont()#
#-----------------------------#
   
   DECLARE cq_man CURSOR FOR
    SELECT *
      FROM man_apont_pol1301
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = m_num_processo
       AND cod_status   = 'I'
     ORDER BY num_seq_apont

   FOREACH cq_man INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man')
         RETURN FALSE
      END IF                                           

      LET p_criticou = FALSE
   
      IF NOT pol1301_le_roteiros() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_mestre() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_ins_tempo() THEN
         RETURN FALSE
      END IF

      IF p_man.num_seq_operac IS NOT NULL THEN
         IF NOT pol1301_atuali_ord_oper() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol1301_ins_detalhe() THEN
         RETURN FALSE
      END IF

      IF NOT pol1301_gra_tabs_velhas() THEN
         RETURN FALSE 
      END IF
      
      INSERT INTO sequencia_apo_pol1301
       VALUES(p_cod_empresa, m_num_processo, p_man.num_seq_apont,
              p_num_seq_reg, p_seq_reg_mestre)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Insert','sequencia_apo_pol1301')
         RETURN FALSE
      END IF

      IF p_man.oper_final = 'N' THEN
         LET p_man.qtd_boas = 0
      END IF
      
      LET m_qtd_apont = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata
      
      IF m_qtd_apont > 0 THEN
         IF NOT pol1301_move_estoq() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_le_roteiros()
#----------------------------#

   SELECT cod_roteiro,                                 
          num_altern_roteiro,                             
          dat_ini                                         
     INTO p_cod_roteiro,                                  
          p_num_altern_roteiro,                           
          p_dat_inicio                                    
     FROM ordens                                          
    WHERE cod_empresa = p_cod_empresa                     
      AND num_ordem   = p_man.num_ordem                   
                                                         
   IF STATUS <> 0 THEN                                    
      CALL log003_err_sql('Lendo','ordens')               
      RETURN FALSE                                        
   END IF                                                 
                                                       
   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN     
      LET p_dat_inicio = TODAY           
   END IF                                                 

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_ins_mestre()
#----------------------------#
   
   DEFINE p_cod_uni_funcio     LIKE uni_funcional.cod_uni_funcio,
          p_man_apo_mestre     RECORD LIKE man_apo_mestre.*

   LET p_cod_uni_funcio = ''

   DECLARE cq_funcio CURSOR FOR 
		SELECT cod_uni_funcio 
		  FROM uni_funcional 
		 WHERE cod_empresa     = p_cod_empresa
			AND cod_centro_custo = p_man.cod_cent_cust
   
   FOREACH cq_funcio INTO p_cod_uni_funcio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','uni_funcional')
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   LET p_man_apo_mestre.empresa         = p_cod_empresa
   LET p_man_apo_mestre.seq_reg_mestre  = 0
   LET p_man_apo_mestre.sit_apontamento = 'A'
   LET p_man_apo_mestre.tip_moviment    = 'N'
   LET p_man_apo_mestre.data_producao   = p_man.dat_inicial
   LET p_man_apo_mestre.ordem_producao  = p_man.num_ordem
   LET p_man_apo_mestre.item_produzido  = p_man.cod_item
   LET p_man_apo_mestre.secao_requisn   = p_cod_uni_funcio
   LET p_man_apo_mestre.usu_apontamento = p_user
   LET p_man_apo_mestre.data_apontamento= TODAY  
   LET p_man_apo_mestre.hor_apontamento = TIME
   LET p_man_apo_mestre.usuario_estorno = ''
   LET p_man_apo_mestre.data_estorno    = ''
   LET p_man_apo_mestre.hor_estorno     = ''
   LET p_man_apo_mestre.apo_automatico  = 'N'
   LET p_man_apo_mestre.seq_reg_origem  = ''
   LET p_man_apo_mestre.observacao      = ''
   LET p_man_apo_mestre.seq_registro_integracao = ''

   INSERT INTO man_apo_mestre (
      empresa, 
      #seq_reg_mestre,
      sit_apontamento, 
      tip_moviment, 
      data_producao, 
      ordem_producao, 
      item_produzido, 
      secao_requisn, 
      usu_apontamento, 
      data_apontamento, 
      hor_apontamento, 
      usuario_estorno, 
      data_estorno, 
      hor_estorno, 
      apo_automatico, 
      seq_reg_origem, 
      observacao, 
      seq_registro_integracao) 
   VALUES(p_man_apo_mestre.empresa,  
          #p_man_apo_mestre.seq_reg_mestre,       
          p_man_apo_mestre.sit_apontamento, 
          p_man_apo_mestre.tip_moviment,    
          p_man_apo_mestre.data_producao,   
          p_man_apo_mestre.ordem_producao,  
          p_man_apo_mestre.item_produzido,  
          p_man_apo_mestre.secao_requisn,   
          p_man_apo_mestre.usu_apontamento, 
          p_man_apo_mestre.data_apontamento,
          p_man_apo_mestre.hor_apontamento, 
          p_man_apo_mestre.usuario_estorno, 
          p_man_apo_mestre.data_estorno,    
          p_man_apo_mestre.hor_estorno,     
          p_man_apo_mestre.apo_automatico,  
          p_man_apo_mestre.seq_reg_origem,  
          p_man_apo_mestre.observacao,      
          p_man_apo_mestre.seq_registro_integracao)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_mestre')
      RETURN FALSE
   END IF

   LET p_seq_reg_mestre = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_ins_tempo()
#--------------------------#

   DEFINE p_man_tempo_producao RECORD LIKE man_tempo_producao.*

   LET p_man_tempo_producao.empresa            = p_cod_empresa
   LET p_man_tempo_producao.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_tempo_producao.seq_registro_tempo = 0
   LET p_man_tempo_producao.turno_producao     = p_man.cod_turno
   LET p_man_tempo_producao.data_ini_producao  = p_man.dat_inicial
   LET p_man_tempo_producao.hor_ini_producao   = p_man.hor_inicial[1,5]
   LET p_man_tempo_producao.dat_final_producao = p_man.dat_final
   LET p_man_tempo_producao.hor_final_producao = p_man.hor_final[1,5]
   LET p_man_tempo_producao.periodo_produtivo  = 'A' # Tipo A=produção Tipo I=parada
   LET p_man_tempo_producao.tempo_tot_producao = p_man.qtd_hor 
   LET p_man_tempo_producao.tmp_ativo_producao = p_man.qtd_hor #descontar tempo de paradas, se houver
   LET p_man_tempo_producao.tmp_inatv_producao = 0 # tempo da parada, se for tipo I
      
   INSERT INTO man_tempo_producao(
      empresa,           
      seq_reg_mestre,    
      #seq_registro_tempo,
      turno_producao,    
      data_ini_producao, 
      hor_ini_producao,  
      dat_final_producao,
      hor_final_producao,
      periodo_produtivo, 
      tempo_tot_producao,
      tmp_ativo_producao,
      tmp_inatv_producao)
   VALUES(p_man_tempo_producao.empresa,           
          p_man_tempo_producao.seq_reg_mestre,    
          #p_man_tempo_producao.seq_registro_tempo,
          p_man_tempo_producao.turno_producao,    
          p_man_tempo_producao.data_ini_producao, 
          p_man_tempo_producao.hor_ini_producao,  
          p_man_tempo_producao.dat_final_producao,
          p_man_tempo_producao.hor_final_producao,
          p_man_tempo_producao.periodo_produtivo, 
          p_man_tempo_producao.tempo_tot_producao,
          p_man_tempo_producao.tmp_ativo_producao,
          p_man_tempo_producao.tmp_inatv_producao)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_tempo_producao')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1301_atuali_ord_oper()
#---------------------------------#
   
   DEFINE p_qtd_sdo_op     LIKE ord_oper.qtd_planejada,
          p_qtd_sdo_opa    LIKE ord_oper.qtd_planejada,
          l_dat_iniio      LIKE ord_oper.dat_inicio,
          l_seq_ant        INTEGER
   
   SELECT dat_inicio
     INTO l_dat_iniio
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_oper:dat_inicio')
      RETURN FALSE
   END IF
   
   IF l_dat_iniio IS NULL OR l_dat_iniio = ' ' THEN
      LET l_dat_iniio = p_dat_inicio
   END IF
   
   UPDATE ord_oper
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refugo = qtd_refugo + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_inicio = p_dat_inicio
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ord_oper:qtds')
      RETURN FALSE
   END IF
   
   IF p_man.qtd_refugo > 0 OR p_man.qtd_sucata > 0 THEN
      UPDATE ord_oper
         SET qtd_planejada = qtd_planejada - (p_man.qtd_refugo + p_man.qtd_sucata)
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND num_seq_operac > p_man.num_seq_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ord_oper:qtd.planejada')
         RETURN FALSE
      END IF
   END IF
   
   SELECT (qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata)
     INTO p_qtd_sdo_op 
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper:saldo')
      RETURN FALSE
   END IF
   
   IF p_qtd_sdo_op IS NULL THEN
      LET p_qtd_sdo_op = 0
   END IF
   
   IF p_qtd_sdo_op <= 0 THEN
      UPDATE ord_oper
         SET ies_apontamento = 'F'
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND cod_operac     = p_man.cod_operac
    	   AND num_seq_operac = p_man.num_seq_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','ord_oper:ies_apontamento')
         RETURN FALSE
      END IF
   END IF

   IF p_man.num_seq_operac > 1 THEN
      LET l_seq_ant = p_man.num_seq_operac - 1
      SELECT (qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata)
        INTO p_qtd_sdo_opa 
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND num_seq_operac = l_seq_ant
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ord_oper:seq.anterior')
         RETURN FALSE
      END IF
      IF p_qtd_sdo_opa IS NULL THEN
         LET p_qtd_sdo_opa = 0
      END IF
      IF p_qtd_sdo_opa > p_qtd_sdo_op THEN
         LET p_msg = 'Ordem.....: ', p_man.num_ordem USING '<<<<<<<<<','\n',
                     'Operação..: ', p_man.cod_operac CLIPPED,'\n',
                     'Seq operac: ', p_man.num_seq_operac USING '<<<','\n\n',
                     'A operação anterior não possui\n',
                     'apontamentos sufucientes.'
         CALL log0030_mensagem(p_msg, 'info')
         RETURN FALSE  
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1301_ins_detalhe()
#----------------------------#
   
   DEFINE p_man_apo_detalhe     RECORD LIKE man_apo_detalhe.*

   SELECT cod_unid_prod 
     INTO p_cod_unid_prod
     FROM cent_trabalho
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_trab = p_man.cod_cent_trab

   IF STATUS <> 0 THEN
      LET p_cod_unid_prod = '     '
   END IF

   LET p_man_apo_detalhe.empresa            = p_cod_empresa
   LET p_man_apo_detalhe.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_apo_detalhe.roteiro_fabr       = p_cod_roteiro
   LET p_man_apo_detalhe.altern_roteiro     = p_num_altern_roteiro
   LET p_man_apo_detalhe.sequencia_operacao = p_man.num_seq_operac
   LET p_man_apo_detalhe.operacao           = p_man.cod_operac
   LET p_man_apo_detalhe.unid_produtiva     = p_cod_unid_prod
   LET p_man_apo_detalhe.centro_trabalho    = p_man.cod_cent_trab
   LET p_man_apo_detalhe.arranjo_fisico     = p_man.cod_arranjo
   LET p_man_apo_detalhe.centro_custo       = p_man.cod_cent_cust
   LET p_man_apo_detalhe.atualiza_eqpto_min = 'N'
   LET p_man_apo_detalhe.eqpto              = p_man.cod_eqpto
   LET p_man_apo_detalhe.atlz_ferr_min      = 'N'
   LET p_man_apo_detalhe.ferramental        = '0' #pol1301_le_ferramenta()
   LET p_man_apo_detalhe.operador           = p_man.matricula
   LET p_man_apo_detalhe.observacao         = ''
   LET p_man_apo_detalhe.nome_programa      = p_man.nom_prog

  INSERT INTO man_apo_detalhe (
     empresa, 
     seq_reg_mestre, 
     roteiro_fabr, 
     altern_roteiro, 
     sequencia_operacao, 
     operacao, 
     unid_produtiva, 
     centro_trabalho, 
     arranjo_fisico, 
     centro_custo, 
     atualiza_eqpto_min, 
     eqpto, 
     atlz_ferr_min, 
     ferramental, 
     operador, 
     observacao,
     nome_programa)
  VALUES(p_man_apo_detalhe.empresa,           
         p_man_apo_detalhe.seq_reg_mestre,    
         p_man_apo_detalhe.roteiro_fabr,      
         p_man_apo_detalhe.altern_roteiro,    
         p_man_apo_detalhe.sequencia_operacao,
         p_man_apo_detalhe.operacao,          
         p_man_apo_detalhe.unid_produtiva,    
         p_man_apo_detalhe.centro_trabalho,   
         p_man_apo_detalhe.arranjo_fisico,    
         p_man_apo_detalhe.centro_custo,      
         p_man_apo_detalhe.atualiza_eqpto_min,
         p_man_apo_detalhe.eqpto,             
         p_man_apo_detalhe.atlz_ferr_min,     
         p_man_apo_detalhe.ferramental,       
         p_man_apo_detalhe.operador,    
         p_man_apo_detalhe.observacao,    
         p_man_apo_detalhe.nome_programa)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_detalhe')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1301_le_ferramenta()
#-------------------------------#

   DEFINE p_cod_ferramenta CHAR(15),
          p_seq_processo   INTEGER

   LET p_cod_ferramenta = NULL

   DECLARE cq_consumo CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa             = p_cod_empresa
      AND item                = p_man.cod_item
      AND roteiro             = p_cod_roteiro
      AND roteiro_alternativo = p_num_altern_roteiro
      AND operacao            = p_man.cod_operac
      AND seq_operacao        = p_man.num_seq_operac
   
   FOREACH cq_consumo INTO p_seq_processo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo')
         EXIT FOREACH
      END IF

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = p_seq_processo

      FOREACH cq_fer INTO p_cod_ferramenta
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','man_ferramenta_processo')
            EXIT FOREACH
         END IF
         
         EXIT FOREACH
         
      END FOREACH

   END FOREACH 
   
   IF p_cod_ferramenta IS NULL THEN
      LET p_cod_ferramenta = '0'
   END IF
   
   RETURN (p_cod_ferramenta) 
   
END FUNCTION

#---------------------------------#
FUNCTION pol1301_gra_tabs_velhas()
#---------------------------------#

   DEFINE p_apo_oper           RECORD LIKE apo_oper.*,
          p_cfp_aptm           RECORD LIKE cfp_aptm.*,
          p_cfp_apms           RECORD LIKE cfp_apms.*,
          p_cfp_appr           RECORD LIKE cfp_appr.*
  
  DEFINE l_qtd_apont           DECIMAL(10,3)
  
  LET p_apo_oper.cod_empresa     = p_cod_empresa
  LET p_apo_oper.dat_producao    = p_man.dat_inicial
  LET p_apo_oper.cod_item        = p_man.cod_item
  LET p_apo_oper.num_ordem       = p_man.num_ordem
  
  IF p_man.num_seq_operac IS NULL THEN
     LET p_apo_oper.num_seq_operac  = 0
  ELSE
     LET p_apo_oper.num_seq_operac  = p_man.num_seq_operac
  END IF
  
  LET p_apo_oper.cod_operac      = p_man.cod_operac
  LET p_apo_oper.cod_cent_trab   = p_man.cod_cent_trab
  LET p_apo_oper.cod_arranjo     = p_man.cod_arranjo
  LET p_apo_oper.cod_cent_cust   = p_man.cod_cent_cust
  LET p_apo_oper.cod_turno       = p_man.cod_turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial[1,5]
  LET p_apo_oper.hor_fim         = p_man.hor_final[1,5]
  LET p_apo_oper.qtd_boas        = p_man.qtd_boas
  LET p_apo_oper.qtd_refugo      = p_man.qtd_refugo
  LET p_apo_oper.qtd_sucata      = p_man.qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.cod_local
  LET p_apo_oper.cod_tip_movto   = p_man.tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = CURRENT YEAR TO SECOND
  LET p_apo_oper.nom_usuario     = p_user
  LET p_apo_oper.num_processo    = 0

  INSERT INTO apo_oper(
     cod_empresa,
     dat_producao,
     cod_item,
     num_ordem,
     num_seq_operac,
     cod_operac,
     cod_cent_trab,
     cod_arranjo,
     cod_cent_cust,
     cod_turno,
     hor_inicio,
     hor_fim,
     qtd_boas,
     qtd_refugo,
     qtd_sucata,
     cod_tip_movto,
     num_conta,
     cod_local,
     qtd_horas,
     dat_apontamento,
     nom_usuario)
     #num_processo)
     
   VALUES(
     p_apo_oper.cod_empresa,
     p_apo_oper.dat_producao,
     p_apo_oper.cod_item,
     p_apo_oper.num_ordem,
     p_apo_oper.num_seq_operac,
     p_apo_oper.cod_operac,
     p_apo_oper.cod_cent_trab,
     p_apo_oper.cod_arranjo,
     p_apo_oper.cod_cent_cust,
     p_apo_oper.cod_turno,
     p_apo_oper.hor_inicio,
     p_apo_oper.hor_fim,
     p_apo_oper.qtd_boas,
     p_apo_oper.qtd_refugo,
     p_apo_oper.qtd_sucata,
     p_apo_oper.cod_tip_movto,
     p_apo_oper.num_conta,
     p_apo_oper.cod_local,
     p_apo_oper.qtd_horas,
     p_apo_oper.dat_apontamento,
     p_apo_oper.nom_usuario)
     #p_apo_oper.num_processo)

 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','apo_oper')
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2] # apo_oper.num_processo

  LET p_cfp_apms.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_apms.num_seq_registro = p_num_seq_reg
  LET p_cfp_apms.cod_tip_movto    = p_apo_oper.cod_tip_movto

  IF p_man.tip_movto  = "E" THEN
    LET p_cfp_apms.ies_situa    = "C"
  ELSE
    LET p_cfp_apms.ies_situa    = "A"
  END IF

  LET p_cfp_apms.dat_producao   = p_apo_oper.dat_producao
  LET p_cfp_apms.num_ordem      = p_apo_oper.num_ordem
  
  IF p_man.cod_eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.cod_eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.cod_ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.cod_ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET  p_cfp_apms.cod_cent_trab     = p_apo_oper.cod_cent_trab
  LET p_cfp_apms.cod_unid_prod      = p_cod_unid_prod
  LET p_cfp_apms.cod_roteiro        = p_cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_num_altern_roteiro
  LET p_cfp_apms.num_seq_operac     = p_man.num_seq_operac
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = p_apo_oper.num_conta
  LET p_cfp_apms.cod_local          = p_apo_oper.cod_local
  LET p_cfp_apms.dat_apontamento    = EXTEND(p_apo_oper.dat_apontamento, YEAR TO DAY)
  LET p_cfp_apms.hor_apontamento    = EXTEND(p_apo_oper.dat_apontamento, HOUR TO SECOND)
  LET p_cfp_apms.nom_usuario_resp   = p_user
  LET p_cfp_apms.tex_apont          = NULL

  IF p_man.tip_movto = "E"  THEN
    LET p_cfp_apms.dat_estorno     = TODAY
    LET p_cfp_apms.hor_estorno     = TIME
    LET p_cfp_apms.nom_usu_estorno = p_user
  ELSE
    LET p_cfp_apms.dat_estorno     = NULL
    LET p_cfp_apms.hor_estorno     = NULL
    LET p_cfp_apms.nom_usu_estorno = NULL
  END IF

  INSERT INTO cfp_apms VALUES(p_cfp_apms.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_apms')
      RETURN FALSE
   END IF

  LET l_qtd_apont = p_apo_oper.qtd_boas + p_apo_oper.qtd_refugo + p_apo_oper.qtd_sucata

  LET p_cfp_appr.cod_empresa        = p_apo_oper.cod_empresa
  LET p_cfp_appr.num_seq_registro   = p_num_seq_reg
  LET p_cfp_appr.dat_producao       = p_apo_oper.dat_producao
  LET p_cfp_appr.cod_item           = p_apo_oper.cod_item
  LET p_cfp_appr.cod_turno          = p_apo_oper.cod_turno
  LET p_cfp_appr.qtd_produzidas     = l_qtd_apont
  LET p_cfp_appr.qtd_pecas_boas     = p_apo_oper.qtd_boas
  LET p_cfp_appr.qtd_sucata         = p_apo_oper.qtd_refugo + p_apo_oper.qtd_sucata
  LET p_cfp_appr.qtd_defeito_real   = 0
  LET p_cfp_appr.qtd_defeito_padrao = 0
  LET p_cfp_appr.qtd_ciclos         = 0
  LET p_cfp_appr.num_operador       = p_man.matricula

  INSERT INTO cfp_appr VALUES(p_cfp_appr.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_appr')
      RETURN FALSE
   END IF

  LET p_cfp_aptm.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_aptm.num_seq_registro = p_num_seq_reg
  LET p_cfp_aptm.dat_producao     = p_apo_oper.dat_producao
  LET p_cfp_aptm.cod_turno        = p_apo_oper.cod_turno
  LET p_cfp_aptm.ies_periodo      = "A"
  LET p_cfp_aptm.cod_parada       = NULL

  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_fim
  LET p_cfp_aptm.hor_fim_periodo = p_dat_char
  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_inicio
  LET p_cfp_aptm.hor_ini_periodo = p_dat_char

  LET p_cfp_aptm.hor_ini_assumido = p_cfp_aptm.hor_ini_periodo
  LET p_cfp_aptm.hor_fim_assumido = p_cfp_aptm.hor_fim_periodo
  LET p_cfp_aptm.hor_tot_periodo  = p_man.qtd_hor 
  LET p_cfp_aptm.hor_tot_assumido = p_cfp_aptm.hor_tot_periodo

  INSERT INTO cfp_aptm VALUES(p_cfp_aptm.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_aptm')
      RETURN FALSE
   END IF
   
   INSERT INTO man_relc_tabela
    VALUES(p_cod_empresa,
           p_seq_reg_mestre,
           p_num_seq_reg,
           "B")

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_relc_tabela')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1301_material()#
#--------------------------#

   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa,
           cod_item_pai,
           pct_refug
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.num_ordem

   FOREACH cq_compon INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_baixa,
           p_num_neces,
           p_pct_refug

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_compon')
         RETURN FALSE
      END IF  
      
      IF NOT pol1301_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' OR 
         p_ies_ctr_estoque = 'N'  OR
         p_sofre_baixa = 'N'  THEN
         CONTINUE FOREACH
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_prod
         
      IF p_qtd_baixar > 0 THEN
         IF NOT pol1301_baixa_neces() THEN
            RETURN FALSE
         END IF
         IF NOT pol1301_baixa_compon() THEN
            RETURN FALSE
         END IF
      END IF
     
      IF p_qtd_baixar < 0 THEN
            
         LET p_qtd_sucata = p_qtd_baixar * (-1)
         
         IF NOT pol1301_aponta_sucata() THEN
            RETURN FALSE
         END IF
         
         IF NOT pol1301_baixa_neces() THEN
            RETURN FALSE
         END IF

      END IF
            
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_baixa_neces()
#-----------------------------#

   UPDATE necessidades
      SET qtd_saida = qtd_saida + p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_neces   = p_num_neces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','necessidades')
      RETURN FALSE
   END IF     

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1301_baixa_compon()#
#------------------------------#   
   
   DEFINE p_qtd_reservada   DECIMAL(10,3), 
          p_qtd_saldo       DECIMAL(10,3),
          p_baixa_do_lote   DECIMAL(10,3),
          p_sdo_lote        DECIMAL(10,3)

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
   
   IF p_ies_ctr_lote = 'S' THEN
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_cod_compon
          AND cod_local = p_cod_local_baixa
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND num_lote IS NOT NULL
          AND num_lote <> ' '
        ORDER BY dat_hor_producao     
   ELSE
      DECLARE cq_fifo CURSOR FOR
       SELECT *
         FROM estoque_lote_ender
        WHERE cod_empresa = p_cod_empresa
          AND cod_item = p_cod_compon
          AND cod_local = p_cod_local_baixa
          AND ies_situa_qtd = 'L'
          AND qtd_saldo > 0
          AND (num_lote IS NULL OR num_lote = ' ')
        ORDER BY dat_hor_producao     
   END IF
         
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote_ender')
         RETURN FALSE
      END IF
      
      IF p_ies_ctr_lote = 'S' THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND num_lote = p_estoque_lote_ender.num_lote
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reservada 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_estoque_lote_ender.cod_item
            AND cod_local= p_estoque_lote_ender.cod_local
            AND (num_lote IS NULL OR num_lote = ' ')
      END IF
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','estoque_lote_ender')
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
      
      LET p_qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada
      
      IF p_qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_qtd_saldo < p_qtd_baixar THEN
         LET p_baixa_do_lote = p_qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_qtd_saldo
      ELSE
         LET p_baixa_do_lote = p_qtd_baixar
         LET p_qtd_baixar = 0
      END IF
                 
      LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
      LET p_item.cod_item      = p_estoque_lote_ender.cod_item
      LET p_item.cod_local     = p_estoque_lote_ender.cod_local
      LET p_item.num_lote      = p_estoque_lote_ender.num_lote
      LET p_item.comprimento   = p_estoque_lote_ender.comprimento
      LET p_item.largura       = p_estoque_lote_ender.largura    
      LET p_item.altura        = p_estoque_lote_ender.altura     
      LET p_item.diametro      = p_estoque_lote_ender.diametro   
      LET p_item.cod_operacao  = p_cod_oper_sp
      LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
      LET p_item.qtd_movto     = p_baixa_do_lote      
      LET p_item.dat_movto     = TODAY
      LET p_item.ies_tip_movto = p_ies_tip_movto
      LET p_item.dat_proces    = TODAY
      LET p_item.hor_operac    = TIME
      LET p_item.num_prog      = p_man.nom_prog
      LET p_item.num_docum     = p_man.num_ordem
      LET p_item.num_seq       = 0
      LET p_item.tip_operacao  = 'S' #Saída
      LET p_item.usuario       = p_man.nom_usuario
      LET p_item.cod_turno     = p_man.cod_turno
      LET p_item.trans_origem  = 0
      LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
      IF NOT estoque_insere_movto(p_item) THEN
         LET m_msg = 'Problemas baixando material:\n', p_msg CLIPPED
         CALL log0030_mensagem(m_msg,'Info')
         RETURN FALSE
      END IF
      
      LET p_tip_operac = 'S'
      LET p_qtd_prod = p_baixa_do_lote
      LET p_transac_apont = p_num_trans_atual
      
      IF NOT pol1301_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

      IF NOT pol1301_man_consumo() THEN            
         RETURN FALSE                                        
      END IF                                 
      
      IF NOT pol1301_insere_trans_apont() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      LET p_msg = 'Ordem.....: ', p_man.num_ordem USING '<<<<<<<<<','\n',
                  'Componente: ', p_cod_compon CLIPPED,'\n',
                  'Local.....: ', p_cod_local_baixa CLIPPED,'\n\n',
                  'Sem estoque para baixar.'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE  
   END IF
   
   LET p_qtd_baixar = 0
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1301_le_item_man()
#-----------------------------#

   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.ies_tip_item,
          b.ies_sofre_baixa
     INTO p_cod_local_estoq,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tip_item,
          p_sofre_baixa          
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_compon
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ITEM/ITEM_MAN')  
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1301_move_estoq()
#----------------------------#
      
   UPDATE ordens
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refug  = qtd_refug + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_ini    = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordens')
      RETURN FALSE
   END IF
   
   LET p_ies_tip_movto = 'N'
   LET p_tip_operac = 'E'                                  
   
   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_prod = p_man.qtd_boas
      LET p_tip_producao = 'B'
      LET p_ies_situa = 'L'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_refugo > 0 THEN
      LET p_qtd_prod = p_man.qtd_refugo
      LET p_tip_producao = 'R'
      LET p_ies_situa = 'R'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_sucata > 0 THEN
      LET p_man.cod_item = p_man.cod_sucata
      LET p_qtd_prod = p_man.qtd_sucata
      LET p_tip_producao = 'B'
      LET p_ies_situa = 'L'
      IF NOT pol1301_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1301_aponta_estoque()
#--------------------------------#

   IF NOT pol1301_le_info_item(p_man.cod_item) THEN
      RETURN FALSE
   END IF
      
   IF p_ies_ctr_lote = 'S' THEN
      IF p_man.num_lote IS NULL OR p_man.num_lote = ' ' THEN
         LET p_man.num_lote = p_man.num_ordem
      END IF
   ELSE
      LET p_man.num_lote = NULL    
   END IF

   IF p_ies_ctr_estoque = 'S' THEN
      
      IF NOT pol1301_movta_estoque() THEN
         RETURN FALSE
      END IF
      IF NOT pol1301_item_produzido() THEN                  
         RETURN FALSE                                        
      END IF                                                 
                                                          
      IF NOT pol1301_chf_componente() THEN            
         RETURN FALSE                                        
      END IF                                                 

   END IF
   
   IF NOT pol1301_material() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1301_le_info_item(p_cod)#
#-----------------------------------#
   
   DEFINE p_cod  char(15)
   
   SELECT cod_local_estoq,
          cod_local_insp,
          ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao
     INTO p_cod_local_estoq,
          p_cod_local_insp,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tem_inspecao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:fli')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1301_movta_estoque()#
#-------------------------------#
 
   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
   END RECORD
      
   LET p_cod_tip_apon = 'A'
      
   LET p_item.cod_empresa   = p_man.cod_empresa
   LET p_item.cod_item      = p_man.cod_item
   LET p_item.cod_local     = p_cod_local_estoq
   LET p_item.num_lote      = p_man.num_lote
   LET p_item.comprimento   = p_man.comprimento
   LET p_item.largura       = p_man.largura    
   LET p_item.altura        = p_man.altura     
   LET p_item.diametro      = p_man.diametro  
    
   LET p_item.cod_operacao  = p_cod_oper_rp
   
   LET p_item.ies_situa     = p_ies_situa
   LET p_item.qtd_movto     = p_qtd_prod
   LET p_item.dat_movto     = TODAY
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = TODAY
   LET p_item.hor_operac    = TIME
   LET p_item.num_prog      = p_man.nom_prog
   LET p_item.num_docum     = p_man.num_ordem
   LET p_item.num_seq       = 0
   
   LET p_item.tip_operacao  = 'E' #Entrada
   
   LET p_item.usuario       = p_man.nom_usuario
   LET p_item.cod_turno     = p_man.cod_turno
   LET p_item.trans_origem  = 0
   LET p_item.ies_ctr_lote  = p_ies_ctr_lote
   
   IF NOT estoque_insere_movto(p_item) THEN
         LET m_msg = 'Problemas apontando estoque:\n', p_msg CLIPPED
         CALL log0030_mensagem(m_msg,'Info')
      RETURN FALSE
   END IF
   
   LET p_transac_apont = p_num_trans_atual
   LET p_transac_pai = p_num_trans_atual

   IF NOT pol1301_insere_trans_apont() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1301_insere_trans_apont()
#-----------------------------------#
       
  INSERT INTO trans_apont_pol1301 
     VALUES(p_cod_empresa, 
            m_num_processo,
            p_transac_apont, 
            p_man.num_seq_apont,
            p_tip_operac)
            
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','trans_apont_pol1301')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1301_item_produzido()#
#--------------------------------#
   
   DEFINE p_man_item_produzido       RECORD LIKE  man_item_produzido.*
   
   LET p_man_item_produzido.empresa               = p_man.cod_empresa
   LET p_man_item_produzido.seq_reg_mestre        = p_seq_reg_mestre
   LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   LET p_man_item_produzido.tip_movto             = 'N'
   LET p_man_item_produzido.item_produzido        = p_estoque_lote_ender.cod_item
   LET p_man_item_produzido.lote_produzido        = p_estoque_lote_ender.num_lote
   LET p_man_item_produzido.grade_1               = p_estoque_lote_ender.cod_grade_1
   LET p_man_item_produzido.grade_2               = p_estoque_lote_ender.cod_grade_2
   LET p_man_item_produzido.grade_3               = p_estoque_lote_ender.cod_grade_3
   LET p_man_item_produzido.grade_4               = p_estoque_lote_ender.cod_grade_4
   LET p_man_item_produzido.grade_5               = p_estoque_lote_ender.cod_grade_5
   LET p_man_item_produzido.num_peca              = p_estoque_lote_ender.num_peca
   LET p_man_item_produzido.serie                 = p_estoque_lote_ender.num_serie
   LET p_man_item_produzido.volume                = p_estoque_lote_ender.num_volume
   LET p_man_item_produzido.comprimento           = p_estoque_lote_ender.comprimento
   LET p_man_item_produzido.largura               = p_estoque_lote_ender.largura
   LET p_man_item_produzido.altura                = p_estoque_lote_ender.altura
   LET p_man_item_produzido.diametro              = p_estoque_lote_ender.diametro
   LET p_man_item_produzido.local                 = p_estoque_lote_ender.cod_local
   LET p_man_item_produzido.endereco              = p_estoque_lote_ender.endereco
   LET p_man_item_produzido.tip_producao          = p_tip_producao
   LET p_man_item_produzido.qtd_produzida         = p_qtd_prod
   LET p_man_item_produzido.qtd_convertida        = 0
   LET p_man_item_produzido.sit_est_producao      = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_item_produzido.data_producao         = p_estoque_lote_ender.dat_hor_producao
   LET p_man_item_produzido.data_valid            = p_estoque_lote_ender.dat_hor_validade
   LET p_man_item_produzido.conta_ctbl            = ''
   LET p_man_item_produzido.moviment_estoque      = p_transac_pai
   LET p_man_item_produzido.seq_reg_normal        = ''
   LET p_man_item_produzido.observacao            = p_estoque_lote_ender.tex_reservado
   LET p_man_item_produzido.identificacao_estoque = ' '
      
  INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
     #seq_registro_item,    
     tip_movto,            
     item_produzido,       
     lote_produzido,       
     grade_1,              
     grade_2,              
     grade_3,              
     grade_4,              
     grade_5,              
     num_peca,             
     serie,                
     volume,               
     comprimento,          
     largura,              
     altura,               
     diametro,             
     local,                
     endereco,             
     tip_producao,         
     qtd_produzida,        
     qtd_convertida,       
     sit_est_producao,     
     data_producao,        
     data_valid,           
     conta_ctbl,           
     moviment_estoque,     
     seq_reg_normal,       
     observacao,           
     identificacao_estoque)
   VALUES(
     p_man_item_produzido.empresa,              
     p_man_item_produzido.seq_reg_mestre,       
     #p_man_item_produzido.seq_registro_item,    
     p_man_item_produzido.tip_movto,            
     p_man_item_produzido.item_produzido,       
     p_man_item_produzido.lote_produzido,       
     p_man_item_produzido.grade_1,              
     p_man_item_produzido.grade_2,              
     p_man_item_produzido.grade_3,              
     p_man_item_produzido.grade_4,              
     p_man_item_produzido.grade_5,              
     p_man_item_produzido.num_peca,             
     p_man_item_produzido.serie,                
     p_man_item_produzido.volume,               
     p_man_item_produzido.comprimento,          
     p_man_item_produzido.largura,              
     p_man_item_produzido.altura,               
     p_man_item_produzido.diametro,             
     p_man_item_produzido.local,                
     p_man_item_produzido.endereco,             
     p_man_item_produzido.tip_producao,         
     p_man_item_produzido.qtd_produzida,        
     p_man_item_produzido.qtd_convertida,       
     p_man_item_produzido.sit_est_producao,     
     p_man_item_produzido.data_producao,        
     p_man_item_produzido.data_valid,           
     p_man_item_produzido.conta_ctbl,           
     p_man_item_produzido.moviment_estoque,     
     p_man_item_produzido.seq_reg_normal,       
     p_man_item_produzido.observacao,           
     p_man_item_produzido.identificacao_estoque)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','man_item_produzido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1301_chf_componente()#
#--------------------------------#
  
  DEFINE p_chf_compon    RECORD LIKE chf_componente.*
  
  LET p_chf_compon.empresa            = p_estoque_lote_ender.cod_empresa
  LET p_chf_compon.sequencia_registro = p_num_seq_reg
  LET p_chf_compon.tip_movto          = p_tip_operac
  LET p_chf_compon.item_componente    = p_estoque_lote_ender.cod_item
  LET p_chf_compon.qtd_movto          = p_qtd_prod
  LET p_chf_compon.local_estocagem    = p_estoque_lote_ender.cod_local
  LET p_chf_compon.endereco           = p_estoque_lote_ender.endereco
  LET p_chf_compon.num_volume         = p_estoque_lote_ender.num_volume
  LET p_chf_compon.grade_1            = p_estoque_lote_ender.cod_grade_1
  LET p_chf_compon.grade_2            = p_estoque_lote_ender.cod_grade_2
  LET p_chf_compon.grade_3            = p_estoque_lote_ender.cod_grade_3
  LET p_chf_compon.grade_4            = p_estoque_lote_ender.cod_grade_4
  LET p_chf_compon.grade_5            = p_estoque_lote_ender.cod_grade_5
  LET p_chf_compon.pedido_venda       = p_estoque_lote_ender.num_ped_ven
  LET p_chf_compon.seq_pedido_venda   = p_estoque_lote_ender.num_seq_ped_ven
  LET p_chf_compon.sit_qtd_item       = p_estoque_lote_ender.ies_situa_qtd
  LET p_chf_compon.peca               = p_estoque_lote_ender.num_peca
  LET p_chf_compon.serie_componente   = p_estoque_lote_ender.num_serie
  LET p_chf_compon.comprimento        = p_estoque_lote_ender.comprimento
  LET p_chf_compon.largura            = p_estoque_lote_ender.largura
  LET p_chf_compon.altura             = p_estoque_lote_ender.altura
  LET p_chf_compon.diametro           = p_estoque_lote_ender.diametro
  LET p_chf_compon.lote               = p_estoque_lote_ender.num_lote
  LET p_chf_compon.dat_hor_producao   = p_estoque_lote_ender.dat_hor_producao
  LET p_chf_compon.dat_hor_validade   = p_estoque_lote_ender.dat_hor_validade
  
  if p_tip_operac = 'S' then
     LET p_chf_compon.reservado = p_tip_producao
  else
     LET p_chf_compon.reservado = null
  end if
  
  INSERT INTO chf_componente VALUES(p_chf_compon.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','chf_componente')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1301_man_consumo()#
#-----------------------------#
   
   DEFINE p_man_comp_consumido   RECORD LIKE man_comp_consumido.*
   
   LET p_man_comp_consumido.empresa            = p_estoque_lote_ender.cod_empresa
   LET p_man_comp_consumido.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_comp_consumido.seq_registro_item  = 0
   LET p_man_comp_consumido.tip_movto          = p_ies_tip_movto
   LET p_man_comp_consumido.item_componente    = p_estoque_lote_ender.cod_item
   LET p_man_comp_consumido.grade_1            = p_estoque_lote_ender.cod_grade_1  
   LET p_man_comp_consumido.grade_2            = p_estoque_lote_ender.cod_grade_2  
   LET p_man_comp_consumido.grade_3            = p_estoque_lote_ender.cod_grade_3  
   LET p_man_comp_consumido.grade_4            = p_estoque_lote_ender.cod_grade_4  
   LET p_man_comp_consumido.grade_5            = p_estoque_lote_ender.cod_grade_5  
   LET p_man_comp_consumido.num_peca           = p_estoque_lote_ender.num_peca     
   LET p_man_comp_consumido.serie              = p_estoque_lote_ender.num_serie    
   LET p_man_comp_consumido.volume             = p_estoque_lote_ender.num_volume   
   LET p_man_comp_consumido.comprimento        = p_estoque_lote_ender.comprimento  
   LET p_man_comp_consumido.largura            = p_estoque_lote_ender.largura      
   LET p_man_comp_consumido.altura             = p_estoque_lote_ender.altura       
   LET p_man_comp_consumido.diametro           = p_estoque_lote_ender.diametro     
   LET p_man_comp_consumido.lote_componente    = p_estoque_lote_ender.num_lote    
   LET p_man_comp_consumido.local_estoque      = p_estoque_lote_ender.cod_local     
   LET p_man_comp_consumido.endereco           = p_estoque_lote_ender.endereco
   LET p_man_comp_consumido.qtd_baixa_prevista = p_qtd_prod                       
   LET p_man_comp_consumido.qtd_baixa_real     = p_qtd_prod                        
   LET p_man_comp_consumido.sit_est_componente = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_comp_consumido.data_producao      = p_estoque_lote_ender.dat_hor_producao
   LET p_man_comp_consumido.data_valid         = p_estoque_lote_ender.dat_hor_validade
   LET p_man_comp_consumido.conta_ctbl         = ' '
   LET p_man_comp_consumido.moviment_estoque   = p_transac_apont
   LET p_man_comp_consumido.mov_estoque_pai    = p_transac_pai
   LET p_man_comp_consumido.seq_reg_normal     = ''
   LET p_man_comp_consumido.observacao         = p_tip_producao
   LET p_man_comp_consumido.identificacao_estoque = ''
   LET p_man_comp_consumido.depositante        = ''
   
   INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
     #seq_registro_item, 
     tip_movto,         
     item_componente,   
     grade_1,           
     grade_2,           
     grade_3,           
     grade_4,           
     grade_5,           
     num_peca,          
     serie,             
     volume,            
     comprimento,       
     largura,           
     altura,            
     diametro,          
     lote_componente,   
     local_estoque,     
     endereco,          
     qtd_baixa_prevista,
     qtd_baixa_real,    
     sit_est_componente,
     data_producao,     
     data_valid,        
     conta_ctbl,        
     moviment_estoque,  
     mov_estoque_pai,   
     seq_reg_normal,    
     observacao,        
     identificacao_estoque,
     depositante)
   VALUES (
     p_man_comp_consumido.empresa,                   
     p_man_comp_consumido.seq_reg_mestre,    
     #p_man_comp_consumido.seq_registro_item, 
     p_man_comp_consumido.tip_movto,         
     p_man_comp_consumido.item_componente,   
     p_man_comp_consumido.grade_1,           
     p_man_comp_consumido.grade_2,           
     p_man_comp_consumido.grade_3,           
     p_man_comp_consumido.grade_4,           
     p_man_comp_consumido.grade_5,           
     p_man_comp_consumido.num_peca,         
     p_man_comp_consumido.serie,             
     p_man_comp_consumido.volume,            
     p_man_comp_consumido.comprimento,       
     p_man_comp_consumido.largura,           
     p_man_comp_consumido.altura,            
     p_man_comp_consumido.diametro,          
     p_man_comp_consumido.lote_componente,   
     p_man_comp_consumido.local_estoque,     
     p_man_comp_consumido.endereco,          
     p_man_comp_consumido.qtd_baixa_prevista,
     p_man_comp_consumido.qtd_baixa_real,    
     p_man_comp_consumido.sit_est_componente,
     p_man_comp_consumido.data_producao,     
     p_man_comp_consumido.data_valid,        
     p_man_comp_consumido.conta_ctbl,        
     p_man_comp_consumido.moviment_estoque,  
     p_man_comp_consumido.mov_estoque_pai,   
     p_man_comp_consumido.seq_reg_normal,    
     p_man_comp_consumido.observacao,        
     p_man_comp_consumido.identificacao_estoque,
     p_man_comp_consumido.depositante)     
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','man_comp_consumido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION















#------------------------------------#
FUNCTION estoque_insere_movto(p_item)#
#------------------------------------#

#---parâmetros recebidos com visibilidade local

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01)
  END RECORD

   LET p_msg = ''
      
   LET p_movto.* = p_item.*

   CASE p_movto.tip_operacao
      WHEN 'E' #entrada
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'E'
            IF NOT estoque_grava_entrada() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'S'
            IF NOT estoque_reverte_entrada() THEN
               RETURN FALSE
            END IF
         END IF
      WHEN 'S' #saida
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'S'
            IF NOT estoque_grava_saida() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'E'
            IF NOT estoque_reverte_saida() THEN
               RETURN FALSE
            END IF
         END IF

   END CASE

   IF NOT estoque_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_atu_estoque()#
#-----------------------------#

   DEFINE p_qtd_liberada       DECIMAL(10,3),
          p_qtd_lib_excep      DECIMAL(10,3),
          p_qtd_rejeitada      DECIMAL(10,3),
          p_qtd_impedida       DECIMAL(10,3)

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_liberada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'L' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_liberada IS NULL THEN
      LET p_qtd_liberada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_lib_excep
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'E' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO EXCEPCIONAL DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_lib_excep IS NULL THEN
      LET p_qtd_lib_excep = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_rejeitada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'R' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO REJEITADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_rejeitada IS NULL THEN
      LET p_qtd_rejeitada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_impedida
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'I' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO IMPEDIDO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_impedida IS NULL THEN
      LET p_qtd_impedida = 0
   END IF
   
   UPDATE estoque
      SET qtd_liberada = p_qtd_liberada,
          qtd_lib_excep = p_qtd_lib_excep,
          qtd_rejeitada = p_qtd_rejeitada,
          qtd_impedida  = p_qtd_impedida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
     
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO SALDO DA TABELA ESTOQUE'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_grava_entrada()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION estoque_gra_lote()#
#--------------------------#

   CALL estoque_le_lote()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT estoque_atu_lote(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION estoque_le_lote()#
#-------------------------#
      
   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF   

END FUNCTION

#--------------------------#
FUNCTION estoque_ins_lote()#
#--------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_movto.cod_empresa,
                 p_movto.cod_item,
                 p_movto.cod_local,
                 p_movto.num_lote,
                 p_movto.ies_situa,
                 p_movto.qtd_movto)
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------------#
FUNCTION estoque_atu_lote(p_qtd_movto)#
#-------------------------------------#
   
   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)

   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)
      
      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------#
FUNCTION estoque_gra_lot_ender()#
#-------------------------------#
      
   CALL estoque_le_lot_ender()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         LET p_num_transac = p_estoque_lote_ender.num_transac
         IF NOT estoque_atu_lote_ender(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION estoque_le_lot_ender()#
#------------------------------#

   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION estoque_ins_lote_ender()#
#--------------------------------#

   CALL estoque_carrega_campos() 

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)
              
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_carrega_campos()
#-------------------------------#
   
   INITIALIZE p_estoque_lote_ender TO NULL
   
   LET p_estoque_lote_ender.cod_empresa        = p_movto.cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_movto.cod_item 
	 LET p_estoque_lote_ender.cod_local          = p_movto.cod_local
	 LET p_estoque_lote_ender.num_lote           = p_movto.num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_movto.ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_movto.qtd_movto
   LET p_estoque_lote_ender.largura            = p_movto.largura
   LET p_estoque_lote_ender.altura             = p_movto.altura
   LET p_estoque_lote_ender.diametro           = p_movto.diametro
   LET p_estoque_lote_ender.comprimento        = p_movto.comprimento
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION
         
#-------------------------------------------#
FUNCTION estoque_atu_lote_ender(p_qtd_movto)#
#-------------------------------------------#

   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)
   
   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)

      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE_ENDER SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-----------------------------#         
FUNCTION estoque_gra_estoque()#
#-----------------------------#
   
   DEFINE p_qtd_estoq      DECIMAL(10,3)
   DEFINE p_estoque record LIKE estoque.*
   
   SELECT *
     INTO p_estoque.*
     FROM estoque
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS = 100 THEN
      INITIALIZE p_estoque.* TO NULL
      LET p_estoque.cod_empresa = p_movto.cod_empresa
      LET p_estoque.cod_item = p_movto.cod_item
      LET p_estoque.qtd_liberada  = 0
      LET p_estoque.qtd_impedida  = 0
      LET p_estoque.qtd_rejeitada = 0
      LET p_estoque.qtd_lib_excep = 0
      LET p_estoque.qtd_disp_venda = 0
      LET p_estoque.qtd_reservada = 0
      
      INSERT INTO estoque
       VALUES(p_estoque.*)
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE.'  
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA ESTOQUE.'  
         RETURN FALSE
      END IF   
   END IF
   
   IF p_ies_estoque = 'S' THEN
      LET p_estoque.dat_ult_saida = p_movto.dat_movto
   ELSE
      LET p_estoque.dat_ult_entrada = p_movto.dat_movto
   END IF
         
   UPDATE estoque
      SET dat_ult_entrada = p_estoque.dat_ult_entrada,
          dat_ult_saida   = p_estoque.dat_ult_saida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE.'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_gra_estoq_trans()#
#---------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01),
          p_num_conta       CHAR(20)

   INITIALIZE p_estoque_trans.* TO NULL      
                                                                                       
   SELECT ies_com_detalhe                                                                                     
     INTO p_ies_com_detalhe                                                                                   
     FROM estoque_operac                                                                                      
    WHERE cod_empresa  = p_movto.cod_empresa                                                                        
      AND cod_operacao = p_movto.cod_operacao                                                                       
                                                                                                                 
   IF STATUS <> 0 THEN   
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC - OPER:',p_movto.cod_operacao
      RETURN FALSE                                                                                             
   END IF                                                                                                     
                                                                                                                 
   IF p_ies_com_detalhe = 'S' THEN                                                                            
      IF p_movto.tip_operacao = 'S' THEN        #operação de saida                                                                        
         SELECT num_conta_debito                                                                           
           INTO p_num_conta                                                                                
           FROM estoque_operac_ct                                                                          
          WHERE cod_empresa  = p_movto.cod_empresa                                                               
            AND cod_operacao = p_movto.cod_operacao                                                              
      ELSE                                                                                                    
         SELECT num_conta_credito                                                                             
           INTO p_num_conta                                                                                  
           FROM estoque_operac_ct                                                                             
          WHERE cod_empresa  = p_movto.cod_empresa                                                                  
            AND cod_operacao = p_movto.cod_operacao                                                                 
      END IF                                                                                                  
   ELSE                                                                                                       
      LET p_num_conta = NULL                                                                                  
   END IF                                                                                                     
                                                                                                                 
   IF STATUS <> 0 THEN                                                                                        
     LET p_erro =  STATUS                                                                                     
     LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC_CT - OPER:', p_movto.cod_operacao
     RETURN FALSE                                                                                             
   END IF                                                                                                     

   LET p_estoque_trans.cod_empresa        = p_movto.cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_movto.cod_item
   LET p_estoque_trans.dat_movto          = p_movto.dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_movto.dat_movto
   LET p_estoque_trans.cod_operacao       = p_movto.cod_operacao
   LET p_estoque_trans.num_docum          = p_movto.num_docum
   LET p_estoque_trans.num_seq            = p_movto.num_seq
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto
   LET p_estoque_trans.qtd_movto          = p_movto.qtd_movto
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL

   IF p_movto.tip_operacao = 'S' THEN      #se for uma operação de saída
      LET p_estoque_trans.cod_local_est_orig = p_movto.cod_local
      LET p_estoque_trans.num_lote_orig = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_orig = p_movto.ies_situa
   ELSE
      LET p_estoque_trans.cod_local_est_dest = p_movto.cod_local
      LET p_estoque_trans.num_lote_dest = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_dest = p_movto.ies_situa
   END IF
   
   LET p_estoque_trans.cod_turno   = p_movto.cod_turno
   LET p_estoque_trans.nom_usuario = p_movto.usuario
   LET p_estoque_trans.dat_proces  = p_movto.dat_proces
   LET p_estoque_trans.hor_operac  = p_movto.hor_operac
   LET p_estoque_trans.num_prog    = p_movto.num_prog

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_ins_estoq_trans()#
#---------------------------------#

   INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF

   LET p_num_trans_atual = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION estoque_rev_estoq_trans()#
#---------------------------------#
    
   SELECT * 
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_TRANS'
      RETURN FALSE
   END IF

   LET p_estoque_trans.dat_proces         = p_movto.dat_proces
   LET p_estoque_trans.hor_operac         = p_movto.hor_operac
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_ins_estoque_trans_rev() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION estoque_gra_est_trans_end()#
#-----------------------------------#

 #---para chamar essa rotina é necessário ter lido a estoque_lote_ender previamente---#
   INITIALIZE p_estoque_trans_end.*  TO NULL
 
   LET p_estoque_trans_end.num_transac      = p_num_trans_atual                        
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco               
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1            
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2            
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3            
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4            
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5            
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven            
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven        
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao       
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade       
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca               
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie              
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento            
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura                
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura                 
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro               
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1       
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2       
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3       
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1           
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2           
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3           
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1           
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2           
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3           
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa                 
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item                    
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto                   
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto                   
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao                
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto               
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog                    
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p                                           
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f                                            
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p                                           
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f                                            
   LET p_estoque_trans_end.num_volume       = 0                                           
   LET p_estoque_trans_end.dat_hor_prod_ini = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.dat_hor_prod_fim = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.vlr_temperatura  = 0                                           
   LET p_estoque_trans_end.endereco_origem  = ' '                                         
   LET p_estoque_trans_end.tex_reservado    = ' '                                        
   
   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION estoque_ins_est_trans_end()#
#-----------------------------------#
      
   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO NA TAB ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION estoque_rev_trans_end()#
#-------------------------------#

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   LET p_estoque_trans_end.num_transac = p_num_trans_atual
   LET p_estoque_trans_end.ies_tip_movto = p_movto.ies_tip_movto    

   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION estoque_gra_estoq_auditoria()#
#-------------------------------------#
  
  INSERT INTO estoque_auditoria(
   cod_empresa,
   num_transac,
   nom_usuario,
   dat_hor_proces,
   num_programa)
  VALUES(p_movto.cod_empresa, 
      p_num_trans_atual, 
      p_movto.usuario, 
      p_movto.dat_proces, 
      p_movto.num_prog)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_AUDITORIA'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------------#
FUNCTION estoque_reverte_entrada()#
#---------------------------------#

   CALL estoque_le_lote()

   IF STATUS = 0 THEN
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION estoque_ins_estoque_trans_rev()#
#---------------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_estoque_trans.num_transac,
           p_num_trans_atual)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS_REV'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_grava_saida()#
#-----------------------------#
   
   DEFINE p_qtd_saldo DECIMAL(10,3)
   
   CALL estoque_le_lote()

   IF STATUS = 0 THEN               
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_reverte_saida()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

