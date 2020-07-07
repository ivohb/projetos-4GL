#-----------------------------------------------------------------#
# SISTEMA.: ESPECÍFICO                                            #
# AREA....: ADM. DA PRODUÇÃO                                      #
# PROGRAMA: CICLOS POR PEÇA E PEÇAS POR CICLO (POL0847)           #
# DATA....: 22/05/2013                                            #
#-----------------------------------------------------------------#
{
CREATE TABLE ciclo_peca_970
    (
    cod_empresa      CHAR (2),
    cod_item         CHAR (15),
    qtd_ciclo_peca   INTEGER,
    qtd_peca_ciclo   INTEGER,
    num_seq          DECIMAL(3,0),
    num_sub_seq      DECIMAL(3,0),
    qtd_peca_emb     INTEGER,
    qtd_peca_hor     INTEGER,
    fator_mo         DECIMAL(4,2),
    cod_item_cliente CHAR (30),
    passo            INTEGER,
    qtd_pc_cic_cust  INTEGER,
    pf               DECIMAL(8,0),
    opprox           CHAR (10),
    setatual         CHAR (10),
    setprox          CHAR (10),
    classfunc        CHAR (10),
    qtd_peca_orc     INTEGER,
    dias_validade    INTEGER,
    peso_unit_custo DECIMAL (12,5)
    );

CREATE UNIQUE INDEX ciclo_peca_970
    ON ciclo_peca_970 (cod_empresa, cod_item);

}

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
         p_user          LIKE usuarios.cod_usuario,
         g_tipo_sgbd     CHAR(03)

END GLOBALS

  #Componentes de Tela
  DEFINE m_form                   VARCHAR(10),
         m_container              VARCHAR(10),
         m_status_bar             VARCHAR(10),
         m_menu_bar               VARCHAR(10),
         m_create_button          VARCHAR(10),
         m_update_button          VARCHAR(10),
         m_delete_button          VARCHAR(10),
         m_find_button            VARCHAR(10), 
         m_print_button           VARCHAR(10),
         m_first_button           VARCHAR(10),
         m_previous_button        VARCHAR(10),
         m_next_button            VARCHAR(10),
         m_last_button            VARCHAR(10),
         m_panel                  VARCHAR(10),
         m_field_cod_item         VARCHAR(10),
         m_zoom_cod_item          VARCHAR(10),
         m_field_qtd_ciclo_peca   VARCHAR(10),
	       m_field_qtd_peca_ciclo   VARCHAR(10),  
	       m_field_cust_peca_ciclo   VARCHAR(10), 
	       m_field_num_seq          VARCHAR(10),  
	       m_field_num_sub_seq      VARCHAR(10),  
	       m_field_qtd_peca_emb     VARCHAR(10),  
	       m_field_qtd_peca_hor     VARCHAR(10),  
	       m_field_fator_mo         VARCHAR(10),  
	       m_field_cod_item_cliente VARCHAR(10),  
	       m_field_passo            VARCHAR(10)   
  #Componentes de Tela         
                        
  DEFINE mr_tela, mr_tela_bkp RECORD
      cod_item         CHAR(15),
      den_item         CHAR(76),
	    qtd_ciclo_peca   INTEGER,
	    qtd_peca_ciclo   INTEGER,
	    num_seq          DECIMAL(3,0),
	    num_sub_seq      DECIMAL(3,0),
	    qtd_peca_emb     INTEGER,
	    qtd_peca_hor     INTEGER,
	    fator_mo         DECIMAL(4,2),
	    cod_item_cliente CHAR(30),
	    passo            INTEGER,
	    qtd_pc_cic_cust  INTEGER,
	    #-----Ivo 26/07/2017------#
      pf               DECIMAL(8,0),
      opprox           CHAR(10) ,
      setatual         CHAR(10) ,
      setprox          CHAR(10) ,
      classfunc        CHAR(10), 
	    #-----------------------#
	    qtd_peca_orc     INTEGER,
	    dias_validade    INTEGER,
	    peso_unit_custo  DECIMAL (12,5)
  END RECORD
  
  #-----Ivo 26/07/2017------#
  DEFINE     
    m_pf               CHAR(10),
    m_opprox           CHAR(10) ,
    m_setatual         CHAR(10) ,
    m_setprox          CHAR(10) ,
    m_classfunc        CHAR(10), 
  #--------------------------#
    m_qtd_peca_orc     CHAR(10) ,
    m_dias_validade    CHAR(10) ,
    m_peso_unit_custo  CHAR(10)
  
  #Variáveis da consulta
  DEFINE m_order_by            CHAR(500),
         m_where_clause        CHAR(500)
  
  DEFINE m_event_update        SMALLINT,
         m_pesq_ativa          SMALLINT,
         m_last_row            SMALLINT
  
#-------------------#
 FUNCTION itb00009()
#-------------------#
  DEFINE l_status SMALLINT
  
  CALL fgl_setenv("ADVPL","1")
  CALL LOG_connectDatabase("DEFAULT")

  CALL log001_acessa_usuario("MANUFAT","LOGERP")
  RETURNING l_status, p_cod_empresa, p_user

  IF NOT l_status THEN
    CALL itb00009_cria_janela()
    IF m_container IS NULL OR m_container = " " THEN 
       CALL itb00009_ativa_janela()
    END IF    
  END IF

END FUNCTION

#-------------------------------#
 FUNCTION itb00009_cria_janela()
#-------------------------------#
  DEFINE l_space VARCHAR(10)
         
  IF m_container IS NULL OR m_container = ' ' THEN 
     LET m_form = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(m_form,"TITLE","Ciclos por Peça e Peças por Ciclo")
  ELSE
     LET m_form = _ADVPL_create_component(NULL,"LPANEL", m_container)  
  END IF                              
  
  CALL _ADVPL_set_property(m_form,"SIZE",800,600)
  
  IF m_container IS NULL OR m_container = ' ' THEN  
     LET m_status_bar = _ADVPL_create_component(NULL,"LSTATUSBAR",m_form)
  END IF   

  LET m_menu_bar = _ADVPL_create_component(NULL,"LMENUBAR",m_form)

  LET m_create_button = _ADVPL_create_component(NULL,"LCREATEBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_create_button,"EVENT","itb00009_event_create")
  CALL _ADVPL_set_property(m_create_button,"CONFIRM_EVENT","itb00009_confirm_event_create")
  CALL _ADVPL_set_property(m_create_button,"CANCEL_EVENT","itb00009_cancel_event_create")
  
  LET m_update_button = _ADVPL_create_component(NULL,"LUPDATEBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_update_button,"EVENT","itb00009_event_update")
  CALL _ADVPL_set_property(m_update_button,"CONFIRM_EVENT","itb00009_confirm_event_update")
  CALL _ADVPL_set_property(m_update_button,"CANCEL_EVENT","itb00009_cancel_event_update")
  
  LET m_delete_button = _ADVPL_create_component(NULL,"LDELETEBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_delete_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_delete_button,"EVENT","itb00009_event_delete")
 
  LET m_find_button = _ADVPL_create_component(NULL,"LFINDBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_find_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_find_button,"EVENT","itb00009_event_find")
  
  LET m_first_button = _ADVPL_create_component(NULL,"LFIRSTBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_first_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_first_button,"EVENT","itb00009_event_first")

  LET m_previous_button = _ADVPL_create_component(NULL,"LPREVIOUSBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_previous_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_previous_button,"EVENT","itb00009_event_previous")

  LET m_next_button = _ADVPL_create_component(NULL,"LNEXTBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_next_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_next_button,"EVENT","itb00009_event_next")

  LET m_last_button = _ADVPL_create_component(NULL,"LLASTBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_last_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_last_button,"EVENT","itb00009_event_last")

  LET m_print_button = _ADVPL_create_component(NULL,"LPRINTBUTTON",m_menu_bar)
  CALL _ADVPL_set_property(m_print_button,"TYPE","NO_CONFIRM")
  CALL _ADVPL_set_property(m_print_button,"EVENT","itb00009_event_print")
  
  CALL _ADVPL_create_component(NULL,"LQUITBUTTON",m_menu_bar)
  
  LET m_panel = _ADVPL_create_component(NULL,"LPANEL",m_form)
  CALL _ADVPL_set_property(m_panel,"ALIGN","CENTER")
  
  LET l_space = _ADVPL_create_component(NULL,"LPANEL",m_form)
  CALL _ADVPL_set_property(l_space,"ALIGN","TOP")
  CALL _ADVPL_set_property(l_space,"HEIGHT",3)
  
  CALL itb00009_cria_componentes()
  
  CALL itb00009_inicializa_campos()
  CALL itb00009_habilita_campos(FALSE)  
  
  LET m_event_update = FALSE

 END FUNCTION
 
#------------------------------------#
 FUNCTION itb00009_cria_componentes()
#------------------------------------#
  DEFINE l_component     VARCHAR(10),
         l_panel_top     VARCHAR(10),
         l_panel_left    VARCHAR(10),
         l_panel_center  VARCHAR(10),
         l_y             SMALLINT
  
  LET l_panel_top = _ADVPL_create_component(NULL,"LTITLEDPANELEX",m_panel)
  CALL _ADVPL_set_property(l_panel_top,"HEIGHT",60)
  CALL _ADVPL_set_property(l_panel_top,"ALIGN","TOP")
    
  LET l_panel_left = _ADVPL_create_component(NULL,"LPANEL",m_panel)
  CALL _ADVPL_set_property(l_panel_left,"WIDTH",7)
  CALL _ADVPL_set_property(l_panel_left,"ALIGN","LEFT")
  
  LET l_panel_center = _ADVPL_create_component(NULL,"LPANEL",m_panel)
  CALL _ADVPL_set_property(l_panel_center,"ALIGN","CENTER")
  
  #ITEM
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_top)
  CALL _ADVPL_set_property(l_component,"TEXT","Item:")
  CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"POSITION",10,8)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
   
  LET m_field_cod_item = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_top)
  CALL _ADVPL_set_property(m_field_cod_item,"VARIABLE",mr_tela,"cod_item")
  CALL _ADVPL_set_property(m_field_cod_item,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_cod_item,"LENGTH",15)                    
  CALL _ADVPL_set_property(m_field_cod_item,"PICTURE","@! XXXXXXXXXXXXXXXX") 
  CALL _ADVPL_set_property(m_field_cod_item,"VALID","itb00009_valid_cod_item")
  CALL _ADVPL_set_property(m_field_cod_item,"POSITION",140,6)  
  
  LET m_zoom_cod_item = _ADVPL_create_component(NULL,"LIMAGEBUTTON",l_panel_top)
  CALL _ADVPL_set_property(m_zoom_cod_item,"IMAGE","BTPESQ")
  CALL _ADVPL_set_property(m_zoom_cod_item,"TOOLTIP","Zoom item")
  CALL _ADVPL_set_property(m_zoom_cod_item,"CLICK_EVENT","itb00009_click_zoom_cod_item")
  CALL _ADVPL_set_property(m_zoom_cod_item,"SIZE",24,20)
  CALL _ADVPL_set_property(m_zoom_cod_item,"POSITION",283,6)
  
  LET l_component = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_top)
  CALL _ADVPL_set_property(l_component,"VARIABLE",mr_tela,"den_item")
  CALL _ADVPL_set_property(l_component,"ENABLE",FALSE)
  CALL _ADVPL_set_property(l_component,"LENGTH",50)
  CALL _ADVPL_set_property(l_component,"POSITION",313,6)
  #--------------
  
  LET l_y = 0
  
  #Ciclos por Peça
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde ciclos por peça:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18)
   
  LET m_field_qtd_ciclo_peca = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"VARIABLE",mr_tela,"qtd_ciclo_peca")
  CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"LENGTH",9,0)                    
  CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"POSITION",160,16)
  
  LET l_y = l_y + 23
  
  #Peças por ciclo
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde de peças por ciclo:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_qtd_peca_ciclo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"VARIABLE",mr_tela,"qtd_peca_ciclo")
  CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"LENGTH",9,0) 
  CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"POSITION",160,16+l_y)
  
  LET l_y = l_y + 23

  #Peças por ciclo
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde de peças no blank:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_cust_peca_ciclo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"VARIABLE",mr_tela,"qtd_pc_cic_cust  ")
  CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"LENGTH",9,0) 
  CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"POSITION",160,16+l_y)
  
  LET l_y = l_y + 23
  
  #Sequência
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Sequência:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_num_seq = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_num_seq,"VARIABLE",mr_tela,"num_seq")
  CALL _ADVPL_set_property(m_field_num_seq,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_num_seq,"LENGTH",3,0) 
  CALL _ADVPL_set_property(m_field_num_seq,"POSITION",160,16+l_y)
  
  LET l_y = l_y + 23
  
  #Sub Sequência
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Sub Sequência:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_num_sub_seq = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_num_sub_seq,"VARIABLE",mr_tela,"num_sub_seq")
  CALL _ADVPL_set_property(m_field_num_sub_seq,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_num_sub_seq,"LENGTH",3,0) 
  CALL _ADVPL_set_property(m_field_num_sub_seq,"POSITION",160,16+l_y)
  
  LET l_y = l_y + 23
  
  #Peças Embalagem
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde pecas por embalagem:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_qtd_peca_emb = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_qtd_peca_emb,"VARIABLE",mr_tela,"qtd_peca_emb")
  CALL _ADVPL_set_property(m_field_qtd_peca_emb,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_qtd_peca_emb,"LENGTH",9,0) 
  CALL _ADVPL_set_property(m_field_qtd_peca_emb,"POSITION",160,16+l_y)
  
  LET l_y = l_y + 23
  
  #Peças Hora Custo
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde de peças do EGA:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_qtd_peca_hor = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_qtd_peca_hor,"VARIABLE",mr_tela,"qtd_peca_hor")
  CALL _ADVPL_set_property(m_field_qtd_peca_hor,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_qtd_peca_hor,"LENGTH",9,0)
  CALL _ADVPL_set_property(m_field_qtd_peca_hor,"POSITION",160,16+l_y) 
  
  LET l_y = l_y + 23
  
  #Fator Mão de Obra
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Fator Mão de Obra:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_fator_mo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_fator_mo,"VARIABLE",mr_tela,"fator_mo")
  CALL _ADVPL_set_property(m_field_fator_mo,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_fator_mo,"LENGTH",4,2) 
  CALL _ADVPL_set_property(m_field_fator_mo,"POSITION",160,16+l_y) 
  
  LET l_y = l_y + 23
  
  #Código Item Cliente
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Código Item Cliente:")
  #CALL _ADVPL_set_property(l_component,"SIZE",130,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_cod_item_cliente = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_cod_item_cliente,"VARIABLE",mr_tela,"cod_item_cliente")
  CALL _ADVPL_set_property(m_field_cod_item_cliente,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_cod_item_cliente,"LENGTH",30) 
  CALL _ADVPL_set_property(m_field_cod_item_cliente,"POSITION",160,16+l_y) 
  
  LET l_y = l_y + 23
  
  #Passo
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Passo:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_field_passo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_field_passo,"VARIABLE",mr_tela,"passo")
  CALL _ADVPL_set_property(m_field_passo,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_field_passo,"LENGTH",9,0) 
  CALL _ADVPL_set_property(m_field_passo,"POSITION",160,16+l_y) 

  LET l_y = l_y + 23
  
  #-----Ivo 26/07/2017------#
  #pf
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Nro PF (Processo Fabrica):")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_pf = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_pf,"VARIABLE",mr_tela,"pf")
  CALL _ADVPL_set_property(m_pf,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_pf,"LENGTH",8,0) 
  CALL _ADVPL_set_property(m_pf,"POSITION",160,16+l_y) 

  LET l_y = l_y + 23
  
  #opprox
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Próxima operação:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_opprox = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_opprox,"VARIABLE",mr_tela,"opprox")
  CALL _ADVPL_set_property(m_opprox,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_opprox,"LENGTH",10,0) 
  CALL _ADVPL_set_property(m_opprox,"POSITION",160,16+l_y) 
   
  LET l_y = l_y + 23
  
  #setatual
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Setor atual:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_setatual = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_setatual,"VARIABLE",mr_tela,"setatual")
  CALL _ADVPL_set_property(m_setatual,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_setatual,"LENGTH",10,0) 
  CALL _ADVPL_set_property(m_setatual,"POSITION",160,16+l_y) 
   
  LET l_y = l_y + 23
  
  #setprox
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Próximo setor:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_setprox = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_setprox,"VARIABLE",mr_tela,"setprox")
  CALL _ADVPL_set_property(m_setprox,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_setprox,"LENGTH",10,0) 
  CALL _ADVPL_set_property(m_setprox,"POSITION",160,16+l_y) 
   
  LET l_y = l_y + 23
  
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Classe funcional:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",10,18+l_y)
   
  LET m_classfunc = _ADVPL_create_component(NULL,"LTEXTFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_classfunc,"VARIABLE",mr_tela,"classfunc")
  CALL _ADVPL_set_property(m_classfunc,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_classfunc,"LENGTH",10,0) 
  CALL _ADVPL_set_property(m_classfunc,"POSITION",160,16+l_y) 

  LET l_y = 0
  
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Qtde de pecas orçadas:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",500,18)
   
  LET m_qtd_peca_orc = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_qtd_peca_orc,"VARIABLE",mr_tela,"qtd_peca_orc")
  CALL _ADVPL_set_property(m_qtd_peca_orc,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_qtd_peca_orc,"LENGTH",10,0) 
  CALL _ADVPL_set_property(m_qtd_peca_orc,"POSITION",632,16) 

  LET l_y = l_y + 23
  
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Dias de validade do item:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",500,18+l_y)
   
  LET m_dias_validade = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_dias_validade,"VARIABLE",mr_tela,"dias_validade")
  CALL _ADVPL_set_property(m_dias_validade,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_dias_validade,"LENGTH",6,0) 
  CALL _ADVPL_set_property(m_dias_validade,"POSITION",632,16+l_y) 

  LET l_y = l_y + 23
  
  LET l_component = _ADVPL_create_component(NULL,"LLABEL",l_panel_center)
  CALL _ADVPL_set_property(l_component,"TEXT","Peso unit custo:")
  #CALL _ADVPL_set_property(l_component,"SIZE",100,15)
  CALL _ADVPL_set_property(l_component,"FONT",NULL,NULL,TRUE,NULL)
  CALL _ADVPL_set_property(l_component,"POSITION",500,18+l_y)

  LET m_peso_unit_custo = _ADVPL_create_component(NULL,"LNUMERICFIELD",l_panel_center)
  CALL _ADVPL_set_property(m_peso_unit_custo,"VARIABLE",mr_tela,"peso_unit_custo")
  CALL _ADVPL_set_property(m_peso_unit_custo,"ENABLE",TRUE)
  CALL _ADVPL_set_property(m_peso_unit_custo,"LENGTH",6,0) 
  CALL _ADVPL_set_property(m_peso_unit_custo,"POSITION",632,16+l_y) 
  
  #----------------------------------------#
  
 END FUNCTION 
 
#--------------------------------# 
 FUNCTION itb00009_ativa_janela()
#--------------------------------# 
  
  CALL _ADVPL_set_property(m_form,"ACTIVATE",TRUE)
  
 END FUNCTION
 
#--------------------------------#
 FUNCTION itb00009_event_create()
#--------------------------------#
  CALL itb00009_inicializa_campos()
  CALL itb00009_habilita_campos(TRUE)  
  CALL _ADVPL_set_property(m_field_cod_item,"FORCE_GET_FOCUS")
  
  RETURN TRUE
  
 END FUNCTION
 
#----------------------------------------#
 FUNCTION itb00009_confirm_event_create()
#----------------------------------------#

  IF NOT itb00009_verifica_preechimento_dados() THEN
     RETURN FALSE
  END IF
    
  WHENEVER ERROR CONTINUE
    INSERT INTO ciclo_peca_970  
               (cod_empresa,      
                cod_item,         
                qtd_ciclo_peca,   
                qtd_peca_ciclo,   
                num_seq,          
                num_sub_seq,     
                qtd_peca_emb,     
                qtd_peca_hor,     
                fator_mo,         
                cod_item_cliente, 
                passo,
                qtd_pc_cic_cust,
                pf,                 #---Ivo 26/07/2017---#
                opprox,   
                setatual, 
                setprox,  
                classfunc,          #--------------------#
                qtd_peca_orc,
                dias_validade,
                peso_unit_custo)

	VALUES (p_cod_empresa,
                mr_tela.cod_item,         
                mr_tela.qtd_ciclo_peca,   
                mr_tela.qtd_peca_ciclo,   
                mr_tela.num_seq,          
                mr_tela.num_sub_seq,      
                mr_tela.qtd_peca_emb,     
                mr_tela.qtd_peca_hor,     
                mr_tela.fator_mo,         
                mr_tela.cod_item_cliente, 
                mr_tela.passo,
                mr_tela.qtd_pc_cic_cust,
                mr_tela.pf,          #---Ivo 26/07/2017---#  
                mr_tela.opprox,   
                mr_tela.setatual, 
                mr_tela.setprox,  
                mr_tela.classfunc,
                mr_tela.qtd_peca_orc,
                mr_tela.dias_validade,
                mr_tela.peso_unit_custo)   #--------------------#
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN  
     CALL log003_err_sql("INSERT","ciclo_peca_970")
     RETURN FALSE
  END IF    
     
  CALL _ADVPL_set_property(m_status_bar,"INFO_TEXT","Inclusão efetuada com sucesso.") 
  CALL itb00009_habilita_campos(FALSE)  
     
  RETURN TRUE
  
 END FUNCTION  

#---------------------------------------#
 FUNCTION itb00009_cancel_event_create()
#---------------------------------------#

  CALL itb00009_inicializa_campos()
  CALL itb00009_habilita_campos(FALSE)  
 
  RETURN TRUE
  
 END FUNCTION   
 
#---------------------------------------------#
 FUNCTION itb00009_habilita_campos(l_habilita)
#---------------------------------------------#
  DEFINE l_habilita SMALLINT
  
  IF m_event_update THEN
     CALL _ADVPL_set_property(m_field_cod_item,"ENABLE",FALSE)
     CALL _ADVPL_set_property(m_zoom_cod_item,"ENABLE",FALSE)
  ELSE
     CALL _ADVPL_set_property(m_field_cod_item,"ENABLE",l_habilita)
     CALL _ADVPL_set_property(m_zoom_cod_item,"ENABLE",l_habilita)
  END IF
  
  CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_num_seq,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_num_sub_seq,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_qtd_peca_emb,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_qtd_peca_hor,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_fator_mo,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_cod_item_cliente,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_field_passo,"ENABLE",l_habilita)

    #-----Ivo 26/07/2017------#
  CALL _ADVPL_set_property(m_pf,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_opprox,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_setatual,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_setprox,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_classfunc,"ENABLE",l_habilita)
    #-------------------------#
  CALL _ADVPL_set_property(m_qtd_peca_orc,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_dias_validade,"ENABLE",l_habilita)
  CALL _ADVPL_set_property(m_peso_unit_custo,"ENABLE",l_habilita)
  
 END FUNCTION 

#------------------------------------#
 FUNCTION itb00009_inicializa_campos()
#------------------------------------#
  DEFINE l_ind SMALLINT
  
  INITIALIZE mr_tela.*, mr_tela_bkp.* TO NULL
 
  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")

 END FUNCTION
 
#----------------------------------------------#
 FUNCTION itb00009_verifica_preechimento_dados()
#----------------------------------------------#
 
  IF mr_tela.cod_item IS NULL 
  OR mr_tela.cod_item = " " THEN
     CALL log0030_mensagem("Código do item deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_cod_item,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.qtd_ciclo_peca IS NULL THEN
     CALL log0030_mensagem("Ciclos por Peça deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_qtd_ciclo_peca,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.qtd_peca_ciclo IS NULL THEN
     CALL log0030_mensagem("Peças por Ciclo deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_qtd_peca_ciclo,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF

  IF mr_tela.qtd_pc_cic_cust  IS NULL THEN
     CALL log0030_mensagem("Qtd pc ciclo cust deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_cust_peca_ciclo,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.num_seq IS NULL THEN
     CALL log0030_mensagem("Sequência deve ser informada.","excl")
     CALL _ADVPL_set_property(m_field_num_seq,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.num_sub_seq IS NULL THEN
     CALL log0030_mensagem("Sub Sequência deve ser informada.","excl")
     CALL _ADVPL_set_property(m_field_num_sub_seq,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.qtd_peca_emb IS NULL THEN
     CALL log0030_mensagem("Peças Embalagem deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_qtd_peca_emb,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.qtd_peca_hor IS NULL THEN
     CALL log0030_mensagem("Peças Hora Custo deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_qtd_peca_hor,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.fator_mo IS NULL THEN
     CALL log0030_mensagem("Fator de Mão de Obra deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_fator_mo,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  IF mr_tela.cod_item_cliente IS NULL 
  OR mr_tela.cod_item_cliente = " " THEN
     CALL log0030_mensagem("Código Item Cliente deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_cod_item_cliente,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF
  
  {IF mr_tela.passo IS NULL THEN
     CALL log0030_mensagem("Passo deve ser informado.","excl")
     CALL _ADVPL_set_property(m_field_passo,"FORCE_GET_FOCUS")
     RETURN FALSE
  END IF}
  
  RETURN TRUE
         
 END FUNCTION 
 
#--------------------------------# 
 FUNCTION itb00009_event_update()
#--------------------------------# 
  IF mr_tela.cod_item IS NULL 
  OR mr_tela.cod_item = " " THEN
     CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Efetue primeiramente a pesquisa.")
     RETURN FALSE
  END IF
  
  LET m_event_update = TRUE
  
  CALL itb00009_habilita_campos(TRUE)  
  CALL _ADVPL_set_property(m_field_cod_item,"FORCE_GET_FOCUS")
  
  RETURN TRUE
  
 END FUNCTION 
 
#----------------------------------------#
 FUNCTION itb00009_confirm_event_update()
#----------------------------------------#
  IF NOT itb00009_verifica_preechimento_dados() THEN
     RETURN FALSE
  END IF
  
  IF itb00009_cursor_for_update() THEN
  
     WHENEVER ERROR CONTINUE
       UPDATE ciclo_peca_970
          SET qtd_ciclo_peca   = mr_tela.qtd_ciclo_peca,  
	      qtd_peca_ciclo   = mr_tela.qtd_peca_ciclo,  
	      num_seq          = mr_tela.num_seq,         
	      num_sub_seq      = mr_tela.num_sub_seq,     
	      qtd_peca_emb     = mr_tela.qtd_peca_emb,    
	      qtd_peca_hor     = mr_tela.qtd_peca_hor,    
	      fator_mo         = mr_tela.fator_mo,        
	      cod_item_cliente = mr_tela.cod_item_cliente,
	      passo            = mr_tela.passo,
	      qtd_pc_cic_cust  = mr_tela.qtd_pc_cic_cust,
        pf               = mr_tela.pf,              #---Ivo 26/07/2017---#      
        opprox           = mr_tela.opprox,      
        setatual         = mr_tela.setatual,    
        setprox          = mr_tela.setprox,       
        classfunc        = mr_tela.classfunc, 	      #--------------------#                
        qtd_peca_orc     = mr_tela.qtd_peca_orc,
        dias_validade    =  mr_tela.dias_validade,
        peso_unit_custo  = mr_tela.peso_unit_custo
        WHERE CURRENT OF cm_ciclo_peca_970
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN  
        CALL log085_transacao("COMMIT")
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("COMMIT","itb00009")
        ELSE
           CALL _ADVPL_set_property(m_status_bar,"INFO_TEXT","Modificação efetuada com sucesso.")
        END IF
     ELSE 
        CALL log003_err_sql("UPDATE","ciclo_peca_970")
        CALL log085_transacao("ROLLBACK")
        IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("COMMIT","itb00009")
        END IF
     END IF
     
     CLOSE cm_ciclo_peca_970
     
  END IF
  
  CALL itb00009_habilita_campos(FALSE)  
  
  LET m_event_update = FALSE
     
  RETURN TRUE
  
 END FUNCTION  
 
#---------------------------------------#
 FUNCTION itb00009_cancel_event_update()
#---------------------------------------#  
  CALL itb00009_habilita_campos(FALSE)  
  
  LET mr_tela.* = mr_tela_bkp.*
  
  LET m_event_update = FALSE
 
  RETURN TRUE
  
 END FUNCTION    
 
#---------------------------------# 
 FUNCTION itb00009_event_delete()
#---------------------------------#

  IF log005_seguranca(p_user,"VDP","itb00009","EX") THEN
  ELSE
     CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Exclusão não permitida.")
     RETURN FALSE
  END IF

  IF mr_tela.cod_item IS NULL THEN
     CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Efetue primeiramente a pesquisa.")
     RETURN FALSE
  END IF
  
  IF LOG_question("Deseja realmente excluir?") THEN
     IF itb00009_cursor_for_update() THEN
     
        WHENEVER ERROR CONTINUE
          DELETE
            FROM ciclo_peca_970
           WHERE CURRENT OF cm_ciclo_peca_970
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN  
           CALL log085_transacao("COMMIT")
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("COMMIT","itb00009")
           ELSE
              CALL itb00009_inicializa_campos()
              CALL _ADVPL_set_property(m_status_bar,"INFO_TEXT","Exclusão efetuada com sucesso.")
           END IF
        ELSE 
           CALL log003_err_sql("DELETE","ciclo_peca_970")
           CALL log085_transacao("ROLLBACK")
           IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("COMMIT","itb00009")
           END IF
        END IF
        
        CLOSE cm_ciclo_peca_970
        
     END IF
  END IF
  
 END FUNCTION 
 
#-------------------------------------#
 FUNCTION itb00009_cursor_for_update()
#-------------------------------------#
  WHENEVER ERROR CONTINUE
   DECLARE cm_ciclo_peca_970 CURSOR FOR
    SELECT * 
      FROM ciclo_peca_970
     WHERE cod_empresa = p_cod_empresa 
       AND cod_item    = mr_tela.cod_item FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DELCARE CURSOR","cm_ciclo_peca_970")
     RETURN FALSE
  END IF

  CALL log085_transacao("BEGIN")
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN","man9925_cursor_for_update")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  OPEN cm_ciclo_peca_970
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN CURSOR","cm_ciclo_peca_970")
     CALL log085_transacao("ROLLBACK")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cm_ciclo_peca_970
  WHENEVER ERROR STOP
  CASE sqlca.sqlcode
     WHEN 0    RETURN TRUE
     WHEN -250 CALL log0030_mensagem("Registro sendo atualizado por outro usuário. Aguarde e tente novamente.","excl")
     WHEN -246 CALL log0030_mensagem("Registro sendo atualizado por outro usuário. Aguarde e tente novamente.","excl")
     WHEN 100  CALL log0030_mensagem("Registro não mais existe na tabela. Execute a consulta novamente.","excl")
     OTHERWISE CALL log003_err_sql("FETCH CURSOR","cm_ciclo_peca_970")
  END CASE

  CLOSE cm_ciclo_peca_970
  FREE cm_ciclo_peca_970

  CALL log085_transacao("ROLLBACK")
  
 END FUNCTION 
 
#-----------------------------#
 FUNCTION itb00009_construct()
#-----------------------------#

  DEFINE l_construct VARCHAR(10)

  LET l_construct = _ADVPL_create_component(NULL,"LCONSTRUCT")

  CALL _ADVPL_set_property(l_construct,"CONSTRUCT_NAME","PARÂMETROS PARA CONSULTA")
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_TABLE","ciclo_peca_970","CicloPeca")
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","cod_item","Item",1 {CHAR},15,0,"zoom_item")
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","qtd_ciclo_peca","Ciclo peça",1 {INT},10,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","qtd_peca_ciclo","Peça ciclo",1 {INT},10,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","num_seq","Sequência",1 {INT},3,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","num_sub_seq","Sub sequenc",1 {INT},3,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","qtd_peca_emb","Peça embal",1 {INT},10,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","qtd_peca_hor","Peça hr custo",1 {INT},10,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","fator_mo","Fator MO",1 {INT},4,0)
  CALL _ADVPL_set_property(l_construct,"ADD_VIRTUAL_COLUMN","ciclo_peca_970","cod_item_cliente","Item cliente",1 {CHAR},30,0)
  
  IF NOT _ADVPL_get_property(l_construct,"INIT_CONSTRUCT") THEN
     RETURN FALSE
  END IF

  LET m_where_clause = _ADVPL_get_property(l_construct,"WHERE_CLAUSE")
  LET m_order_by     = _ADVPL_get_property(l_construct,"ORDER_BY")

  RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION itb00009_event_find()
#------------------------------#

  DEFINE l_sql_stmt CHAR(5000),
         l_count    SMALLINT

  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  
  IF NOT itb00009_construct() THEN
     CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Pesquisa cancelada.")

     LET m_pesq_ativa = FALSE
     CALL itb00009_inicializa_campos()
     RETURN FALSE
  END IF

  LET l_sql_stmt = " SELECT ciclo_peca_970.cod_item, ",
                    " item.den_item, ",
	                  " ciclo_peca_970.qtd_ciclo_peca, ",
	                  " ciclo_peca_970.qtd_peca_ciclo, ",
	                  " ciclo_peca_970.num_seq, ",
	                  " ciclo_peca_970.num_sub_seq, ",
	                  " ciclo_peca_970.qtd_peca_emb, ",
	                  " ciclo_peca_970.qtd_peca_hor, ",
	                  " ciclo_peca_970.fator_mo, ",
	                  " ciclo_peca_970.cod_item_cliente, ",
	                  " ciclo_peca_970.passo, ",
	                  " ciclo_peca_970.qtd_pc_cic_cust, ",
	                  " ciclo_peca_970.pf, " ,     
	                  " ciclo_peca_970.opprox, ",   
	                  " ciclo_peca_970.setatual, ", 
	                  " ciclo_peca_970.setprox, ",  
	                  " ciclo_peca_970.classfunc, ",
	                  " ciclo_peca_970.qtd_peca_orc, ",
	                  " ciclo_peca_970.dias_validade, ",
	                  " ciclo_peca_970.peso_unit_custo ",
                    " FROM ciclo_peca_970, item ",
                    " WHERE ciclo_peca_970.cod_empresa = ? ",
                      " AND ciclo_peca_970.cod_empresa = item.cod_empresa ",
                      " AND ciclo_peca_970.cod_item = item.cod_item "
  
  IF m_where_clause IS NOT NULL AND m_where_clause <> " " THEN
     LET l_sql_stmt = l_sql_stmt CLIPPED, " AND ", m_where_clause CLIPPED
  END IF

  IF m_order_by IS NOT NULL AND m_order_by <> " " THEN
     LET l_sql_stmt = l_sql_stmt CLIPPED, " ORDER BY ", m_order_by CLIPPED
  ELSE
     LET l_sql_stmt = l_sql_stmt CLIPPED, " ORDER BY ciclo_peca_970.cod_item"
  END IF

  WHENEVER ERROR CONTINUE
   PREPARE var_query FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","var_query")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_find SCROLL CURSOR WITH HOLD FOR var_query
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE CURSOR","cq_find")
     RETURN FALSE
  END IF

  FREE var_query

  WHENEVER ERROR CONTINUE
      OPEN cq_find USING p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN CURSOR","cq_find")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FETCH cq_find INTO mr_tela.*
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN     
     LET m_pesq_ativa = TRUE
  ELSE
     IF sqlca.sqlcode = 100 THEN
        CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Argumentos de pesquisa não encontrados.")
        LET m_pesq_ativa = FALSE
     END IF
  END IF

  RETURN TRUE

 END FUNCTION 

#-------------------------------#
 FUNCTION itb00009_event_first()
#-------------------------------#
  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  CALL itb00009_paginacao("FIRST")

  RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION itb00009_event_previous()
#----------------------------------#
  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  CALL itb00009_paginacao("PREVIOUS")

  RETURN TRUE

 END FUNCTION

#------------------------------#
 FUNCTION itb00009_event_next()
#------------------------------#
  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  CALL itb00009_paginacao("NEXT")

  RETURN TRUE

 END FUNCTION

#------------------------------#
 FUNCTION itb00009_event_last()
#------------------------------#
  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  CALL itb00009_paginacao("LAST")

  RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION itb00009_paginacao(l_funcao)
#-------------------------------------#
  DEFINE l_funcao CHAR(08),  
         l_cod_item CHAR(15)         #---Ivo 26/07/2017---#

  IF NOT m_pesq_ativa THEN
     CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Efetue primeiramente a pesquisa.")
     RETURN FALSE
  END IF

  CALL _ADVPL_set_property(m_status_bar,"CLEAR_TEXT")
  
  WHILE TRUE
     WHENEVER ERROR CONTINUE
     CASE
       #primeiro
       WHEN l_funcao = "FIRST"    FETCH FIRST    cq_find INTO mr_tela.*
       #utlimo                    
       WHEN l_funcao = "LAST"     FETCH LAST     cq_find INTO mr_tela.*
       #próximo                   
       WHEN l_funcao = "NEXT"     FETCH NEXT     cq_find INTO mr_tela.*
       #anterior
       WHEN l_funcao = "PREVIOUS" FETCH PREVIOUS cq_find INTO mr_tela.*
     END CASE
     WHENEVER ERROR STOP
     
     IF sqlca.sqlcode <> 0 THEN
        CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Não existem mais itens nesta direção.")
        EXIT WHILE
     END IF
     
     LET l_cod_item = mr_tela.cod_item

     #verifica se já não foi excluído
     WHENEVER ERROR CONTINUE
       SELECT  cod_item,               #---Ivo 26/07/2017---#
               qtd_ciclo_peca,  
               qtd_peca_ciclo,  
               num_seq,         
               num_sub_seq,     
               qtd_peca_emb,    
               qtd_peca_hor,    
               fator_mo,        
               cod_item_cliente,
               passo,         
               qtd_pc_cic_cust,  
               pf,              
               opprox,          
               setatual,        
               setprox,         
               classfunc,
               qtd_peca_orc,
               dias_validade,
               peso_unit_custo      
         INTO mr_tela.cod_item,           
              mr_tela.qtd_ciclo_peca,     
              mr_tela.qtd_peca_ciclo,     
              mr_tela.num_seq,            
              mr_tela.num_sub_seq,        
              mr_tela.qtd_peca_emb,       
              mr_tela.qtd_peca_hor,       
              mr_tela.fator_mo,           
              mr_tela.cod_item_cliente,   
              mr_tela.passo,      
              mr_tela.qtd_pc_cic_cust,        
              mr_tela.pf,                 
              mr_tela.opprox,             
              mr_tela.setatual,           
              mr_tela.setprox,            
              mr_tela.classfunc,         #---Ivo 26/07/2017---#      
              mr_tela.qtd_peca_orc,
              mr_tela.dias_validade,
              mr_tela.peso_unit_custo
         FROM ciclo_peca_970
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = l_cod_item     #---Ivo 26/07/2017---#
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 100 THEN
        CASE
          WHEN l_funcao = "FIRST" LET l_funcao = "NEXT"
          WHEN l_funcao = "LAST"  LET l_funcao = "PREVIOUS"
        END CASE
        
        CONTINUE WHILE
     END IF
     
     EXIT WHILE
  END WHILE

 END FUNCTION
 
#----------------------------------# 
 FUNCTION itb00009_valid_cod_item()
#----------------------------------# 
  INITIALIZE mr_tela.den_item TO NULL
  
  IF mr_tela.cod_item IS NULL 
  OR mr_tela.cod_item = " " THEN
     RETURN TRUE
  END IF
   
  WHENEVER ERROR CONTINUE
    SELECT den_item
      INTO mr_tela.den_item
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = mr_tela.cod_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_mensagem("Item não cadastrado.","excl")
     RETURN FALSE
  END IF   
  
  IF NOT m_event_update THEN
     WHENEVER ERROR CONTINUE
       SELECT DISTINCT 1
         FROM ciclo_peca_970
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = mr_tela.cod_item
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        CALL log0030_mensagem("Item já cadastrado.","excl")
        RETURN FALSE
     END IF   
  END IF
  
  RETURN TRUE
  
 END FUNCTION    
 
#---------------------------------------# 
 FUNCTION itb00009_click_zoom_cod_item()
#---------------------------------------# 
  DEFINE l_zoom VARCHAR(10)

  LET l_zoom = _ADVPL_create_component(NULL,"LZOOMMETADATA")
  CALL _ADVPL_get_property(l_zoom,"INIT_ZOOM","zoom_item")

  IF _ADVPL_get_property(l_zoom,"RETURN_BY_TABLE_COLUMN","item","cod_item") IS NULL THEN
     RETURN
  END IF
  
  LET mr_tela.cod_item = _ADVPL_get_property(l_zoom,"RETURN_BY_TABLE_COLUMN","item","cod_item")
  LET mr_tela.den_item = _ADVPL_get_property(l_zoom,"RETURN_BY_TABLE_COLUMN","item","den_item")
  
  CALL itb00009_valid_cod_item()
 
  RETURN TRUE
  
 END FUNCTION   
 
#-------------------------------#
 FUNCTION itb00009_event_print()
#-------------------------------#

  CALL itb00009_listagem()
  
  RETURN TRUE

 END FUNCTION 
 
#----------------------------#
 FUNCTION itb00009_listagem()
#----------------------------#

  CALL StartReport("itb00009_gera_relatorio","itb00009","Ciclos por Peça e Peças por Ciclo",132,TRUE,TRUE)

 END FUNCTION

#--------------------------------------------#
 FUNCTION itb00009_gera_relatorio(reportfile)
#--------------------------------------------#

  DEFINE reportfile VARCHAR(250)

  START REPORT itb00009_relat TO reportfile
  CALL itb00009_processa_relat()
  FINISH REPORT itb00009_relat

  CALL FinishReport("itb00009")

 END FUNCTION 

#----------------------------------#
 FUNCTION itb00009_processa_relat()
#----------------------------------#
   DEFINE lr_relat RECORD
       cod_item         CHAR(15),
       den_item         CHAR(76),
	     qtd_ciclo_peca   INTEGER,
	     qtd_peca_ciclo   INTEGER,
	     num_seq          DECIMAL(3,0),
	     num_sub_seq      DECIMAL(3,0),
	     qtd_peca_emb     INTEGER,
	     qtd_peca_hor     INTEGER,
	     fator_mo         DECIMAL(4,2),
	     cod_item_cliente CHAR(30),
	     passo            INTEGER,
	     qtd_pc_cic_cust  INTEGER,
       pf               DECIMAL(8,0),     #---Ivo 26/07/2017---#
       opprox           CHAR(10) ,
       setatual         CHAR(10) ,
       setprox          CHAR(10) ,
       classfunc        CHAR(10),          #--------------------#
       qtd_peca_orc     INTEGER,
       dias_validade    INTEGER
   END RECORD
  
   DEFINE l_count SMALLINT
   
   LET m_last_row = FALSE
   
   LET l_count = 0

   WHENEVER ERROR CONTINUE
    DECLARE cq_relat CURSOR FOR
     SELECT ciclo_peca_970.cod_item,
            item.den_item,
            ciclo_peca_970.qtd_ciclo_peca,
            ciclo_peca_970.qtd_peca_ciclo,
            ciclo_peca_970.num_seq,
            ciclo_peca_970.num_sub_seq,
            ciclo_peca_970.qtd_peca_emb,
            ciclo_peca_970.qtd_peca_hor,
            ciclo_peca_970.fator_mo,
            ciclo_peca_970.cod_item_cliente,    #---Ivo 26/07/2017---#
            ciclo_peca_970.passo,           
            ciclo_peca_970.qtd_pc_cic_cust,
            ciclo_peca_970.pf,              
            ciclo_peca_970.opprox,          
            ciclo_peca_970.setatual,        
            ciclo_peca_970.setprox,         
            ciclo_peca_970.classfunc,            #-------------------#  
            ciclo_peca_970.qtd_peca_orc,
            ciclo_peca_970.dias_validade
       FROM ciclo_peca_970, item
      WHERE ciclo_peca_970.cod_empresa = p_cod_empresa
        AND ciclo_peca_970.cod_empresa = item.cod_empresa
        AND ciclo_peca_970.cod_item    = item.cod_item
      ORDER BY ciclo_peca_970.cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_relat")
      RETURN FALSE
   END IF    
   
   WHENEVER ERROR STOP
    FOREACH cq_relat INTO lr_relat.*
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("FOREACH","cq_relat")
      RETURN FALSE
   END IF      
   
       OUTPUT TO REPORT itb00009_relat(lr_relat.*) 
   
       LET l_count = l_count + 1
       
   END FOREACH
   
   FREE cq_relat
   
   IF l_count = 0 THEN
      CALL _ADVPL_set_property(m_status_bar,"ERROR_TEXT","Não existem dados a serem listados.")
   END IF
  
 END FUNCTION 
 
#-------------------------------#
 REPORT itb00009_relat(lr_relat)
#-------------------------------#

   DEFINE lr_relat RECORD
       cod_item         CHAR(15),
       den_item         CHAR(76),
	     qtd_ciclo_peca   INTEGER,
	     qtd_peca_ciclo   INTEGER,
	     num_seq          DECIMAL(3,0),
	     num_sub_seq      DECIMAL(3,0),
	     qtd_peca_emb     INTEGER,
	     qtd_peca_hor     INTEGER,
	     fator_mo         DECIMAL(4,2),
	     cod_item_cliente CHAR(30),
	     passo            INTEGER,
	     qtd_pc_cic_cust  INTEGER,
       pf               DECIMAL(8,0),     #---Ivo 26/07/2017---#
       opprox           CHAR(10) ,
       setatual         CHAR(10) ,
       setprox          CHAR(10) ,
       classfunc        CHAR(10),          #--------------------#
       qtd_peca_orc     INTEGER,
       dias_validade    INTEGER

   END RECORD
   
   DEFINE l_den_empresa LIKE empresa.den_empresa
   
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH ReportPageLength("itb00009")
          
   FORMAT
          
      PAGE HEADER  
      
      #CALL ReportPageHeader("itb00009")
         
      WHENEVER ERROR CONTINUE
        SELECT den_empresa
          INTO l_den_empresa
          FROM empresa
         WHERE cod_empresa = p_cod_empresa
      WHENEVER ERROR STOP   
      
      PRINT COLUMN 001, l_den_empresa,  
            COLUMN 121, "PAG.: ", PAGENO USING "####&"
            
      PRINT COLUMN 001, "ITB00009",
            COLUMN 044, "CICLOS POR PECA / PECA POR CICLO",
            COLUMN 102, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
     
      PRINT ""
      
      PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------------"
      PRINT COLUMN 001, "   COD ITEM           DESCRICAO         CICLO/PC PC/CICLO PC CUST SEQ SUB/SEQ PC/EMB PC/HR FAT/MO  PF  PRX OPER S ATUA PRXSET C FUNC PÇ ORC VALID"
      PRINT COLUMN 001, "--------------- ----------------------- -------- -------- ------- --- ------- ------ ----- ------ ------ ------ ------ ------ ------ ------ -----"
   
      ON EVERY ROW
         
         PRINT COLUMN 001, lr_relat.cod_item,
               COLUMN 017, lr_relat.den_item[1,23],
               COLUMN 041, lr_relat.qtd_ciclo_peca USING "#######&",
               COLUMN 050, lr_relat.qtd_peca_ciclo USING "#######&",
               COLUMN 059, lr_relat.qtd_pc_cic_cust  USING "######&",
               COLUMN 067, lr_relat.num_seq        USING "##&",
               COLUMN 073, lr_relat.num_sub_seq    USING "##&",
               COLUMN 077, lr_relat.qtd_peca_emb   USING "######&",
               COLUMN 081, lr_relat.qtd_peca_hor   USING "######&",
               COLUMN 093, lr_relat.fator_mo       USING "#&.&&",        
               COLUMN 099, lr_relat.pf             USING "######",    
               COLUMN 106, lr_relat.opprox[1,6],
               COLUMN 113, lr_relat.setatual[1,6],
               COLUMN 120, lr_relat.setprox[1,6],
               COLUMN 127, lr_relat.classfunc[1,6],
               COLUMN 134, lr_relat.qtd_peca_orc USING '#####&',
               COLUMN 41, lr_relat.dias_validade USING '####&'
                     
      ON LAST ROW
         LET m_last_row = TRUE

      PAGE TRAILER
         IF m_last_row THEN
            PRINT "* * * ULTIMA FOLHA * * *", log5211_termino_impressao() CLIPPED
            LET m_last_row = FALSE
         ELSE
            PRINT " "
         END IF
        
 END REPORT 

#-------------------------------------------#      
 FUNCTION itb00009_set_container(l_container)      
#-------------------------------------------#      
  DEFINE l_container VARCHAR(20)                 
                                                   
  LET m_container = l_container                   
                                                  
  RETURN TRUE                                     
                                                  
 END FUNCTION                                      
                                                   
#---------------------------------------------#    
 FUNCTION itb00009_set_status_bar(l_status_bar)    
#---------------------------------------------#    
  DEFINE l_status_bar VARCHAR(20)                
                                                   
  LET m_status_bar = l_status_bar     
  RETURN TRUE                                     
                                                   
 END FUNCTION                                      
                                                   
#----------------------------#                     
 FUNCTION itb00009_get_form()                      
#----------------------------#                     

  RETURN m_form                     
  
 END FUNCTION
