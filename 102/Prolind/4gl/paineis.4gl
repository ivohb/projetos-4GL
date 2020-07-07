#----------------#
 FUNCTION paineis()
#----------------#
     DEFINE l_dialog_reference,
            l_panel_reference,
            l_label_reference, l_panel_item, l_panel_familia VARCHAR(10)
 
     LET l_dialog_reference = _ADVPL_create_component(NULL,"LDIALOG")
     CALL _ADVPL_set_property(l_dialog_reference,"SIZE",640,480)
     CALL _ADVPL_set_property(l_dialog_reference,"TITLE","Exemplo de Utilização: LPANEL")
 
     LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_dialog_reference)
     CALL _ADVPL_set_property(l_panel_reference,"ALIGN","TOP")
     CALL _ADVPL_set_property(l_panel_reference,"BACKGROUND_COLOR",200,190,230)
     CALL _ADVPL_set_property(l_panel_reference,"HEIGHT",30)
 
     LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_dialog_reference)
     CALL _ADVPL_set_property(l_panel_reference,"ALIGN","LEFT")
     CALL _ADVPL_set_property(l_panel_reference,"BACKGROUND_COLOR",150,215,235)
     CALL _ADVPL_set_property(l_panel_reference,"WIDTH",600)
  


     LET l_panel_reference = _ADVPL_create_component(NULL,"LPANEL",l_dialog_reference)
     CALL _ADVPL_set_property(l_panel_reference,"ALIGN","CENTER")
     CALL _ADVPL_set_property(l_panel_reference,"BACKGROUND_COLOR",225,225,225)
 
     LET l_panel_item = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference)
     CALL _ADVPL_set_property(l_panel_item,"ALIGN","TOP")
     CALL _ADVPL_set_property(l_panel_item,"BACKGROUND_COLOR",240,230,175)
     CALL _ADVPL_set_property(l_panel_item,"HEIGHT",230)
 
     LET l_panel_familia = _ADVPL_create_component(NULL,"LPANEL",l_panel_reference)
     CALL _ADVPL_set_property(l_panel_familia,"ALIGN","BOTTOM")
     CALL _ADVPL_set_property(l_panel_familia,"BACKGROUND_COLOR",245,125,130)
     CALL _ADVPL_set_property(l_panel_familia,"HEIGHT",230)

 
     CALL _ADVPL_set_property(l_dialog_reference,"ACTIVATE",TRUE)
 END FUNCTION